<#
.SYNOPSIS
  Tareas 13 y 15 · Comprueba que un TPV cumple el bastionado de configurar-tpv.ps1.

.DESCRIPTION
  Solo lee: no cambia nada. Saca una tabla OK / FALLO por requisito de la tarea 7 y la guarda,
  si se indica, como evidencia. Se ejecuta como administrador (para leer el firewall y Defender).

.EXAMPLE
  .\comprobar-tpv.ps1 -Salida ..\..\evidencias\13-tpv\tpv1-comprobacion.txt
#>
param(
    [string] $Servidor = '192.168.10.10',
    [int]    $PuertoOdoo = 8069,
    [string] $UsuarioCajero = 'cajero',
    [string] $Salida
)

$resultados = [System.Collections.Generic.List[object]]::new()
function Comprobar([string] $req, [string] $que, [scriptblock] $prueba) {
    # Cada prueba devuelve @{ ok = <bool>; det = <texto> }
    try { $r = & $prueba } catch { $r = @{ ok = $false; det = "error: $($_.Exception.Message)" } }
    $resultados.Add([pscustomobject]@{
        Requisito = $req; Comprobacion = $que
        Resultado = if ($r.ok) { 'OK' } else { 'FALLO' }; Detalle = $r.det })
}
function Leer([string] $ruta, [string] $nombre) { (Get-ItemProperty -Path $ruta -Name $nombre -ErrorAction SilentlyContinue).$nombre }

$so = Get-CimInstance Win32_OperatingSystem
Comprobar 'Enunciado' 'Windows 10 Pro / Enterprise / IoT' {
    @{ ok = [bool](($so.Caption -match 'Windows 10') -and ($so.Caption -notmatch 'Home')); det = "$($so.Caption) $($so.Version)" } }
Comprobar 'Tarea 23' 'Nombre del equipo TPV1 o TPV2' { @{ ok = [bool]($env:COMPUTERNAME -match '^TPV[12]$'); det = $env:COMPUTERNAME } }

Comprobar 'RT-04' "Existe la cuenta '$UsuarioCajero' y está activa" {
    $u = Get-LocalUser -Name $UsuarioCajero -ErrorAction SilentlyContinue
    @{ ok = [bool]($u -and $u.Enabled); det = $(if ($u) { "activa: $($u.Enabled)" } else { 'no existe' }) } }
Comprobar 'RT-04' "'$UsuarioCajero' no es administrador" {
    $admins = Get-LocalGroupMember -Group (Get-LocalGroup -SID 'S-1-5-32-544') | ForEach-Object Name
    @{ ok = [bool](-not ($admins -like "*\$UsuarioCajero")); det = "Administradores: $($admins -join ', ')" } }
Comprobar 'RT-04' 'Un usuario estándar no puede elevar (UAC)' {
    $lua = Leer 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'EnableLUA'
    $usr = Leer 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'ConsentPromptBehaviorUser'
    @{ ok = [bool](($lua -eq 1) -and ($usr -eq 0)); det = "EnableLUA=$lua, ConsentPromptBehaviorUser=$usr" } }
Comprobar 'RT-04' 'Administrador e Invitado integrados desactivados' {
    $activas = Get-LocalUser | Where-Object { ($_.SID.Value -match '-50[01]$') -and $_.Enabled } | ForEach-Object Name
    @{ ok = [bool](-not $activas); det = $(if ($activas) { "activas: $($activas -join ', ')" } else { 'desactivadas' }) } }

Comprobar 'RT-05' 'USB de almacenamiento bloqueado' {
    $usb = Leer 'HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR' 'Start'
    $deny = Leer 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices' 'Deny_All'
    @{ ok = [bool](($usb -eq 4) -and ($deny -eq 1)); det = "USBSTOR Start=$usb, Deny_All=$deny" } }

Comprobar 'RT-06' 'Firewall activo y todo bloqueado por defecto' {
    $p = Get-NetFirewallProfile
    $bien = -not ($p | Where-Object { -not $_.Enabled -or $_.DefaultInboundAction -ne 'Block' -or $_.DefaultOutboundAction -ne 'Block' })
    @{ ok = [bool]($bien); det = ($p | ForEach-Object { "$($_.Name): $($_.Enabled)/$($_.DefaultInboundAction)/$($_.DefaultOutboundAction)" }) -join '; ' } }
