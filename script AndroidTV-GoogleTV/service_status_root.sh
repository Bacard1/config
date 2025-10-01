cat > ~/service_status.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

echo "=== СТАТУС НА УСЛУГИТЕ ==="
echo ""

# Критични Android услуги
critical_services=(
    "system_server"
    "media.audio_policy" 
    "com.android.systemui"
    "android.process.media"
    "surfaceflinger"
)

echo "🔍 Критични Android услуги:"
for service in "${critical_services[@]}"; do
    if pgrep -f "$service" > /dev/null; then
        echo "   ✅ $service - АКТИВЕН"
    else
        echo "   ❌ $service - НЕАКТИВЕН"
    fi
done

echo ""
echo "🔍 Termux услуги:"
termux_services=(
    "termux"
    "sshd"
    "bash"
)

for service in "${termux_services[@]}"; do
    if pgrep -f "$service" > /dev/null; then
        echo "   ✅ $service - АКТИВЕН"
    else
        echo "   ❌ $service - НЕАКТИВЕН"
    fi
done

echo ""
echo "🔍 Мрежови услуги:"
network_services=(
    "wifi"
    "bluetooth"
    "network"
)

for service in "${network_services[@]}"; do
    status=$(tsu -c "svc $service" 2>/dev/null | head -1 || echo "unknown")
    echo "   📡 $service - $status"
done

echo ""
echo "🔍 Аудио услуги:"
audio_services=(
    "audio"
    "media.audio_policy"
)

for service in "${audio_services[@]}"; do
    if pgrep -f "$service" > /dev/null; then
        echo "   🔊 $service - АКТИВЕН"
    else
        echo "   🔇 $service - НЕАКТИВЕН"
    fi
done

echo ""
echo "=== ДОПЪЛНИТЕЛНА ИНФОРМАЦИЯ ==="

# Информация за устройството
echo "📱 Информация за устройството:"
termux-info | grep -E "(Device|Android|Architecture)" | head -5

# Информация за звука
echo ""
echo "🎵 Информация за звука:"
termux-volume 2>/dev/null || echo "   Termux volume не е наличен"

EOF

chmod +x ~/service_status.sh
