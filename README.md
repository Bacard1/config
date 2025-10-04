<<<<<<< HEAD
=======
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

```bash
pkg install -y nmap net-tools dnsutils openssl iperf3
pkg install root-repo
pkg install tcpdump
pkg install -y termux-tools netcat-openbsd
```


```bash
uname -a
pkg list-installed | grep tcp
pkg install -y python python-pip yt-dlp jq xmlstarlet
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

Solution 1: Install from Debian repositories (if using Debian/Ubuntu)
bash
apt update
apt install -y scrcpy
Solution 2: Install via Snap (if available)
bash
apt install -y snapd
snap install scrcpy
Solution 3: Download and install the pre-built binary
bash
# Download the latest release
wget https://github.com/Genymobile/scrcpy/releases/download/v2.4/scrcpy-server-v2.4
wget https://github.com/Genymobile/scrcpy/releases/download/v2.4/scrcpy-x64-v2.4.tar.gz

# Extract and install
tar -xzf scrcpy-x64-v2.4.tar.gz
cp scrcpy-x64-v2.4/scrcpy /usr/local/bin/
cp scrcpy-server-v2.4 /usr/local/share/scrcpy/scrcpy-server

# Make executable
chmod +x /usr/local/bin/scrcpy

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
>>>>>>> 94838511d6a4d18fd3999e22cea03dfb297a4b85
