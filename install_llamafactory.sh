#!/usr/bin/env bash
#
# LlamaFactory installer for AutoDL
#
# What this script does:
# 1) Installs a Python 3.10 compatible LlamaFactory release
# 2) Uses the official PyPI index to avoid stale mirror metadata
# 3) Uses --no-deps to avoid re-resolving the full dependency graph
#
# Usage:
#   bash install_llamafactory.sh
#
set -euo pipefail

# LlamaFactory 0.9.4 requires Python >= 3.11, so on this AutoDL image we pin to 0.9.3.
python -m pip install --no-deps --index-url https://pypi.org/simple "llamafactory==0.9.3"
