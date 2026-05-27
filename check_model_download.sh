#!/usr/bin/env bash
#
# Model download sanity checker for AutoDL
#
# What this script does:
# 1) Verifies whether Qwen2.5 files exist locally
# 2) Checks for common missing artifacts before training starts
# 3) Prints a short status report so you know whether to re-download
#
# Usage:
#   bash check_model_download.sh
#
set -euo pipefail

PROJECT_DIR=${PROJECT_DIR:-$(cd "$(dirname "$0")" && pwd)}
MODEL_DIR="$PROJECT_DIR/models/Qwen2.5-7B-Instruct"

required_files=(
  "config.json"
  "tokenizer.json"
  "tokenizer_config.json"
  "generation_config.json"
)

echo "== Qwen2.5 model check =="
if [ ! -d "$MODEL_DIR" ]; then
  echo "MISS model directory: $MODEL_DIR"
  exit 1
fi

echo "Model directory exists: $MODEL_DIR"
missing=0
for f in "${required_files[@]}"; do
  if [ -f "$MODEL_DIR/$f" ]; then
    echo "OK   $f"
  else
    echo "MISS $f"
    missing=1
  fi
done

if [ "$missing" -eq 0 ]; then
  echo "Model download looks OK."
else
  echo "Some model files are missing. Consider re-running download_qwen25_cn.sh"
fi
