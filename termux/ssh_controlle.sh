#!/bin/bash

show_menu() {
    echo "==========================="
    echo "  Системно меню"
    echo "==========================="
    #----------------------------------------------------------#
    # install openssh
    #----------------------------------------------------------#
    echo "1. Инсталиране на SSH"
    #----------------------------------------------------------#
    # set password and ssh-key
    #----------------------------------------------------------#
    echo "2. Задаване на парола и SSH ключ/нов потребител"
    #----------------------------------------------------------#
    # setup termux boot and services
    #----------------------------------------------------------#
    echo "3. Настройка на Termux:Boot и услуги"
    #----------------------------------------------------------#
    # show ssh keys
    #----------------------------------------------------------#
    echo "4. Покажи SSH ключове"
    #----------------------------------------------------------#
    # add key to authorized_keys
    #----------------------------------------------------------#
    echo "5. Добавяне на ключ в authorized_keys"
    echo "0. Изход"
    echo
}

#----------------------------------------------------------#
# install openssh
#----------------------------------------------------------#
install_ssh() {
    echo "Започване на инсталацията на SSH..."
    echo "Актуализиране на пакетите..."
    pkg update
    echo "Надграждане на пакетите..."
    pkg upgrade -y
    echo "Инсталиране на OpenSSH..."
    pkg install openssh -y
    echo "SSH инсталацията завърши успешно!"
}

#----------------------------------------------------------#
# set password and ssh-key
#----------------------------------------------------------#
set_password_and_sshkey() {
    # Задаване на парола
    echo "=== Задаване на парола ==="
    while true; do
        read -s -p "Въведете нова парола: " password
        echo
        read -s -p "Потвърдете паролата: " password_confirm
        echo
        
        if [ "$password" = "$password_confirm" ]; then
            echo "Паролата е зададена успешно!"
            # Задаване на парола за текущия потребител
            echo -e "$password\n$password" | passwd > /dev/null 2>&1
            break
        else
            echo "Паролите не съвпадат! Опитайте отново."
        fi
    done
    
    # Генериране на SSH ключ
    echo ""
    echo "=== Генериране на SSH ключ ==="
    read -p "Въведете потребителско име: " username
    read -p "Въведете хост: " hostname
    
    # Проверка дали директорията .ssh съществува
    if [ ! -d ~/.ssh ]; then
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
    fi
    
    # Генериране на ключа
    key_file="$HOME/.ssh/${username}"
    echo "Генериране на SSH ключ във файл: $key_file"
    ssh-keygen -t rsa -f "$key_file" -C "${username}@${hostname}"
    
    echo ""
    echo "SSH ключът е генериран успешно!"
    echo "Публичният ключ се намира във: ${key_file}.pub"
    echo "Частният ключ се намира във: ${key_file}"
    
    # Показване на публичния ключ
    echo ""
    echo "Съдържание на публичния ключ:"
    cat "${key_file}.pub"
}

#----------------------------------------------------------#
# setup termux boot and services
#----------------------------------------------------------#
setup_boot_services() {
    echo "=== Настройка на Termux:Boot и SSH услуга ==="
    echo ""
    
    # Проверка за Termux:Boot
    echo "=== ПРОВЕРКА ЗА TERMUX:BOOT ==="
    read -p "Инсталирахте ли Termux:Boot от F-Droid? (да/не): " termux_boot_installed
    
    case $termux_boot_installed in
        [Дд]а|[Yy]es|"")
            echo "Продължавам с настройката..."
            ;;
        [Нн]е|[Nn]o)
            echo "Моля, инсталирайте Termux:Boot от F-Droid преди да продължите."
            echo "След инсталацията, стартирайте приложението веднъж и се върнете тук."
            return
            ;;
        *)
            echo "Неразбран отговор. Предполагам, че сте инсталирали Termux:Boot."
            ;;
    esac
    
    echo ""
    echo "=== ИНСТАЛИРАНЕ НА TERMUX-SERVICES ==="
    pkg install termux-services -y
    echo ""
    
    echo "=== СТАРТИРАНЕ НА SERVICE-DAEMON ==="
    service-daemon start
    echo ""
    
    echo "=== АКТИВИРАНЕ НА SSH УСЛУГАТА ==="
    sv-enable sshd
    echo "SSH услугата е активирана за автоматично стартиране"
    echo ""
    
    echo "=== СТАРТИРАНЕ НА SSH УСЛУГАТА ==="
    sv up sshd
    echo "SSH услугата е стартирана"
    echo ""
    
    echo "=== СТАТУС НА SSH УСЛУГАТА ==="
    sv status sshd
    echo ""
    
    echo "=== СЪЗДАВАНЕ НА BOOT ДИРЕКТОРИЯ И СКРИПТ ==="
    # Създаване на boot директория ако не съществува
    if [ ! -d ~/.termux/boot ]; then
        mkdir -p ~/.termux/boot
        echo "Създадена е директория ~/.termux/boot/"
    fi
    
    # Създаване на скрипта
    cat > ~/.termux/boot/start-sshd << 'EOF'
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
sshd
EOF
    
    # Правене на скрипта изпълним
    chmod +x ~/.termux/boot/start-sshd
    
    echo "Създаден е скрипт ~/.termux/boot/start-sshd"
    echo ""
    
    echo "=== НАСТРОЙКАТА ЗАВЪРШИ ==="
    echo "SSH услугата е настроена за автоматично стартиране:"
    echo "- При всяко стартиране на устройството (чрез Termux:Boot)"
    echo "- При всяко стартиране на Termux (чрез termux-services)"
    echo ""
    echo "Порт на SSH сървъра: 8022"
    echo "За да спрете услугата: sv down sshd"
    echo "За да деактивирате автоматичното стартиране: sv-disable sshd"
}

