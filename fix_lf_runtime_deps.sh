#!/usr/bin/env bash
#
# Runtime dependency fixer for LlamaFactory 0.9.3
#
# What this script does:
# 1) Forces the active env onto a LlamaFactory-compatible package set
# 2) Downgrades the over-new packages that break startup on Python 3.10
# 3) Installs the missing runtime packages required by llamafactory-cli
#
# Usage:
#   bash fix_lf_runtime_deps.sh
#
set -euo pipefail

PIP_INDEX_URL=${PIP_INDEX_URL:-https://pypi.tuna.tsinghua.edu.cn/simple}

python -m pip uninstall -y transformers tokenizers accelerate datasets peft trl numpy || true
python -m pip install -U --index-url "$PIP_INDEX_URL" \
  "numpy<2.0.0" \
  "transformers>=4.45.0,<=4.52.4,!=4.46.0,!=4.46.1,!=4.46.2,!=4.46.3,!=4.47.0,!=4.47.1,!=4.48.0,!=4.52.0" \
  "tokenizers>=0.19.0,<=0.21.1" \
  "accelerate>=0.34.0,<=1.7.0" \
  "datasets>=2.16.0,<=3.6.0" \
  "peft>=0.14.0,<=0.15.2" \
  "trl>=0.8.6,<=0.9.6" \
  "safetensors>=0.4.4" \
  "omegaconf>=2.3.0" \
  "sentencepiece>=0.2.0" \
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
