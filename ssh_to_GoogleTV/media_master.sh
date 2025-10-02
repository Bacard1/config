#!/bin/bash
# 🎥 ИНТЕЛИГЕНТЕН МЕДИЕН МЕНИДЖЪР - ПРЕПОРЪЧИТЕЛЕН!
echo "=== 🎥 SMART MEDIA DOWNLOADER ==="

URL=$1
QUALITY=${2:-"best"}

if [ -z "$URL" ]; then
    echo "❌ Usage: $0 <YouTube_URL> [quality]"
    echo ""
    echo "Quality examples:"
    echo "  best                  - Най-добро качество"
    echo "  worst                 - Най-лошо качество"
    echo "  bestvideo[height<=720] - HD готово за TV"
    echo "  bestaudio             - Само аудио"
    echo ""
    echo "Example: $0 'https://youtube.com/watch?v=xxx' 'bestvideo[height<=720]'"
    exit 1
fi

echo "📥 Downloading: $URL"
echo "🎬 Quality: $QUALITY"
echo "⏳ This may take a while..."

# Създаване на директория ако не съществува
mkdir -p ~/storage/downloads/tv_media

# Сваляне с yt-dlp
yt-dlp -f "$QUALITY" \
       -o "~/storage/downloads/tv_media/%(title).100s.%(ext)s" \
       --add-metadata \
       --no-overwrites \
       "$URL"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Download successful!"
    echo "📁 Location: ~/storage/downloads/tv_media/"
    echo "💾 Files:"
    ls -la ~/storage/downloads/tv_media/* | tail -5
else
    echo "❌ Download failed! Check the URL and connection."
fi
