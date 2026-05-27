import json
import random
import re
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
SOURCE_DIR = BASE_DIR.parent / "DISC-Law-SFT"
TRIPLET_FILE = SOURCE_DIR / "DISC-Law-SFT-Triplet-released.jsonl"
QA_FILE = SOURCE_DIR / "DISC-Law-SFT-Pair-QA-released.jsonl"
OUTPUT_TRAIN_FILE = BASE_DIR / "legal_sft_train.json"
OUTPUT_VAL_FILE = BASE_DIR / "legal_sft_val.json"
OUTPUT_ALL_FILE = BASE_DIR / "legal_sft_all.json"
OUTPUT_TRAIN_JSONL = BASE_DIR / "train.jsonl"
OUTPUT_VAL_JSONL = BASE_DIR / "val.jsonl"
DATASET_INFO_FILE = BASE_DIR / "dataset_info.json"

SEED = 42
TARGET_TRAIN = 5000
TARGET_VAL = 500

SYSTEM_TRIPLET = "你是一个专业的中国法律AI助手。请仔细阅读用户提供的案情描述，准确引用相关中国法律法规进行分析，并给出专业的法律判断或建议。"
SYSTEM_QA = "你是一个专业的中国法律AI助手。请依据中国现行法律法规，专业、准确地解答用户的法律咨询。"


def normalize_text(text: str) -> str:
    text = (text or "").replace("\r\n", "\n").replace("\r", "\n")
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def strip_prompt_prefix(text: str) -> str:
    text = normalize_text(text)
    prefixes = [
        r"^基于下列案件.*?[。．]\s*\n",
        r"^阅读以下案情.*?[。．]\s*\n",
        r"^请根据.*?进行分析.*?[。．]\s*\n",
        r"^请预测这个案子的判决\s*\n",
        r"^请推理出以下案件中可能的判决\s*\n",
        r"^请根据案件中的事实，推理出可能的判决\s*\n",
    ]
    for pattern in prefixes:
        text = re.sub(pattern, "", text, flags=re.S)
    return text.strip()


def has_law_reference(answer: str) -> bool:
    return bool(re.search(r"《[^》]{1,40}(法|条例|司法解释|民法典|刑法|诉讼法|证券法|海商法|公司法|劳动合同法|行政诉讼法)[^》]{0,20}》", answer))


records = []
seen = set()


def add_record(instruction: str, input_text: str, output_text: str) -> None:
    input_text = normalize_text(input_text)
    output_text = normalize_text(output_text)
    if not input_text or not output_text:
        return
    key = (instruction, input_text, output_text)
    if key in seen:
        return
    seen.add(key)
    records.append({"instruction": instruction, "input": input_text, "output": output_text})


print("Loading DISC-Law-SFT Triplet...")
with open(TRIPLET_FILE, "r", encoding="utf-8") as f:
    for line in f:
        item = json.loads(line)
        input_text = strip_prompt_prefix(item.get("input", ""))
        output_text = item.get("output", "")
        if len(input_text) < 20 or len(output_text) < 30:
            continue
        add_record(SYSTEM_TRIPLET, input_text, output_text)

print("Loading DISC-Law-SFT QA...")
with open(QA_FILE, "r", encoding="utf-8") as f:
    for line in f:
        item = json.loads(line)
        question = normalize_text(item.get("input", ""))
        answer = item.get("output", "")
        if len(question) < 4 or len(answer) < 20:
            continue
        if not has_law_reference(answer) and len(answer) < 80:
            continue
        add_record(SYSTEM_QA, question, answer)

random.seed(SEED)
random.shuffle(records)

if len(records) < TARGET_TRAIN + TARGET_VAL:
    print(f"Warning: cleaned dataset has only {len(records)} samples.")

total = min(len(records), TARGET_TRAIN + TARGET_VAL)
final_records = records[:total]
train_records = final_records[: min(TARGET_TRAIN, total)]
val_records = final_records[min(TARGET_TRAIN, total) : total]

for path, data in [(OUTPUT_ALL_FILE, final_records), (OUTPUT_TRAIN_FILE, train_records), (OUTPUT_VAL_FILE, val_records)]:
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

for path, data in [(OUTPUT_TRAIN_JSONL, train_records), (OUTPUT_VAL_JSONL, val_records)]:
    with open(path, "w", encoding="utf-8") as f:
        for row in data:
            f.write(json.dumps(row, ensure_ascii=False) + "\n")

DATASET_INFO = {
    "disc_law_llm_sft_train": {
        "file_name": "train.jsonl",
        "columns": {"prompt": "instruction", "query": "input", "response": "output", "system": "system"},
    },
    "disc_law_llm_sft_val": {
        "file_name": "val.jsonl",
        "columns": {"prompt": "instruction", "query": "input", "response": "output", "system": "system"},
    },
}

with open(DATASET_INFO_FILE, "w", encoding="utf-8") as f:
    json.dump(DATASET_INFO, f, ensure_ascii=False, indent=2)

print(f"Done. total={len(final_records)} train={len(train_records)} val={len(val_records)}")
