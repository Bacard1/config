# Създаване на SSH ключ за Termux с правилно име на потребителя

---
---

### Проблем 1: Ключът е създаден с различно име на потребителя до сега.
```bash

ssh-keygen -t ed25519 -f ~/.ssh/mitv_termux1 -C "mitv_termux1@mitv"
```

### Проблем 2: Ключът е създаден с грешен коментар
В момента имате:
```
u0_a143@localhost
```
А трябва:
```
mitv_termux1@mitv
```

## Коригирани стъпки:

### 1. Изтриване на стария ключ (ако е нужно)
```bash
rm ~/.ssh/mitv_termux1*
```

### 2. Създаване на ключ с ПРАВИЛНИЯ коментар
```bash
ssh-keygen -t ed25519 -f ~/.ssh/mitv_termux1 -C "mitv_termux1@mitv"
```

**Параметри:**
- `-t ed25519` - тип на криптирането
- `-f ~/.ssh/mitv_termux1` - име на файла
- `-C "mitv_termux1@mitv"` - коментар (името на потребителя)

### 3. Проверка на създадения ключ
```bash
cat ~/.ssh/mitv_termux1.pub
```

**Трябва да видите:**
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... mitv_termux1@mitv
```

### 4. Копиране на публичния ключ към Home Assistant
```bash
# Показване на ключа за копиране
cat ~/.ssh/mitv_termux1.pub
```

### 5. Създаване на конфигурационен файл
```bash
nano ~/ha_config.sh
```

Добавете:
```bash
#!/bin/bash
HA_HOST="192.168.50.122"  # IP на вашия HA сървър
HA_USER="root"            # или друг потребител
HA_PORT="8022"
HA_KEY="$HOME/.ssh/mitv_termux1"

ha_connect() {
    ssh -i $HA_KEY -p $HA_PORT $HA_USER@$HA_HOST "$@"
}

ha_sensors() {
    ha_connect "ha sensors list"
}

ha_info() {
    ha_connect "ha info"
}
```

### 6. Направете файла изпълним
```bash
chmod +x ~/ha_config.sh
source ~/ha_config.sh
```

### 7. Тестване на връзката
```bash
# Тестова команда
ha_info

# Или директно
ssh -i ~/.ssh/mitv_termux1 -p 8022 root@192.168.50.122 "ha info"
```

## Алтернативен подход - преименуване на ключа:

Ако не искате да създавате нов ключ, може да промените коментара:

### 1. Промяна на коментара в съществуващ ключ

```bash
# Копиране на публичния ключ с нов коментар
cat ~/.ssh/mitv_termux1.pub | sed 's/u0_a143@localhost/mitv_termux1@mitv/' > ~/.ssh/mitv_termux1_new.pub
```

### 2. Проверка
```bash
cat ~/.ssh/mitv_termux1_new.pub
```

## Важни бележки:

1. **Коментарът (-C параметър)** не влияе на сигурността, само улеснява идентификацията
2. **SSH ключовете** трябва да се добавят в `~/.ssh/authorized_keys` на Home Assistant сървъра
3. **Порт 8022** е портът на Termux, не на Home Assistant
4. За да достъпите Home Assistant, трябва да използвате правилния IP и порт на HA сървъра

Изберете един от подходите и ключът ще бъде създаден с правилното име на потребителя!