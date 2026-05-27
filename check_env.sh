#!/usr/bin/env bash
#
# Environment checker for AutoDL
#
# What this script does:
# 1) Prints key system and Python tool versions
# 2) Checks whether conda is available and whether the target env exists
# 3) Verifies whether the main training/evaluation Python packages are importable
# 4) Reports likely issues before you start training
#
# Usage:
#   bash check_env.sh
#
set -euo pipefail

ENV_NAME=${ENV_NAME:-law-llm}
PROJECT_DIR=${PROJECT_DIR:-$(cd "$(dirname "$0")" && pwd)}
cd "$PROJECT_DIR"

echo "== System =="
uname -a || true
echo

echo "== Conda =="
if command -v conda >/dev/null 2>&1; then
  conda --version || true
  conda env list || true
  if conda env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
    echo "Conda env exists: $ENV_NAME"
  else
    echo "Conda env missing: $ENV_NAME"
  fi
else
  echo "conda not found"
fi
echo

echo "== Python =="
python --version || true
python -m pip --version || true
echo

echo "== Git =="
git --version || true
echo

echo "== Package import checks =="
python - <<'PY'
import importlib
modules = [
    "yaml",
    "requests",
    "huggingface_hub",
    "sentencepiece",
    "tokenizers",
    "tqdm",
    "cn2an",
    "opencc",
    "Levenshtein",
    "pypinyin",
]
for mod in modules:
    try:
        importlib.import_module(mod)
        print(f"OK   {mod}")
    except Exception as e:
        print(f"MISS {mod}: {e}")
PY

echo

echo "== LlamaFactory check =="
if conda run -n "$ENV_NAME" python - <<'PY'
import importlib
import sys
mods = ["llamafactory", "cn2an", "Levenshtein"]
for m in mods:
    importlib.import_module(m)
print("imports ok")
PY
then
  echo "OK   python packages inside conda env"
else
  echo "FAIL missing python packages in conda env"
fi

if conda run -n "$ENV_NAME" bash -lc 'command -v llamafactory-cli >/dev/null 2>&1 && llamafactory-cli --help >/dev/null 2>&1'; then
  echo "OK   llamafactory-cli"
else
  echo "FAIL llamafactory-cli not runnable in conda env"
fi

echo

echo "== Dataset files =="
for f in dataset/dataset_info.json dataset/train.jsonl dataset/val.jsonl llamafactory_qwen25_lora.yaml; do
  if [ -f "$f" ]; then
    echo "OK   $f"
  else
    echo "MISS $f"
  fi
done

echo

echo "== Done =="
echo "If you see misses above, install the missing component before training."