Comprobar 'RT-06' 'Reglas de salida del TPV' {
    $n = @(Get-NetFirewallRule -Group 'Almi-Chain TPV' -ErrorAction SilentlyContinue).Count
    @{ ok = ($n -ge 12); det = "$n reglas en el grupo 'Almi-Chain TPV'" } }
Comprobar 'RT-06' 'Edge solo abre Odoo' {
    $bloq = Leer 'HKLM:\SOFTWARE\Policies\Microsoft\Edge\URLBlocklist' '1'
    $perm = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Edge\URLAllowlist' -ErrorAction SilentlyContinue).PSObject.Properties |
            Where-Object Name -match '^\d+$' | ForEach-Object Value
    @{ ok = [bool](($bloq -eq '*') -and ($perm -match [regex]::Escape($Servidor))); det = "bloqueado: $bloq; permitido: $($perm -join ', ')" } }
Comprobar 'RT-06' "Llega a Odoo ($($Servidor):$PuertoOdoo) desde Edge" {
    # PowerShell no tiene regla de salida: se comprueba que la regla de Edge apunta al servidor
    $r = Get-NetFirewallRule -Group 'Almi-Chain TPV' -ErrorAction SilentlyContinue | Where-Object DisplayName -like '*Odoo*'
    $dir = $r | Get-NetFirewallAddressFilter | ForEach-Object RemoteAddress
    @{ ok = [bool]($dir -contains $Servidor); det = "regla: $($r.DisplayName); destino: $dir" } }
Comprobar 'RT-06' 'Otra web no carga (PowerShell, sin regla, a 1.1.1.1:443)' {
    $ok = (Test-NetConnection 1.1.1.1 -Port 443 -WarningAction SilentlyContinue).TcpTestSucceeded
    @{ ok = [bool](-not $ok); det = "conexión: $ok" } }

Comprobar 'RG/RT' 'Windows Update automático' {
    $au = Leer 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'AUOptions'
    @{ ok = [bool]($au -eq 4); det = "AUOptions=$au" } }
Comprobar 'RG/RT' 'Defender en tiempo real' {
    $mp = Get-MpComputerStatus
    @{ ok = [bool]($mp.RealTimeProtectionEnabled); det = "tiempo real: $($mp.RealTimeProtectionEnabled); firmas: $($mp.AntivirusSignatureLastUpdated)" } }
Comprobar 'Seguridad' 'Escritorio remoto desactivado' {
    $rdp = Leer 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' 'fDenyTSConnections'
    @{ ok = [bool]($rdp -eq 1); det = "fDenyTSConnections=$rdp" } }
Comprobar 'RT-01' 'Modo quiosco (Acceso asignado) configurado' {
    $aa = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\AssignedAccessConfiguration\Profiles' -ErrorAction SilentlyContinue
    @{ ok = [bool]$aa; det = $(if ($aa) { "$(@($aa).Count) perfil(es)" } else { 'sin configurar (paso 4 de la guía)' }) } }

$tabla = $resultados | Format-Table -AutoSize -Wrap | Out-String -Width 200
$fallos = @($resultados | Where-Object Resultado -eq 'FALLO').Count
$resumen = "{0} comprobaciones: {1} OK, {2} FALLO · {3} · {4}" -f $resultados.Count, ($resultados.Count - $fallos), $fallos, $env:COMPUTERNAME, (Get-Date -Format 'dd/MM/yyyy HH:mm')
Write-Host $tabla
Write-Host $resumen -ForegroundColor $(if ($fallos) { 'Yellow' } else { 'Green' })
if ($Salida) {
    New-Item -ItemType Directory -Force -Path (Split-Path $Salida) | Out-Null
    "# Tareas 13 y 15 · comprobar-tpv.ps1`n$tabla`n$resumen" | Out-File -FilePath $Salida -Encoding utf8
    Write-Host "Guardado en $Salida"
}
exit [int]($fallos -gt 0)
