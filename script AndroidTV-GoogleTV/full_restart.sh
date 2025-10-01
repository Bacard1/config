cat > ~/full_restart.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

echo "=== ПЪЛНО РЕСТАРТИРАНЕ НА СИСТЕМАТА ==="
echo ""

echo "⚠️  ВНИМАНИЕ: Това ще рестартира някои системни услуги!"
echo ""

read -p "Продължаване? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "Отменено."
    exit 0
fi

echo "1. Спиране на всички Termux процеси..."
pkill -f "termux" 2>/dev/null
sleep 2

echo "2. Рестартиране на аудио система..."
{
    tsu -c "killall media.audio_policy" 2>/dev/null
    sleep 1
    tsu -c "start media.audio_policy" 2>/dev/null
} && echo "   ✅ Аудио система рестартирана"

echo "3. Рестартиране на SystemUI..."
{
    tsu -c "pkill -f com.android.systemui" 2>/dev/null
    sleep 3
} && echo "   ✅ SystemUI рестартиран"

echo "4. Рестартиране на мрежови услуги..."
{
    tsu -c "svc wifi restart" 2>/dev/null
    tsu -c "svc bluetooth restart" 2>/dev/null
} && echo "   ✅ Мрежови услуги рестартирани"

echo "5. Възстановяване на настройки по подразбиране..."
{
    termux-volume 10 2>/dev/null
    export PATH=/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/bin/applets:$PATH
} && echo "   ✅ Настройки възстановени"

echo ""
echo "=== РЕСТАРТИРАНЕТО ЗАВЪРШИ ==="
echo ""
echo "Следващи стъпки:"
echo "1. Затворете и отворете Termux отново"
echo "2. Пуснете: ./service_status.sh за проверка"
echo "3. Ако има проблеми, рестартирайте устройството"

EOF

chmod +x ~/full_restart.sh
