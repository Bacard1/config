# Пуснете този скрипт за практически решения
cat > ~/practical_fixes.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

echo "=== ПРАКТИЧЕСКИ РЕШЕНИЯ ЗА ЗВУКА ==="
echo ""
echo "Стъпка 1: Рестартиране на устройството"
echo "  - Натиснете и задръжте Power бутона"
echo "  - Изберете 'Restart'"
echo ""
echo "Стъпка 2: Проверка на настройките"
echo "  - Отворете Настройки → Звук"
echo "  - Проверете 'Volume key behavior'"
echo "  - Променете на 'Adjust media volume'"
echo ""
echo "Стъпка 3: Safe Mode тест"
echo "  - Изключете устройството"
echo "  - Включете, като задържате Volume Down"
echo "  - Ако в Safe Mode звукът работи, проблемът е от приложение"
echo ""
echo "Стъпка 4: Хардуерен тест"
echo "  - Натиснете бутоните за звук внимателно"
echo "  - Пуснете и натиснете отново"
echo "  - Проверете за заяване на бутоните"
echo ""
echo "За алтернативно управление използвайте:"
echo "./volume_control.sh"
EOF

chmod +x ~/practical_fixes.sh
