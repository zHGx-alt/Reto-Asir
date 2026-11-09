# Tarea 12: Arranque dual Windows 10 + Ubuntu en el equipo del gerente

- **Bloque:** 2 SO
- **Depende de:** tarea 8 (tabla de hardware)
- **Requisitos que cubre:** RG-01, RG-03, RG-04 y RG-05 (tarea 7, sección 3.1)
- **Reto:** Almi-Chain (ASIR1 2026-27)
- **Estado:** hecha en VM (actualizaciones y cifrado terminados el 29/10/2026)
- **Fecha:** 22/10/2026; actualizada el 29/10/2026

## 1. Alcance

El enunciado pide para el despacho del gerente un equipo con arranque dual Windows 10 y GNU/Linux, restringido con mínimos privilegios y configuración segura por defecto. Este documento explica cómo se ha instalado y configurado en una máquina virtual, qué se ha comprobado y dónde están las evidencias.

La distribución elegida es **Ubuntu Desktop LTS**: tiene soporte largo, instalador que detecta Windows y crea el arranque dual solo, y actualizaciones de seguridad automáticas de serie.

## 2. Entorno de pruebas

El equipo real (Lenovo ThinkCentre Neo 50q, tarea 8) se simula en una máquina virtual con menos recursos (supuesto S-07 de la tarea 7).

| Elemento | Valor |
|---|---|
| Hipervisor | VirtualBox 7.2 desde el 29/10. Se instaló en VMware Workstation y se migró el disco (sección 7) |
| Firmware | UEFI, disco GPT (como el equipo real) |
| CPU y memoria | 4 procesadores virtuales, 8 GB de RAM |
| Disco | 60 GB. En VMware, NVMe; en VirtualBox, **SATA** (con NVMe Windows no arranca, error 0xc0000001) |
| Teclado | **USB** en VirtualBox: con el PS/2 la pantalla de BitLocker no recibe las teclas |
| Red | NAT |
| Sistema 1 | **Windows 10 Pro 22H2**, compilación 19045.6456 (acumulativa de octubre de 2025) |
| Sistema 2 | **Ubuntu Desktop 26.04.1 LTS** («Resolute Raccoon»), imagen `Release amd64 (20260826)`. Leído del disco de la VM sin arrancarla el 27/10 ([evidencia](../evidencias/12-dual-boot/ubu-08-version-desde-disco.txt)). Lleva GRUB 2.14 y sudo-rs |
| Nombre del equipo en Ubuntu | `pc-gerente` |

## 3. Particiones

Resultado de `lsblk -f` en Ubuntu ([captura](../evidencias/12-dual-boot/ubu-04-lsblk-particiones.png)):

| Partición | Sistema de archivos | Uso |
|---|---|---|
| `nvme0n1p1` | FAT32, unos 200 MB | Partición EFI. La comparten los dos sistemas; Ubuntu la monta en `/boot/efi`. |
| `nvme0n1p2` | — | Partición reservada de Microsoft (MSR). |
| `nvme0n1p3` | NTFS, **cifrada con BitLocker** desde el 29/10 | Windows (`C:`). |
| `nvme0n1p4` | NTFS | Recuperación de Windows (WinRE). |
| `nvme0n1p5` | ext4, unos 18 GB | Ubuntu (`/`). `/home/gerente` cifrado con fscrypt. Sin partición swap: Ubuntu usa un archivo de intercambio. |

En VirtualBox los nombres son `sda1` a `sda5`, porque el disco va por SATA ([lsblk del 29/10](../evidencias/12-dual-boot/ubu-09-fscrypt-home-gerente.txt)).

En el equipo real, con 512 GB, el reparto previsto es de unos 100 GB para cada sistema y el resto para datos (tarea 8).

## 4. Procedimiento

El orden importa: **primero Windows y después Ubuntu**. Si se hace al revés, Windows sobrescribe el arranque y GRUB desaparece.

### 4.1 Windows 10

