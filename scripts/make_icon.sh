#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/TavernSwitcher/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"

convert -size 1024x1024 \
  gradient:'#071426-#153b63' \
  -fill 'rgba(255,205,75,0.16)' -draw 'circle 810,170 810,500' \
  -fill 'rgba(64,174,255,0.18)' -draw 'circle 190,820 190,490' \
  -gravity center \
  -font DejaVu-Sans-Bold -pointsize 410 \
  -fill '#FFE89A' -annotate +0-20 '☁' \
  -alpha off -depth 8 -define png:color-type=2 \
  "$OUT"

echo "Created $OUT"
