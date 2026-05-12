<#
.SYNOPSIS
  简历构建脚本 — Markdown → HTML → PDF (headless Chrome)
.DESCRIPTION
  将 resume.md 编译为单页 A4 PDF，保留样式与中文排版。
  依赖: Pandoc + Chrome/Edge

  用法:
    .\resume\build.ps1
    .\resume\build.ps1 -Input .\resume\resume.md -Output .\resume\output\王子畅_简历.pdf
.PARAMETER Input
  Markdown 简历路径，默认 .\resume\resume.md
.PARAMETER Output
  PDF 输出路径，默认 .\resume\output\王子畅_AI产品经理_简历.pdf
#>

param (
  [string]$InputFile = "",
  [string]$OutputFile = ""
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path "$ScriptDir/.."

if (-not $InputFile) { $InputFile = "$ScriptDir/resume.md" }
if (-not $OutputFile) { $OutputFile = "$ScriptDir/output/王子畅_AI产品经理_简历.pdf" }

# ── 1. 检查依赖 ───────────────────────────────────────
$pandoc = Get-Command pandoc -ErrorAction SilentlyContinue
if (-not $pandoc) {
  Write-Error "Pandoc 未安装。安装: winget install pandoc"
  exit 1
}

# 找 Chrome/Edge
$chrome = $null
$paths = @(
  "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "${env:LOCALAPPDATA}\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles}\Microsoft\Edge\Application\msedge.exe",
  "${env:LOCALAPPDATA}\Microsoft\Edge\Application\msedge.exe"
)
foreach ($p in $paths) {
  if (Test-Path $p) { $chrome = $p; break }
}
if (-not $chrome) {
  Write-Error "Chrome/Edge 未找到。请安装 Chrome 或手动用浏览器打开 HTML 打印为 PDF。"
  exit 1
}

# ── 2. 构建 HTML ──────────────────────────────────────
$htmlFile = "$ScriptDir/output/resume_temp.html"
$cssFile = "$ScriptDir/style/resume.css"

Write-Host "[1/3] Markdown → HTML ..." -ForegroundColor Cyan
$null = New-Item -ItemType Directory -Path (Split-Path $htmlFile -Parent) -Force

& pandoc $InputFile `
  --from markdown `
  --to html5 `
  --standalone `
  --css $cssFile `
  --metadata pagetitle="王子畅 — AI 产品经理" `
  -o $htmlFile

if ($LASTEXITCODE -ne 0) {
  Write-Error "Pandoc 转换失败"
  exit 1
}
Write-Host "  → $htmlFile"

# ── 3. Headless Chrome → PDF ──────────────────────────
Write-Host "[2/3] HTML → PDF (headless Chrome) ..." -ForegroundColor Cyan
$null = New-Item -ItemType Directory -Path (Split-Path $OutputFile -Parent) -Force

# 生成绝对路径 URL
$htmlUrl = "file:///$( $htmlFile.Replace('\', '/') )"

& $chrome --headless=new --disable-gpu --no-margins `
  --print-to-pdf="$OutputFile" `
  --window-size="2100,2970" `
  "$htmlUrl" 2>$null

if ($LASTEXITCODE -ne 0) {
  Write-Error "Chrome PDF 生成失败"
  exit 1
}

# ── 4. 清理临时文件 ──────────────────────────────────
Remove-Item $htmlFile -Force -ErrorAction SilentlyContinue

# ── 5. 验证 ──────────────────────────────────────────
Write-Host "[3/3] 验证 ..." -ForegroundColor Cyan
if (Test-Path $OutputFile) {
  $size = (Get-Item $OutputFile).Length
  Write-Host "  ✅ PDF 已生成: $OutputFile ($([math]::Round($size/1024)) KB)" -ForegroundColor Green

  # 用 pypdf 验证可读性
  python3 -c "
import sys
try:
    from pypdf import PdfReader
    r = PdfReader('$($OutputFile.Replace("'","''"))')
    txt = ''
    for p in r.pages:
        txt += p.extract_text() or ''
    keywords = ['王子畅', 'AuditScribe', '安永', 'Fujitsu']
    found = [kw for kw in keywords if kw in txt]
    missing = [kw for kw in keywords if kw not in txt]
    print(f'  页数: {len(r.pages)}')
    print(f'  关键词命中: {found}')
    if missing:
        print(f'  关键词缺失: {missing}')
    else:
        print('  ✅ 全部关键词验证通过')
except Exception as e:
    print(f'  验证跳过: {e}')
" 2>$null
} else {
  Write-Error "PDF 未生成"
  exit 1
}

Write-Host ""
Write-Host "🎯 完成: $OutputFile" -ForegroundColor Green
