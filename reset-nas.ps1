# Executar como Administrador

# Verifica privilégios
$admin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $admin) {
    Write-Host "Execute este script como Administrador."
    exit
}


# Permitir logons Guest SMB
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" -Force | Out-Null

New-ItemProperty `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" `
    -Name "AllowInsecureGuestAuth" `
    -Value 1 `
    -PropertyType DWord `
    -Force | Out-Null

# Serviços

$services = @(
    "lmhosts",
    "LanmanWorkstation",
    "FDResPub",
    "fdPHost"
)

foreach ($service in $services) {
    try {
        Set-Service $service -StartupType Automatic
        Start-Service $service -ErrorAction SilentlyContinue
    }
    catch {}
}

# Limpa caches

ipconfig /flushdns | Out-Null
nbtstat -R | Out-Null
nbtstat -RR | Out-Null

#shutdown -r -t 0
