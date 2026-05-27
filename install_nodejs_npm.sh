#!/usr/bin/env bash
#
# Node.js/npm installer for AutoDL
#
# What this script does:
# 1) Installs nodejs and npm via the system package manager
# 2) Enables llama.cpp UI asset builds that require npm
# 3) Is optional; training and GGUF export can still work without it, but the UI step will be skipped otherwise
#
# Usage:
#   bash install_nodejs_npm.sh
#
set -euo pipefail

if command -v npm >/dev/null 2>&1; then
  echo "npm already installed"
  exit 0
fi

if command -v apt-get >/dev/null 2>&1; then
  apt-get update
  apt-get install -y nodejs npm
else
  echo "apt-get not found. Please install nodejs/npm manually."
  exit 1
fi
