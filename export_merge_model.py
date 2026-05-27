#!/usr/bin/env python
"""
Adapter merge/export helper.

What this script does:
1) Copies the best adapter checkpoint and tokenizer artifacts into a merge directory
2) Prepares a stable output folder for downstream packaging or full-model merge
3) Keeps the adapter download-friendly for AutoDL users

Important:
- If you want a true merged base model, you can later plug in the official LlamaFactory merge command.
- This script currently standardizes the exported artifacts and organizes them cleanly.
"""

from pathlib import Path
import json
import shutil

BASE_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = BASE_DIR / "outputs" / "qwen2.5-law-lora"
FINAL_DIR = OUTPUT_DIR / "final"
MERGED_DIR = OUTPUT_DIR / "merged_full_model"
META_FILE = OUTPUT_DIR / "merge_meta.json"


def copy_if_exists(src: Path, dst: Path):
    if src.exists():
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        return True
    return False


def main():
    FINAL_DIR.mkdir(parents=True, exist_ok=True)
    MERGED_DIR.mkdir(parents=True, exist_ok=True)

    copied = []
    candidate_roots = [FINAL_DIR, OUTPUT_DIR]
    filenames = [
        "adapter_model.safetensors",
        "adapter_model.bin",
        "adapter_config.json",
        "tokenizer.json",
        "tokenizer_config.json",
        "special_tokens_map.json",
        "generation_config.json",
    ]

    for root in candidate_roots:
        for name in filenames:
            src = root / name
            dst = MERGED_DIR / name
            if copy_if_exists(src, dst):
                copied.append(name)

    meta = {
        "source": str(FINAL_DIR),
        "merged_dir": str(MERGED_DIR),
        "copied_files": copied,
        "note": "This directory is packaged for download. If you need a strict base-model merge, plug in the official LlamaFactory merge step here.",
    }
    with open(META_FILE, "w", encoding="utf-8") as f:
        json.dump(meta, f, ensure_ascii=False, indent=2)
    print(json.dumps(meta, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
