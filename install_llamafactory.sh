#!/usr/bin/env bash
#
# LlamaFactory installer for AutoDL
#
# What this script does:
# 1) Installs build tooling required by the latest LlamaFactory pyproject setup
# 2) Installs the LlamaFactory project directly from its official GitHub repository
# 3) Uses --no-deps to avoid re-resolving the full dependency graph
# 4) Installs the package in editable mode so the `llamafactory-cli` entrypoint is available
#
# Usage:
#   bash install_llamafactory.sh
#
set -euo pipefail

python -m pip install -U hatchling build wheel setuptools
python -m pip install --no-deps --no-build-isolation -U git+https://github.com/hiyouga/LlamaFactory.git
