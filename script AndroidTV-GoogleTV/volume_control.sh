# Създаване на скрипт за управление на звука
cat > ~/volume_control.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

echo "=== УПРАВЛЕНИЕ НА ЗВУКА БЕЗ ROOT ==="

show_menu() {
    echo ""
    echo "1: 🔊 Увеличи звук (постепенно)"
    echo "2: 🔈 Намали звук (постепенно)" 
    echo "3: 🎵 Текущо състояние на звука"
    echo "4: 📋 Инструкции за проблем с бутоните"
    echo "5: 🛠️  Други опции за фикс"
    echo "6: 🚪 Изход"
    echo ""
}

volume_up_gradual() {
    echo "Увеличаване на звука постепенно..."
    for i in 3 6 9 12 15; do
        termux-volume $i
        sleep 0.5
        echo "🔊 Ниво: $i"
    done
}

volume_down_gradual() {
    echo "Намаляване на звука постепенно..."
    for i in 15 12 9 6 3; do
        termux-volume $i
        sleep 0.5
        echo "🔈 Ниво: $i"
    done
}

show_instructions() {
    echo "=== РЕШЕНИЯ ЗА ПРОБЛЕМ С БУТОНИТЕ ==="
    echo ""
    echo "🔹 РЕШЕНИЕ 1: Рестартиране на устройството"
    echo "   - Задръжте Power бутона"
    echo "   - Изберете 'Restart'"
    echo ""
    echo "🔹 РЕШЕНИЕ 2: Проверка на настройките"
    echo "   - Настройки → Звук и вибрация"
    echo "   - Настройки → Достъпност"
    echo "   - Настройки → Специални възможности"
    echo ""
    echo "🔹 РЕШЕНИЕ 3: Изчистване на кеш"
    echo "   - Настройки → Приложения"
    echo "   - Намерете 'System UI'"
    echo "   - Изчистете кеш данните"
    echo ""
    echo "🔹 РЕШЕНИЕ 4: Safe Mode"
    echo "   - Изключете устройството"
    echo "   - Включете, като задържате Volume Down"
    echo "   - Пуснете, когато видите 'Safe Mode'"
    echo ""
}

other_options() {
    echo "=== ДОПЪЛНИТЕЛНИ ОПЦИИ ==="
    echo ""
    echo "1: Тестване на Termux volume команди"
    echo "2: Проверка на инсталирани пакети"
    echo "3: Информация за устройството"
    echo "4: Назад"
    echo ""
    read -p "Избери опция: " subchoice
    
    case $subchoice in
        1)
            echo "Тестване на volume команди..."
            for level in 5 10 15; do
                echo "Задаване на ниво: $level"
                termux-volume $level
                sleep 1
            done
            ;;
        2)
            echo "Инсталирани пакети:"
            pkg list-installed | grep -E "(termux-api|android-tools)"
            ;;
        3)
            echo "Информация за устройството:"
            termux-info | head -10
            ;;
        4)
            return
            ;;
        *)
            echo "Невалиден избор"
            ;;
    esac
}

# Основен цикъл
while true; do
    show_menu
    read -p "Избери опция [1-6]: " choice
    
    case $choice in
        1)
            volume_up_gradual
            ;;
        2)
            volume_down_gradual
            ;;
        3)
            echo "Текущо ниво на звука (използвайте termux-volume за промяна):"
            termux-volume
            ;;
        4)
            show_instructions
            ;;
        5)
            other_options
            ;;
        6)
            echo "Изход..."
            break
            ;;
        *)
            echo "Невалиден избор. Опитайте отново."
            ;;
    esac
    
    echo ""
    read -p "Натиснете Enter за продължение..."
done
EOF

chmod +x ~/volume_control.sh
