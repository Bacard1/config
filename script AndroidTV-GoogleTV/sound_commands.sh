# Създаване на бързи команди
cat > ~/sound_commands.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# Бързи функции за звука
alias sound-max="termux-volume 15"
alias sound-med="termux-volume 10"
alias sound-low="termux-volume 5"
alias sound-mute="termux-volume 0"

# Постепенно увеличаване
sound-up() {
    for i in {5..15..2}; do
        termux-volume $i
        sleep 0.3
    done
}

# Постепенно намаляване
sound-down() {
    for i in {15..1..-2}; do
        termux-volume $i
        sleep 0.3
    done
}

echo "Бързи звукови команди са заредени!"
echo "sound-max   - максимален звук"
echo "sound-med   - среден звук" 
echo "sound-low   - нисък звук"
echo "sound-mute  - заглушаване"
echo "sound-up    - постепенно увеличаване"
echo "sound-down  - постепенно намаляване"
EOF

# Добавяне към .bashrc
echo "source ~/sound_commands.sh" >> ~/.bashrc
