# ============================================================================
# SSH Server - Instalacion Completa para Windows 10/11
# ============================================================================
# EJECUTAR COMO ADMINISTRADOR

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " INSTALACION COMPLETA DE SSH SERVER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "ERROR: Ejecuta como Administrador" -ForegroundColor Red
    Write-Host ""
    Write-Host "Click derecho en PowerShell -> Ejecutar como administrador" -ForegroundColor Yellow
    Read-Host "Enter para salir"
    exit 1
}

Write-Host "[OK] Ejecutando como Administrador" -ForegroundColor Green
Write-Host ""

# ============================================================================
# PASO 1: Verificar estado actual de OpenSSH
# ============================================================================
Write-Host "[1] Verificando estado de OpenSSH..." -ForegroundColor Yellow

$sshClient = Get-WindowsCapability -Online | Where-Object { $_.Name -like 'OpenSSH.Client*' }
$sshServer = Get-WindowsCapability -Online | Where-Object { $_.Name -like 'OpenSSH.Server*' }

Write-Host "  Cliente SSH: $($sshClient.State)" -ForegroundColor Gray
Write-Host "  Servidor SSH: $($sshServer.State)" -ForegroundColor Gray

# ============================================================================
# PASO 2: Instalar OpenSSH Server si no esta instalado
# ============================================================================
Write-Host ""
Write-Host "[2] Instalando OpenSSH Server..." -ForegroundColor Yellow

if ($sshServer.State -eq "Installed") {
    Write-Host "  Ya esta instalado" -ForegroundColor Green
} else {
    Write-Host "  Instalando (puede tardar 1-2 minutos)..." -ForegroundColor Yellow
    try {
        Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction Stop
        Write-Host "  Instalado correctamente" -ForegroundColor Green
    } catch {
        Write-Host "  Error instalando: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "  SOLUCION ALTERNATIVA:" -ForegroundColor Yellow
        Write-Host "  1. Ve a Configuracion -> Aplicaciones -> Caracteristicas opcionales" -ForegroundColor White
        Write-Host "  2. Busca 'OpenSSH' y agrega 'OpenSSH Server'" -ForegroundColor White
        Read-Host "Enter para salir"
        exit 1
    }
}

# ============================================================================
# PASO 3: Verificar que el servicio existe ahora
# ============================================================================
Write-Host ""
Write-Host "[3] Verificando servicio sshd..." -ForegroundColor Yellow

# Esperar un momento para que Windows registre el servicio
Start-Sleep -Seconds 3

$sshdService = Get-Service -Name sshd -ErrorAction SilentlyContinue

if (-not $sshdService) {
    Write-Host "  Servicio no encontrado, esperando registro..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    $sshdService = Get-Service -Name sshd -ErrorAction SilentlyContinue
}

if (-not $sshdService) {
    Write-Host "  ERROR: Servicio sshd no se registro" -ForegroundColor Red
    Write-Host ""
    Write-Host "  REINICIA WINDOWS y ejecuta este script de nuevo" -ForegroundColor Yellow
    Read-Host "Enter para salir"
    exit 1
}

Write-Host "  Servicio encontrado: $($sshdService.Status)" -ForegroundColor Green

# ============================================================================
# PASO 4: Configurar e iniciar servicio
# ============================================================================
Write-Host ""
Write-Host "[4] Configurando servicio SSH..." -ForegroundColor Yellow

try {
    # Configurar inicio automatico
    Set-Service -Name sshd -StartupType 'Automatic' -ErrorAction Stop
    Write-Host "  Inicio automatico configurado" -ForegroundColor Green

    # Iniciar servicio
    if ($sshdService.Status -ne "Running") {
        Start-Service sshd -ErrorAction Stop
        Write-Host "  Servicio iniciado" -ForegroundColor Green
    } else {
        Write-Host "  Servicio ya ejecutandose" -ForegroundColor Green
    }
} catch {
    Write-Host "  Error: $_" -ForegroundColor Red
}

# ============================================================================
# PASO 5: Configurar ssh-agent
# ============================================================================
Write-Host ""
Write-Host "[5] Configurando ssh-agent..." -ForegroundColor Yellow

