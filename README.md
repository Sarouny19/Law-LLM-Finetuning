# Qwen2.5 + LlamaFactory 法律微调项目

这个项目按“训练”和“评估”完全分开设计，适合在 AutoDL 上先完成训练，再单独跑 LawBench 评估。

## 这次改成了 conda 友好型启动

你说服务器镜像里自带 `miniconda3`，所以现在项目不再默认按纯 `pip` 方式启动，而是改成更适合 AutoDL 的 **conda 友好型流程**。

新的思路是：

1. 找到 AutoDL 自带的 conda
2. 创建独立环境 `law-llm-5090`
3. 在这个环境里安装依赖
4. 用这个环境跑训练和评估

这样做的好处：

- 不污染系统 Python
- 更容易重复执行
- 出问题时更容易回滚
- 对 AutoDL 这种共享镜像更稳

---

## 当前你要的整套闭环

1. 自动拉取所需 GitHub 依赖
2. 使用中国镜像下载 Qwen2.5 到固定路径
3. 下载 `llama.cpp` 工具
4. 本地生成训练数据
5. 用 LlamaFactory 在 AutoDL 训练
6. 训练后自动导出、打包、可下载
7. 训练完单独跑 LawBench 官方评估
8. 评估结果单独打包带回本地

---

## 新增环境检查脚本

### `check_env.sh`

这个脚本用来在正式训练前检查环境是否正常：

```bash
bash check_env.sh
```

它会检查：

- 系统信息
- conda 是否存在
- `law-llm-5090` 环境是否存在
- Python / pip 版本
- Git 是否可用
- 常用依赖是否可导入
- `llamafactory-cli` 是否可运行
- 数据文件是否已经生成

如果你想先排错，这个脚本建议在任何安装/训练之前运行一次。

---

## 模型下载现在支持多镜像 + 本地备份 + 低并发

### `download_qwen25_cn.sh`

现在下载脚本会按这个顺序尝试：

1. `https://hf-mirror.com`
2. `https://mirror.sjtu.edu.cn/hugging-face-models`
3. 如果都不通，就使用你手动上传到服务器的本地模型目录

它还做了两件事来更适合这台服务器：

- `max_workers=1`，降低并发，减少资源压力
- 在镜像失败后短暂停顿再试，避免短时间连续失败

你还可以传入本地模型路径：

```bash
LOCAL_SOURCE_DIR=/path/to/Qwen2.5-7B-Instruct bash download_qwen25_cn.sh
```

如果镜像都不通，这个方式最稳。

---

## hfd 镜像站专用下载方式

如果你想用镜像站推荐的稳定高速下载方式，可以用 `hfd`。

### 适合场景

- Hugging Face 直连不通
- 镜像网页能访问，但普通下载不稳定
- 需要更稳定的分段下载和断点续传

### 安装 aria2

`hfd` 基于 `aria2`，所以先装它：

```bash
bash install_hfd_aria2.sh
```

如果你想手动安装，也可以：

```bash
sudo apt update
sudo apt install -y aria2
```

### 下载 hfd

```bash
wget https://hf-mirror.com/hfd/hfd.sh
chmod +x hfd.sh
```

项目里我也新增了一个封装脚本：

```bash
bash download_hfd_model.sh <repo_id>
```

下载模型示例：

```bash
bash download_hfd_model.sh Qwen/Qwen2.5-7B-Instruct
```

下载数据集示例：

```bash
bash download_hfd_model.sh dreamingInTheSky-xzl2211/BilingualData --dataset
```

### 设置环境变量

Linux：

```bash
export HF_ENDPOINT=https://hf-mirror.com
```

PowerShell：

```powershell
$env:HF_ENDPOINT = "https://hf-mirror.com"
```

---

## Conda 友好型安装脚本

### 1. 一键创建并安装 conda 环境

```bash
bash install_conda_env.sh
```

这个脚本会：

- 自动找到 AutoDL 自带的 conda
- 删除旧的坏环境后重新创建一个新的 `law-llm-5090`
- 安装 Python 3.10 兼容的依赖组合
- 使用国内 PyPI 镜像
- 固定 `numpy<2.0.0`
- 固定 `transformers` 在 LlamaFactory 0.9.3 兼容线
- 固定 `accelerate/datasets/peft/trl/tokenizers` 到兼容版本
- 安装 `omegaconf`
- 安装 `llamafactory==0.9.3`

### 2. 只装基础依赖

```bash
bash install_base_deps.sh
```

### 3. 只装 LawBench 依赖

```bash
bash install_lawbench_deps.sh
```

### 4. 只装训练运行时依赖

```bash
bash install_train_runtime_deps.sh
```

### 5. 只装 LlamaFactory

```bash
bash install_llamafactory.sh
```

LlamaFactory 当前固定到：

```bash
llamafactory==0.9.3
```

原因：

- `0.9.4` 要求 `Python >= 3.11`
- 你当前环境是 `Python 3.10.20`
- 所以必须回退到兼容版本

### 6. 仍然保留分段安装入口

```bash
bash install_deps_autodl.sh
```

