cat > ~/restore_services.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

echo "=== ВЪЗСТАНОВЯВАНЕ НА УСЛУГИ И НАСТРОЙКИ ==="
echo ""

# Функция за проверка на статуса
check_status() {
    if [ $? -eq 0 ]; then
        echo "✓ $1"
    else
        echo "✗ $1"
    fi
}

echo "1. Възстановяване на аудио услуги..."
# Рестартиране на аудио услуги (ако имаме root)
tsu -c "killall media.audio_policy" 2>/dev/null
tsu -c "start media.audio_policy" 2>/dev/null
check_status "Аудио услуги"

echo "2. Възстановяване на SystemUI..."
# Рестартиране на SystemUI
tsu -c "pkill -f com.android.systemui" 2>/dev/null
sleep 3
check_status "SystemUI"

echo "3. Възстановяване на настройките за звук..."
# Нулиране на настройките за звук
termux-volume 10 2>/dev/null
check_status "Настройки за звук"

echo "4. Проверка на Termux услуги..."
# Рестартиране на Termux услуги
pkill -f "termux" 2>/dev/null
sleep 2
check_status "Termux услуги"

echo "5. Възстановяване на мрежови услуги..."
# Рестартиране на мрежови услуги
tsu -c "svc wifi disable" 2>/dev/null
tsu -c "svc wifi enable" 2>/dev/null
check_status "Мрежови услуги"

echo "6. Проверка на Bluetooth услуги..."
tsu -c "svc bluetooth disable" 2>/dev/null
tsu -c "svc bluetooth enable" 2>/dev/null
check_status "Bluetooth услуги"

echo ""
echo "=== ВЪЗСТАНОВЯВАНЕ НА ПАКЕТИ ==="

echo "7. Проверка на инсталирани пакети..."
pkg list-installed | grep -E "(tsu|android-tools|termux-api|python)" | while read pkg; do
    echo "   ✓ $pkg"
done

echo "8. Актуализиране на пакети..."
pkg update -y && pkg upgrade -y
check_status "Актуализация на пакети"

echo ""
echo "=== ВЪЗСТАНОВЯВАНЕ НА НАСТРОЙКИ ==="

echo "9. Възстановяване на PATH..."
export PATH=/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/bin/applets:$PATH
echo 'export PATH=/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/bin/applets:$PATH' > ~/.bashrc
check_status "PATH настройки"

echo "10. Възстановяване на shell разрешения..."
chmod +x /data/data/com.termux/files/usr/bin/sh 2>/dev/null
chmod +x /data/data/com.termux/files/usr/bin/bash 2>/dev/null
chmod +x /data/data/com.termux/files/usr/bin/dash 2>/dev/null
check_status "Shell разрешения"

echo ""
echo "=== СЪЗДАДЕНИ СКРИПТОВЕ ==="

# Списък на създадените скриптове
scripts=("volume_control.sh" "sound_commands.sh" "practical_fixes.sh" "system_check.sh" "reboot_options.sh")

for script in "${scripts[@]}"; do
    if [ -f ~/$script ]; then
        echo "   ✓ ~/$script"
    else
        echo "   ✗ ~/$script (липсва)"
    fi
done

echo ""
echo "=== ПРОВЕРКА НА СИСТЕМАТА ==="

echo "11. Тест на базови функции..."
bash -c "echo '✓ Bash работи'" && check_status "Bash"
termux-volume && check_status "Termux volume"
pkg list-installed &>/dev/null && check_status "Пакетен мениджър"

echo ""
echo "=== ФИНАЛНА ПРОВЕРКА ==="

echo "12. Проверка на критични услуги..."
services=("media.audio_policy" "com.android.systemui")

for service in "${services[@]}"; do
    if pgrep -f "$service" > /dev/null; then
        echo "   ✓ $service работи"
    else
        echo "   ✗ $service не работи"
    fi
done

echo ""
echo "=== ВЪЗСТАНОВЯВАНЕТО ЗАВЪРШИ ==="
echo ""
echo "Препоръки:"
echo "1. Рестартирайте Termux: exit и отворете отново"
echo "2. Рестартирайте устройството за пълно възстановяване"
echo "3. Тествайте звука с: ./volume_control.sh"
echo "4. Проверете системата с: ./system_check.sh"

EOF

chmod +x ~/restore_services.sh
