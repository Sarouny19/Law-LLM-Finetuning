#!/usr/bin/env bash
#
# Stable staged dependency installer for AutoDL
#
# What this script does:
# 1) Installs the base runtime packages
# 2) Installs the LawBench evaluation packages
# 3) Installs the training runtime packages required by Transformers/LlamaFactory
# 4) Installs LlamaFactory from GitHub without re-resolving dependencies
#
# This staged approach is designed to be more stable on shared AutoDL images.
#
# Usage:
#   bash install_deps_autodl.sh
#
set -euo pipefail

bash install_base_deps.sh
bash install_lawbench_deps.sh
bash install_train_runtime_deps.sh
bash install_llamafactory.sh
