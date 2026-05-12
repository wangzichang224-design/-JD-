# Resume Agent

> 简历即代码 · AI 驱动的工作流

将你的经历库（结构化数据）与目标 JD 进行智能匹配，自动生成针对性优化的简历 Markdown 文本。

## 项目结构

```
resume-agent/
├── data/
│   └── my_experiences.json      # 个人完整经历库（STAR 格式）
├── schemas/
│   ├── experience.schema.json   # 经历条目结构定义
│   └── jd_analysis.schema.json  # JD 分析结果结构定义
├── jd/                          # 存放待解析的 JD 文本文件 (.txt)
├── outputs/                     # 生成的简历输出目录
├── src/
│   └── resume_agent/
│       ├── __init__.py          # 公共 API
│       ├── jd_parser.py         # Module A: JD 解析器
│       ├── retriever.py         # Module B: 经历召回引擎
│       ├── md_generator.py      # Module C: Markdown 生成器
│       └── pipeline.py          # 管线编排 & CLI 入口
└── pyproject.toml
```

## 工作流

```
JD 文本 → [A. 解析] → 结构化 JD → [B. 召回] → 评分排序 → [C. 生成] → Markdown 简历
```

### Module A — JD 解析器 (`jd_parser.py`)

基于规则解析 JD 纯文本，输出结构化 `JDAnalysis`：

- 岗位标题、公司信息
- 硬性要求（学历、语言、技术栈等，区分 must-have）
- 软技能
- 关键词（按技术/产品/数据/运营/审计分类）
- 痛点描述
- 召回权重（根据岗位类型自动推断）

全程纯文本处理，不涉及图片或 PDF。

### Module B — 经历召回引擎 (`retriever.py`)

五维加权评分召回最优经历：

| 维度 | 权重（默认） | 说明 |
|------|------------|------|
| Tag Match | 0.30 | 经历标签与 JD 关键词的覆盖率 |
| Hard Requirement | 0.25 | 硬性要求匹配度，must-have 不满足时大幅降分 |
| Industry Relevance | 0.20 | 行业/领域相关性 |
| Evidence Quality | 0.10 | 经历可信度（verified / plausible / anecdotal） |
| Recency | 0.15 | 时效性，3 个月内满分 |

权重会根据岗位类型自动调整（技术岗侧重 tag_match，审计岗侧重 industry_relevance）。

- 自动跳过 `needs_verification=true` 的经历
- 支持 `target_role` 过滤
- 支持 `min_score` 阈值筛选

### Module C — Markdown 生成器 (`md_generator.py`)

将召回结果渲染为可读的中文简历 Markdown：

- 按 教育经历 → 项目经历 → 实习经历 → 专业技能 分组渲染
- STAR 格式 bullet points
- Metrics 嵌入显示
- 关键词匹配标签

## 快速开始

```bash
# 方式 1：Python API
from src.resume_agent import run_pipeline

md = run_pipeline(
    jd_text="""招聘岗位：AI产品经理
岗位职责：
1. 负责AI产品的需求分析...
""",
    job_title="AI产品经理",
    target_role="AI产品经理",
    personal_info={
        "name": "王子畅",
        "email": "wang.zichang@example.com",
        "location": "上海",
    },
)
print(md)

# 方式 2：CLI 管道
echo "招聘岗位：数据分析实习生..." | python -m src.resume_agent.pipeline

# 方式 3：从文件读取
python -m src.resume_agent.pipeline jd/ai_pm.txt > outputs/ai_pm_resume.md
```

## 数据模型

经历库 (`data/my_experiences.json`) 使用 STAR 原则 + 可信度标记：

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 唯一标识 |
| `category` | enum | education / project / internship / work / certification / skill |
| `star_details` | object | S / T / A / R 四字段完整描述 |
| `metrics` | array | 可验证的关键数据 |
| `evidence_level` | enum | verified / plausible / anecdotal |
| `needs_verification` | boolean | 未核实标记，生成器不得写入简历 |
| `target_roles` | string[] | 适合投递的岗位方向 |
| `tags` | string[] | 标签，用于 JD 关键词匹配 |

## 安全设计

- `needs_verification` 标记确保未核实的信息不会出现在简历中
- `evidence_level` 分级管理可信度，召回评分中作为权重因子
- must-have 硬性要求不满足时自动降分，减少不匹配投递
