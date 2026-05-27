#!/usr/bin/env python
"""
GGUF 4-bit export helper.

What this script does:
1) Uses the merged full model as input
2) Calls llama.cpp conversion and quantization tools
3) Produces a local GGUF artifact for later download

Prerequisite:
- Run `bash download_llama_cpp.sh` first so tools/llama.cpp exists.
"""

from pathlib import Path
import subprocess

BASE_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = BASE_DIR / "outputs" / "qwen2.5-law-lora"
MERGED_DIR = OUTPUT_DIR / "merged_full_model"
LLAMA_CPP_DIR = BASE_DIR / "tools" / "llama.cpp"
GGUF_DIR = OUTPUT_DIR / "gguf"
GGUF_FILE = GGUF_DIR / "qwen2.5-law-lora-f16.gguf"
GGUF_Q4_FILE = GGUF_DIR / "qwen2.5-law-lora-q4_k_m.gguf"


def main():
    GGUF_DIR.mkdir(parents=True, exist_ok=True)
    convert_script = LLAMA_CPP_DIR / "convert_hf_to_gguf.py"
    quantize_bin = LLAMA_CPP_DIR / "build" / "bin" / "llama-quantize"

    subprocess.run([
        "python",
        str(convert_script),
        str(MERGED_DIR),
        "--outfile",
        str(GGUF_FILE),
    ], check=True)

    subprocess.run([
        str(quantize_bin),
        str(GGUF_FILE),
        str(GGUF_Q4_FILE),
        "Q4_K_M",
    ], check=True)

    print(f"GGUF exported to {GGUF_Q4_FILE}")


if __name__ == "__main__":
    main()
