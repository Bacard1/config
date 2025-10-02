# 📺 ANDROID TV POWERTOOLS SUITE 🚀

**Пълен комплект за автоматизация и контрол на Android TV/Google TV устройства**

---

## 📦 **ПАКЕТИ И ТЕХНАТА РОЛЯ**

### 🏗️ **ОСНОВНИ СИСТЕМНИ ПАКЕТИ** (*Задължителни*)

```bash
pkg update && pkg upgrade -y
pkg install -y \
    python \
    nodejs \
    git \
    wget \
    curl \
    openssh \
    termux-api \
    ffmpeg \
    vim \
    nano \
    htop \
    neofetch
```

| Пакет | Роля 🎯 | Важност | Пример |
|-------|---------|---------|---------|
| `python` | Автоматизация и скриптове | ✅ **ЗАДЪЛЖИТЕЛЕН** | `python tv_health.py` |
| `openssh` | Отдалечен достъп до TV | ✅ **ЗАДЪЛЖИТЕЛЕН** | `ssh user@tv-ip -p 8022` |
| `git` | Инсталиране на репозитории | ✅ **ЗАДЪЛЖИТЕЛЕН** | `git clone https://github.com/your-repo` |
| `ffmpeg` | Медийна обработка | ✅ **ЗАДЪЛЖИТЕЛЕН** | `ffmpeg -i input.mp4 output_tv.mp4` |
| `htop` | Мониторинг на системата | ✅ **ЗАДЪЛЖИТЕЛЕН** | `htop` |

---

### 🌐 **МРЕЖОВИ ИНСТРУМЕНТИ** (*Препоръчителни*)

```bash
pkg install -y \
    nmap \
    net-tools \
    dnsutils \
    tcpdump \
    openssl \
    iperf3
```

| Пакет | Роля 🎯 | Важност | Пример |
|-------|---------|---------|---------|
| `nmap` | Сканиране на мрежата | 🔍 **ВИСОКА** | `nmap -sn 192.168.1.0/24` |
| `net-tools` | Мрежова диагностика | 🔧 **СРЕДНА** | `netstat -tulpn` |
| `tcpdump` | Анализ на мрежов трафик | 🕵️ **СРЕДНА** | `tcpdump -i wlan0` |

---

### 📺 **TV-СПЕЦИФИЧНИ ПАКЕТИ** (*Специализирани*)

```bash
pkg install -y \
    yt-dlp \
    python3 \
    pip \
    jq \
    xmlstarlet
```

| Пакет | Роля 🎯 | Важност | Пример |
|-------|---------|---------|---------|
| `yt-dlp` | Сваляне на видео | 🎥 **ВИСОКА** | `yt-dlp YouTube-URL` |
| `termux-api` | Интеграция с Android | 📱 **СРЕДНА** | `termux-battery-status` |
| `jq` | JSON обработка | 📊 **СРЕДНА** | `curl api | jq '.data'` |

---

### 🛠️ **ДОПЪЛНИТЕЛНИ ПАКЕТИ** (*Разширени*)

```bash
pkg install -y \
    termux-tools \
    termux-services \
    termux-exec \
    proot \
    root-repo \
    x11-repo
```

---

## 🐧 **DEBIAN СРЕДА ЗА РАЗШИРЕНИ ВЪЗМОЖНОСТИ**

### 🏗️ **Инсталация на Debian:**
```bash
pkg install proot-distro
proot-distro install debian
proot-distro login debian
```

### 🛠️ **Debian пакети за TV:**
```bash
# В Debian environment
apt update && apt upgrade -y
apt install -y \
    adb \
    android-tools-adb \
    android-tools-fastboot \
    scrcpy \
    vlc \
    mediainfo \
    smartmontools
```

### 🔧 **Специфични инструменти:**
```bash
# ADB контрол на TV
apt install -y android-sdk-platform-tools-common

# Мрежови сканери
apt install -y ettercap-text-only wireshark-cli

# Системни монитори
apt install -y iotop iftop nethogs
```

---

## 🚀 **ПЪЛЕН КОМПЛЕКТ СКРИПТОВЕ**

### 1. **🛡️ TV Health Guardian** (`tv_health.sh`)
```bash
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
[ -n "$TEMP" ] && echo "🌡️ Temperature: $((TEMP/1000))°C"

# Мрежова информация
IP=$(adb shell ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
[ -n "$IP" ] && echo "🌐 IP Address: $IP"
```
**🎯 Роля**: Постоянен мониторинг на здравето на TV-то  
**📊 Важност**: ✅ **ЗАДЪЛЖИТЕЛЕН**  
**🔧 Защо е нужен**: Предотвратява прегряване и паметта да свърши  