它会依次执行：

1. `install_base_deps.sh`
2. `install_lawbench_deps.sh`
3. `install_train_runtime_deps.sh`
4. `install_llamafactory.sh`

---

## 训练脚本现在怎么跑

### 训练入口 1

```bash
bash autodl_start.sh
```

这是 **conda 友好型训练启动脚本**，它会尝试自动激活 `law-llm-5090` 环境，并在开训前先修复运行时依赖。

### 训练入口 2

```bash
bash autodl_full_pipeline.sh
```

这是更完整的全流程脚本，也会尝试自动激活 conda 环境。

---

## 训练和评估怎么分开

### 训练阶段

1. 准备 conda 环境
2. 下载模型
3. 下载工具
4. 处理数据
5. LlamaFactory 训练
6. 导出 adapter
7. 打包训练产物

### 评估阶段

1. 单独准备 LawBench 预测结果
2. 用官方评估脚本算分
3. 输出 `results.csv`
4. 单独带回本地

---

## LlamaFactory 在哪里体现

### 1. `dataset/dataset_info.json`
这是 LlamaFactory 识别自定义数据集的标准文件。

当前使用 alpaca 映射：

- `prompt -> instruction`
- `query -> input`
- `response -> output`
- `system -> system`

### 2. `llamafactory_qwen25_lora.yaml`
这是直接给 LlamaFactory 训练用的配置。

### 3. `dataset/build_dataset.py`
负责把原始 `DISC-Law-SFT` 数据变成 LlamaFactory 可读的 alpaca 格式。

---

## `source` 还要不要

不要。

原因：

- LlamaFactory 不需要 `source`
- 训练不会用到它
- 去掉后更干净、更标准

---

## 推荐执行顺序

### 1) 本地准备数据

```bash
python dataset/build_dataset.py
```

### 2) 检查环境

```bash
bash check_env.sh
```

### 3) 准备 conda 环境

```bash
bash install_conda_env.sh
```

或者分段执行：

```bash
bash install_base_deps.sh
bash install_lawbench_deps.sh
bash install_train_runtime_deps.sh
bash install_llamafactory.sh
```

### 4) 激活环境

```bash
conda activate law-llm-5090
```

### 5) 上传到 AutoDL

上传这些文件：

- `dataset/`
- `llamafactory_qwen25_lora.yaml`
- `check_env.sh`
- `install_conda_env.sh`
- `requirements_autodl.txt`
- `install_base_deps.sh`
- `install_lawbench_deps.sh`
- `install_train_runtime_deps.sh`
- `install_llamafactory.sh`
- `install_deps_autodl.sh`
- `install_hfd_aria2.sh`
- `install_nodejs_npm.sh`
- `download_hfd_model.sh`
- `autodl_start.sh`
- `autodl_full_pipeline.sh`
- `download_qwen25_cn.sh`
- `download_llama_cpp.sh`
- `fetch_github_deps.sh`
- `export_merge_model.py`
- `export_pack_training_artifacts.py`
- `export_gguf_4bit.py`
- `lawbench_eval.py`

### 6) 一键训练

```bash
bash autodl_start.sh
```

或者更完整的：

```bash
bash autodl_full_pipeline.sh
```

### 7) 看训练图

```bash
tensorboard --logdir outputs/qwen2.5-law-lora
```

### 8) 下载训练包

训练结束后下载：

- `outputs/qwen2.5-law-lora/package/`
- `outputs/qwen2.5-law-lora/qwen2.5-law-lora-package.zip`
- `outputs/qwen2.5-law-lora/merged_full_model/`

### 9) 单独做 LawBench 评估

先把预测结果整理到：

```text
outputs/lawbench_eval/zero_shot/<system_name>/
```

然后执行：

```bash
python lawbench_eval.py
```

输出：

```text
outputs/lawbench_eval/zero_shot/results.csv
```

### 10) 导出 GGUF 4bit

```bash
python export_gguf_4bit.py
```

前提：先执行 `bash download_llama_cpp.sh`。

---

## 稳定版建议

如果你是第一次在 AutoDL 上跑，建议这样：

1. `bash check_env.sh`
2. `bash install_conda_env.sh`
3. `conda activate law-llm-5090`
4. `bash autodl_start.sh`

如果镜像都不通，就先把模型手动上传到服务器，再这样启动：

```bash
LOCAL_SOURCE_DIR=/your/local/Qwen2.5-7B-Instruct bash download_qwen25_cn.sh
```

或者直接用 `hfd` 的方式下载：

```bash
bash install_hfd_aria2.sh
bash download_hfd_model.sh Qwen/Qwen2.5-7B-Instruct
```

---

## 法律评测说明

LawBench 官方评估入口已经按标准方式封装：

```bash
cd evaluation
python main.py -i <pred_dir> -o <metric_result>
```

---

## 备注

- `source` 不需要，已移除。
- 训练和评估已完全分开。
- 所有可执行脚本都加了开头注释，说明脚本用途和执行顺序。
- 当前已经增加 conda 友好型安装与启动方式。
