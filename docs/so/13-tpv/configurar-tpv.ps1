#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Tareas 13 y 15 · Bastiona un TPV de barra con Windows 10 (Pro o IoT Enterprise LTSC).

.DESCRIPTION
  Deja el equipo con mínimos privilegios y seguridad por defecto (requisitos RT-04 a RT-06 de la tarea 7):
    1. Nombre del equipo (TPV1 / TPV2).
    2. Cuenta estándar "cajero" (sin administrador) y política de contraseñas.
    3. UAC: un usuario estándar no puede elevar; la cuenta integrada Administrador e Invitado, desactivadas.
    4. USB de almacenamiento bloqueado (teclado, ratón, pantalla táctil e impresora siguen funcionando).
    5. Firewall: entrada bloqueada y salida solo a Odoo, DNS, DHCP y actualizaciones (RT-06).
    6. Microsoft Edge limitado al TPV de Odoo (lista blanca de URL, sin descargas, sin herramientas de desarrollo).
    7. Windows Update y Defender activos; actualizaciones a las 3:00 sin reiniciar con la sesión abierta.
    8. Sin Escritorio remoto, sin SMBv1, sin reproducción automática y sin suspensión.
  El modo quiosco (Acceso asignado) se configura después a mano, en 2 minutos (DOCUMENTACION.md, paso 4).

  Con -CertificadoOdoo, instala además el certificado del proxy HTTPS de Odoo (tarea 52) como raíz de confianza.

  Es idempotente: se puede ejecutar varias veces. Guarda un registro en C:\ProgramData\AlmiChain\.

.EXAMPLE
  Set-ExecutionPolicy -Scope Process Bypass
  .\configurar-tpv.ps1 -NumeroTpv 1

.EXAMPLE
  .\configurar-tpv.ps1 -NumeroTpv 2 -CertificadoOdoo .\odoo.crt
#>
param(
    [Parameter(Mandatory)] [ValidateSet(1, 2)] [int] $NumeroTpv,
    [string] $Servidor = '192.168.10.10',     # servidor Odoo (tarea 23)
    [string] $Router = '192.168.10.1',        # puerta de enlace y DNS
    [int[]]  $PuertosOdoo = @(8069, 443),     # 443 cuando esté el proxy HTTPS (tarea 52)
    [string] $UsuarioCajero = 'cajero',
    [string] $CertificadoOdoo                 # odoo.crt del proxy HTTPS (tarea 52), opcional
)

$ErrorActionPreference = 'Stop'
$GrupoReglas = 'Almi-Chain TPV'
New-Item -ItemType Directory -Force -Path 'C:\ProgramData\AlmiChain' | Out-Null
Start-Transcript -Path "C:\ProgramData\AlmiChain\configurar-tpv-$(Get-Date -Format yyyyMMdd-HHmmss).log" | Out-Null

function Paso([string] $texto) { Write-Host "`n==> $texto" -ForegroundColor Cyan }
function Poner-Registro([string] $ruta, [string] $nombre, $valor, [string] $tipo = 'DWord') {
    if (-not (Test-Path $ruta)) { New-Item -Path $ruta -Force | Out-Null }
    New-ItemProperty -Path $ruta -Name $nombre -Value $valor -PropertyType $tipo -Force | Out-Null
}

# ---------------------------------------------------------------------------
Paso '0/8 Comprobaciones previas'
$so = Get-CimInstance Win32_OperatingSystem
Write-Host "  Sistema: $($so.Caption) $($so.Version)"
if ($so.Caption -notmatch 'Windows 10') { Write-Warning 'No es Windows 10: el enunciado pide Windows 10 en los TPV.' }
if ($so.Caption -match 'Home') { throw 'Windows Home no tiene Acceso asignado ni directivas: hace falta Pro, Enterprise o IoT Enterprise.' }

# ---------------------------------------------------------------------------
Paso "1/8 Nombre del equipo: TPV$NumeroTpv"
$nombre = "TPV$NumeroTpv"
if ($env:COMPUTERNAME -ne $nombre) {
    Rename-Computer -NewName $nombre -Force
    Write-Host "  Cambiado (se aplica al reiniciar)."
} else { Write-Host '  Ya se llama así.' }

