# Tarea 12 · BitLocker en C: sin TPM, con contraseña de arranque (PowerShell como administrador).
# Uso: powershell -ExecutionPolicy Bypass -File 12-bitlocker-sin-tpm.ps1 -Salida E:\
#   -Salida: carpeta FUERA de C: (USB o carpeta compartida) donde dejar la clave de recuperación y la evidencia.
# La clave de recuperación NO se muestra en pantalla: va a un fichero que se pasa a KeePassXC y se borra.
param([Parameter(Mandatory)][string]$Salida)
$ErrorActionPreference = 'Stop'
$cv = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
if ($cv.EditionID -match 'Core') { throw "Edicion $($cv.EditionID): Windows Home no trae BitLocker" }

# Directiva «Requerir autenticación adicional al iniciar» + «Permitir BitLocker sin un TPM compatible»
# (lo mismo que gpedit: Componentes de Windows > Cifrado de unidad BitLocker > Unidades del sistema operativo)
$k = 'HKLM:\SOFTWARE\Policies\Microsoft\FVE'; New-Item $k -Force | Out-Null
@{UseAdvancedStartup=1; EnableBDEWithNoTPM=1; UseTPM=2; UseTPMPIN=2; UseTPMKey=2; UseTPMKeyPIN=2}.GetEnumerator() |
  ForEach-Object { New-ItemProperty $k -Name $_.Key -Value $_.Value -PropertyType DWord -Force | Out-Null }
gpupdate /target:computer /force | Out-Null

$v = Get-BitLockerVolume C:
if (-not ($v.KeyProtector | Where-Object KeyProtectorType -eq 'Password')) {
  do {
    $a = Read-Host -AsSecureString 'Contrasena de ARRANQUE de BitLocker (minimo 8, la de KeePassXC)'
    $b = Read-Host -AsSecureString 'Repitela'
    $pa = [Runtime.InteropServices.Marshal]::PtrToStringBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($a))
    $pb = [Runtime.InteropServices.Marshal]::PtrToStringBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($b))
    $ok = ($pa -ceq $pb) -and $pa.Length -ge 8; $pa = $pb = $null
    if (-not $ok) { Write-Host 'No coinciden o tiene menos de 8 caracteres. Otra vez.' -ForegroundColor Yellow }
  } until ($ok)
  Enable-BitLocker -MountPoint C: -EncryptionMethod XtsAes256 -UsedSpaceOnly -SkipHardwareTest -PasswordProtector -Password $a | Out-Null
}
if (-not ((Get-BitLockerVolume C:).KeyProtector | Where-Object KeyProtectorType -eq 'RecoveryPassword')) {
  # -WarningAction: sin él, el cmdlet escribe la clave en pantalla como advertencia
  Add-BitLockerKeyProtector -MountPoint C: -RecoveryPasswordProtector -WarningAction SilentlyContinue *> $null
}
$rp = (Get-BitLockerVolume C:).KeyProtector | Where-Object KeyProtectorType -eq 'RecoveryPassword' | Select-Object -First 1
@("BitLocker C: $env:COMPUTERNAME ($(Get-Date -Format 'yyyy-MM-dd'))", "ID de la clave: $($rp.KeyProtectorId)",
  "Clave de recuperacion: $($rp.RecoveryPassword)") | Set-Content -Encoding utf8 (Join-Path $Salida 'CLAVE-RECUPERACION-BITLOCKER.txt')
$rp = $null
& { "# Tarea 12 · BitLocker en C: ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
    "Edicion: $($cv.EditionID)  Version: $($cv.DisplayVersion)  Compilacion: $($cv.CurrentBuild).$($cv.UBR)"
    manage-bde -status C:
    (Get-BitLockerVolume C:).KeyProtector | Format-Table KeyProtectorType, KeyProtectorId -AutoSize | Out-String
} | Set-Content -Encoding utf8 (Join-Path $Salida 'win-09-bitlocker-status.txt')
Write-Host "HECHO. Clave en $Salida (pasarla a KeePassXC y borrar el fichero). El cifrado sigue en segundo plano." -ForegroundColor Green
