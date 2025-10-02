#!/bin/bash
# 🔄 АВТОМАТИЧНА АКТУАЛИЗАЦИЯ НА ЦЯЛАТА СИСТЕМА - ЗАДЪЛЖИТЕЛЕН!
echo "=== 🔄 SYSTEM AUTO-UPDATER ==="

echo "🕐 Start time: $(date)"

echo ""
echo "📦 Updating Termux packages..."
pkg update && pkg upgrade -y

echo ""
echo "🐍 Updating Python packages..."
if command -v pip &> /dev/null; then
    pip install --upgrade pip 2>/dev/null
    pip install --upgrade yt-dlp 2>/dev/null
    echo "✅ Python packages updated"
else
    echo "⚠️ pip not available"
fi

echo ""
echo "🐧 Checking Debian environment..."
if command -v proot-distro &> /dev/null && proot-distro list | grep -q debian; then
    echo "🔄 Updating Debian packages..."
    proot-distro login debian -- apt update && apt upgrade -y
    echo "✅ Debian updated"
else
    echo "⚠️ Debian not installed"
fi

echo ""
echo "🧹 Cleaning up..."
pkg clean
echo "✅ Cleanup complete"

echo ""
echo "🕐 End time: $(date)"
echo "✅ System update complete!"
