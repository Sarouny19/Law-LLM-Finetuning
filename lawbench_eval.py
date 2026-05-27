#!/usr/bin/env python
"""
LawBench official evaluation wrapper.

What this script does:
1) Locates the local LawBench repository under ./tools/LawBench
2) Points evaluation input/output paths to this project's output directory
3) Runs the official LawBench evaluator in evaluation/main.py

Expected input layout:
- predictions should be placed under:
  outputs/lawbench_eval/zero_shot/<system_name>/<task_id>.json

Expected output:
- outputs/lawbench_eval/zero_shot/results.csv

Note:
- This script is a thin wrapper around the official LawBench evaluation entry.
- It does not generate predictions. Use a separate generation script before running this.
"""

from pathlib import Path
import subprocess
import sys

BASE_DIR = Path(__file__).resolve().parent
TOOLS_DIR = BASE_DIR / "tools"
LAWBENCH_DIR = TOOLS_DIR / "LawBench"
EVAL_DIR = LAWBENCH_DIR / "evaluation"
PRED_DIR = BASE_DIR / "outputs" / "lawbench_eval" / "zero_shot"
RESULT_FILE = PRED_DIR / "results.csv"


def main():
    if not EVAL_DIR.exists():
        raise FileNotFoundError(
            f"LawBench evaluation folder not found: {EVAL_DIR}. Run bash fetch_github_deps.sh first."
        )

    PRED_DIR.mkdir(parents=True, exist_ok=True)
    cmd = [sys.executable, "main.py", "-i", str(PRED_DIR), "-o", str(RESULT_FILE)]
    subprocess.run(cmd, cwd=str(EVAL_DIR), check=True)
    print(f"LawBench results saved to {RESULT_FILE}")


if __name__ == "__main__":
    main()
