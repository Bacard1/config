# ssh_controller.ps1

function Show-Menu {
    Clear-Host
    Write-Host "===========================" -ForegroundColor Cyan
    Write-Host "  СИСТЕМНО МЕНЮ" -ForegroundColor Cyan
    Write-Host "===========================" -ForegroundColor Cyan
    Write-Host "1. Инсталиране на OpenSSH сървър" -ForegroundColor Yellow
    Write-Host "2. Задаване на парола и генериране на SSH ключ" -ForegroundColor Yellow
    Write-Host "3. Настройка на SSH услугата" -ForegroundColor Yellow
    Write-Host "4. Покажи SSH ключове" -ForegroundColor Yellow
    Write-Host "5. Добавяне на ключ в authorized_keys" -ForegroundColor Yellow
    Write-Host "6. Покажи статус на SSH услугата" -ForegroundColor Yellow
    Write-Host "7. Диагностика на SSH услугата" -ForegroundColor Magenta
    Write-Host "8. Коригиране на SSH услугата" -ForegroundColor Magenta
    Write-Host "9. ПЪЛНА РЕИНСТАЛАЦИЯ на OpenSSH" -ForegroundColor Red  # Променено на 99
    Write-Host "333. ДЕИНСТАЛАЦИЯ на OpenSSH" -ForegroundColor Red  # Променено на 99
    Write-Host "0. Изход" -ForegroundColor Red
    Write-Host ""
}
#----------------------------------------------------------#
# Check if SSH is installed (without admin rights)
#----------------------------------------------------------#
function Test-SSHInstalled {
    try {
        $service = Get-Service -Name sshd -ErrorAction SilentlyContinue
        return [bool]$service
    }
    catch {
        return $false
    }
}

