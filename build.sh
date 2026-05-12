#!/usr/bin/env bash
# build.sh — MacOS/Linux 用简历构建脚本
# 依赖: pandoc + chromium (或 google-chrome)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INPUT="${1:-$SCRIPT_DIR/resume.md}"
OUTPUT="${2:-$SCRIPT_DIR/output/王子畅_AI产品经理_简历.pdf}"
CSS="$SCRIPT_DIR/style/resume.css"

mkdir -p "$(dirname "$OUTPUT")"

# Find Chrome
CHROME=""
for cmd in chromium-browser chromium google-chrome google-chrome-stable; do
  if command -v "$cmd" &>/dev/null; then
    CHROME="$cmd"
    break
  fi
done

if [ -z "$CHROME" ]; then
  echo "❌ Chrome 未找到"
  exit 1
fi

echo "[1/3] Markdown → HTML"
HTML_TMP="$(mktemp /tmp/resume_XXXXXX.html)"
pandoc "$INPUT" -f markdown -t html5 --standalone --css "$CSS" -o "$HTML_TMP"

echo "[2/3] HTML → PDF"
"$CHROME" --headless=new --disable-gpu --no-margins \
  --print-to-pdf="$OUTPUT" \
  --window-size="2100,2970" \
  "file://${HTML_TMP}"

echo "[3/3] 清理 + 验证"
rm "$HTML_TMP"

if [ -f "$OUTPUT" ]; then
  FILE_SIZE=$(stat -f%z "$OUTPUT" 2>/dev/null || stat -c%s "$OUTPUT" 2>/dev/null)
  echo "✅ PDF 已生成: $OUTPUT ($(( FILE_SIZE / 1024 )) KB)"
  echo ""
  echo "🎯 完成"
else
  echo "❌ PDF 未生成"
  exit 1
fi
