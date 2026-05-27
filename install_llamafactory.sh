#!/usr/bin/env bash
#
# LlamaFactory installer for AutoDL
#
# What this script does:
# 1) Installs the LlamaFactory project directly from its official GitHub repository
# 2) Uses --no-deps to avoid re-resolving the full dependency graph
# 3) Installs the package in editable mode so the `llamafactory-cli` entrypoint is available
#
# Usage:
#   bash install_llamafactory.sh
#
set -euo pipefail

python -m pip install --no-deps -U git+https://github.com/hiyouga/LlamaFactory.git
