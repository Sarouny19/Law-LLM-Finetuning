#!/usr/bin/env bash
#
# AutoDL training starter for vGPU-32GB.
#
# What this script does:
# 1) Activates the dedicated conda environment if available
# 2) Repairs runtime dependency mismatches for LlamaFactory/Transformers
# 3) Downloads the model and tools if needed
# 4) Builds the cleaned training dataset
# 5) Launches LlamaFactory training
# 6) Exports the adapter and packages training artifacts
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

bash fix_lf_runtime_deps.sh
bash download_qwen25_cn.sh
bash download_llama_cpp.sh
bash fetch_github_deps.sh
python dataset/build_dataset.py
llamafactory-cli train llamafactory_qwen25_lora.yaml
python export_merge_model.py
python export_pack_training_artifacts.py
