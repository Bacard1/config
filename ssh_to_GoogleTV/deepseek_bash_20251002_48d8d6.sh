#!/bin/bash
echo "🚀 Creating Android TV PowerTools Suite..."

# Създаване на директория
mkdir -p ~/tv_powertools
cd ~/tv_powertools

echo "📁 Creating scripts in: $(pwd)"

## 1. 🛡️ TV HEALTH GUARDIAN
cat > tv_health.sh << 'EOF'
#!/bin/bash
# 🛡️ РЕАЛЕН МОНИТОРИНГ НА TV ЗДРАВЕ - ЗАДЪЛЖИТЕЛЕН!
echo "=== 🛡️ TV HEALTH GUARDIAN ==="

# Системна информация
echo "📺 Model: $(adb shell getprop ro.product.model)"
echo "🤖 Android: $(adb shell getprop ro.build.version.release)"

# Памет и хранилище
MEMORY=$(adb shell free -m | grep Mem: | awk '{print $4}')
STORAGE=$(adb shell df -h /data | tail -1 | awk '{print $4}')
echo "🧠 Memory: ${MEMORY}MB free"
echo "💾 Storage: ${STORAGE} free"

# Температура
TEMP=$(adb shell cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -1)
if [ -n "$TEMP" ]; then
    TEMP_C=$((TEMP/1000))
    echo "🌡️ Temperature: ${TEMP_C}°C"
fi

# Мрежова информация
IP=$(adb shell ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
if [ -n "$IP" ]; then
    echo "🌐 IP Address: $IP"
    echo "🔗 Connect via: ssh -p 8022 $IP"
fi

# Батерия (ако е приложимо)
BATTERY=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,')
if [ -n "$BATTERY" ]; then
    echo "🔋 Battery: ${BATTERY}%"
fi
EOF

## 2. 🎮 ADB MASTER CONTROLLER
cat > adb_master.sh << 'EOF'
#!/bin/bash
# 🎮 ПЪЛЕН КОНТРОЛ НА TV ПРЕЗ ADB - ЗАДЪЛЖИТЕЛЕН!
echo "=== 🎮 ADB MASTER CONTROLLER ==="

if [ $# -eq 0 ]; then
    echo "❌ Usage: $0 {screen|install apk|uninstall package|reboot|apps|info}"
    echo ""
    echo "Examples:"
    echo "  $0 screen                    - 📸 Take screenshot"
    echo "  $0 install /sdcard/app.apk   - 📦 Install app"
    echo "  $0 uninstall com.example.app - 🗑️ Remove app"
    echo "  $0 reboot                    - 🔃 Reboot TV"
    echo "  $0 apps                      - 📱 List user apps"
    echo "  $0 info                      - ℹ️ System info"
    exit 1
fi

case $1 in
    "screen")
        FILENAME="screen_$(date +%Y%m%d_%H%M%S).png"
        adb exec-out screencap -p > "$FILENAME"
        echo "📸 Screenshot saved: $FILENAME"
        ;;
    "install")
        if [ -n "$2" ]; then
            adb install -r "$2"
            echo "📦 App installed: $2"
        else
            echo "❌ Please specify APK file"
        fi
        ;;
    "uninstall")
        if [ -n "$2" ]; then
            adb uninstall "$2"
            echo "🗑️ App removed: $2"
        else
            echo "❌ Please specify package name"
        fi
        ;;
    "reboot")
        adb reboot
        echo "🔃 Rebooting TV..."
        ;;
    "apps")
        echo "📱 User installed apps:"
        adb shell pm list packages -3 | sed 's/package://g'
        ;;
    "info")
        echo "📊 Device Information:"
        adb shell getprop ro.product.model
        adb shell getprop ro.build.version.release
        ;;
    *)
        echo "❌ Unknown command: $1"
        ;;
esac
EOF

## 3. 🔄 SYSTEM AUTO-UPDATER
cat > system_updater.sh << 'EOF'
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
EOF

## 4. 📡 NETWORK INTELLIGENCE
cat > network_intel.sh << 'EOF'
#!/bin/bash
# 📡 ЦЯЛОСТЕН МРЕЖОВ АНАЛИЗ - ПРЕПОРЪЧИТЕЛЕН!
echo "=== 📡 NETWORK INTELLIGENCE ==="

# TV мрежова информация
echo "🔍 Gathering network information..."

TV_IP=$(adb shell ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)

