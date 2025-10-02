#!/bin/bash
# 🏗️ ИНСТАЛИРАНЕ НА ВСИЧКИ НЕОБХОДИМИ ПАКЕТИ
echo "🚀 Installing Android TV PowerTools Packages..."

echo "🕐 Start time: $(date)"

echo ""
echo "📦 Updating package lists..."
pkg update && pkg upgrade -y

echo ""
echo "🔧 Installing core system packages..."
pkg install -y python nodejs git wget curl openssh

echo ""
echo "🎬 Installing media packages..."
pkg install -y ffmpeg vim htop neofetch

echo ""
echo "🌐 Installing network tools..."
pkg install -y nmap net-tools dnsutils tcpdump openssl

echo ""
echo "📺 Installing TV-specific packages..."
pkg install -y yt-dlp python3 pip jq xmlstarlet termux-api

echo ""
echo "🛠️ Installing additional tools..."
pkg install -y termux-tools termux-services termux-exec proot root-repo x11-repo

echo ""
echo "🐧 Installing Debian environment..."
pkg install -y proot-distro
proot-distro install debian

echo ""
echo "📦 Installing Debian packages..."
proot-distro login debian -- apt update && apt upgrade -y
proot-distro login debian -- apt install -y adb android-tools-adb scrcpy vlc

echo ""
echo "🧹 Final cleanup..."
pkg clean

echo ""
echo "🕐 End time: $(date)"
echo "=========================================="
echo "✅ Installation complete!"
echo "📁 Scripts location: ~/tv_powertools/"
echo "🎯 Run: cd ~/tv_powertools && ./tv_health.sh"
echo "=========================================="
