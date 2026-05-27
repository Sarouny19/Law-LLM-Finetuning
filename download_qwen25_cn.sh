#!/usr/bin/env bash
#
# Qwen2.5 mirror downloader for AutoDL
#
# What this script does:
# 1) Creates a standard local model directory under ./models
# 2) Tries multiple China-friendly mirrors for Qwen2.5-7B-Instruct
# 3) Avoids Hugging Face Xet/CAS acceleration to reduce network failures on restricted nodes
# 4) Downloads in a low-concurrency mode to reduce memory pressure on shared AutoDL nodes
# 5) Falls back to a local already-downloaded model directory if network is blocked
# 6) Saves the model to a fixed path that training scripts can reuse directly
#
# Usage:
#   bash download_qwen25_cn.sh
#
set -euo pipefail

PROJECT_DIR=${PROJECT_DIR:-$(cd "$(dirname "$0")" && pwd)}
MODELS_DIR="$PROJECT_DIR/models"
MODEL_DIR="$MODELS_DIR/Qwen2.5-7B-Instruct"
LOCAL_SOURCE_DIR=${LOCAL_SOURCE_DIR:-}
MODEL_ID=${MODEL_ID:-Qwen/Qwen2.5-7B-Instruct}
mkdir -p "$MODELS_DIR"

if [ -d "$MODEL_DIR" ] && [ -n "$(ls -A "$MODEL_DIR" 2>/dev/null || true)" ]; then
  echo "Qwen2.5 already exists at $MODEL_DIR"
  exit 0
fi

if [ -n "$LOCAL_SOURCE_DIR" ] && [ -d "$LOCAL_SOURCE_DIR" ]; then
  echo "Using local source model from $LOCAL_SOURCE_DIR"
  cp -a "$LOCAL_SOURCE_DIR" "$MODEL_DIR"
  echo "Copied model to $MODEL_DIR"
  exit 0
fi

export HF_HUB_DISABLE_TELEMETRY=1
export HF_HUB_DISABLE_PROGRESS_BARS=0
export HF_HUB_DISABLE_XET=1
export HF_HUB_ENABLE_HF_TRANSFER=0

python - "$MODEL_DIR" "$MODEL_ID" <<'PY'
import os
import sys
import time

from huggingface_hub import snapshot_download
from tqdm.auto import tqdm

local_dir = sys.argv[1]
model_id = sys.argv[2]
endpoints = [
    "https://hf-mirror.com",
    "https://mirror.sjtu.edu.cn/hugging-face-models",
]
last_error = None

for endpoint in endpoints:
    try:
        print(f"Trying mirror: {endpoint}")
        os.environ["HF_ENDPOINT"] = endpoint
        snapshot_download(
            repo_id=model_id,
            local_dir=local_dir,
            tqdm_class=tqdm,
            max_workers=1,
        )
        print(f"Downloaded {model_id} to {local_dir}")
        sys.exit(0)
    except Exception as e:
        last_error = e
        print(f"Mirror failed: {endpoint} -> {e}")
        time.sleep(2)

print("All mirrors failed. Please set LOCAL_SOURCE_DIR to a manually uploaded model folder.")
print(f"Last error: {last_error}")
sys.exit(1)
PY