# ---------------------------------------------------------------------------
Paso "2/8 Cuenta estándar '$UsuarioCajero' y política de contraseñas"
if (-not (Get-LocalUser -Name $UsuarioCajero -ErrorAction SilentlyContinue)) {
    $clave = Read-Host "Contraseña para '$UsuarioCajero' (generada en KeePassXC)" -AsSecureString
    New-LocalUser -Name $UsuarioCajero -Password $clave -FullName 'Cajero de barra' `
        -Description 'Uso diario del TPV (sin administrador)' -PasswordNeverExpires | Out-Null
    Add-LocalGroupMember -Group (Get-LocalGroup -SID 'S-1-5-32-545') -Member $UsuarioCajero   # Usuarios
    Write-Host '  Creada.'
} else { Write-Host '  Ya existe.' }
# Nunca en Administradores (SID S-1-5-32-544: el nombre del grupo cambia con el idioma)
$admins = Get-LocalGroup -SID 'S-1-5-32-544'
if (Get-LocalGroupMember -Group $admins | Where-Object Name -like "*\$UsuarioCajero") {
    Remove-LocalGroupMember -Group $admins -Member $UsuarioCajero
    Write-Host "  Quitada de Administradores."
}
net accounts /minpwlen:12 /lockoutthreshold:10 /lockoutwindow:15 /lockoutduration:15 | Out-Null
Write-Host '  Contraseñas de 12 caracteres como mínimo; bloqueo tras 10 intentos durante 15 min.'

# ---------------------------------------------------------------------------
Paso '3/8 UAC, Administrador integrado e Invitado'
$uac = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Poner-Registro $uac 'EnableLUA' 1
Poner-Registro $uac 'ConsentPromptBehaviorAdmin' 2      # el administrador confirma en el escritorio seguro
Poner-Registro $uac 'ConsentPromptBehaviorUser' 0       # un usuario estándar no puede elevar: se deniega sin preguntar
Poner-Registro $uac 'PromptOnSecureDesktop' 1
foreach ($sid in @('-500', '-501')) {                    # Administrador e Invitado integrados
    Get-LocalUser | Where-Object { $_.SID.Value.EndsWith($sid) -and $_.Enabled } | Disable-LocalUser
}
Write-Host '  UAC activo; Administrador e Invitado integrados desactivados.'

# ---------------------------------------------------------------------------
Paso '4/8 USB de almacenamiento bloqueado (RT-05)'
Poner-Registro 'HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR' 'Start' 4
Poner-Registro 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices' 'Deny_All' 1
Poner-Registro 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoDriveTypeAutoRun' 255
Write-Host '  Memorias y discos USB no se montan; reproducción automática desactivada.'

# ---------------------------------------------------------------------------
Paso '5/8 Firewall: entrada bloqueada y salida solo a lo necesario (RT-06)'
Get-NetFirewallRule -Group $GrupoReglas -ErrorAction SilentlyContinue | Remove-NetFirewallRule
$reglas = @(
    @{ DisplayName = 'TPV · Edge al servidor Odoo'; Program = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
       Protocol = 'TCP'; RemoteAddress = $Servidor; RemotePort = $PuertosOdoo }
    @{ DisplayName = 'TPV · DNS al router (UDP)'; Service = 'Dnscache'; Protocol = 'UDP'; RemoteAddress = $Router; RemotePort = 53 }
    @{ DisplayName = 'TPV · DNS al router (TCP)'; Service = 'Dnscache'; Protocol = 'TCP'; RemoteAddress = $Router; RemotePort = 53 }
    @{ DisplayName = 'TPV · DHCP'; Service = 'Dhcp'; Protocol = 'UDP'; RemotePort = 67 }
    @{ DisplayName = 'TPV · Hora (NTP)'; Service = 'W32Time'; Protocol = 'UDP'; RemotePort = 123 }
)
# Actualizaciones de Windows, Defender y Edge: solo HTTP/HTTPS y solo esos servicios
foreach ($servicio in 'wuauserv', 'BITS', 'UsoSvc', 'DoSvc', 'CryptSvc', 'WinDefend', 'edgeupdate') {
    $reglas += @{ DisplayName = "TPV · Actualizaciones ($servicio)"; Service = $servicio; Protocol = 'TCP'; RemotePort = @(80, 443) }
}
foreach ($r in $reglas) {
    New-NetFirewallRule @r -Direction Outbound -Action Allow -Group $GrupoReglas -Profile Any | Out-Null
    Write-Host "  + $($r.DisplayName)"
}
Set-NetFirewallProfile -Profile Domain, Private, Public -Enabled True `
    -DefaultInboundAction Block -DefaultOutboundAction Block -NotifyOnListen False
Write-Host '  Perfiles activos: todo lo que no está en la lista se bloquea, en los dos sentidos.'

# ---------------------------------------------------------------------------
Paso '6/8 Microsoft Edge limitado al TPV de Odoo'
$edge = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
Remove-Item "$edge\URLAllowlist", "$edge\URLBlocklist" -Recurse -Force -ErrorAction SilentlyContinue
Poner-Registro "$edge\URLBlocklist" '1' '*' 'String'                         # todo bloqueado…
$i = 1
foreach ($puerto in $PuertosOdoo) {
    $esquema = if ($puerto -eq 443) { 'https' } else { 'http' }
    $url = if ($puerto -eq 443) { "https://$Servidor" } else { "$($esquema)://$($Servidor):$puerto" }
    Poner-Registro "$edge\URLAllowlist" "$i" $url 'String'                   # …salvo Odoo
    $i++
}
Poner-Registro $edge 'DeveloperToolsAvailability' 2      # sin herramientas de desarrollo
Poner-Registro $edge 'InPrivateModeAvailability' 1       # sin InPrivate
Poner-Registro $edge 'DownloadRestrictions' 3            # sin descargas
Poner-Registro $edge 'PasswordManagerEnabled' 0          # no guarda la contraseña del cajero de Odoo
Poner-Registro $edge 'BrowserSignin' 0
Poner-Registro $edge 'SyncDisabled' 1
Poner-Registro $edge 'AutofillCreditCardEnabled' 0
Poner-Registro $edge 'HideFirstRunExperience' 1
Poner-Registro "$edge\ExtensionInstallBlocklist" '1' '*' 'String'
Write-Host "  Solo abre $(($PuertosOdoo | ForEach-Object { "$($Servidor):$_" }) -join ', ')."

# ---------------------------------------------------------------------------
Paso '7/8 Windows Update y Microsoft Defender'
$wu = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
Poner-Registro $wu 'NoAutoUpdate' 0
Poner-Registro $wu 'AUOptions' 4                          # descargar e instalar automáticamente…
Poner-Registro $wu 'ScheduledInstallDay' 0                # …todos los días…
Poner-Registro $wu 'ScheduledInstallTime' 3               # …a las 3:00, con el local cerrado
Poner-Registro $wu 'NoAutoRebootWithLoggedOnUsers' 1      # nunca reinicia en mitad de un cobro
Set-Service wuauserv -StartupType Manual                   # lo arranca Windows cuando hace falta
Set-MpPreference -DisableRealtimeMonitoring $false -PUAProtection Enabled
Write-Host '  Actualizaciones diarias a las 3:00; Defender en tiempo real y contra aplicaciones no deseadas.'

# ---------------------------------------------------------------------------
Paso '8/8 Servicios y energía'
Poner-Registro 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' 'fDenyTSConnections' 1
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue | Out-Null
powercfg /change standby-timeout-ac 0
powercfg /change monitor-timeout-ac 30
Write-Host '  Escritorio remoto y SMBv1 desactivados; el TPV no se suspende (la pantalla se apaga a los 30 min).'

if ($CertificadoOdoo) {
    Paso 'Extra: certificado del proxy HTTPS de Odoo (tarea 52)'
    $cert = Import-Certificate -FilePath $CertificadoOdoo -CertStoreLocation Cert:\LocalMachine\Root
    Write-Host "  Instalado como raíz de confianza. Huella: $($cert.Thumbprint) (comprobarla con la que dio activar-https.sh)"
}

Write-Host "`nListo. Siguiente: modo quiosco (DOCUMENTACION.md, paso 4), reiniciar y ejecutar comprobar-tpv.ps1." -ForegroundColor Green
Stop-Transcript | Out-Null