---

### 2. **🎮 ADB Master Controller** (`adb_master.sh`)
```bash
#!/bin/bash
# 🎮 ПЪЛЕН КОНТРОЛ НА TV ПРЕЗ ADB - ЗАДЪЛЖИТЕЛЕН!
echo "=== 🎮 ADB MASTER CONTROLLER ==="

case $1 in
    "screen")
        adb exec-out screencap -p > "screen_$(date +%Y%m%d_%H%M%S).png"
        echo "📸 Screenshot saved!"
        ;;
    "install")
        adb install -r "$2"
        echo "📦 App installed: $2"
        ;;
    "uninstall")
        adb uninstall "$2"
        echo "🗑️ App removed: $2"
        ;;
    "reboot")
        adb reboot
        echo "🔃 Rebooting TV..."
        ;;
    "apps")
        adb shell pm list packages -3
        ;;
    *)
        echo "❌ Usage: $0 {screen|install apk|uninstall package|reboot|apps}"
        echo "   Example: $0 install /sdcard/app.apk"
        ;;
esac
```
**🎯 Роля**: Основен инструмент за управление на TV  
**📊 Важност**: ✅ **ЗАДЪЛЖИТЕЛЕН**  
**🔧 Защо е нужен**: Без него нямате контрол върху приложенията и системата  

---

### 3. **🔄 System Auto-Updater** (`system_updater.sh`)
```bash
#!/bin/bash
# 🔄 АВТОМАТИЧНА АКТУАЛИЗАЦИЯ НА ЦЯЛАТА СИСТЕМА - ЗАДЪЛЖИТЕЛЕН!
echo "=== 🔄 SYSTEM AUTO-UPDATER ==="

echo "📦 Updating Termux packages..."
pkg update && pkg upgrade -y

echo "🐍 Updating Python packages..."
pip install --upgrade pip
pip install --upgrade yt-dlp

echo "🐧 Checking Debian environment..."
if proot-distro list | grep -q debian; then
    echo "🔄 Updating Debian packages..."
    proot-distro login debian -- apt update && apt upgrade -y
fi

echo "🧹 Cleaning up..."
pkg clean
echo "✅ System update complete!"
```
**🎯 Роля**: Поддържа системата актуална и сигурна  
**📊 Важност**: ✅ **ЗАДЪЛЖИТЕЛЕН**  
**🔧 Защо е нужен**: Без актуализации няма сигурност и нови функции  

---

### 4. **📡 Network Intelligence** (`network_intel.sh`)
```bash
#!/bin/bash
# 📡 ЦЯЛОСТЕН МРЕЖОВ АНАЛИЗ - ПРЕПОРЪЧИТЕЛЕН!
echo "=== 📡 NETWORK INTELLIGENCE ==="

# TV мрежова информация
TV_IP=$(adb shell ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)

if [ -n "$TV_IP" ]; then
    echo "📺 TV IP: $TV_IP"
    
    # Сканиране на мрежата
    NETWORK=$(echo $TV_IP | cut -d. -f1-3)
    echo "🔍 Scanning network ${NETWORK}.0/24..."
    
    # Бързо сканиране за активни устройства
    for i in {1..254}; do
        ping -c 1 -W 1 ${NETWORK}.$i | grep "bytes from" | cut -d" " -f4 | cut -d":" -f1 &
    done | sort -V
else
    echo "❌ TV not connected to WiFi"
fi
```
**🎯 Роля**: Мрежова диагностика и анализ  
**📊 Важност**: 💡 **ПРЕПОРЪЧИТЕЛЕН**  
**🔧 Защо е нужен**: Помага при мрежови проблеми и откриване на устройства  

---

### 5. **🎥 Smart Media Downloader** (`media_master.sh`)
```bash
#!/bin/bash
# 🎥 ИНТЕЛИГЕНТЕН МЕДИЕН МЕНИДЖЪР - ПРЕПОРЪЧИТЕЛЕН!
echo "=== 🎥 SMART MEDIA DOWNLOADER ==="

URL=$1
QUALITY=${2:-"best"}

if [ -z "$URL" ]; then
    echo "❌ Usage: $0 <YouTube_URL> [quality]"
    echo "   Example: $0 'https://youtube.com/watch?v=xxx' 'bestvideo[height<=720]'"
    exit 1
fi

echo "📥 Downloading: $URL"
echo "🎬 Quality: $QUALITY"

yt-dlp -f "$QUALITY" \
       -o "~/storage/downloads/%(title).100s.%(ext)s" \
       --add-metadata \
       "$URL"

echo "✅ Download complete! Check ~/storage/downloads/"
```
**🎯 Роля**: Лесно сваляне на видео съдържание  
**📊 Важност**: 💡 **ПРЕПОРЪЧИТЕЛЕН**  
**🔧 Защо е нужен**: За любители на видеа и офлайн съдържание  

