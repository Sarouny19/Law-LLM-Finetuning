from pathlib import Path
import json

BASE_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = BASE_DIR / "outputs" / "qwen2.5-law-lora"
FINAL_DIR = OUTPUT_DIR / "final"
METRICS_FILE = OUTPUT_DIR / "autodl_metrics.json"


def main():
    FINAL_DIR.mkdir(parents=True, exist_ok=True)
    metrics = {
        "model_dir": str(FINAL_DIR),
        "tensorboard_dir": str(OUTPUT_DIR),
        "download_targets": [
            str(FINAL_DIR),
            str(OUTPUT_DIR),
        ],
        "notes": "Upload outputs/qwen2.5-law-lora to local for weights and tensorboard logs.",
    }
    with open(METRICS_FILE, "w", encoding="utf-8") as f:
        json.dump(metrics, f, ensure_ascii=False, indent=2)
    print(json.dumps(metrics, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
