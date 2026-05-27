#!/usr/bin/env bash
#
# llama.cpp downloader/build helper for AutoDL
#
# What this script does:
# 1) Clones the official llama.cpp repository into ./tools/llama.cpp
# 2) Builds the standard llama.cpp toolchain needed for GGUF export and finetune-related utilities
# 3) Optionally disables the UI build only when you explicitly request no-UI mode
# 4) Leaves the repo ready for `export_gguf_4bit.py`
#
# Usage:
#   bash download_llama_cpp.sh
#
set -euo pipefail

PROJECT_DIR=${PROJECT_DIR:-$(cd "$(dirname "$0")" && pwd)}
TOOLS_DIR="$PROJECT_DIR/tools"
LLAMA_CPP_DIR="$TOOLS_DIR/llama.cpp"
mkdir -p "$TOOLS_DIR"

if [ -d "$LLAMA_CPP_DIR/.git" ]; then
  echo "Updating llama.cpp at $LLAMA_CPP_DIR"
  git -C "$LLAMA_CPP_DIR" fetch --all --prune
  git -C "$LLAMA_CPP_DIR" pull --ff-only
else
  echo "Cloning llama.cpp into $LLAMA_CPP_DIR"
  git clone --depth 1 https://github.com/ggerganov/llama.cpp.git "$LLAMA_CPP_DIR"
fi

cd "$LLAMA_CPP_DIR"

if [ "${LLAMA_BUILD_UI:-0}" = "1" ]; then
  echo "Building llama.cpp with UI enabled"
  cmake -B build \
    -DGGML_NATIVE=ON \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_EXAMPLES=OFF \
    -DLLAMA_BUILD_SERVER=OFF \
    -DLLAMA_BUILD_TOOLS=ON \
    -DLLAMA_BUILD_UI=ON
else
  echo "Building llama.cpp without UI (default for no-GPU/no-frontend setup)"
  cmake -B build \
    -DGGML_NATIVE=ON \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_EXAMPLES=OFF \
    -DLLAMA_BUILD_SERVER=OFF \
    -DLLAMA_BUILD_TOOLS=ON \
    -DLLAMA_BUILD_UI=OFF
fi
cmake --build build -j "${JOBS:-$(nproc 2>/dev/null || echo 4)}"
