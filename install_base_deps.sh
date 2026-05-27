#!/usr/bin/env bash
#
# Base dependency installer for AutoDL
#
# What this script does:
# 1) Upgrades pip tooling
# 2) Installs only the minimal shared packages needed by the project
# 3) Avoids installing heavy training stacks or LlamaFactory here
#
# Usage:
#   bash install_base_deps.sh
#
set -euo pipefail

python -m pip install -U pip setuptools wheel
python -m pip install -U --prefer-binary sentencepiece tokenizers
python -m pip install -U pyyaml requests huggingface_hub[cli] cmake ninja
