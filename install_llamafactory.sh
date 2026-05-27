#!/usr/bin/env bash
#
# LlamaFactory installer for AutoDL
#
# What this script does:
# 1) Installs build tooling required by the latest LlamaFactory pyproject setup
# 2) Uses the public PyPI index for build tools if the mirror does not carry them
# 3) Installs the LlamaFactory project directly from its official GitHub repository
# 4) Uses --no-deps to avoid re-resolving the full dependency graph
# 5) Installs the package with no build isolation once build tools are present
#
# Usage:
#   bash install_llamafactory.sh
#
set -euo pipefail

PIP_INDEX_URL=${PIP_INDEX_URL:-https://pypi.org/simple}

python -m pip install -U --index-url "$PIP_INDEX_URL" hatchling build wheel setuptools
python -m pip install --no-deps --no-build-isolation -U git+https://github.com/hiyouga/LlamaFactory.git
