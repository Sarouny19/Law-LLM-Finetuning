#!/usr/bin/env bash
#
# Final conda environment bootstrapper for AutoDL vGPU-32GB
#
# What this script does:
# 1) Creates a clean, dedicated conda environment for LlamaFactory 0.9.3
# 2) Removes any existing broken environment with the same name first
# 3) Pins package versions to a known-compatible Python 3.10 stack
# 4) Installs everything from stable public PyPI or the selected mirror
#
# Usage:
#   bash install_conda_env.sh
#
set -euo pipefail

PROJECT_DIR=${PROJECT_DIR:-$(cd "$(dirname "$0")" && pwd)}
ENV_NAME=${ENV_NAME:-law-llm-vgpu32}
PYTHON_VERSION=${PYTHON_VERSION:-3.10}
PIP_INDEX_URL=${PIP_INDEX_URL:-https://pypi.tuna.tsinghua.edu.cn/simple}

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
  echo "Removing existing broken env: $ENV_NAME"
  "$CONDA_BIN" env remove -y -n "$ENV_NAME"
fi

echo "Creating clean env: $ENV_NAME"
"$CONDA_BIN" create -y -n "$ENV_NAME" python="$PYTHON_VERSION" --override-channels -c defaults

eval "$($CONDA_BIN shell.bash hook)"
conda activate "$ENV_NAME"

python -m pip install -U pip setuptools wheel
python -m pip install -U --index-url https://pypi.org/simple "regex>=2025.10.22" "omegaconf>=2.3.0"

# LlamaFactory 0.9.3 compatible stack for Python 3.10.
# Keep this stack narrow to avoid resolver drift on China-network mirrors.
python -m pip install -U --index-url https://pypi.tuna.tsinghua.edu.cn/simple \
  "numpy<2.0.0" \
  "transformers>=4.45.0,<=4.52.4,!=4.46.0,!=4.46.1,!=4.46.2,!=4.46.3,!=4.47.0,!=4.47.1,!=4.48.0,!=4.52.0" \
  "tokenizers>=0.19.0,<=0.21.1" \
  "accelerate>=0.34.0,<=1.7.0" \
  "datasets>=2.16.0,<=3.6.0" \
  "peft>=0.14.0,<=0.15.2" \
  "trl>=0.8.6,<=0.9.6" \
  "safetensors>=0.4.4" \
  "sentencepiece>=0.2.0" \
  "pyyaml" \
  "requests" \
  "huggingface_hub[cli]" \
  "cmake" \
  "ninja" \
  "rouge_chinese==1.0.3" \
  "cn2an==0.5.22" \
  "ltp==4.2.13" \
  "OpenCC==1.1.6" \
  "python-Levenshtein==0.21.1" \
  "pypinyin==0.49.0" \
  "tqdm==4.64.1" \
  "timeout_decorator==0.5.0" \
  "av" \
  "einops" \
  "fastapi" \
  "fire" \
  "gradio>=4.38.0,<=5.31.0" \
  "librosa" \
  "matplotlib>=3.7.0" \
  "protobuf" \
  "pydantic<=2.10.6" \
  "scipy" \
  "sse-starlette" \
  "tiktoken" \
  "tyro<0.9.0" \
  "uvicorn"

python -m pip install --no-deps --index-url "$PIP_INDEX_URL" "llamafactory==0.9.3"
python -m pip check || true
python - <<'PY'
import transformers, omegaconf, peft, accelerate, datasets, trl
print("runtime import check OK")
PY

echo "Conda environment ready: $ENV_NAME"
echo "Activate it with: conda activate $ENV_NAME"
echo "If you want to remove the broken old env, run: conda env remove -n law-llm-compat"
