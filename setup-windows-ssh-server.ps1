# ============================================================================
# SSH Server - Post-DISM Service Registration
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " REGISTRANDO SERVICIO SSH MANUALMENTE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "ERROR: Ejecuta como Administrador" -ForegroundColor Red
    Read-Host "Enter para salir"
    exit 1
}

# Buscar sshd.exe
Write-Host "[1] Buscando sshd.exe..." -ForegroundColor Yellow
$sshdPaths = @(
    "$env:SystemRoot\System32\OpenSSH\sshd.exe",
    "$env:ProgramFiles\OpenSSH\sshd.exe",
    "${env:ProgramFiles(x86)}\OpenSSH\sshd.exe"
)

$sshdExe = $null
foreach ($path in $sshdPaths) {
    Write-Host "  Verificando: $path" -ForegroundColor Gray
    if (Test-Path $path) {
        $sshdExe = $path
        Write-Host "  ENCONTRADO: $path" -ForegroundColor Green
        break
    }
}

if (-not $sshdExe) {
    Write-Host ""
    Write-Host "  sshd.exe NO encontrado en rutas conocidas" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Buscando en todo el sistema (puede tardar)..." -ForegroundColor Yellow
    $found = Get-ChildItem -Path "C:\" -Recurse -Filter "sshd.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) {
        $sshdExe = $found.FullName
        Write-Host "  ENCONTRADO: $sshdExe" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Red
        Write-Host " SSHD.EXE NO ENCONTRADO" -ForegroundColor Red
        Write-Host "========================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "Opciones:" -ForegroundColor Yellow
        Write-Host "  1. REINICIA Windows y ejecuta este script de nuevo" -ForegroundColor White
        Write-Host "  2. Instala OpenSSH manualmente desde Configuracion" -ForegroundColor White
        Write-Host ""
        Read-Host "Enter para salir"
        exit 1
    }
}

# Verificar servicio existente
Write-Host ""
Write-Host "[2] Verificando servicio sshd..." -ForegroundColor Yellow
$sshd = Get-Service -Name sshd -ErrorAction SilentlyContinue

if ($sshd) {
    Write-Host "  Servicio ya existe: $($sshd.Status)" -ForegroundColor Green
} else {
    Write-Host "  Servicio no existe, registrando..." -ForegroundColor Yellow

    # Registrar servicio manualmente
    $sshdDir = Split-Path $sshdExe -Parent
    $configFile = Join-Path $sshdDir "sshd_config"

    Write-Host "  Ejecutando: $sshdExe install" -ForegroundColor Gray

    Push-Location $sshdDir
    $result = & $sshdExe install 2>&1
    Pop-Location

    Write-Host "  Resultado: $result" -ForegroundColor Gray

    Start-Sleep -Seconds 2
    $sshd = Get-Service -Name sshd -ErrorAction SilentlyContinue

    if ($sshd) {
        Write-Host "  Servicio registrado OK" -ForegroundColor Green
    } else {
        Write-Host "  Error registrando servicio" -ForegroundColor Red
        Write-Host ""
        Write-Host "  SOLUCION: REINICIA Windows" -ForegroundColor Yellow
        Read-Host "Enter para salir"
        exit 1
    }
}

# Iniciar servicio
Write-Host ""
Write-Host "[3] Iniciando servicio..." -ForegroundColor Yellow
try {
    if ($sshd.Status -ne "Running") {
        Start-Service sshd -ErrorAction Stop
        Write-Host "  Servicio iniciado OK" -ForegroundColor Green
    } else {
        Write-Host "  Ya esta ejecutandose" -ForegroundColor Green
    }
    Set-Service -Name sshd -StartupType 'Automatic'
    Write-Host "  Inicio automatico configurado" -ForegroundColor Green
} catch {
    Write-Host "  Error: $_" -ForegroundColor Red
}

# Firewall
Write-Host ""
Write-Host "[4] Configurando firewall..." -ForegroundColor Yellow
$rule = Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue
if (-not $rule) {
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
    Write-Host "  Regla creada" -ForegroundColor Green
} else {
    Write-Host "  Regla ya existe" -ForegroundColor Green
}

# Verificar clave SSH
Write-Host ""
Write-Host "[5] Verificando clave SSH de Termux..." -ForegroundColor Yellow
$authKeys = "C:\Users\$env:USERNAME\.ssh\authorized_keys"
if (Test-Path $authKeys) {
    Write-Host "  Clave configurada OK" -ForegroundColor Green
} else {
    Write-Host "  Clave no encontrada, configurando..." -ForegroundColor Yellow
    $termuxKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID2E69ezD9SyfKotp9Su0PSLptX6bjt33OEpjfK8si termux@localhost"
    New-Item -ItemType Directory -Path "C:\Users\$env:USERNAME\.ssh" -Force | Out-Null
    Set-Content -Path $authKeys -Value $termuxKey
    icacls $authKeys /inheritance:r /grant "${env:USERNAME}:F" | Out-Null
    Write-Host "  Clave configurada OK" -ForegroundColor Green
}

# Info final
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " CONFIGURACION COMPLETADA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.*" } | Select-Object -First 1).IPAddress
Write-Host ""
Write-Host "Desde Termux:" -ForegroundColor White
Write-Host "  ssh $env:USERNAME@$ip" -ForegroundColor Cyan
Write-Host ""

Read-Host "Enter para salir"
