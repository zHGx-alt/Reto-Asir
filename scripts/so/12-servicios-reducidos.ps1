# Tarea 12 - Windows del gerente: desactiva los servicios que el despacho no necesita (rubrica ISO RA1, nivel 5:
# "el sistema queda endurecido (minimos privilegios, servicios reducidos)") y deja la evidencia antes/despues.
# Uso (PowerShell como administrador): powershell -ExecutionPolicy Bypass -File 12-servicios-reducidos.ps1 [-Salida C:\Users\admin\Desktop]
# Se puede repetir: los que ya estan desactivados o no existen se saltan.
param([string]$Salida = "$env:USERPROFILE\Desktop")
$ErrorActionPreference = 'Stop'

# Que se quita y por que. La cola de impresion (Spooler) se queda: el gerente imprime.
$quitar = [ordered]@{
  'XblAuthManager' = 'Xbox Live: inicio de sesion de juegos'
  'XblGameSave'    = 'Xbox Live: partidas guardadas'
  'XboxNetApiSvc'  = 'Xbox Live: red'
  'XboxGipSvc'     = 'Accesorios de Xbox'
  'Fax'            = 'Fax: no hay linea de fax'
  'WMPNetworkSvc'  = 'Compartir la biblioteca de Windows Media Player en red'
  'MapsBroker'     = 'Descarga de mapas sin conexion'
  'lfsvc'          = 'Geolocalizacion del equipo'
  'RetailDemo'     = 'Modo demostracion de tienda'
  'RemoteRegistry' = 'Editar el registro desde otro equipo'
  'SharedAccess'   = 'Compartir la conexion a Internet (ICS)'
  'DiagTrack'      = 'Telemetria (Experiencias del usuario y telemetria asociadas)'
}

function Activos { Get-Service | Where-Object { $_.StartType -ne 'Disabled' } | Sort-Object Name |
  Select-Object Name, DisplayName, StartType, Status }

$antes = Activos
$hechos = foreach ($n in $quitar.Keys) {
  $s = Get-Service -Name $n -ErrorAction SilentlyContinue
  if ($s -and $s.StartType -ne 'Disabled') {
    if ($s.Status -eq 'Running') { Stop-Service -Name $n -Force -ErrorAction SilentlyContinue }
    Set-Service -Name $n -StartupType Disabled
    "$n ($($quitar[$n]))"
  }
}
$despues = Activos

$f = Join-Path $Salida 'win-14-servicios-reducidos.txt'
& {
  "# Tarea 12 - Windows del gerente: servicios reducidos ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
  ''; "## Servicios no deshabilitados ANTES ($($antes.Count))"; $antes | Format-Table -AutoSize | Out-String -Width 200
  "## Servicios no deshabilitados DESPUES ($($despues.Count))"; $despues | Format-Table -AutoSize | Out-String -Width 200
  '## Deshabilitados en esta ejecucion'; if ($hechos) { $hechos } else { '(ninguno: ya estaban deshabilitados o no existen)' }
  ''; '## Motivo de cada uno'; foreach ($n in $quitar.Keys) { "- ${n}: $($quitar[$n])" }
} | Out-File -FilePath $f -Encoding utf8
Write-Host "HECHO. Evidencia en $f"
