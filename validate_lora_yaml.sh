#!/usr/bin/env bash
#
# Validate the LlamaFactory LoRA YAML before training.
#
# What this script does:
# 1) Ensures eval/save strategy are compatible with load_best_model_at_end
# 2) Verifies the core config keys are present
# 3) Fails fast before a costly training run starts
#
# Usage:
#   bash validate_lora_yaml.sh
#
set -euo pipefail

YAML_FILE=${YAML_FILE:-llamafactory_qwen25_lora.yaml}

python - <<'PY'
import sys
from pathlib import Path
import yaml

path = Path("llamafactory_qwen25_lora.yaml")
if not path.exists():
    print(f"Missing YAML: {path}")
    sys.exit(1)

cfg = yaml.safe_load(path.read_text(encoding="utf-8"))

def get(*keys):
    for k in keys:
        if k in cfg:
            return cfg[k]
    return None

eval_strategy = get("eval_strategy", "evaluation_strategy")
save_strategy = get("save_strategy")
load_best = get("load_best_model_at_end")

print(f"eval_strategy={eval_strategy}")
print(f"save_strategy={save_strategy}")
print(f"load_best_model_at_end={load_best}")

if load_best and eval_strategy != save_strategy:
    print("ERROR: load_best_model_at_end requires eval_strategy and save_strategy to match")
    sys.exit(2)

required = [
    "model_name_or_path",
    "stage",
    "finetuning_type",
    "dataset",
    "dataset_dir",
    "dataset_info",
    "template",
    "output_dir",
]
missing = [k for k in required if k not in cfg]
if missing:
    print("ERROR: missing keys:", ", ".join(missing))
    sys.exit(3)

print("YAML validation OK")
PY
