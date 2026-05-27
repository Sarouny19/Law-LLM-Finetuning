#!/usr/bin/env bash
#
# Training runtime dependency installer for AutoDL
#
# What this script does:
# 1) Installs the Python packages needed by LlamaFactory/Transformers training
# 2) Avoids re-installing heavy CUDA or torch packages
# 3) Pins Transformers to a LlamaFactory-compatible 4.x release
# 4) Installs OmegaConf because LlamaFactory imports it at startup
# 5) Installs tensorboard for logging and bitsandbytes for the 8-bit optimizer
#
# Usage:
#   bash install_train_runtime_deps.sh
#
set -euo pipefail

python -m pip install -U --prefer-binary --index-url https://pypi.org/simple "regex>=2025.10.22" "tensorboard" "bitsandbytes"
python -m pip install -U --prefer-binary --index-url https://pypi.tuna.tsinghua.edu.cn/simple "transformers>=4.45.0,<=4.52.4,!=4.46.0,!=4.46.1,!=4.46.2,!=4.46.3,!=4.47.0,!=4.47.1,!=4.48.0,!=4.52.0" "peft>=0.13.0" "accelerate>=0.34.0" "datasets>=2.21.0" "trl>=0.10.0" "safetensors>=0.4.4" "omegaconf>=2.3.0"
