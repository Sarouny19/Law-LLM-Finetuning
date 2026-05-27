#!/usr/bin/env bash
#
# Hugging Face Mirror (hfd) downloader for AutoDL
#
# What this script does:
# 1) Downloads the hfd helper from hf-mirror.com
# 2) Uses aria2 for stable segmented downloads
# 3) Supports both model and dataset downloads through hf-mirror
# 4) Is intended as the most reliable option when normal hub access is blocked
#
# Usage examples:
#   bash download_hfd_model.sh user_or_org/model_name
#   bash download_hfd_model.sh user_or_org/dataset_name --dataset
#
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: bash download_hfd_model.sh <repo_id> [--dataset]"
  exit 1
fi

REPO_ID="$1"
SHIFTED_ARGS=("${@:2}")
PROJECT_DIR=${PROJECT_DIR:-$(cd "$(dirname "$0")" && pwd)}
TOOLS_DIR="$PROJECT_DIR/tools"
HFD_SCRIPT="$TOOLS_DIR/hfd.sh"
mkdir -p "$TOOLS_DIR"

if ! command -v aria2c >/dev/null 2>&1; then
  echo "aria2c not found. Please install aria2 first."
  echo "Example: sudo apt update && sudo apt install -y aria2"
  exit 1
fi

if [ ! -f "$HFD_SCRIPT" ]; then
  echo "Downloading hfd helper to $HFD_SCRIPT"
  wget -O "$HFD_SCRIPT" https://hf-mirror.com/hfd/hfd.sh
  chmod +x "$HFD_SCRIPT"
fi

export HF_ENDPOINT="${HF_ENDPOINT:-https://hf-mirror.com}"

bash "$HFD_SCRIPT" "$REPO_ID" "${SHIFTED_ARGS[@]}"
