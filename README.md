# Qwen2.5 + LlamaFactory 法律微调项目

这个项目按“训练”和“评估”完全分开设计，适合在 AutoDL 上先完成训练，再单独跑 LawBench 评估。

## 当前采用的最终环境

- 适配中国网络
- 适配 vGPU-32GB
- 适配 Python 3.10
- 适配 LlamaFactory 0.9.3
- 使用干净的新环境 `law-llm-vgpu32`

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

## 环境检查

先检查环境：

```bash
bash check_env.sh
```

它会检查：

- 系统信息
- conda 环境
- Python / pip 版本
- Git
- 关键依赖是否安装
- `llamafactory-cli` 是否可运行
- 数据文件是否已经生成

---

## 模型下载

### 推荐方式

```bash
bash download_qwen25_cn.sh
```

如果你自己已经把模型放到本地目录，也可以：

```bash
LOCAL_SOURCE_DIR=/path/to/Qwen2.5-7B-Instruct bash download_qwen25_cn.sh
```

---

## hfd 下载方式

如果镜像下载不稳定，可以用 `hfd`：

```bash
bash install_hfd_aria2.sh
bash download_hfd_model.sh Qwen/Qwen2.5-7B-Instruct
```

数据集同理：

```bash
bash download_hfd_model.sh dreamingInTheSky-xzl2211/BilingualData --dataset
```

---

## 安装环境

### 1. 一键重建干净环境

```bash
bash install_conda_env.sh
```

这个脚本会：

- 删除旧的坏环境
- 新建 `law-llm-vgpu32`
- 固定 Python 3.10 兼容版本
- 安装 LlamaFactory 0.9.3 运行所需全部依赖

### 2. 训练运行时依赖

```bash
bash install_train_runtime_deps.sh
```

这个脚本现在会额外安装：

- `tensorboard`
- `bitsandbytes`

这样可以解决：

- `TensorBoardCallback requires tensorboard to be installed`
- `Trainer tried to instantiate bnb optimizer but bitsandbytes is not installed`

### 3. LlamaFactory 安装

```bash
bash install_llamafactory.sh
```

---

## 训练脚本

### 直接开训

```bash
bash autodl_start.sh
```

这个脚本会：

1. 激活 `law-llm-vgpu32`
2. 修复运行时依赖
3. 下载模型和工具
4. 构建数据集
5. 启动 LlamaFactory 训练
6. 导出并打包训练产物

---

## 训练配置说明

### `llamafactory_qwen25_lora.yaml`

当前训练配置已经修正为兼容训练参数：

- `evaluation_strategy: steps`
- `save_strategy: steps`
- `load_best_model_at_end: true`

这三项必须匹配，否则 `transformers` 会报错。

---

## 为什么之前跑不起来

之前遇到的错误已经逐个解决过：

- `dataset_info` 不该写进训练 YAML
- `dataset_info.json` 里的字段映射必须和真实 JSONL 一致
- 模板不能用 `qwen2_vl`
- `tensorboard` 没装会报回调错误
- `bitsandbytes` 没装会导致 8bit 优化器报错
- `load_best_model_at_end` 要求 `eval_strategy/save_strategy` 一致

---

## 训练轮数

当前配置里：

```yaml
num_train_epochs: 3
```

所以训练是 **3 轮**。

---

## 训练大概多久

你当前日志里显示：

```text
41/1875 [02:03<1:28:12,  2.89s/it]
```

这意味着当前阶段大概还有 **1小时28分左右** 的量级，整轮训练大约会在 **2 小时左右/epoch** 附近浮动。

因为你设置的是 3 轮，所以总训练时长大致可以按：

- **单轮约 1.5~2.5 小时**
- **三轮约 4.5~7.5 小时**

更稳妥的开机建议是：

- **至少预留 8 小时**
- 如果中间还要重新跑验证/导出，建议 **开 10 小时** 更保险

---

## 训练和评估分开

训练完成后再单独跑评估：

```bash
python lawbench_eval.py
```

---

## 依赖版本说明

当前环境固定为：

- `llamafactory==0.9.3`
- `transformers` 4.45 ~ 4.52.4
- `accelerate<=1.7.0`
- `datasets<=3.6.0`
- `peft<=0.15.2`
- `trl<=0.9.6`
- `tokenizers<=0.21.1`
- `numpy<2.0.0`
- `omegaconf>=2.3.0`
- `tensorboard`
- `bitsandbytes`

---

## 推荐执行顺序

### 1. 初始化环境

```bash
bash install_conda_env.sh
```

### 2. 检查环境

```bash
bash check_env.sh
```

### 3. 开始训练

```bash
bash autodl_start.sh
```

---

## 备注

- 训练和评估已完全分开。
- 当前环境针对 vGPU-32GB 做了最终兼容。
- 配置已经修正，避免 `load_best_model_at_end` 和保存/评估策略冲突。
- 现在训练日志可以正常写入 TensorBoard，8bit 优化器也可正常使用。