if [ -n "$TV_IP" ]; then
    echo "📺 TV IP Address: $TV_IP"
    
    # Gateway
    GATEWAY=$(adb shell ip route | grep default | awk '{print $3}')
    echo "🚪 Gateway: $GATEWAY"
    
    # DNS
    echo "📡 DNS Servers:"
    adb shell getprop | grep net.dns | head -2
    
    # Сканиране на мрежата
    NETWORK=$(echo $TV_IP | cut -d. -f1-3)
    echo ""
    echo "🔍 Scanning network ${NETWORK}.0/24 for active devices..."
    
    # Бързо сканиране
    count=0
    for i in {1..50}; do
        if ping -c 1 -W 1 ${NETWORK}.$i &>/dev/null; then
            echo "🟢 ${NETWORK}.$i - Active"
            count=$((count + 1))
        fi
    done
    echo "📊 Found $count active devices in range 1-50"
else
    echo "❌ TV not connected to WiFi or ADB not available"
fi

# Портова проверка
echo ""
echo "🔒 Checking open ports on TV..."
adb shell netstat -tulpn 2>/dev/null | grep -E ":(80|443|22|5555)" | head -10 || echo "⚠️ Cannot check ports"
EOF

## 5. 🎥 SMART MEDIA DOWNLOADER
cat > media_master.sh << 'EOF'
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
EOF

## 6. 🚀 PERFORMANCE BOOSTER
cat > performance_boost.sh << 'EOF'
#!/bin/bash
# 🚀 ОПТИМИЗАЦИЯ НА TV ПРОИЗВОДИТЕЛНОСТ - ПРЕПОРЪЧИТЕЛЕН!
echo "=== 🚀 PERFORMANCE BOOSTER ==="

echo "🔍 Checking current performance..."
MEM_BEFORE=$(adb shell free -m | grep Mem: | awk '{print $4}')
echo "🧠 Available memory before: ${MEM_BEFORE}MB"

echo ""
echo "🧹 Clearing app caches..."
CACHE_APPS=(
    "com.netflix.ninja"
    "com.amazon.firetv.youtube" 
    "com.google.android.youtube.tv"
    "com.spotify.music"
    "com.hulu.plus"
)

for app in "${CACHE_APPS[@]}"; do
    if adb shell pm list packages | grep -q "$app"; then
        adb shell pm clear "$app"
        echo "✅ Cleared cache: $app"
    fi
done

