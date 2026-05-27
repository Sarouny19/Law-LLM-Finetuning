#!/usr/bin/env bash
#
# AutoDL training starter for vGPU-32GB.
#
# What this script does:
# 1) Activates the dedicated conda environment if available
# 2) Repairs runtime dependency mismatches for LlamaFactory/Transformers
# 3) Validates and sanitizes the training YAML before launching
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
SANITIZED_YAML="$PROJECT_DIR/.llamafactory_qwen25_lora.sanitized.yaml"

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

echo "=== Validating and sanitizing training config ==="
python - <<'PY'
from pathlib import Path
import sys
import yaml

src = Path("llamafactory_qwen25_lora.yaml")
dst = Path(".llamafactory_qwen25_lora.sanitized.yaml")
if not src.exists():
    print(f"Missing config: {src}")
    sys.exit(1)

cfg = yaml.safe_load(src.read_text(encoding="utf-8"))
# Hard-remove any stray keys that some LlamaFactory versions don't accept.
for key in ["dataset_info", "evaluation_strategy"]:
    cfg.pop(key, None)

# Normalize to the exact keys the current stack expects.
if "eval_strategy" not in cfg:
    cfg["eval_strategy"] = "steps"
if "save_strategy" not in cfg:
    cfg["save_strategy"] = "steps"

# Safety: if eval is enabled, strategies must match.
if cfg.get("load_best_model_at_end", False):
    cfg["eval_strategy"] = cfg.get("save_strategy", "steps")

# Ensure validation dataset is explicit.
if "eval_dataset" not in cfg:
    raise SystemExit("Missing required key: eval_dataset")

# Some versions also want only one train dataset entry.
if isinstance(cfg.get("dataset"), str) and "," in cfg["dataset"]:
    train_ds, *_ = [x.strip() for x in cfg["dataset"].split(",") if x.strip()]
    cfg["dataset"] = train_ds

if cfg.get("dataset") == cfg.get("eval_dataset"):
    raise SystemExit("dataset and eval_dataset must be different")

dst.write_text(yaml.safe_dump(cfg, sort_keys=False, allow_unicode=True), encoding="utf-8")
print(dst.resolve())
print(dst.read_text(encoding="utf-8"))
print("sanitized keys:", sorted(cfg.keys()))
PY

bash validate_lora_yaml.sh
bash fix_lf_runtime_deps.sh
bash download_qwen25_cn.sh
bash download_llama_cpp.sh
bash fetch_github_deps.sh
python dataset/build_dataset.py
llamafactory-cli train "$SANITIZED_YAML"
python export_merge_model.py
python export_pack_training_artifacts.py
