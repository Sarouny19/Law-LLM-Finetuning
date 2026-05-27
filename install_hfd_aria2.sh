#!/usr/bin/env bash
#
# aria2 installer for AutoDL
#
# What this script does:
# 1) Installs aria2 through the system package manager
# 2) Keeps the install separate from Python dependencies for stability
# 3) Is used by hfd-based Hugging Face downloads
#
# Usage:
#   bash install_hfd_aria2.sh
#
set -euo pipefail

if command -v aria2c >/dev/null 2>&1; then
  echo "aria2c already installed"
  exit 0
fi

if command -v apt-get >/dev/null 2>&1; then
  apt-get update
  apt-get install -y aria2
else
  echo "apt-get not found. Please install aria2 manually."
  exit 1
fi
