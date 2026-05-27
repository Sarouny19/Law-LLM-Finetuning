#!/usr/bin/env bash
#
# LlamaFactory runtime dependency fixer for AutoDL
#
# What this script does:
# 1) Upgrades the small set of Python packages that LlamaFactory/Transformers need at runtime
# 2) Fixes common import/version mismatches on prebuilt AutoDL images
# 3) Keeps the fix separate so you can rerun it without reinstalling the full stack
#
# Usage:
#   bash fix_lf_runtime_deps.sh
#
set -euo pipefail

python -m pip install -U regex transformers peft accelerate datasets tokenizers sentencepiece