echo ""
echo "🗑️ Removing temporary files..."
adb shell rm -rf /data/local/tmp/* 2>/dev/null
adb shell rm -rf /cache/* 2>/dev/null
echo "✅ Temp files cleaned"

echo ""
echo "🔧 Restarting system UI..."
adb shell am force-stop com.android.systemui
sleep 2
adb shell input keyevent KEYCODE_HOME
echo "✅ UI restarted"

echo ""
echo "📊 Performance report:"
MEM_AFTER=$(adb shell free -m | grep Mem: | awk '{print $4}')
echo "🧠 Available memory after: ${MEM_AFTER}MB"
echo "📈 Memory freed: $((MEM_AFTER - MEM_BEFORE))MB"

echo ""
echo "✅ Performance optimization complete!"
EOF

## 7. 📊 SYSTEM REPORT GENERATOR
cat > system_report.sh << 'EOF'
#!/bin/bash
# 📊 ДЕТАЙЛЕН СИСТЕМЕН ОТЧЕТ - ДИАГНОСТИЧЕН
echo "=== 📊 SYSTEM REPORT GENERATOR ==="

REPORT_FILE="tv_system_report_$(date +%Y%m%d_%H%M%S).txt"

{
echo "=========================================="
echo "       ANDROID TV SYSTEM REPORT"
echo "=========================================="
echo "Generated: $(date)"
echo ""

echo "📱 DEVICE INFORMATION:"
echo "----------------------"
adb shell getprop ro.product.manufacturer
adb shell getprop ro.product.model
adb shell getprop ro.product.device
adb shell getprop ro.build.version.release
adb shell getprop ro.build.version.sdk
echo ""

echo "💾 STORAGE INFORMATION:"
echo "----------------------"
adb shell df -h
echo ""

echo "🧠 MEMORY INFORMATION:"
echo "----------------------"
adb shell free -m
echo ""

echo "🌐 NETWORK INFORMATION:"
echo "----------------------"
adb shell ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print "IP Address: "$2}'
adb shell netstat -tulpn 2>/dev/null | grep LISTEN | head -10
echo ""

echo "📦 INSTALLED APPLICATIONS (User):"
echo "----------------------"
adb shell pm list packages -3 | sed 's/package://g' | head -20
echo ""

echo "🔥 SYSTEM TEMPERATURE:"
echo "----------------------"
adb shell cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -3 | while read temp; do
    echo "$((temp/1000))°C"
done

} > "$REPORT_FILE"

echo "✅ System report saved: $REPORT_FILE"
echo "📄 Content preview:"
head -20 "$REPORT_FILE"
EOF

## 8. 🔒 SECURITY AUDITOR
cat > security_audit.sh << 'EOF'
#!/bin/bash
# 🔒 ПРОВЕРКА НА СИГУРНОСТТА - ДИАГНОСТИЧЕН
echo "=== 🔒 SECURITY AUDITOR ==="

echo "🔍 Checking ADB debugging status..."
ADB_STATUS=$(adb shell settings get global adb_enabled 2>/dev/null)
echo "📱 ADB Debugging: $ADB_STATUS"

echo ""
echo "🌐 Checking network connections..."
echo "📡 Listening ports:"
adb shell netstat -tulpn 2>/dev/null | grep LISTEN | head -15

echo ""
echo "🔓 Checking installed apps..."
echo "⚠️ Potentially dangerous apps (user installed):"
adb shell pm list packages -3 | sed 's/package://g' | grep -E "(debug|test|root|admin)" || echo "✅ No suspicious apps found"

echo ""
echo "📱 App permissions audit..."
echo "🔐 Apps with dangerous permissions:"
adb shell dumpsys package | grep -A2 "android.permission.INTERNET" | grep "Package" | head -10

echo ""
echo "🔒 Security recommendations:"
if [ "$ADB_STATUS" = "1" ]; then
    echo "❌ ADB debugging is ENABLED - consider disabling in production"
else
    echo "✅ ADB debugging is disabled - good for security"
fi

echo ""
echo "✅ Security audit complete!"
EOF

## 9. 🏗️ INSTALLATION SCRIPT
cat > install_packages.sh << 'EOF'
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
EOF

## 10. 🎯 QUICK START SCRIPT
cat > quick_start.sh << 'EOF'
#!/bin/bash
# 🎯 БЪРЗ СТАРТ ЗА ANDROID TV POWERTOOLS
echo "=== 🎯 ANDROID TV POWERTOOLS - QUICK START ==="

echo ""
echo "📋 Available scripts:"
echo "----------------------"
echo "1. 🛡️  tv_health.sh       - System health check"
echo "2. 🎮  adb_master.sh      - ADB remote control" 
echo "3. 🔄  system_updater.sh  - Update all packages"
echo "4. 📡  network_intel.sh   - Network analysis"
echo "5. 🎥  media_master.sh    - Media downloader"
echo "6. 🚀  performance_boost.sh - Performance optimization"
echo "7. 📊  system_report.sh   - System report"
echo "8. 🔒  security_audit.sh  - Security check"
echo "9. 🏗️  install_packages.sh - Install all packages"

echo ""
echo "🚀 Quick commands:"
echo "----------------------"
echo "🔍 Check TV health:    ./tv_health.sh"
echo "📸 Take screenshot:    ./adb_master.sh screen"
echo "🔄 Update system:      ./system_updater.sh"
echo "📡 Scan network:       ./network_intel.sh"
echo "🎥 Download video:     ./media_master.sh 'URL'"
echo "🚀 Boost performance:  ./performance_boost.sh"

echo ""
echo "📖 First time setup:"
echo "----------------------"
echo "1. Run: ./install_packages.sh"
echo "2. Connect TV via ADB: adb connect TV_IP:5555"
echo "3. Check connection: ./tv_health.sh"
echo "4. Enjoy! 🎉"

echo ""
echo "❓ Help:"
echo "----------------------"
echo "All scripts have built-in help: ./script_name.sh"
echo "Check Termux FAQ: https://wiki.termux.com"
EOF

# Направа на всички скриптове изпълними
chmod +x *.sh

echo ""
echo "=========================================="
echo "✅ Android TV PowerTools Suite Created!"
echo "=========================================="
echo "📁 Location: $(pwd)"
echo "📊 Total scripts: $(ls *.sh | wc -l)"
echo ""
echo "📋 Created scripts:"
ls -la *.sh
echo ""
echo "🚀 To get started:"
echo "   cd ~/tv_powertools"
echo "   ./quick_start.sh"
echo "   ./install_packages.sh"
echo "=========================================="