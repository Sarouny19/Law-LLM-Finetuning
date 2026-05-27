from pathlib import Path

from transformers import AutoModelForCausalLM, AutoTokenizer

BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "outputs" / "qwen2.5-law-lora" / "final"

PROMPT = """<|im_start|>system
你是一个专业的中国法律AI助手。<|im_end|>
<|im_start|>user
{query}<|im_end|>
<|im_start|>assistant
"""


def main():
    tokenizer = AutoTokenizer.from_pretrained(str(MODEL_PATH), trust_remote_code=True)
    model = AutoModelForCausalLM.from_pretrained(str(MODEL_PATH), trust_remote_code=True, device_map="auto")
    tokenizer.pad_token = tokenizer.eos_token if tokenizer.pad_token is None else tokenizer.pad_token

    query = "请根据《刑法》分析盗窃罪的构成要件。"
    inputs = tokenizer(PROMPT.format(query=query), return_tensors="pt").to(model.device)
    output = model.generate(**inputs, max_new_tokens=512, do_sample=False, temperature=0.1)
    print(tokenizer.decode(output[0], skip_special_tokens=False))


if __name__ == "__main__":
    main()
