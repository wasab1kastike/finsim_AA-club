#!/usr/bin/env bash
set -euo pipefail

FONT_DIR="$(dirname "$0")/../fonts"
mkdir -p "$FONT_DIR"

# Download Inter variable font and store as Inter-Regular.ttf
curl -fL -o "$FONT_DIR/Inter-Regular.ttf" \
  "https://github.com/google/fonts/raw/main/ofl/inter/Inter%5Bopsz,wght%5D.ttf"

echo "Downloaded Inter-Regular.ttf to $FONT_DIR"
