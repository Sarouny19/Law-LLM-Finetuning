#!/usr/bin/env bash
#
# Conda environment bootstrapper for AutoDL
#
# What this script does:
# 1) Finds the conda executable that ships with the AutoDL image
# 2) Creates a dedicated project environment if it does not exist
# 3) Installs the base, LawBench, and LlamaFactory dependencies inside that environment
# 4) Installs the training-runtime packages required by Transformers/LlamaFactory
#
# Usage:
#   bash install_conda_env.sh
#
set -euo pipefail

PROJECT_DIR=${PROJECT_DIR:-$(cd "$(dirname "$0")" && pwd)}
ENV_NAME=${ENV_NAME:-law-llm}
PYTHON_VERSION=${PYTHON_VERSION:-3.10}

CONDA_BIN="${CONDA_EXE:-}"
if [ -z "$CONDA_BIN" ]; then
  if [ -x "$HOME/miniconda3/bin/conda" ]; then
    CONDA_BIN="$HOME/miniconda3/bin/conda"
  elif [ -x "/opt/conda/bin/conda" ]; then
    CONDA_BIN="/opt/conda/bin/conda"
  elif command -v conda >/dev/null 2>&1; then
    CONDA_BIN="$(command -v conda)"
  else
    echo "conda not found. Please ensure the AutoDL image includes miniconda3."
    exit 1
  fi
fi

if "$CONDA_BIN" env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
  echo "Conda env $ENV_NAME already exists."
else
  "$CONDA_BIN" create -y -n "$ENV_NAME" python="$PYTHON_VERSION" --override-channels -c defaults
fi

"$CONDA_BIN" run -n "$ENV_NAME" python -m pip install -U pip setuptools wheel
"$CONDA_BIN" run -n "$ENV_NAME" python -m pip install -U --prefer-binary sentencepiece tokenizers
"$CONDA_BIN" run -n "$ENV_NAME" python -m pip install -U pyyaml requests huggingface_hub[cli] cmake ninja
"$CONDA_BIN" run -n "$ENV_NAME" python -m pip install -U rouge_chinese==1.0.3 cn2an==0.5.22 ltp==4.2.13 OpenCC==1.1.6 python-Levenshtein==0.21.1 pypinyin==0.49.0 tqdm==4.64.1 timeout_decorator==0.5.0
"$CONDA_BIN" run -n "$ENV_NAME" python -m pip install -U "regex>=2025.10.22" "transformers>=4.45.0" "peft>=0.13.0" "accelerate>=0.34.0" "datasets>=2.21.0" "trl>=0.10.0" "safetensors>=0.4.4" "omegaconf>=2.3.0"
"$CONDA_BIN" run -n "$ENV_NAME" python -m pip install --no-deps --index-url https://pypi.org/simple "llamafactory==0.9.3"

echo "Conda environment ready: $ENV_NAME"
echo "Activate it with: conda activate $ENV_NAME"
