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