1. Instalar Windows 10 desde la ISO **sin usar todo el disco**, dejando espacio sin asignar para Ubuntu.
2. Comprobar el disco en **Administración de discos**. Si `C:` se queda corta, ampliarla con **Extender volumen**, dejando sin asignar el espacio de Ubuntu.
3. Comprobar que **BitLocker está desactivado** (Panel de control → Sistema y seguridad → Cifrado de unidad BitLocker). Con el disco cifrado, Ubuntu no puede reducir ni leer la partición de Windows.
4. Desactivar la **hibernación y el inicio rápido**. Con el inicio rápido, Windows deja la partición NTFS a medio cerrar y puede corromperse si se accede a ella desde Linux. En un CMD como administrador:
   ```
   powercfg /h off
   ```
   ```
   powercfg /a
   ```
   El segundo comando debe indicar que el inicio rápido no está disponible.
5. Crear las cuentas (sección 5). En un CMD como administrador; el `*` hace que la contraseña se pida sin mostrarse:
   ```
   net user admin * /add
   ```
   ```
   net localgroup Administradores admin /add
   ```
   ```
   net user gerente * /add
   ```
   `gerente` queda solo en el grupo `Usuarios` (cuenta estándar).
6. Entrar como `admin` y eliminar la cuenta creada durante la instalación (Configuración → Cuentas → Familia y otros usuarios → Quitar → Eliminar cuenta y datos), para que solo quede una cuenta de administración.
7. Comprobar que la cuenta integrada `Administrador` está desactivada (`net user Administrador` → «Cuenta activa: No»).
8. Comprobar que el Firewall de Windows Defender está activo en todos los perfiles y que Windows Update funciona.

### 4.2 Ubuntu

1. Apagar Windows del todo. En VMware: **VM → Settings → CD/DVD → Use ISO image file** con la ISO de Ubuntu y **Connect at power on**. Si arranca Windows, usar **VM → Power → Power On to Firmware** y poner el CD primero.
2. En el instalador: idioma y teclado español, **instalación interactiva**, selección predeterminada.
3. Tipo de instalación: **«Instalar Ubuntu junto a Windows Boot Manager»**. Usa el espacio sin asignar y no toca Windows. Nunca «Borrar disco».
4. Cuenta: usuario **`administrador`**, equipo **`pc-gerente`**, «Solicitar mi contraseña para acceder» marcado. El usuario creado en el instalador tiene `sudo`, así que es la cuenta de mantenimiento. El nombre `admin` no se puede usar en Ubuntu (sección 7).
5. Al terminar, desconectar la ISO y reiniciar. Debe aparecer el menú de GRUB con Ubuntu y Windows Boot Manager.

Si Windows no aparece en el menú, o el menú no se muestra, editar `/etc/default/grub` con estos valores y ejecutar `sudo update-grub`:

```
GRUB_TIMEOUT_STYLE=menu
GRUB_TIMEOUT=10
GRUB_DISABLE_OS_PROBER=false
```

### 4.3 Configuración de Ubuntu (como `administrador`)

```bash
sudo apt update && sudo apt full-upgrade -y
```

Usuario de uso diario, sin `sudo`:

```bash
sudo adduser gerente
```

Cortafuegos: deniega todo lo entrante y permite lo saliente.

```bash
sudo ufw enable
```

Las actualizaciones de seguridad automáticas (`unattended-upgrades`) vienen activadas en Ubuntu. Se comprueba que las dos líneas valen `"1"`:

```bash
cat /etc/apt/apt.conf.d/20auto-upgrades
```

### 4.4 Actualizar y cifrar (después de instalar los dos sistemas)

**Windows Update.** Con Windows conectado a internet, Configuración → Windows Update → Buscar actualizaciones, e instalar y reiniciar hasta que no quede nada. Debe aparecer la acumulativa **2025-10 (KB5066791)**: es la última de Windows 10 sin ESU (sección 7).

