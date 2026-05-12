# Resume Builder — 简历即代码

一份 Markdown 主简历，一键导出 A4 PDF。

## 用法

### Windows

```powershell
.\resume\build.ps1
```

指定输入输出：

```powershell
.\resume\build.ps1 -Input .\resume\resume.md -Output .\resume\output\王子畅_简历.pdf
```

### MacOS / Linux

```bash
chmod +x resume/build.sh
./resume/build.sh
```

## 依赖

| 工具 | 用途 |
|------|------|
| [Pandoc](https://pandoc.org/) | Markdown → HTML |
| Chrome / Edge (headless) | HTML → PDF |

### 安装指南

**Windows (winget)**：
```powershell
winget install pandoc
```
Chrome 正常安装即可，脚本会自动发现。

**MacOS (Homebrew)**：
```bash
brew install pandoc
```

## 文件结构

```
resume/
├── resume.md            # 主简历（可编辑）
├── resume_bank.md       # 素材库（不导出）
├── build.ps1            # Windows 构建
├── build.sh             # MacOS/Linux 构建
├── style/
│   └── resume.css       # A4 打印样式
└── output/              # PDF 输出目录
    └── 王子畅_*.pdf
```

## 定制指南

1. 编辑 `resume.md`，改内容
2. 从 `resume_bank.md` 复制适合 JD 的 bullet 替换
3. 运行 `build.ps1` 或 `build.sh`

样式调整：修改 `style/resume.css`。页边距、字号、行距都在 CSS 里。
