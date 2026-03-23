# ============================================================================
# Añadir Clave SSH Correcta de Termux
# ============================================================================

Write-Host "`n🔑 Actualizando clave SSH de Termux..." -ForegroundColor Cyan

$username = $env:USERNAME
$sshDir = "C:\Users\$username\.ssh"
$authKeysFile = "$sshDir\authorized_keys"

# Tu clave pública CORRECTA de Termux
$termuxKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID2E69ezD9SyfKotp9Su0PSLptX6bjt33OEpjfK8si termux@localhost"

try {
    # Crear directorio .ssh
    if (-not (Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
    }

    # Reemplazar el contenido con la clave correcta
    Set-Content -Path $authKeysFile -Value $termuxKey -Force
    Write-Host "✅ Clave SSH actualizada correctamente" -ForegroundColor Green

    # Establecer permisos
    icacls $authKeysFile /inheritance:r /grant "${username}:F" | Out-Null
    Write-Host "✅ Permisos configurados" -ForegroundColor Green

    # Obtener IP de red local
    $localIP = Get-NetIPAddress -AddressFamily IPv4 |
        Where-Object { $_.IPAddress -like "192.168.*" } |
        Select-Object -First 1 -ExpandProperty IPAddress

    Write-Host "`n============================================" -ForegroundColor Cyan
    Write-Host "✅ TODO LISTO PARA CONECTAR" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Cyan

    Write-Host "`nDesde Termux, ejecuta:" -ForegroundColor White
    Write-Host "  ssh $username@$localIP" -ForegroundColor Cyan
    Write-Host "`n(Sin contraseña, usará tu clave SSH)`n" -ForegroundColor Gray

} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}
