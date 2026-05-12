---
title: "简历素材库 — 不导出"
---

# 简历素材库

此文件不参与导出，仅用于按 JD 快速替换 bullet。

## AI 产品方向（主版本已用）

见 resume.md。

## 后端/技术方向（替换用）

### AuditScribe
- 独立设计并开发审计底稿自动生成系统，四层架构：Streamlit 前端 → pandas/openpyxl 数据处理层 → 规则引擎 → Excel 写入层
- 实现 PDF 银行回函解析器（pypdf），从非结构化 PDF 中提取银行名称、账号、余额，准确率 100%
- 搭建完整 CI 评测管线：5 个测试场景 × 可复现 seed，每轮变更自动跑分并记录

### 简历筛选工具
- 开发 JD 关键词提取 + 简历结构化匹配原型，Python + 规则引擎实现

## 数据分析方向（替换用）

### AuditScribe
- 设计"红蓝对抗"评测框架，对 Agent 输出进行三维度量化评分（Precision / Recall / Cell Accuracy）
- 在 full 场景（3 种错误同时注入）下实现 Precision 100%、Recall 67%

### 安永
- 处理 2 家 A 股上市公司年审数据，涉及收入确认、固定资产、往来款等科目的审计抽样与数据分析

## 可替换 bullet（按技能分类）

### 产品/项目管理
- 从 0 到 1 设计产品架构，定义用户故事、产品路标和 MVP 范围
- 跨职能协作（工程 + 审计专家），将业务需求拆解为可执行的技术方案
- 建立产品评测体系，用数据驱动迭代决策

### 技术
- Python（pandas/openpyxl/pypdf/Streamlit）全栈开发经验
- LLM API 集成（DeepSeek / OpenAI），Agent 工作流设计
- Git / GitHub，CI 评测管线

### 审计/财务
- 企业会计准则，审计底稿流程
- 货币资金、固定资产、往来款等科目审计程序
- Excel 数据分析和勾稽检查
