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