$sshAgent = Get-Service -Name ssh-agent -ErrorAction SilentlyContinue
if ($sshAgent) {
    try {
        Set-Service -Name ssh-agent -StartupType 'Automatic' -ErrorAction SilentlyContinue
        Start-Service ssh-agent -ErrorAction SilentlyContinue
        Write-Host "  ssh-agent configurado" -ForegroundColor Green
    } catch {
        Write-Host "  ssh-agent no disponible (opcional)" -ForegroundColor Gray
    }
} else {
    Write-Host "  ssh-agent no instalado (opcional)" -ForegroundColor Gray
}

# ============================================================================
# PASO 6: Configurar Firewall
# ============================================================================
Write-Host ""
Write-Host "[6] Configurando firewall..." -ForegroundColor Yellow

$rule = Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue
if (-not $rule) {
    try {
        New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
        Write-Host "  Regla de firewall creada" -ForegroundColor Green
    } catch {
        Write-Host "  Error creando regla: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Regla ya existe" -ForegroundColor Green
}

# ============================================================================
# PASO 7: Configurar clave SSH de Termux
# ============================================================================
Write-Host ""
Write-Host "[7] Configurando clave SSH de Termux..." -ForegroundColor Yellow

$sshDir = "C:\Users\$env:USERNAME\.ssh"
$authKeys = "$sshDir\authorized_keys"

# Crear directorio .ssh si no existe
if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
    Write-Host "  Directorio .ssh creado" -ForegroundColor Green
}

# Verificar si la clave ya existe
$termuxKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID2E69ezD9SyfKotp9Su0PSLptX6bjt33OEpjfK8si termux@localhost"

if (Test-Path $authKeys) {
    $existingKeys = Get-Content $authKeys -Raw
    if ($existingKeys -like "*$termuxKey*") {
        Write-Host "  Clave de Termux ya configurada" -ForegroundColor Green
    } else {
        Add-Content -Path $authKeys -Value $termuxKey
        Write-Host "  Clave de Termux agregada" -ForegroundColor Green
    }
} else {
    Set-Content -Path $authKeys -Value $termuxKey
    Write-Host "  Archivo authorized_keys creado" -ForegroundColor Green
}

# Corregir permisos
try {
    $acl = Get-Acl $authKeys
    $acl.SetAccessRuleProtection($true, $false)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($env:USERNAME, "FullControl", "Allow")
    $acl.SetAccessRule($rule)
    $adminRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators", "FullControl", "Allow")
    $acl.SetAccessRule($adminRule)
    Set-Acl $authKeys $acl
    Write-Host "  Permisos configurados" -ForegroundColor Green
} catch {
    # Fallback a icacls
    icacls $authKeys /inheritance:r /grant "${env:USERNAME}:F" /grant "Administrators:F" 2>$null | Out-Null
    Write-Host "  Permisos configurados (icacls)" -ForegroundColor Green
}

# ============================================================================
# VERIFICACION FINAL
# ============================================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " VERIFICACION FINAL" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

$sshdFinal = Get-Service -Name sshd -ErrorAction SilentlyContinue
if ($sshdFinal -and $sshdFinal.Status -eq "Running") {
    Write-Host ""
    Write-Host " [OK] SSH Server ejecutandose!" -ForegroundColor Green
    Write-Host ""

    # Obtener IP local
    $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.*" } | Select-Object -First 1).IPAddress
    if (-not $ip) {
        $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.PrefixOrigin -eq "Dhcp" } | Select-Object -First 1).IPAddress
    }

    Write-Host "Desde Termux, conecta con:" -ForegroundColor White
    Write-Host ""
    Write-Host "  ssh $env:USERNAME@$ip" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Si pide password, usa tu password de Windows." -ForegroundColor Gray
    Write-Host "Con la clave SSH, deberia conectar sin password." -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host " [!] Servicio no esta corriendo" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Estado: $($sshdFinal.Status)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Intenta:" -ForegroundColor Yellow
    Write-Host "  Start-Service sshd" -ForegroundColor Cyan
}

Write-Host ""
Read-Host "Enter para salir"
