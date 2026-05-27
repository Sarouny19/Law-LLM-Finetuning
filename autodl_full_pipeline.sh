#!/usr/bin/env bash
#
# AutoDL full pipeline script (conda-friendly)
#
# What this script does:
# 1) Activates the dedicated conda environment if available
# 2) Fetches required GitHub dependencies if they are missing
# 3) Downloads Qwen2.5 from a China-friendly mirror into a standard local path
# 4) Downloads and builds llama.cpp for GGUF export
# 5) Builds the dataset locally
# 6) Runs LlamaFactory training
# 7) Merges and packages training artifacts for download
#
# LawBench evaluation stays separate and should be run after training.
#
set -euo pipefail

export TOKENIZERS_PARALLELISM=false
export PYTHONUNBUFFERED=1

PROJECT_DIR=${PROJECT_DIR:-$(cd "$(dirname "$0")" && pwd)}
ENV_NAME=${ENV_NAME:-law-llm}

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
  conda activate "$ENV_NAME" || true
fi

cd "$PROJECT_DIR"

bash download_qwen25_cn.sh
bash download_llama_cpp.sh
bash fetch_github_deps.sh
python dataset/build_dataset.py
llamafactory-cli train llamafactory_qwen25_lora.yaml
python export_merge_model.py
python export_pack_training_artifacts.py