#----------------------------------------------------------#
# Check admin rights
#----------------------------------------------------------#
function Test-AdminRights {
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

#----------------------------------------------------------#
# Enhanced Diagnose SSH Service Issues
#----------------------------------------------------------#
function Diagnose-SSHService {
    Write-Host "=== ДИАГНОСТИКА НА SSH УСЛУГАТА ===" -ForegroundColor Magenta
    
    # Проверка на услугата
    $service = Get-Service sshd -ErrorAction SilentlyContinue
    if (!$service) {
        Write-Host "SSH услугата не е намерена!" -ForegroundColor Red
        return $false
    }
    
    Write-Host "Информация за услугата:" -ForegroundColor Yellow
    Write-Host "  Име: $($service.Name)" -ForegroundColor Gray
    Write-Host "  Статус: $($service.Status)" -ForegroundColor Gray
    Write-Host "  Тип на стартиране: $($service.StartType)" -ForegroundColor Gray
    Write-Host "  DisplayName: $($service.DisplayName)" -ForegroundColor Gray
    
    # Проверка на пътя към изпълнимия файл
    try {
        $serviceInfo = Get-WmiObject -Class Win32_Service -Filter "Name='sshd'"
        Write-Host "  Път: $($serviceInfo.PathName)" -ForegroundColor Gray
        Write-Host "  Стартови параметри: $($serviceInfo.StartName)" -ForegroundColor Gray
    }
    catch {
        Write-Host "  Неуспешно взимане на информация за пътя" -ForegroundColor Red
    }
    
    # Проверка на конфигурационни файлове
    $sshConfigPath = "C:\ProgramData\ssh\sshd_config"
    if (Test-Path $sshConfigPath) {
        Write-Host "`nКонфигурационният файл съществува: $sshConfigPath" -ForegroundColor Green
        
        # Проверка за специфични настройки
        $configContent = Get-Content $sshConfigPath
        $portLine = $configContent | Where-Object { $_ -like "Port *" }
        $passwordAuth = $configContent | Where-Object { $_ -like "PasswordAuthentication *" }
        $pubkeyAuth = $configContent | Where-Object { $_ -like "PubkeyAuthentication *" }
        
        if ($portLine) {
            Write-Host "  Порт: $portLine" -ForegroundColor Gray
        }
        if ($passwordAuth) {
            Write-Host "  PasswordAuthentication: $passwordAuth" -ForegroundColor Gray
        }
        if ($pubkeyAuth) {
            Write-Host "  PubkeyAuthentication: $pubkeyAuth" -ForegroundColor Gray
        }
    } else {
        Write-Host "`nКонфигурационният файл НЕ съществува: $sshConfigPath" -ForegroundColor Red
    }
    
    # Проверка на хостов ключове
    $hostKeys = Get-ChildItem "C:\ProgramData\ssh\ssh_host_*" -ErrorAction SilentlyContinue
    if ($hostKeys) {
        Write-Host "`nНамерени хостов ключове: $($hostKeys.Count)" -ForegroundColor Green
        $hostKeys | ForEach-Object { Write-Host "  - $($_.Name) ($([math]::Round($_.Length/1024, 2)) KB)" -ForegroundColor Gray }
    } else {
        Write-Host "`nНяма намерени хостов ключове!" -ForegroundColor Red
    }
    
    # Проверка на firewall правило
    $firewallRule = Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue
    if ($firewallRule) {
        Write-Host "`nFirewall правило: Enabled ($($firewallRule.Enabled))" -ForegroundColor Green
    } else {
        Write-Host "`nFirewall правило: Not configured" -ForegroundColor Red
    }
    
    # Проверка на permissions в ProgramData\ssh
    Write-Host "`nПроверка на permissions..." -ForegroundColor Yellow
    $sshDir = "C:\ProgramData\ssh"
    if (Test-Path $sshDir) {
        try {
            $acl = Get-Acl $sshDir
            Write-Host "  Директорията $sshDir има правилните permissions" -ForegroundColor Green
        }
        catch {
            Write-Host "  Грешка при проверка на permissions: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Детайлна проверка на event logs
    Write-Host "`nПроверка на event logs за SSH грешки..." -ForegroundColor Yellow
    try {
        # Проверка в System log
        $systemEvents = Get-WinEvent -LogName System -MaxEvents 10 -ErrorAction SilentlyContinue | 
                       Where-Object { $_.TimeCreated -gt (Get-Date).AddMinutes(-10) -and 
                                     ($_.ProviderName -like "*ssh*" -or $_.Message -like "*ssh*" -or $_.Id -in @(7000, 7001, 7023, 7024, 7026)) }
        
        if ($systemEvents) {
            Write-Host "  Намерени събития в System log:" -ForegroundColor Yellow
            foreach ($event in $systemEvents) {
                $cleanMessage = $event.Message -replace "`n", " " -replace "`r", ""
                Write-Host "    [$($event.TimeCreated.ToString('HH:mm:ss'))] $($event.ProviderName): $cleanMessage" -ForegroundColor Gray 
            }
        } else {
            Write-Host "  Няма SSH-related събития в System log" -ForegroundColor Gray
        }
        
        # Проверка в Application log
        $appEvents = Get-WinEvent -LogName Application -MaxEvents 10 -ErrorAction SilentlyContinue | 
                    Where-Object { $_.TimeCreated -gt (Get-Date).AddMinutes(-10) -and 
                                  ($_.ProviderName -like "*ssh*" -or $_.Message -like "*ssh*") }
        
        if ($appEvents) {
            Write-Host "  Намерени събития в Application log:" -ForegroundColor Yellow
            foreach ($event in $appEvents) {
                $cleanMessage = $event.Message -replace "`n", " " -replace "`r", ""
                Write-Host "    [$($event.TimeCreated.ToString('HH:mm:ss'))] $($event.ProviderName): $cleanMessage" -ForegroundColor Gray 
            }
        } else {
            Write-Host "  Няма SSH-related събития в Application log" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "  Неуспешно четене на event logs: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Опит за стартиране и наблюдение
    Write-Host "`nОпит за стартиране на услугата с наблюдение..." -ForegroundColor Yellow
    try {
        # Запишете текущия статус
        $initialStatus = (Get-Service sshd).Status
        
        # Стартирайте услугата
        Start-Service sshd -ErrorAction Stop
        
        # Изчакайте малко
        Start-Sleep -Seconds 3
        
        # Проверете финалния статус
        $finalStatus = (Get-Service sshd).Status
        
        if ($finalStatus -eq "Running") {
            Write-Host "  Услугата стартира успешно и е в статус: $finalStatus" -ForegroundColor Green
            
            # Проверка дали процесът работи
            $process = Get-Process -Name sshd -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "  SSH процес е активен (PID: $($process.Id))" -ForegroundColor Green
            }
            
            return $true
        } else {
            Write-Host "  Услугата не успя да остане работеща. Текущ статус: $finalStatus" -ForegroundColor Red
            
            # Проверка за crash
            if ($initialStatus -eq "Stopped" -and $finalStatus -eq "Stopped") {
                Write-Host "  Услугата вероятно crash-ва веднага след стартиране" -ForegroundColor Red
            }
            
            return $false
        }
    }
    catch {
        Write-Host "  Грешка при стартиране: $($_.Exception.Message)" -ForegroundColor Red
        
        # Опит за стартиране чрез sc команда с повече детайли
        Write-Host "`nДетайлен опит за стартиране чрез sc команда..." -ForegroundColor Yellow
        try {
            $result = sc start sshd 2>&1
            Write-Host "  Резултат: $result" -ForegroundColor Gray
            
            # Изчакайте и проверете статуса
            Start-Sleep -Seconds 2
            $statusAfterSc = (Get-Service sshd).Status
            Write-Host "  Статус след sc команда: $statusAfterSc" -ForegroundColor Gray
            
            if ($statusAfterSc -eq "Running") {
                return $true
            }
        }
        catch {
            Write-Host "  Грешка при sc команда: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        return $false
    }
}

#----------------------------------------------------------#
# Fix SSH Service Issues
#----------------------------------------------------------#
function Fix-SSHService {
    Write-Host "=== ОПИТ ЗА КОРИГИРАНЕ НА SSH УСЛУГАТА ===" -ForegroundColor Magenta
    
    if (-NOT (Test-AdminRights)) {
        Write-Host "ГРЕШКА: Тази операция изисква администраторски права!" -ForegroundColor Red
        return $false
    }
    
    try {
        Write-Host "1. Спиране на услугата..." -ForegroundColor Gray
        Stop-Service sshd -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        
        Write-Host "2. Регенериране на хостов ключове..." -ForegroundColor Gray
        try {
            & "C:\Windows\System32\OpenSSH\ssh-keygen.exe" -A -f "C:\ProgramData\ssh"
            Write-Host "   Хост ключовете са регенерирани" -ForegroundColor Green
        }
        catch {
            Write-Host "   Грешка при регенериране на ключове: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        Write-Host "3. Проверка и поправка на конфигурацията..." -ForegroundColor Gray
        $configPath = "C:\ProgramData\ssh\sshd_config"
        if (Test-Path $configPath) {
            # Направете backup на текущата конфигурация
            $backupPath = "$configPath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Copy-Item $configPath $backupPath -Force
            Write-Host "   Backup създаден: $backupPath" -ForegroundColor Gray
            
            # Опитайте се да поправите често срещани проблеми
            $configContent = Get-Content $configPath
            $fixedConfig = @()
            $hasPort = $false
            $hasPasswordAuth = $false
            
            foreach ($line in $configContent) {
                if ($line -like "Port *") { $hasPort = $true }
                if ($line -like "PasswordAuthentication *") { $hasPasswordAuth = $true }
                
                # Коригиране на често срещани проблеми
                if ($line -eq "#PasswordAuthentication yes") {
                    $fixedConfig += "PasswordAuthentication yes"
                    $hasPasswordAuth = $true
                } elseif ($line -eq "#PubkeyAuthentication yes") {
                    $fixedConfig += "PubkeyAuthentication yes"
                } else {
                    $fixedConfig += $line
                }
            }
            
            # Добавете липсващи настройки
            if (-NOT $hasPort) {
                $fixedConfig += "Port 22"
            }
            if (-NOT $hasPasswordAuth) {
                $fixedConfig += "PasswordAuthentication yes"
            }
            
            # Запишете коригираната конфигурация
            $fixedConfig | Set-Content $configPath -Encoding UTF8
            Write-Host "   Конфигурацията е проверена и актуализирана" -ForegroundColor Green
        }
        
        Write-Host "4. Рестартиране на услугата..." -ForegroundColor Gray
        Start-Service sshd
        
        Start-Sleep -Seconds 3
        $finalStatus = (Get-Service sshd).Status
        
        if ($finalStatus -eq "Running") {
            Write-Host "`n✓ Услугата е успешно коригирана и работи!" -ForegroundColor Green
            return $true
        } else {
            Write-Host "`n⚠ Услугата все още не работи. Статус: $finalStatus" -ForegroundColor Red
            Write-Host "   Опитайте ръчно да проверите event logs" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "Грешка при опита за коригиране: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

#----------------------------------------------------------#
# Install OpenSSH Server
#----------------------------------------------------------#
function Install-SSH {
    Write-Host "=== ИНСТАЛИРАНЕ НА OPENSSH СЪРВЪР ===" -ForegroundColor Green
    
    # Проверка за администраторски права
    if (-NOT (Test-AdminRights)) {
        Write-Host "ГРЕШКА: Тази операция изисква администраторски права!" -ForegroundColor Red
        Write-Host "Моля, стартирайте PowerShell като администратор и опитайте отново." -ForegroundColor Yellow
        return
    }
    
    # Проверка дали вече е инсталиран
    if (Test-SSHInstalled) {
        Write-Host "OpenSSH сървърът вече е инсталиран." -ForegroundColor Yellow
        return
    }
    
    Write-Host "Инсталиране на OpenSSH сървър..." -ForegroundColor Yellow
    
    try {
        # Инсталиране на OpenSSH Server
        Write-Host "Добавяне на Windows Capability..." -ForegroundColor Gray
        $result = Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
        
        if ($result.Status -eq "Installed") {
            Write-Host "OpenSSH сървърът е инсталиран успешно!" -ForegroundColor Green
            
            # Основна настройка след инсталация
            Write-Host "`n=== ОСНОВНА НАСТРОЙКА ===" -ForegroundColor Green
            
            # Генериране на хостов ключове
            Write-Host "Генериране на хостов ключове..." -ForegroundColor Gray
            try {
                & "C:\Windows\System32\OpenSSH\ssh-keygen.exe" -A -f "C:\ProgramData\ssh"
                Write-Host "Хост ключовете са генерирани успешно." -ForegroundColor Green
            }
            catch {
                Write-Host "Грешка при генериране на хостов ключове: $($_.Exception.Message)" -ForegroundColor Red
            }
            
            # Стартиране на услугата
            Write-Host "Стартиране на SSH услугата..." -ForegroundColor Gray
            try {
                Start-Service sshd
                Write-Host "SSH услугата е стартирана." -ForegroundColor Green
            }
            catch {
                Write-Host "Грешка при стартиране на услугата: $($_.Exception.Message)" -ForegroundColor Red
            }
            
            # Задаване на автоматично стартиране
            Write-Host "Задаване на автоматично стартиране..." -ForegroundColor Gray
            Set-Service -Name sshd -StartupType 'Automatic'
            
            Write-Host "Настройката завърши успешно!" -ForegroundColor Green
        } else {
            Write-Host "Грешка при инсталацията. Статус: $($result.Status)" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Грешка при инсталацията: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Моля, проверете дали имате интернет връзка и необходимите права." -ForegroundColor Yellow
    }
}

#----------------------------------------------------------#
# Set password and generate SSH key
#----------------------------------------------------------#
function Set-Password-And-SSHKey {
    Write-Host "=== ЗАДАВАНЕ НА ПАРОЛА И SSH КЛЮЧ ===" -ForegroundColor Green
    
    # Задаване на парола за текущия потребител
    Write-Host "Задаване на парола за текущия потребител..." -ForegroundColor Yellow
    Write-Host "ЗАБЕЛЕЖКА: Това ще промени паролата на вашия Windows акаунт!" -ForegroundColor Red
    $confirm = Read-Host "Желаете ли да продължите? (да/не)"
    
    if ($confirm -notmatch '^[Дд]а|^[Yy]es|^[Yy]') {
        Write-Host "Промяната на паролата е пропусната." -ForegroundColor Yellow
    } else {
        try {
            net user $env:USERNAME *
            Write-Host "Паролата е променена успешно!" -ForegroundColor Green
        }
        catch {
            Write-Host "Грешка при промяна на паролата: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Генериране на SSH ключ
    Write-Host "`n=== ГЕНЕРИРАНЕ НА SSH КЛЮЧ ===" -ForegroundColor Green
    
    $sshPath = "$env:USERPROFILE\.ssh"
    
    # Създаване на .ssh директория ако не съществува
    if (!(Test-Path $sshPath)) {
        New-Item -ItemType Directory -Path $sshPath -Force | Out-Null
        Write-Host "Създадена е директория $sshPath" -ForegroundColor Gray
    }
    
    # Въвеждане на данни за ключа
    $keyName = Read-Host "Въведете име за ключа (по подразбиране: id_rsa)"
    if ([string]::IsNullOrWhiteSpace($keyName)) {
        $keyName = "id_rsa"
    }
    
    $comment = Read-Host "Въведете коментар за ключа (по подразбиране: $env:USERNAME@$env:COMPUTERNAME)"
    if ([string]::IsNullOrWhiteSpace($comment)) {
        $comment = "$env:USERNAME@$env:COMPUTERNAME"
    }
    
    $keyPath = "$sshPath\$keyName"
    
    # Проверка дали ключ вече съществува
    if (Test-Path "$keyPath") {
        Write-Host "ВНИМАНИЕ: Файл с име '$keyName' вече съществува!" -ForegroundColor Red
        $overwrite = Read-Host "Желаете ли да го презапишете? (да/не)"
        if ($overwrite -notmatch '^[Дд]а|^[Yy]es|^[Yy]') {
            Write-Host "Генерирането на ключ е отменено." -ForegroundColor Yellow
            return
        }
    }
    
    Write-Host "Генериране на SSH ключ във файл: $keyPath" -ForegroundColor Yellow
    
    try {
        # Генериране на RSA ключ
        ssh-keygen -t rsa -b 4096 -f $keyPath -C $comment -N '""'
        
        Write-Host "`nSSH ключът е генериран успешно!" -ForegroundColor Green
        Write-Host "Публичният ключ: ${keyPath}.pub" -ForegroundColor Yellow
        Write-Host "Частният ключ: $keyPath" -ForegroundColor Yellow
        
        # Показване на публичния ключ
        Write-Host "`nСъдържание на публичния ключ:" -ForegroundColor Cyan
        Get-Content "${keyPath}.pub" | Write-Host -ForegroundColor White
        
        # Копиране в clipboard ако е наличен
        try {
            Get-Content "${keyPath}.pub" | Set-Clipboard
            Write-Host "`nПубличният ключ е копиран в clipboard!" -ForegroundColor Green
        }
        catch {
            Write-Host "`nСъдържанието на публичния ключ е показано по-горе." -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "Грешка при генериране на ключа: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Уверете се, че ssh-keygen е наличен в PATH." -ForegroundColor Yellow
    }
}

#----------------------------------------------------------#
# Setup SSH service
#----------------------------------------------------------#
function Setup-SSHService {
    Write-Host "=== НАСТРОЙКА НА SSH УСЛУГАТА ===" -ForegroundColor Green
    
    # Проверка за администраторски права
    if (-NOT (Test-AdminRights)) {
        Write-Host "ГРЕШКА: Тази операция изисква администраторски права!" -ForegroundColor Red
        Write-Host "Моля, стартирайте PowerShell като администратор и опитайте отново." -ForegroundColor Yellow
        return
    }
    
    # Проверка дали SSH сървърът е инсталиран
    if (-NOT (Test-SSHInstalled)) {
        Write-Host "OpenSSH сървърът не е инсталиран." -ForegroundColor Red
        Write-Host "Желаете ли да го инсталирате сега? (да/не)" -ForegroundColor Yellow
        $installNow = Read-Host
        if ($installNow -match '^[Дд]а|^[Yy]es|^[Yy]') {
            Install-SSH
            return
        } else {
            Write-Host "Първо инсталирайте OpenSSH сървър (Опция 1)." -ForegroundColor Yellow
            return
        }
    }
    
    try {
        Write-Host "Конфигуриране на SSH услугата..." -ForegroundColor Yellow
        
        # Диагностика първо
        Write-Host "`nИзвършване на диагностика..." -ForegroundColor Cyan
        $diagnosisResult = Diagnose-SSHService
        
        if (-NOT $diagnosisResult) {
            Write-Host "`nИма проблеми с SSH услугата. Опит за автоматично коригиране..." -ForegroundColor Yellow
            
            # Опит за реинсталация на конфигурацията
            Write-Host "Реинсталиране на OpenSSH конфигурация..." -ForegroundColor Gray
            try {
                & "C:\Windows\System32\OpenSSH\ssh-keygen.exe" -A -f "C:\ProgramData\ssh"
                Write-Host "Хост ключовете са регенерирани." -ForegroundColor Green
            }
            catch {
                Write-Host "Грешка при регенериране на ключове: $($_.Exception.Message)" -ForegroundColor Red
            }
            
            # Рестартиране на услугата
            Write-Host "Рестартиране на услугата..." -ForegroundColor Gray
            try {
                Restart-Service sshd -Force
                Write-Host "Услугата е рестартирана." -ForegroundColor Green
            }
            catch {
                Write-Host "Грешка при рестартиране: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        # Стартиране на услугата
        Write-Host "`nСтартиране на SSH услугата..." -ForegroundColor Gray
        try {
            Start-Service sshd -ErrorAction Stop
            Write-Host "SSH услугата е стартирана успешно!" -ForegroundColor Green
        }
        catch {
            Write-Host "Грешка при стартиране на услугата: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Използвайте опция 7 за диагностика на проблема." -ForegroundColor Yellow
        }
        
        # Задаване на услугата да се стартира автоматично
        Write-Host "Задаване на автоматично стартиране..." -ForegroundColor Gray
        Set-Service -Name sshd -StartupType 'Automatic'
        
        # Конфигуриране на firewall правило
        Write-Host "Конфигуриране на Windows Firewall..." -ForegroundColor Gray
        if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
            New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
            Write-Host "Firewall правилото е създадено." -ForegroundColor Green
        } else {
            # Уверете се, че правилото е enabled
            Set-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -Enabled True
            Write-Host "Firewall правилото е активирано." -ForegroundColor Green
        }
        
        # Проверка на финалния статус
        Start-Sleep -Seconds 2
        $finalStatus = Get-Service sshd | Select-Object -ExpandProperty Status
        
        Write-Host "`nSSH услугата е настроена!" -ForegroundColor Green
        Write-Host "Порт: 22" -ForegroundColor Yellow
        Write-Host "Услуга: sshd" -ForegroundColor Yellow
        Write-Host "Статус: $finalStatus" -ForegroundColor $(if ($finalStatus -eq "Running") { "Green" } else { "Red" })
        
        if ($finalStatus -ne "Running") {
            Write-Host "`n⚠ Услугата не успя да се стартира автоматично." -ForegroundColor Red
            Write-Host "  Опитайте ръчно: Start-Service sshd" -ForegroundColor Yellow
            Write-Host "  Използвайте опция 7 за подробна диагностика" -ForegroundColor Yellow
        }
        
        Write-Host "`nКоманди за управление:" -ForegroundColor Cyan
        Write-Host "  Стартиране: Start-Service sshd" -ForegroundColor Gray
        Write-Host "  Спиране: Stop-Service sshd" -ForegroundColor Gray
        Write-Host "  Статус: Get-Service sshd" -ForegroundColor Gray
        Write-Host "  Рестартиране: Restart-Service sshd" -ForegroundColor Gray
        
    }
    catch {
        Write-Host "Грешка при настройката на услугата: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Опитайте да реинсталирате OpenSSH (Опция 1)" -ForegroundColor Yellow
    }
}

#----------------------------------------------------------#
# Show SSH keys
#----------------------------------------------------------#
function Show-SSHKeys {
    Write-Host "=== ПРОВЕРКА НА SSH КЛЮЧОВЕ ===" -ForegroundColor Green
    
    $sshPath = "$env:USERPROFILE\.ssh"
    
    if (!(Test-Path $sshPath)) {
        Write-Host "Директорията $sshPath не съществува!" -ForegroundColor Red
        Write-Host "Няма генерирани SSH ключове." -ForegroundColor Yellow
        return
    }
    
    # Намиране на всички .pub файлове
    $pubFiles = Get-ChildItem -Path $sshPath -Filter "*.pub" -File -ErrorAction SilentlyContinue
    
    if ($pubFiles.Count -eq 0) {
        Write-Host "Няма намерени публични SSH ключове (.pub файлове) в $sshPath" -ForegroundColor Yellow
    }
    else {
        Write-Host "Намерени са $($pubFiles.Count) публични SSH ключ(a):" -ForegroundColor Green
        Write-Host ""
        
        # Показване на съдържанието на всеки файл
        $i = 1
        foreach ($pubFile in $pubFiles) {
            Write-Host "--- Файл $i : $($pubFile.Name) ---" -ForegroundColor Cyan
            Write-Host "Пълен път: $($pubFile.FullName)" -ForegroundColor Gray
            Write-Host "Съдържание:" -ForegroundColor Yellow
            Get-Content $pubFile.FullName -ErrorAction SilentlyContinue | Write-Host -ForegroundColor White
            Write-Host "--- Край на файл $i ---" -ForegroundColor Cyan
            Write-Host ""
            $i++
        }
    }
    
    # Показване на всички файлове в .ssh директорията (без -Force параметър)
    Write-Host "=== ВСИЧКИ ФАЙЛОВЕ В $sshPath ===" -ForegroundColor Green
    try {
        # Използваме -ErrorAction SilentlyContinue вместо -Force
        $allFiles = Get-ChildItem -Path $sshPath -ErrorAction SilentlyContinue
        if ($allFiles) {
            $allFiles | Format-Table Name, Length, LastWriteTime -AutoSize
        } else {
            Write-Host "Не могат да бъдат показани файловете поради липса на права." -ForegroundColor Yellow
            Write-Host "Стартирайте PowerShell като администратор за пълен достъп." -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "Грешка при показване на файловете: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Нямате необходимите права за достъп до тази директория." -ForegroundColor Yellow
    }
}
#----------------------------------------------------------#
# Add key to authorized_keys
#----------------------------------------------------------#
function Add-To-AuthorizedKeys {
    Write-Host "=== ДОБАВЯНЕ НА КЛЮЧ В AUTHORIZED_KEYS ===" -ForegroundColor Green
    
    $sshPath = "$env:USERPROFILE\.ssh"
    $authKeysPath = "$sshPath\authorized_keys"
    
    # Създаване на .ssh директория ако не съществува
    if (!(Test-Path $sshPath)) {
        New-Item -ItemType Directory -Path $sshPath -Force | Out-Null
        Write-Host "Създадена е директория $sshPath" -ForegroundColor Yellow
    }
    
    # Създаване на authorized_keys файл ако не съществува
    if (!(Test-Path $authKeysPath)) {
        New-Item -ItemType File -Path $authKeysPath -Force | Out-Null
        Write-Host "Създаден е нов файл $authKeysPath" -ForegroundColor Yellow
    }
    
    Write-Host "Изберете източник на ключа:" -ForegroundColor Yellow
    Write-Host "1. Въвеждане на ръка" -ForegroundColor Gray
    Write-Host "2. Избор от съществуващ .pub файл" -ForegroundColor Gray
    
    $choice = Read-Host "`nИзберете опция [1-2]"
    
    switch ($choice) {
        "1" {
            Write-Host "Въведете SSH публичния ключ (целия ред):" -ForegroundColor Yellow
            $sshKey = Read-Host
        }
        "2" {
            $pubFiles = Get-ChildItem -Path $sshPath -Filter "*.pub" -File
            if ($pubFiles.Count -eq 0) {
                Write-Host "Няма намерени .pub файлове в $sshPath" -ForegroundColor Red
                return
            }
            
            Write-Host "`nНамерени .pub файлове:" -ForegroundColor Yellow
            $i = 1
            foreach ($file in $pubFiles) {
                Write-Host "$i. $($file.Name)" -ForegroundColor Gray
                $i++
            }
            
            $fileChoice = Read-Host "`nИзберете файл [1-$($pubFiles.Count)]"
            if ([int]::TryParse($fileChoice, [ref]$null) -and $fileChoice -ge 1 -and $fileChoice -le $pubFiles.Count) {
                $selectedFile = $pubFiles[$fileChoice - 1]
                $sshKey = Get-Content $selectedFile.FullName
                Write-Host "Избран файл: $($selectedFile.Name)" -ForegroundColor Green
            }
            else {
                Write-Host "Невалиден избор!" -ForegroundColor Red
                return
            }
        }
        default {
            Write-Host "Невалиден избор!" -ForegroundColor Red
            return
        }
    }
    
    if (![string]::IsNullOrWhiteSpace($sshKey)) {
        # Добавяне на ключа в authorized_keys
        Add-Content -Path $authKeysPath -Value $sshKey
        Write-Host "Ключът е добавен успешно в $authKeysPath" -ForegroundColor Green
        
        # Показване на съдържанието на authorized_keys
        Write-Host "`nСъдържание на authorized_keys:" -ForegroundColor Cyan
        Write-Host "================================" -ForegroundColor Cyan
        Get-Content $authKeysPath | Write-Host -ForegroundColor White
        Write-Host "================================" -ForegroundColor Cyan
    }
    else {
        Write-Host "Не сте въвели ключ!" -ForegroundColor Red
    }
}

#----------------------------------------------------------#
# Show SSH service status
#----------------------------------------------------------#
function Show-SSHStatus {
    Write-Host "=== СТАТУС НА SSH УСЛУГАТА ===" -ForegroundColor Green
    
    try {
        $service = Get-Service -Name sshd -ErrorAction SilentlyContinue
        
        if (!$service) {
            Write-Host "SSH услугата не е намерена." -ForegroundColor Red
            Write-Host "OpenSSH сървърът вероятно не е инсталиран." -ForegroundColor Yellow
            return
        }
        
        Write-Host "Име на услуга: $($service.Name)" -ForegroundColor Yellow
        Write-Host "Показвано име: $($service.DisplayName)" -ForegroundColor Yellow
        Write-Host "Статус: $($service.Status)" -ForegroundColor $(if ($service.Status -eq "Running") { "Green" } else { "Red" })
        Write-Host "Тип на стартиране: $($service.StartType)" -ForegroundColor Yellow
        
        # Проверка на firewall правило (изисква администраторски права)
        $isAdmin = Test-AdminRights
        if ($isAdmin) {
            $firewallRule = Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue
            if ($firewallRule) {
                Write-Host "Firewall правило: Enabled ($($firewallRule.Enabled))" -ForegroundColor Green
            } else {
                Write-Host "Firewall правило: Not configured" -ForegroundColor Red
            }
        }
        
        # Показване на SSH процес
        $process = Get-Process -Name sshd -ErrorAction SilentlyContinue
        if ($process) {
            Write-Host "SSH процес: Running (PID: $($process.Id))" -ForegroundColor Green
        } else {
            Write-Host "SSH процес: Not running" -ForegroundColor Red
        }
        
        # Допълнителна информация ако услугата е пусната
        if ($service.Status -eq "Running") {
            Write-Host "`nSSH сървърът е достъпен на:" -ForegroundColor Cyan
            Write-Host "  Порт: 22" -ForegroundColor Gray
            Write-Host "  Хост: $env:COMPUTERNAME" -ForegroundColor Gray
            Write-Host "  Потребител: $env:USERNAME" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "Грешка при проверка на статуса: $($_.Exception.Message)" -ForegroundColor Red
    }
}
#----------------------------------------------------------#
# Complete SSH Reinstall
#----------------------------------------------------------#
function Complete-SSH-Reinstall {
    Write-Host "=== ПЪЛНА РЕИНСТАЛАЦИЯ НА OPENSSH ===" -ForegroundColor Red
    Write-Host "ВНИМАНИЕ: Това ще премахне и преинсталира напълно OpenSSH!" -ForegroundColor Red
    
    if (-NOT (Test-AdminRights)) {
        Write-Host "ГРЕШКА: Тази операция изисква администраторски права!" -ForegroundColor Red
        return
    }
    
    $confirm = Read-Host "Сигурни ли сте, че искате да продължите? (да/не)"
    if ($confirm -notmatch '^[Дд]а|^[Yy]es|^[Yy]') {
        Write-Host "Операцията е отменена." -ForegroundColor Yellow
        return
    }
    
    try {
        Write-Host "`n1. Спиране на SSH услугата..." -ForegroundColor Gray
        Stop-Service sshd -Force -ErrorAction SilentlyContinue
        
        Write-Host "2. Деинсталиране на OpenSSH сървър..." -ForegroundColor Gray
        $result = Remove-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction SilentlyContinue
        if ($result) {
            Write-Host "   OpenSSH е деинсталиран" -ForegroundColor Green
        }
        
        Write-Host "3. Изчакване за чиста деинсталация..." -ForegroundColor Gray
        Start-Sleep -Seconds 5
        
        Write-Host "4. Премахване на конфигурационни файлове..." -ForegroundColor Gray
        $sshDir = "C:\ProgramData\ssh"
        if (Test-Path $sshDir) {
            # Направете backup само на authorized_keys ако съществува
            $authKeys = "$env:USERPROFILE\.ssh\authorized_keys"
            if (Test-Path $authKeys) {
                $backupPath = "$env:USERPROFILE\authorized_keys.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                Copy-Item $authKeys $backupPath -Force
                Write-Host "   Backup на authorized_keys: $backupPath" -ForegroundColor Gray
            }
            
            # Изтрийте старата директория
            Remove-Item $sshDir -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "   Старата конфигурация е изтрита" -ForegroundColor Green
        }
        
        Write-Host "5. Реинсталиране на OpenSSH сървър..." -ForegroundColor Gray
        $result = Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
        if ($result.Status -eq "Installed") {
            Write-Host "   OpenSSH е реинсталиран успешно!" -ForegroundColor Green
        } else {
            Write-Host "   Грешка при реинсталацията: $($result.Status)" -ForegroundColor Red
            return
        }
        
        Write-Host "6. Създаване на нова конфигурация..." -ForegroundColor Gray
        # Уверете се, че директорията съществува
        if (!(Test-Path $sshDir)) {
            New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
        }
        
        # Създайте чист конфигурационен файл
        $defaultConfig = @"
# OpenSSH Server Configuration
Port 22
AddressFamily any
ListenAddress 0.0.0.0
ListenAddress ::

# Authentication
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no
PermitRootLogin no

# Logging
SyslogFacility AUTH
LogLevel INFO

# Security
StrictModes yes
MaxAuthTries 3
MaxSessions 10

# Users and permissions
AllowUsers $env:USERNAME
"@
        
        $configPath = "$sshDir\sshd_config"
        $defaultConfig | Set-Content $configPath -Encoding UTF8
        Write-Host "   Нова конфигурация е създадена" -ForegroundColor Green
        
        Write-Host "7. Генериране на нови хостов ключове..." -ForegroundColor Gray
        try {
            # Променете директорията и изпълнете ssh-keygen
            Set-Location "C:\Windows\System32\OpenSSH"
            .\ssh-keygen.exe -A
            Write-Host "   Нови хостов ключове са генерирани" -ForegroundColor Green
        }
        catch {
            Write-Host "   Грешка при генериране на ключове: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "   Опит за алтернативно генериране..." -ForegroundColor Yellow
            # Алтернативен метод
            .\ssh-keygen.exe -t rsa -f "$sshDir\ssh_host_rsa_key" -N "" -q
            .\ssh-keygen.exe -t ecdsa -f "$sshDir\ssh_host_ecdsa_key" -N "" -q
            .\ssh-keygen.exe -t ed25519 -f "$sshDir\ssh_host_ed25519_key" -N "" -q
        }
        
        Write-Host "8. Стартиране на SSH услугата..." -ForegroundColor Gray
        Start-Service sshd
        Start-Sleep -Seconds 3
        
        $finalStatus = (Get-Service sshd).Status
        if ($finalStatus -eq "Running") {
            Write-Host "`n✓ OpenSSH е успешно реинсталиран и работи!" -ForegroundColor Green
        } else {
            Write-Host "`n⚠ Услугата все още не работи. Статус: $finalStatus" -ForegroundColor Red
            Write-Host "   Проверете ръчно: Get-Service sshd" -ForegroundColor Yellow
        }
        
        # Възстановете authorized_keys backup ако съществува
        $backupFiles = Get-ChildItem "$env:USERPROFILE\authorized_keys.backup_*" -ErrorAction SilentlyContinue
        if ($backupFiles) {
            $latestBackup = $backupFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            if (Test-Path $latestBackup.FullName) {
                Copy-Item $latestBackup.FullName "$env:USERPROFILE\.ssh\authorized_keys" -Force -ErrorAction SilentlyContinue
                Write-Host "   authorized_keys е възстановен от backup" -ForegroundColor Green
            }
        }
        
    }
    catch {
        Write-Host "Грешка при пълната реинсталация: $($_.Exception.Message)" -ForegroundColor Red
    }
}

#----------------------------------------------------------#
# Uninstall OpenSSH Server
#----------------------------------------------------------#
function Uninstall-SSH {
    Write-Host "=== ДЕИНСТАЛАЦИЯ НА OPENSSH СЪРВЪР ===" -ForegroundColor Red
    Write-Host "ВНИМАНИЕ: Тази операция ще премахне напълно OpenSSH сървъра!" -ForegroundColor Red
    Write-Host "Ще бъдат изтрити всички конфигурации и ключове." -ForegroundColor Yellow
    
    if (-NOT (Test-AdminRights)) {
        Write-Host "ГРЕШКА: Тази операция изисква администраторски права!" -ForegroundColor Red
        Write-Host "Моля, стартирайте PowerShell като администратор." -ForegroundColor Yellow
        return
    }
    
    Write-Host "`nПРЕДУПРЕЖДЕНИЕ:" -ForegroundColor Red
    Write-Host "• OpenSSH сървърът ще бъде премахнат" -ForegroundColor Yellow
    Write-Host "• SSH услугата ще бъде спряна и деактивирана" -ForegroundColor Yellow
    Write-Host "• Конфигурационните файлове ще бъдат изтрити" -ForegroundColor Yellow
    Write-Host "• Firewall правилото ще бъде премахнато" -ForegroundColor Yellow
    Write-Host "• Няма да можете да се свързвате по SSH към този сървър" -ForegroundColor Yellow
    
    $confirm1 = Read-Host "`nСигурни ли сте, че искате да продължите? (да/не)"
    if ($confirm1 -notmatch '^[Дд]а|^[Yy]es|^[Yy]') {
        Write-Host "Деинсталацията е отменена." -ForegroundColor Green
        return
    }
    
    # Допълнително потвърждение със специален код
    Write-Host "`n⚠️  КРИТИЧНО ПРЕДУПРЕЖДЕНИЕ ⚠️" -ForegroundColor Red
    Write-Host "Това действие е НЕОБРАТИМО!" -ForegroundColor Red
    Write-Host "Въведете код '333' за окончателно потвърждение: " -ForegroundColor Red -NoNewline
    $confirmCode = Read-Host
    
    if ($confirmCode -ne "333") {
        Write-Host "Деинсталацията е отменена." -ForegroundColor Green
        return
    }
    
    # Останалата част от функцията остава същата...
}

#----------------------------------------------------------#
# Main script loop
#----------------------------------------------------------#
function Main {
    # Показване на информация за правата
    $isAdmin = Test-AdminRights
    if ($isAdmin) {
        Write-Host "✓ Скриптът се изпълнява с администраторски права" -ForegroundColor Green
    } else {
        Write-Host "⚠ Скриптът НЕ се изпълнява с администраторски права" -ForegroundColor Yellow
        Write-Host "  Опции 1, 3, 7 и 8 ще изискват администраторски права" -ForegroundColor Gray
    }
    Write-Host ""
    
    do {
        Show-Menu
        $choice = Read-Host "Изберете опция [0-999]"
        
        switch ($choice) {
            "1" { Install-SSH }
            "2" { Set-Password-And-SSHKey }
            "3" { Setup-SSHService }
            "4" { Show-SSHKeys }
            "5" { Add-To-AuthorizedKeys }
            "6" { Show-SSHStatus }
            "7" { Diagnose-SSHService }
            "8" { Fix-SSHService }
            "9" { Complete-SSH-Reinstall }
            "333" { Uninstall-SSH }
            "0" { 
                Write-Host "Довиждане!" -ForegroundColor Green
                return 
            }
            default { 
                Write-Host "Невалиден избор! Моля опитайте отново." -ForegroundColor Red
            }
        }
        
        if ($choice -ne "0") {
            Write-Host ""
            Read-Host "Натиснете Enter за да продължите..."
        }
    } while ($choice -ne "0")
}

# Стартиране на основната функция
Main