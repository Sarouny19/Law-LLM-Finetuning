from pathlib import Path
import json
import shutil
import zipfile

BASE_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = BASE_DIR / "outputs" / "qwen2.5-law-lora"
PACKAGE_DIR = OUTPUT_DIR / "package"
ARCHIVE_FILE = OUTPUT_DIR / "qwen2.5-law-lora-package.zip"


def copy_tree(src: Path, dst: Path):
    if not src.exists():
        return
    if src.is_file():
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        return
    for path in src.rglob("*"):
        rel = path.relative_to(src)
        target = dst / rel
        if path.is_dir():
            target.mkdir(parents=True, exist_ok=True)
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, target)


def main():
    PACKAGE_DIR.mkdir(parents=True, exist_ok=True)
    for name in ["merged_full_model", "final", "runs"]:
        copy_tree(OUTPUT_DIR / name, PACKAGE_DIR / name)
    for name in ["merge_meta.json", "autodl_metrics.json", "package_summary.json"]:
        src = OUTPUT_DIR / name
        if src.exists():
            shutil.copy2(src, PACKAGE_DIR / name)
    with zipfile.ZipFile(ARCHIVE_FILE, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for path in PACKAGE_DIR.rglob("*"):
            if path.is_file():
                zf.write(path, path.relative_to(PACKAGE_DIR))
    summary = {
        "package_dir": str(PACKAGE_DIR),
        "archive": str(ARCHIVE_FILE),
        "contains": ["merged_full_model", "final", "runs", "meta files"],
    }
    with open(OUTPUT_DIR / "package_summary.json", "w", encoding="utf-8") as f:
        json.dump(summary, f, ensure_ascii=False, indent=2)
    print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
