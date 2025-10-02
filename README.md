За Google TV с Termux ето пълния списък с необходимите пакети и Debian команди:

## 📦 НЕОБХОДИМИ ПАКЕТИ ЗА TERMUX (Google TV)

### Основни системни пакети:
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

### Мрежови инструменти:
```bash
pkg install -y \
    nmap \
    net-tools \
    dnsutils \
    tcpdump \
    openssl \
    iperf3
```

### Медийни и TV-специфични пакети:
```bash
pkg install -y \
    yt-dlp \
    python3 \
    pip \
    jq \
    xmlstarlet
```

### Допълнителни полезни пакети:
```bash
pkg install -y \
    termux-tools \
    termux-services \
    termux-exec \
    proot \
    root-repo \
    x11-repo
```

## 🐧 DEBIAN КОМАНДИ (через proot)

### Инсталиране на Debian в Termux:
```bash
pkg install proot-distro
proot-distro install debian
proot-distro login debian
```

### Debian пакети за Google TV:
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

### Специфични инструменти за TV:
```bash
# ADB контрол на TV
apt install -y android-sdk-platform-tools-common

# Мрежови сканери
apt install -y ettercap-text-only wireshark-cli

# Системни монитори
apt install -y iotop iftop nethogs
```

## 🔧 GOOGLE TV СПЕЦИФИЧНИ КОМАНДИ

### ADB команди за контрол на TV:
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

### Мрежови команди за TV:
```bash
# Проверка на мрежовата конфигурация
adb shell ifconfig
adb shell netstat -tulpn

# Ping тестове
adb shell ping -c 4 google.com
```

### Системни команди за TV:
```bash
# Информация за паметта
adb shell cat /proc/meminfo

# Информация за CPU
adb shell cat /proc/cpuinfo

# Температура на системата
adb shell cat /sys/class/thermal/thermal_zone*/temp
```

## 🚀 SCRCPY (екран на TV към Termux)

### Инсталиране на scrcpy в Debian:
```bash
# В Debian environment
apt install -y scrcpy

# Стартиране на scrcpy
scrcpy --max-size 800 --bit-rate 2M --max-fps 30
```

## 📱 TERMUX API КОМАНДИ ЗА TV

### Контрол на TV през Termux:
```bash
# Информация за батерията (ако е приложимо)
termux-battery-status

# Вибрация (ако TV поддържа)
termux-vibrate

# Камера и микрофон (ако са налични)
termux-camera-photo
termux-microphone-record
```

## 🛠️ ПОЛЕЗНИ СКРИПТОВЕ ЗА GOOGLE TV

### Скрипт за системен монитор:
```bash
#!/bin/bash
echo "=== GOOGLE TV SYSTEM INFO ==="
echo "Model: $(adb shell getprop ro.product.model)"
echo "Android: $(adb shell getprop ro.build.version.release)"
echo "IP Address: $(adb shell ip addr show wlan0 | grep 'inet ' | awk '{print $2}')"
echo "Storage: $(adb shell df -h /data | tail -1 | awk '{print $4}') free"
echo "Memory: $(adb shell free -m | grep Mem: | awk '{print $4}') MB free"
```

### Скрипт за бърза инсталация на всичко:
```bash
#!/bin/bash
echo "Installing all packages for Google TV..."
pkg update && pkg upgrade -y
pkg install -y python nodejs git wget curl openssh ffmpeg vim htop neofetch nmap net-tools termux-api
pkg install proot-distro
proot-distro install debian
echo "Installation complete!"
```

Тези пакети и команди ще ви дадат пълен контрол над Google TV през Termux! 📺💻
