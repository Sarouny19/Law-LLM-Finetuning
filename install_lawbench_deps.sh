#!/usr/bin/env bash
#
# LawBench dependency installer for AutoDL
#
# What this script does:
# 1) Installs only the official LawBench evaluation dependencies
# 2) Keeps versions pinned where the benchmark expects them
# 3) Installs the packages into the currently active environment
#
# Usage:
#   bash install_lawbench_deps.sh
#
set -euo pipefail

python -m pip install -U --no-deps rouge_chinese==1.0.3 cn2an==0.5.22 ltp==4.2.13 OpenCC==1.1.6 python-Levenshtein==0.21.1 pypinyin==0.49.0 tqdm==4.64.1 timeout_decorator==0.5.0
