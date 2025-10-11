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
    # add key to authorized_keys
    #----------------------------------------------------------#
    echo "3. Добавяне на ключ в authorized_keys"
    #----------------------------------------------------------#
    # setup termux boot and services
    #----------------------------------------------------------#
    echo "4. Настройка на Termux:Boot и услуги"
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

#----------------------------------------------------------#
# setup termux boot and services
#----------------------------------------------------------#
setup_boot_services() {
    echo "=== Настройка на Termux:Boot и услуги ==="
    echo ""
    
    # Информация за Termux:Boot
    echo "1. Информация за Termux:Boot инсталация"
    echo "2. Създаване на boot директория и скриптове"
    echo "3. Инсталиране на termux-services"
    echo "4. Управление на услуги (sshd и др.)"
    echo "5. Създаване на стартиращ скрипт за SSH"
    echo "0. Назад към главното меню"
    echo ""
    
    read -p "Изберете опция [0-5]: " boot_choice
    
    case $boot_choice in
        1)
            echo ""
            echo "=== ИНФОРМАЦИЯ ЗА TERMUX:BOOT ==="
            echo "1. Инсталирайте Termux:Boot от F-Droid"
            echo "2. Изключете оптимизациите за батерията за Termux и Termux:Boot"
            echo "3. Стартирайте Termux:Boot веднъж от иконката"
            echo "4. Създайте ~/.termux/boot/ директория"
            echo "5. Добавете скриптове в ~/.termux/boot/ за изпълнение при стартиране"
            echo ""
            echo "ВАЖНО: Не смесвайте инсталации от Google Play и F-Droid!"
            ;;
            
        2)
            echo ""
            echo ""
            echo "=== СЪЗДАВАНЕ НА BOOT ДИРЕКТОРИЯ ==="
            if [ ! -d ~/.termux/boot ]; then
                mkdir -p ~/.termux/boot
                echo "Създадена е директория ~/.termux/boot/"
            else
                echo "Директорията ~/.termux/boot/ вече съществува"
            fi
            echo "Добавете вашите скриптове в тази директория за изпълнение при стартиране"
            ;;
            
        3)
            echo ""
            echo "=== ИНСТАЛИРАНЕ НА TERMUX-SERVICES ==="
            pkg install termux-services -y
            echo ""
            echo "Стартирам service-daemon."
            service-daemon start
            echo "След рестартиране, можете да управлявате услугите с:"
            echo "  sv-enable <service>   - за постоянно включване"
            echo "  sv up <service>       - за еднократно стартиране"
            echo "  sv down <service>     - за спиране"
            echo "  sv-disable <service>  - за изключване"
            ;;
            
        4)
            while true; do
                echo ""
                echo "=== УПРАВЛЕНИЕ НА УСЛУГИ ==="
                echo "1. Активиране на sshd услуга"
                echo "2. Деактивиране на sshd услуга"
                echo "3. Стартиране на sshd услуга"
                echo "4. Спиране на sshd услуга"
                echo "5. Статус на услугите"
                echo "6. Стартиране на услуга по избор"
                echo "0. Назад"
                echo ""
                
                read -p "Изберете опция [0-6]: " service_choice
                
                case $service_choice in
                    1)
                        sv-enable sshd
                        echo "sshd услугата е активирана"
                        ;;
                    2)
                        sv-disable sshd
                        echo "sshd услугата е деактивирана"
                        ;;
                    3)
                        sv up sshd
                        echo "sshd услугата е стартирана"
                        ;;
                    4)
                        sv down sshd
                        echo "sshd услугата е спряна"
                        ;;
                    5)
                        echo "=== СТАТУС НА УСЛУГИТЕ ==="
                        sv status
                        ;;
                    6)
                        echo ""
                        echo "=== СТАРТИРАНЕ НА УСЛУГА ПО ИЗБОР ==="
                        echo "Някои възможни услуги:"
                        echo "  - sshd (SSH сървър)"
                        echo "  - ftpd (FTP сървър)"
                        echo "  - telnetd (Telnet сървър)"
                        echo "  - httpd (Apache web сървър)"
                        echo "  - nginx (Nginx web сървър)"
                        echo "  - mysqld (MariaDB/MySQL сървър)"
                        echo "  - postgres (PostgreSQL сървър)"
                        echo "  - tor (Tor услуга)"
                        echo ""
                        read -p "Въведете име на услугата: " service_name
                        
                        if [ -n "$service_name" ]; then
                            echo "Стартиране на услуга: $service_name"
                            sv up "$service_name"
                            echo "Статус на услугата $service_name:"
                            sv status "$service_name"
                        else
                            echo "Не сте въвели име на услуга!"
                        fi
                        ;;
                    0)
                        break
                        ;;
                    *)
                        echo "Невалиден избор!"
                        ;;
                esac
                
                echo
                read -p "Натиснете Enter за да продължите..."
                echo
            done
            ;;
            
        5)
            echo ""
            echo "=== СЪЗДАВАНЕ НА СТАРТИРАЩ СКРИПТ ЗА SSH ==="
            
            # Създаване на boot директория ако не съществува
            if [ ! -d ~/.termux/boot ]; then
                mkdir -p ~/.termux/boot
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
            echo "Съдържание на скрипта:"
            echo "======================"
            cat ~/.termux/boot/start-sshd
            echo "======================"
            echo ""
            echo "Този скрипт ще се изпълни при всяко стартиране на устройството"
            ;;
            
        0)
            return
            ;;
            
        *)
            echo "Невалиден избор!"
            ;;
    esac
}

while true; do
    show_menu
    read -p "Изберете опция [0-4]: " choice
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
        # add key to authorized_keys
        #----------------------------------------------------------#
        3)
            add_to_authorized_keys
            ;;
        #----------------------------------------------------------#
        # setup termux boot and services
        #----------------------------------------------------------#
        4)
            setup_boot_services
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