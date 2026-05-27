#!/usr/bin/env bash
#
# GitHub dependency fetcher for AutoDL
#
# What this script does:
# 1) Creates a local tools directory
# 2) Clones or updates GitHub-based dependencies used by this project
# 3) Keeps third-party source code outside the main project root for cleaner packaging
#
# Current dependencies:
# - LawBench official repository
#
# Usage:
#   bash fetch_github_deps.sh
#
set -euo pipefail

PROJECT_DIR=${PROJECT_DIR:-$(cd "$(dirname "$0")" && pwd)}
TOOLS_DIR="$PROJECT_DIR/tools"
mkdir -p "$TOOLS_DIR"

clone_or_update() {
  local repo_url="$1"
  local target_dir="$2"
  local branch="$3"

  if [ -d "$target_dir/.git" ]; then
    echo "Updating $target_dir"
    git -C "$target_dir" fetch --all --prune
    git -C "$target_dir" checkout "$branch"
    git -C "$target_dir" pull --ff-only origin "$branch"
  else
    echo "Cloning $repo_url -> $target_dir"
    git clone --depth 1 --branch "$branch" "$repo_url" "$target_dir"
  fi
}

clone_or_update "https://github.com/open-compass/LawBench.git" "$TOOLS_DIR/LawBench" "main"
