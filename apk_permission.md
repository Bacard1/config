```bash
adb shell pm grant com.termux android.permission.FOREGROUND_SERVICE
adb shell pm grant com.termux android.permission.WAKE_LOCK
adb shell cmd appops set com.termux RUN_IN_BACKGROUND allow

```






1. Разрешаване на автоматично стартиране (boot):

```bash
adb shell pm enable com.termux
adb shell pm grant com.termux android.permission.RECEIVE_BOOT_COMPLETED

```

2. Задаване на разрешение за авто-стартиране:
   
```bash
adb shell cmd appops set com.termux BOOT_COMPLETED allow
adb shell cmd appops set com.termux START_FOREGROUND allow

```

3. Разрешаване на фоново изпълнение:

```bash
adb shell cmd appops set com.termux RUN_ANY_IN_BACKGROUND allow
adb shell cmd appops set com.termux RUN_IN_BACKGROUND allow

```

4. Разрешаване на всички необходими разрешения за автоматично стартиране:

```bash
adb shell pm grant com.termux android.permission.RECEIVE_BOOT_COMPLETED
adb shell cmd appops set com.termux BOOT_COMPLETED allow
adb shell cmd appops set com.termux START_FOREGROUND allow
adb shell cmd appops set com.termux WAKE_LOCK allow

```

5. Проверка на текущите разрешения:

```bash
adb shell cmd appops get com.termux

```

6. Активиране на приложението да се стартира при зареждане:

```bash
adb shell am broadcast -a android.intent.action.BOOT_COMPLETED -n com.termux/.app.BootReceiver

```

Важно:
Тези команди ще позволят на Termux да се стартира автоматично при зареждане на системата

Termux трябва да има създаден boot скрипт в ~/.termux/boot/ за да изпълнява команди при стартиране

Някои производители на Android може да имат допълнителни ограничения за авто-стартиране

_________________________________________________________________________________________________
_________________________________________________________________________________________________

1. Създаване на boot директорията:

```bash
mkdir -p ~/.termux/boot

```

2. Създаване на boot скрипт:
Създайте файл в директорията ~/.termux/boot/. Например, скрипт наречен startup:

```bash
nano ~/.termux/boot/startup

```

Или с echo:

```bash
echo '#!/data/data/com.termux/files/usr/bin/sh' > ~/.termux/boot/startup
echo '# Your startup commands here' >> ~/.termux/boot/startup
echo 'echo "Termux started at $(date)" > /data/data/com.termux/files/home/startup.log' >> ~/.termux/boot/startup

```

3. Примерен boot скрипт:
Ето по-полезен пример (~/.termux/boot/myservice):

```bash
#!/data/data/com.termux/files/usr/bin/sh
# Boot script for Termux

# Log startup
echo "$(date): Boot completed" >> /data/data/com.termux/files/home/boot.log

# Start your services here
# Example: Start a web server
# sshd &

# Example: Run a Python script
# python /data/data/com.termux/files/home/myscript.py &

# Example: Sync files
# rsync -av /path/to/source /path/to/destination &

```

4. Направете скрипта изпълним:

```bash
chmod +x ~/.termux/boot/myservice

```

5. Проверка на скриптовете:

```bash
ls -la ~/.termux/boot/

```

6. Чрез ADB команди (ако искате да създадете направо):
Можете да създадете скрипта директно чрез ADB:

```bash
adb shell "echo '#!/data/data/com.termux/files/usr/bin/sh' > /data/data/com.termux/files/home/.termux/boot/myscript"
adb shell "echo 'echo \\\"Boot completed\\\" > /data/data/com.termux/files/home/boot.log' >> /data/data/com.termux/files/home/.termux/boot/myscript"
adb shell "chmod +x /data/data/com.termux/files/home/.termux/boot/myscript"

```

7. Тестване на boot скрипта:
Ръчно тестване:

```bash
~/.termux/boot/myservice

```

8. Важни бележки:
Скриптовете трябва да започват с #!/data/data/com.termux/files/usr/bin/sh

Всички скриптове трябва да са изпълними (chmod +x)

Използвайте & в края на командите за да се изпълняват във фонов режим

Скриптовете се изпълняват автоматично при стартиране на устройството

9. Пример за Home Assistant скрипт:
Ако искате Termux да комуникира с Home Assistant при стартиране:

```bash
#!/data/data/com.termux/files/usr/bin/sh
# Home Assistant integration boot script

echo "$(date): HA Integration started" >> /data/data/com.termux/files/home/ha_boot.log

# Start your Home Assistant related services here
# python /data/data/com.termux/files/home/ha_bridge.py &

```