#----------------------------------------------------------#
# show ssh keys
#----------------------------------------------------------#
show_ssh_keys() {
    echo "=== ПРОВЕРКА НА SSH ПУБЛИЧНИ КЛЮЧОВЕ ==="
    echo ""
    
    # Проверка дали директорията .ssh съществува
    if [ ! -d ~/.ssh ]; then
        echo "Директорията ~/.ssh не съществува!"
        echo "Няма генерирани SSH ключове."
        return
    fi
    
    # Намиране на всички .pub файлове
    pub_files=$(find ~/.ssh -name "*.pub" -type f)
    
    if [ -z "$pub_files" ]; then
        echo "Няма намерени публични SSH ключове (.pub файлове) в ~/.ssh/"
        return
    fi
    
    # Брой на намерените файлове
    count=$(echo "$pub_files" | wc -l)
    echo "Намерени са $count публични SSH ключ(a) в ~/.ssh/:"
    echo ""
    
    # Показване на съдържанието на всеки файл
    i=1
    echo "$pub_files" | while read -r pub_file; do
        echo "--- Файл $i: $pub_file ---"
        echo "Съдържание:"
        cat "$pub_file"
        echo ""
        echo "--- Край на файл $i ---"
        echo ""
        i=$((i + 1))
    done
    
    # Показване на списък с всички файлове в .ssh
    echo "=== ВСИЧКИ ФАЙЛОВЕ В ~/.ssh/ ==="
    ls -la ~/.ssh/
}

#----------------------------------------------------------#
# add key to authorized_keys
#----------------------------------------------------------#
add_to_authorized_keys() {
    echo "=== Добавяне на ключ в authorized_keys ==="
    
    # Проверка дали директорията .ssh съществува
    if [ ! -d ~/.ssh ]; then
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
    fi
    
    # Проверка дали authorized_keys файла съществува, ако не - създаваме го
    if [ ! -f ~/.ssh/authorized_keys ]; then
        touch ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
        echo "Създаден е нов файл ~/.ssh/authorized_keys"
    fi
    
    echo "Въведете SSH публичния ключ (целия ред):"
    read ssh_key
    
    if [ -n "$ssh_key" ]; then
        # Добавяне на ключа в authorized_keys
        echo "$ssh_key" >> ~/.ssh/authorized_keys
        echo "Ключът е добавен успешно в ~/.ssh/authorized_keys"
        
        # Показване на съдържанието на authorized_keys
        echo ""
        echo "Съдържание на authorized_keys:"
        echo "================================"
        cat ~/.ssh/authorized_keys
        echo "================================"
    else
        echo "Не сте въвели ключ!"
    fi
}

while true; do
    show_menu
    read -p "Изберете опция [0-5]: " choice
    case $choice in
        #----------------------------------------------------------#
        # install openssh
        #----------------------------------------------------------#    
        1)
            install_ssh
            ;;
        #----------------------------------------------------------#
        # set password and ssh-key
        #----------------------------------------------------------#    
        2)
            set_password_and_sshkey
            ;;
        #----------------------------------------------------------#
        # setup termux boot and services
        #----------------------------------------------------------#
        3)
            setup_boot_services
            ;;
        #----------------------------------------------------------#
        # show ssh keys
        #----------------------------------------------------------#
        4)
            show_ssh_keys
            ;;
        #----------------------------------------------------------#
        # add key to authorized_keys
        #----------------------------------------------------------#
        5)
            add_to_authorized_keys
            ;;
        0)
            echo "Довиждане!"
            exit 0
            ;;
        *)
            echo "Невалиден избор! Моля опитайте отново."
            ;;
    esac
    echo
    read -p "Натиснете Enter за да продължите..."
    echo
done