---

### 6. **🚀 Performance Booster** (`performance_boost.sh`)
```bash
#!/bin/bash
# 🚀 ОПТИМИЗАЦИЯ НА TV ПРОИЗВОДИТЕЛНОСТ - ПРЕПОРЪЧИТЕЛЕН!
echo "=== 🚀 PERFORMANCE BOOSTER ==="

echo "🧹 Clearing app caches..."
adb shell pm clear com.netflix.ninja
adb shell pm clear com.amazon.firetv.youtube
adb shell pm clear com.google.android.youtube.tv

echo "🗑️ Removing temporary files..."
adb shell rm -rf /data/local/tmp/*
adb shell rm -rf /cache/*

echo "🔧 Restarting UI..."
adb shell am force-stop com.android.systemui
adb shell input keyevent KEYCODE_HOME

echo "✅ Performance optimization complete!"
```
**🎯 Роля**: Ускоряване на бавно работещ TV  
**📊 Важност**: 💡 **ПРЕПОРЪЧИТЕЛЕН**  
**🔧 Защо е нужен**: Подобрява производителността на стари TV устройства  

---

### 7. **📊 System Report Generator** (`system_report.sh`)
```bash
#!/bin/bash
# 📊 ДЕТАЙЛЕН СИСТЕМЕН ОТЧЕТ - ДИАГНОСТИЧЕН
echo "=== 📊 SYSTEM REPORT GENERATOR ==="

REPORT_FILE="tv_report_$(date +%Y%m%d_%H%M%S).txt"

{
echo "=== GOOGLE TV SYSTEM INFO ==="
echo "Model: $(adb shell getprop ro.product.model)"
echo "Android: $(adb shell getprop ro.build.version.release)"
echo "IP Address: $(adb shell ip addr show wlan0 | grep 'inet ' | awk '{print $2}')"
echo "Storage: $(adb shell df -h /data | tail -1 | awk '{print $4}') free"
echo "Memory: $(adb shell free -m | grep Mem: | awk '{print $4}') MB free"
} > "$REPORT_FILE"

echo "✅ Report saved: $REPORT_FILE"
```
**🎯 Роля**: Създаване на системни отчети  
**📊 Важност**: 📋 **ДИАГНОСТИЧЕН**  
**🔧 Защо е нужен**: За техническа поддръжка и анализ на проблеми  

---

### 8. **🔒 Security Auditor** (`security_audit.sh`)
```bash
#!/bin/bash
# 🔒 ПРОВЕРКА НА СИГУРНОСТТА - ДИАГНОСТИЧЕН
echo "=== 🔒 SECURITY AUDITOR ==="

echo "🔍 Checking ADB debugging..."
ADB_STATUS=$(adb shell settings get global adb_enabled)
echo "ADB Debugging: $ADB_STATUS"

echo "🌐 Checking open ports..."
adb shell netstat -tulpn | grep -E ":(80|443|22)" 

echo "✅ Security audit complete!"
```
**🎯 Роля**: Проверка на сигурността на системата  
**📊 Важност**: 📋 **ДИАГНОСТИЧЕН**  
**🔧 Защо е нужен**: За сигурност и поверителност  

---

## 🔧 **GOOGLE TV КОМАНДИ ЗА РЪЧЕН КОНТРОЛ**

### ADB команди за директно управление:
```bash
# Списък на свързани устройства
adb devices

# Информация за TV
adb shell getprop ro.product.model
adb shell getprop ro.build.version.sdk

# Скрийншот от TV
adb exec-out screencap -p > screenshot.png

# Инсталиране на APK
adb install app.apk

# Деинсталиране на приложение
adb uninstall com.package.name
```

### Мрежови команди:
```bash
# Проверка на мрежовата конфигурация
adb shell ifconfig
adb shell netstat -tulpn

# Ping тестове
adb shell ping -c 4 google.com
```

### Системни команди:
```bash
# Информация за паметта
adb shell cat /proc/meminfo

# Информация за CPU
adb shell cat /proc/cpuinfo

# Температура на системата
adb shell cat /sys/class/thermal/thermal_zone*/temp
```

