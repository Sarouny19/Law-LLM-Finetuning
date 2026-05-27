#!/usr/bin/env bash
#
# AutoDL training starter for vGPU-32GB.
#
# What this script does:
# 1) Activates the dedicated conda environment if available
# 2) Repairs runtime dependency mismatches for LlamaFactory/Transformers
# 3) Validates the training YAML before launching
# 4) Downloads the model and tools if needed
# 5) Builds the cleaned training dataset
# 6) Launches LlamaFactory training
# 7) Exports the adapter and packages training artifacts
#
# This script is intentionally training-only.
# LawBench evaluation is separated into `lawbench_eval.py` and should be run after training.
#
set -euo pipefail

export TOKENIZERS_PARALLELISM=false
export PYTHONUNBUFFERED=1
export CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-0}

PROJECT_DIR=${PROJECT_DIR:-$(cd "$(dirname "$0")" && pwd)}
ENV_NAME=${ENV_NAME:-law-llm-vgpu32}
YAML_FILE="$PROJECT_DIR/llamafactory_qwen25_lora.yaml"

CONDA_BIN="${CONDA_EXE:-}"
if [ -z "$CONDA_BIN" ]; then
  if [ -x "$HOME/miniconda3/bin/conda" ]; then
    CONDA_BIN="$HOME/miniconda3/bin/conda"
  elif [ -x "/opt/conda/bin/conda" ]; then
    CONDA_BIN="/opt/conda/bin/conda"
  elif command -v conda >/dev/null 2>&1; then
    CONDA_BIN="$(command -v conda)"
  fi
fi

if [ -n "$CONDA_BIN" ]; then
  eval "$($CONDA_BIN shell.bash hook)"
  conda activate "$ENV_NAME"
fi

cd "$PROJECT_DIR"

echo "=== Validating training config ==="
python - <<'PY'
import yaml
from pathlib import Path
path = Path("llamafactory_qwen25_lora.yaml")
print(path.resolve())
print(path.read_text(encoding="utf-8"))
cfg = yaml.safe_load(path.read_text(encoding="utf-8"))
print("keys:", sorted(cfg.keys()))
PY

bash validate_lora_yaml.sh
bash fix_lf_runtime_deps.sh
bash download_qwen25_cn.sh
bash download_llama_cpp.sh
bash fetch_github_deps.sh
python dataset/build_dataset.py
llamafactory-cli train "$YAML_FILE"
python export_merge_model.py
python export_pack_training_artifacts.py