**BitLocker en `C:` sin TPM.** El equipo real tiene TPM 2.0, pero la VM no, así que se usa una contraseña de arranque. En PowerShell como administrador, con un USB o carpeta compartida en `E:\` para la clave de recuperación:

```
powershell -ExecutionPolicy Bypass -File scripts\so\12-bitlocker-sin-tpm.ps1 -Salida E:\
```

El [script](../../scripts/so/12-bitlocker-sin-tpm.ps1) aplica la directiva «Permitir BitLocker sin un TPM compatible» (lo mismo que `gpedit.msc`), pide la contraseña de arranque dos veces, cifra con **XTS-AES 256** solo el espacio usado y añade una clave de recuperación. La clave **no sale por pantalla**: se guarda en `E:\CLAVE-RECUPERACION-BITLOCKER.txt`, se pasa a KeePassXC y el fichero se borra. En el equipo real, con TPM, se usaría `-TpmAndPinProtector` en vez de la contraseña.

**`/home/gerente` cifrado con fscrypt.** Con la sesión de `gerente` cerrada, como `administrador`:

```bash
sudo bash scripts/so/12-cifrar-home-gerente.sh
```

El [script](../../scripts/so/12-cifrar-home-gerente.sh) instala `fscrypt` y `libpam-fscrypt`, activa el cifrado en el ext4 (`tune2fs -O encrypt`), cifra `/home/gerente` con una protección ligada a la **contraseña de inicio de sesión** de `gerente` (la pide una vez) y copia dentro los ficheros que tenía. Al entrar, PAM desbloquea la carpeta; con la sesión cerrada, sin esa contraseña los nombres y el contenido son ilegibles.

⚠️ La contraseña de `gerente` se cambia **desde su sesión** (`passwd`), no como root: así `pam_fscrypt` actualiza también la protección de la carpeta. Si root la cambia, la carpeta ya no se abre al entrar.

**Servicios reducidos.** Los dos sistemas traen servicios que el despacho no usa: cuantos menos haya, menos superficie de ataque. Cada script desactiva una lista fija (en el propio script, con el motivo de cada uno), se puede repetir sin problema y guarda la lista de servicios antes y después como evidencia. La cola de impresión se queda en los dos, porque el gerente imprime.

En Windows, en PowerShell como administrador (`admin`):

```
powershell -ExecutionPolicy Bypass -File scripts\so\12-servicios-reducidos.ps1 -Salida E:\
```

Quita Xbox (4 servicios), Fax, compartir la biblioteca de Windows Media Player, mapas sin conexión, geolocalización, modo demostración, Registro remoto, Conexión compartida a Internet y la telemetría. Evidencia: `win-14-servicios-reducidos.txt`.

En Ubuntu, como `administrador`:

```bash
sudo bash scripts/so/12-servicios-reducidos.sh
```

Quita `cups-browsed` (añade solas las impresoras de la red), `avahi-daemon` (anuncia el equipo en la red local), `ModemManager` (no hay módem) y los informes de fallos a Canonical (`whoopsie`, `kerneloops`, `apport`). Evidencia: `/root/ubu-11-servicios-reducidos.txt`, con los puertos que quedan a la escucha (`ss -tulpn`).

## 5. Cuentas

| Sistema | Cuenta | Tipo | Uso |
|---|---|---|---|
| Windows | `admin` | Administrador | Solo mantenimiento (RG-04) |
| Windows | `gerente` | Usuario estándar | Uso diario (RG-03) |
| Windows | `Administrador` | Integrada de Windows | Desactivada |
| Ubuntu | `administrador` | Grupo `sudo` | Solo mantenimiento (RG-04) |
| Ubuntu | `gerente` | Sin `sudo` (grupos `gerente` y `users`) | Uso diario (RG-03) |

Las contraseñas **no están en el repositorio** ([CONTRIBUTING, sección 6](../../CONTRIBUTING.md#6-secretos)). Están en la base de KeePassXC del equipo (`.kdbx`, cifrada), con la clave de recuperación de BitLocker del 29/10. La VM ya no va a Drive (decisión del 30/10, sección 8): allí solo queda la exportación del 23/10, desfasada, con su `.kdbx` de entonces.

Las contraseñas se generaron con **KeePassXC** (frases de 5 palabras, una distinta por cuenta) y se cambiaron el 23/10/2026 (tarea 55). La contraseña maestra de la base de KeePassXC se da aparte, nunca por escrito en el repositorio ni en Drive.

## 6. Verificación

| Requisito | Prueba | Resultado | Evidencia |
|---|---|---|---|
| RG-01 | Menú de GRUB al arrancar | OK: aparecen Ubuntu y Windows Boot Manager (GRUB 2.14) | [GRUB](../evidencias/12-dual-boot/ubu-06-menu-grub.png) |
| RG-01 | Particiones de los dos sistemas y EFI compartida | OK | [lsblk](../evidencias/12-dual-boot/ubu-04-lsblk-particiones.png) |
| RG-03 Windows | `net user gerente`: solo en `Usuarios` | OK | [net user](../evidencias/12-dual-boot/win-03-net-user-gerente.png) |
| RG-03 Windows | Abrir CMD como administrador con `gerente`: el UAC pide usuario y contraseña de `admin` | OK | [UAC](../evidencias/12-dual-boot/win-04-uac-gerente.png) |
| RG-03 Ubuntu | `groups gerente` sin `sudo`; `sudo -v` denegado | OK | [sudo](../evidencias/12-dual-boot/ubu-05-gerente-sin-sudo.webp) |
| RG-04 Windows | `net user`, `net localgroup Administradores` y estado de `Administrador` | OK: solo `admin` y `gerente` como cuentas de uso; en Administradores solo `admin` y la integrada `Administrador`, con «Cuenta activa: No» | [cuentas](../evidencias/12-dual-boot/win-05-cuentas-y-administradores.png) |
| RG-04 Ubuntu | `administrador` en el grupo `sudo` | OK | [groups](../evidencias/12-dual-boot/ubu-03-ufw-y-auto-upgrades.png) |
| RG-05 Windows | `netsh advfirewall show allprofiles state` | OK: dominio, privado y público en ACTIVAR | [firewall](../evidencias/12-dual-boot/win-06-firewall.png) |
| RG-05 Windows | Windows Update al día | OK (29/10): instalada la acumulativa **2025-10 KB5066791**, compilación 19045.6456, y la de .NET KB5066747. Los fallos del 23/10 (0x8024402c) eran porque el adaptador de red estaba deshabilitado en Windows | [historial](../evidencias/12-dual-boot/win-13-historial-windows-update-kb5066791.png), [Get-HotFix](../evidencias/12-dual-boot/win-09-bitlocker-status.txt), [23/10](../evidencias/12-dual-boot/win-07-historial-windows-update.txt) |
| Seguridad Windows | BitLocker en `C:` | OK (29/10): «Cifrado solo de espacio usado», 100 %, XTS-AES 256, «Protección activada»; protectores contraseña y contraseña numérica | [manage-bde](../evidencias/12-dual-boot/win-10-bitlocker-final.txt) |
| Seguridad Windows | Arranque en frío | OK: antes de cargar Windows, BitLocker pide la contraseña | [captura](../evidencias/12-dual-boot/win-11-bitlocker-pide-contrasena-al-arrancar.png) |
| Seguridad Ubuntu | `/home/gerente` cifrado | OK (29/10): `fscrypt status` «is encrypted», AES-256-XTS, protector «login protector for gerente»; `pam_fscrypt` en `common-auth`, `-password` y `-session` | [fscrypt](../evidencias/12-dual-boot/ubu-09-fscrypt-home-gerente.txt) |
| Seguridad Ubuntu | Entrar como `gerente` abre la carpeta sola | OK | [captura](../evidencias/12-dual-boot/ubu-10-gerente-home-cifrado-se-abre-al-entrar.png) |
| Seguridad (tarea 55) | Contraseñas robustas, solo las cuentas previstas | OK: las 4 contraseñas cambiadas el 23/10 y guardadas en KeePassXC; en Ubuntu solo `administrador` y `gerente`, y solo `administrador` en `sudo`; la cuenta de instalación de Windows ya no existe | [Ubuntu](../evidencias/12-dual-boot/ubu-07-cuentas-y-contrasenas.txt), [Windows](../evidencias/12-dual-boot/win-05-cuentas-y-administradores.png) |
| RG-05 Ubuntu | `ufw status verbose`: activo, deny entrante | OK | [ufw](../evidencias/12-dual-boot/ubu-03-ufw-y-auto-upgrades.png) |
| RG-05 Ubuntu | `20auto-upgrades` con las dos opciones a `"1"` | OK | [auto-upgrades](../evidencias/12-dual-boot/ubu-03-ufw-y-auto-upgrades.png) |
| Preparación | BitLocker desactivado **antes de instalar Ubuntu** (se activa al final, sección 4.4) | OK | [BitLocker](../evidencias/12-dual-boot/win-01-bitlocker-desactivado.png) |
| Preparación | Inicio rápido e hibernación no disponibles | OK | [powercfg](../evidencias/12-dual-boot/win-02-powercfg-sin-inicio-rapido.png) |

## 7. Decisiones y problemas encontrados

- **`admin` está reservado en Ubuntu.** El instalador lo rechaza («Ese nombre está reservado para uso del sistema», [captura](../evidencias/12-dual-boot/ubu-01-admin-reservado.png)) porque existe un grupo `admin` heredado de versiones antiguas. Por eso la cuenta de mantenimiento se llama `admin` en Windows y `administrador` en Ubuntu ([captura](../evidencias/12-dual-boot/ubu-02-cuenta-administrador.png)).
- **Mensaje de `sudo` en Ubuntu.** Al intentar `sudo` con `gerente`, aparece «I'm sorry gerente. I'm afraid I can't do that». Las versiones recientes de Ubuntu usan **sudo-rs** (reimplementación de `sudo` en Rust), y ese es su mensaje cuando el usuario no está en sudoers.
- **Disco de Windows lleno.** Tras instalar, `C:` tenía 13 GB y solo 53 MB libres. Se amplió con «Extender volumen» antes de instalar Ubuntu, porque Windows sin espacio libre no puede instalar actualizaciones.
- **Cifrado: BitLocker se activa al final.** Para instalar Ubuntu BitLocker tiene que estar desactivado (con el disco cifrado Ubuntu no puede reducir ni leer la partición de Windows), pero el equipo no puede quedarse así. Por eso se cifra **después** de instalar los dos sistemas (sección 4.4). GRUB sigue arrancando Windows Boot Manager con BitLocker activo, comprobado el 29/10.
- **fscrypt en vez de LUKS para `/home/gerente`.** LUKS obliga a crear una partición o un contenedor y a reparticionar con Ubuntu ya instalado. fscrypt cifra la carpeta dentro del ext4 que ya existe y se abre con la contraseña de inicio de sesión, sin una segunda contraseña. Para cifrar todo Ubuntu, en una reinstalación se elegiría «cifrado de disco» (LUKS) en el instalador.
- **Windows 10 sin soporte desde el 14/10/2025.** La acumulativa de octubre de 2025 (KB5066791) es la última sin ESU. Windows Update lo avisa («Ha finalizado el soporte técnico de Windows 10», [captura](../evidencias/12-dual-boot/win-12-aviso-fin-soporte-windows10.png)). Es un **riesgo**: a partir de ahí no llegan parches de seguridad. Para el equipo real se recomienda **Windows 11 Pro** (el Neo 50q tiene TPM 2.0 y CPU compatible) o, si se mantiene Windows 10, contratar **ESU**.
- **Red de Windows deshabilitada.** Los fallos de Windows Update del 23/10 eran porque el adaptador de red estaba deshabilitado en Windows. Se habilitó en Conexiones de red.
- **Migración de VMware a VirtualBox (29/10).** En VMware Workstation, sobre Ubuntu con Wayland, no funcionaban ni copiar y pegar ni algunas teclas (`\` salía como `|`). Se juntó el disco con `vmware-vdiskmanager -r … -t 0` y se conectó a una VM de VirtualBox con EFI. Cambios necesarios: disco en **SATA** (con NVMe, Windows da 0xc0000001), teclado **USB** (con el PS/2 la pantalla de BitLocker no recibe teclas) y las VMware Tools deshabilitadas (no se dejan desinstalar fuera de VMware). Al cambiar de controlador, VirtualBox volvió a la instantánea anterior y se perdieron los cambios de Ubuntu de esa mañana; se repitieron.
- **Windows se pone primero en el arranque.** Tras actualizar, el firmware arrancaba Windows Boot Manager directamente y GRUB no salía. Se corrigió desde Windows: `bcdedit /set {fwbootmgr} displayorder {id-de-Ubuntu} /addfirst` (el id sale en `bcdedit /enum firmware`).
- **Clave de recuperación de BitLocker vista en pantalla.** `Add-BitLockerKeyProtector` escribe la clave como advertencia aunque se redirija la salida. Se sustituyó por otra creada sin mostrarla, se borró la primera y el script lleva `-WarningAction SilentlyContinue`. La vigente solo está en KeePassXC.
- **Contraseñas de Ubuntu repuestas el 29/10.** Las de `administrador` y `gerente` se volvieron a poner desde el modo de recuperación (`passwd`) y están en KeePassXC. En la consola de VirtualBox se colaba a veces un **Esc** al hacer clic en la ventana (sale como `^[`), que acababa dentro de la contraseña: antes de escribir una contraseña, pulsar Retroceso.
- **Reiniciar desde Windows no siempre pide la contraseña de BitLocker.** En una prueba, `Restart-Computer` llegó a Windows sin pedirla; al arrancar en frío la pide siempre. El caso que importa (equipo apagado y robado) está cubierto. Queda anotado para comprobarlo en el equipo real con TPM.
- **Inicio rápido.** La opción no aparece en las opciones de energía porque la VM no admite hibernación. Aun así se ejecutó `powercfg /h off` para dejarlo garantizado.

## 8. Entrega de la máquina virtual

**Decisión del 30/10/2026:** la VM ya no se sube a Drive. Está en el **PC de Adrian** (VirtualBox, instantánea `tarea12-cifrado-y-actualizado-2026-10-29`) y se enseña desde ahí; lo que demuestra la tarea son las evidencias de la sección 6. Quién tiene cada VM del reto: [maquinas-virtuales.md](../gestion/maquinas-virtuales.md).

Lo que sigue es la exportación del **23/10/2026** (VMware), que sigue en Drive pero está **desfasada**: no tiene ni las actualizaciones ni el cifrado del 29/10. Sus tres ficheros pequeños se quedan en el repositorio solo como registro de esa entrega (y de cómo se arregló la `.nvram`, abajo); para enseñar la VM se usa la del PC de Adrian.

La VM no se sube al repositorio, porque ocupa varios GB y GitHub no admite archivos de más de 100 MB. Se exporta desde VMware con **File → Export to OVF**. Los archivos pequeños están en el repositorio, en [`docs/evidencias/12-dual-boot/vm/`](../evidencias/12-dual-boot/vm/). El disco y las credenciales están en Google Drive: [carpeta Reto-Asir](https://drive.google.com/drive/folders/13diK9g2t1CdGL-nc2t7qDt9rSzgpb_n_?usp=drive_link).

| Archivo | Dónde | Tamaño | Contenido | SHA-256 |
|---|---|---|---|---|
| `VM-dualboot-W10-ubuntu.ovf` | Repositorio | 10 KB | Descripción de la VM (hardware virtual) | `c23de2fccd742c986462a3c2a59ec025e322fea661ef71e2d3fe9a4944dce2ff` |
| `VM-dualboot-W10-ubuntu.mf` | Repositorio | 318 B | Sumas SHA-256 de los archivos de la VM | — |
| `VM-dualboot-W10-ubuntu-file1.nvram` | Repositorio | 265 KB | Variables UEFI (entradas de arranque de Windows y Ubuntu) | `0ebda58a3956a09f1f0115275dd8e6e960a64446ea68ac3bfe1d2b52099d7c54` |
| `VM-dualboot-W10-ubuntu-disk1.vmdk` | Drive | 12,4 GB | Disco con los dos sistemas | `29d633bb62d832d1239d8eace263a835d4896c8dcc037e7d8e9573aa6cc3597a` |
| `Contraseñas.kdbx` | Drive | — | Base de KeePassXC cifrada con las contraseñas de las cuentas (sección 5) | — |

El disco no puede ir al repositorio: GitHub no admite archivos de más de 100 MB, y el `.gitignore` excluye los discos de VM.

Para usarla:

1. Poner en la misma carpeta los tres archivos del repositorio y el `.vmdk` de Drive.
2. Comprobar que no se han corrompido: `sha256sum VM-dualboot-W10-ubuntu*` y comparar con la tabla o con el `.mf`.
3. En VMware, **File → Open** y elegir el `.ovf`.

La `.nvram` es necesaria: guarda las entradas de arranque UEFI. Sin ella, la VM puede no encontrar GRUB al arrancar.

**Si se exporta con `ovftool`** en vez de con el menú de VMware, comprobar que la `.nvram` está en el paquete: la exportación del 23/10 la dejó fuera (el `.ovf` apuntaba a `Windows 10 x64.nvram` sin incluirla). Se añadió a mano: copia de la `.nvram` de la VM como `VM-dualboot-W10-ubuntu-file1.nvram`, una línea `<File>` en `<References>`, `vmw:value="ovf:/file/file2"` en la clave `nvram` y el `.mf` regenerado. `ovftool VM-dualboot-W10-ubuntu.ovf` lo valida sin errores.

## 9. Pendiente

- [x] Apuntar la versión exacta de Ubuntu y la ISO usada (sección 2): 26.04.1 LTS, imagen del 26/08/2026 (27/10).
- [x] Windows Update al día: acumulativa 2025-10 KB5066791 (29/10).
- [x] Cifrado: BitLocker en `C:` y fscrypt en `/home/gerente` (29/10, sección 4.4).
- [x] ~~Exportar la VM a OVA y subirla a Drive~~: no se hace (decisión del 30/10). La VM se queda en el PC de Adrian ([maquinas-virtuales.md](../gestion/maquinas-virtuales.md)). Si hay que pasarla: `VBoxManage export VM-dualboot-W10-ubuntu -o VM-dualboot-W10-ubuntu.ova` en ese momento, y la clave de recuperación y las contraseñas nuevas van en el `.kdbx`.
- [ ] En el equipo real: Windows 11 Pro o ESU (sección 7) y BitLocker con TPM + PIN.
- [ ] **Servicios reducidos** ([tarea 64](../gestion/gantt.md), Adrian, 09/11) (rúbrica, ISO RA1, nivel 5: «el sistema queda endurecido (mínimos privilegios, servicios reducidos)»; auditoría del 06/11). Los scripts están hechos (sección 4.4) y comprobada su sintaxis, pero **falta ejecutarlos en la VM** (PC de Adrian) y copiar las dos evidencias, `win-14-servicios-reducidos.txt` y `ubu-11-servicios-reducidos.txt`, a `docs/evidencias/12-dual-boot/`. Después, añadir sus filas a la tabla de la sección 6. (Las Guest Additions de la VM van en la tarea 62.)
- [x] Drive revisado el 24/10: están el `.vmdk` y el `.kdbx` del 23/10 y no hay ningún `.txt` con contraseñas.