---

## 🚀 **SCRCPY - ЕКРАННО ОТРАЗЯВАНЕ**

### Инсталиране и използване:
```bash
# В Debian environment
apt install -y scrcpy

# Стартиране на scrcpy
scrcpy --max-size 800 --bit-rate 2M --max-fps 30
```

---

## 📱 **TERMUX API КОМАНДИ**

### Интеграция с Android хардуер:
```bash
# Информация за батерията
termux-battery-status

# Вибрация (ако TV поддържа)
termux-vibrate

# Камера и микрофон
termux-camera-photo
termux-microphone-record
```

---

## 🎯 **КАТЕГОРИЗАЦИЯ ПО ВАЖНОСТ**

### ✅ **ЗАДЪЛЖИТЕЛНИ СКРИПТОВЕ** (Core Suite):
1. **`tv_health.sh`** - Здравето на TV е ПАРАМOUNT! 🛡️
2. **`adb_master.sh`** - Основен контрол - БЕЗ НЕГО НЯМА КОНТРОЛ! 🎮  
3. **`system_updater.sh`** - Без актуализации няма сигурност! 🔄

### 💡 **ПРЕПОРЪЧИТЕЛНИ СКРИПТОВЕ** (Power Tools):
4. **`network_intel.sh`** - За мрежови диагностики 🌐
5. **`performance_boost.sh`** - За стари/бавни TV ⚡
6. **`media_master.sh`** - За видео ентусиасти 🎬

### 📊 **ДИАГНОСТИЧНИ СКРИПТОВЕ** (Advanced):
7. **`system_report.sh`** - За техническа поддръжка 📋
8. **`security_audit.sh`** - За сигурност и поверителност 🔒

---

## 🏗️ **ИНСТАЛАЦИОНЕН СКРИПТ** (`install_all.sh`)

```bash
#!/bin/bash
echo "🚀 Installing Complete Android TV PowerTools Suite..."

# Актуализация и основни пакети
pkg update && pkg upgrade -y
pkg install -y python nodejs git wget curl openssh ffmpeg vim htop neofetch nmap net-tools termux-api
pkg install -y yt-dlp python3 pip jq xmlstarlet termux-tools proot root-repo

# Debian среда
pkg install proot-distro -y
proot-distro install debian

# Създаване на директория за скриптовете
mkdir -p ~/tv_powertools
cd ~/tv_powertools

echo "✅ Installation complete! Ready for TV domination! 📺"
echo "📁 Scripts directory: ~/tv_powertools/"
```

---

## 📊 **ВИЗУАЛНА АРХИТЕКТУРА НА СИСТЕМАТА**

```
ANDROID TV POWERTOOLS SUITE 🏰
│
├── 🏗️ FOUNDATION (Пакети)
│   ├── 📦 Core System
│   ├── 🌐 Network Tools  
│   ├── 📺 TV Specific
│   └── 🐧 Debian Environment
│
├── 🛡️ HEALTH & MONITORING
│   ├── tv_health.sh          ✅ ЗАДЪЛЖИТЕЛЕН
│   └── system_report.sh      📋 ДИАГНОСТИЧЕН
│
├── 🎮 CONTROL & MANAGEMENT  
│   ├── adb_master.sh         ✅ ЗАДЪЛЖИТЕЛЕН
│   ├── performance_boost.sh  💡 ПРЕПОРЪЧИТЕЛЕН
│   └── system_updater.sh     ✅ ЗАДЪЛЖИТЕЛЕН
│
├── 🌐 NETWORK & SECURITY
│   ├── network_intel.sh      💡 ПРЕПОРЪЧИТЕЛЕН
│   └── security_audit.sh     📋 ДИАГНОСТИЧЕН
│
└── 🎥 MEDIA & UTILITIES
    └── media_master.sh       💡 ПРЕПОРЪЧИТЕЛЕН
```

---

## ⚠️ **ВАЖНИ ПРЕДУПРЕЖДЕНИЯ**

- 🔒 **Сигурност**: Винаги сменете SSH паролата!
- 📶 **Мрежа**: TV и управляващото устройство трябва да са в една мрежа
- 🔋 **Батерия**: Някои функции консумират повече енергия
- ⚡ **Производителност**: Сложните скриптове може да забавят TV

**🎉 ЧЕСТИТО! Вече имате ПЪЛЕН КОНТРОЛ над вашия Android TV! 🎉**