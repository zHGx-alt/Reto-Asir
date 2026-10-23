# Tarea 12: Arranque dual Windows 10 + Ubuntu en el equipo del gerente

- **Bloque:** 2 SO
- **Depende de:** tarea 8 (tabla de hardware)
- **Requisitos que cubre:** RG-01, RG-03, RG-04 y RG-05 (tarea 7, sección 3.1)
- **Reto:** Almi-Chain (ASIR1 2026-27)
- **Estado:** hecha en VM, con pendientes (sección 9: versión de Ubuntu, actualizaciones de Windows y cifrado); pendiente de revisión
- **Fecha:** 22/10/2026

## 1. Alcance

El enunciado pide para el despacho del gerente un equipo con arranque dual Windows 10 y GNU/Linux, restringido con mínimos privilegios y configuración segura por defecto. Este documento explica cómo se ha instalado y configurado en una máquina virtual, qué se ha comprobado y dónde están las evidencias.

La distribución elegida es **Ubuntu Desktop LTS**: tiene soporte largo, instalador que detecta Windows y crea el arranque dual solo, y actualizaciones de seguridad automáticas de serie.

## 2. Entorno de pruebas

El equipo real (Lenovo ThinkCentre Neo 50q, tarea 8) se simula en una máquina virtual con menos recursos (supuesto S-07 de la tarea 7).

| Elemento | Valor |
|---|---|
| Hipervisor | VMware Workstation |
| Firmware | UEFI, disco GPT (como el equipo real) |
| CPU y memoria | 4 procesadores virtuales, 8 GB de RAM |
| Disco | 60 GB, NVMe virtual |
| Red | NAT |
| Sistema 1 | Windows 10 x64 |
| Sistema 2 | Ubuntu Desktop LTS. **Versión exacta pendiente de apuntar** (`lsb_release -d` en la VM, y el nombre de la ISO). Lleva GRUB 2.14 y sudo-rs, así que es una versión reciente |
| Nombre del equipo en Ubuntu | `pc-gerente` |

## 3. Particiones

Resultado de `lsblk -f` en Ubuntu ([captura](../evidencias/12-dual-boot/ubu-04-lsblk-particiones.png)):

| Partición | Sistema de archivos | Uso |
|---|---|---|
| `nvme0n1p1` | FAT32, unos 200 MB | Partición EFI. La comparten los dos sistemas; Ubuntu la monta en `/boot/efi`. |
| `nvme0n1p2` | — | Partición reservada de Microsoft (MSR). |
| `nvme0n1p3` | NTFS | Windows (`C:`). |
| `nvme0n1p4` | ext4, unos 18 GB | Ubuntu (`/`). Sin partición swap: Ubuntu usa un archivo de intercambio. |

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

## 5. Cuentas

| Sistema | Cuenta | Tipo | Uso |
|---|---|---|---|
| Windows | `admin` | Administrador | Solo mantenimiento (RG-04) |
| Windows | `gerente` | Usuario estándar | Uso diario (RG-03) |
| Windows | `Administrador` | Integrada de Windows | Desactivada |
| Ubuntu | `administrador` | Grupo `sudo` | Solo mantenimiento (RG-04) |
| Ubuntu | `gerente` | Sin `sudo` (grupos `gerente` y `users`) | Uso diario (RG-03) |

Las contraseñas **no están en el repositorio** ([CONTRIBUTING, sección 6](../../CONTRIBUTING.md#6-secretos)). Se entregan aparte, en una base de KeePassXC que está en la misma carpeta de Drive que la máquina virtual (sección 8).

Las contraseñas se generaron con **KeePassXC** (frases de 5 palabras, una distinta por cuenta) y se cambiaron el 23/10/2026 (tarea 55). La base de KeePassXC (`.kdbx`, cifrada) se entrega con la VM en Drive; su contraseña maestra se da aparte, nunca por escrito en el repositorio ni en Drive.

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
| RG-05 Windows | Windows Update funcionando | **Parcial:** el 22/10 sincronizó e instaló KB5020683 (actualización de noviembre de 2022, la del instalador) y un driver. El 23/10 todos los intentos fallan por falta de conexión de la VM (errores 0x8024402c y 0x80240438). **No hay ninguna actualización acumulativa de seguridad instalada.** Pendiente: conectar la VM, instalar las actualizaciones disponibles y repetir la evidencia | [historial](../evidencias/12-dual-boot/win-07-historial-windows-update.txt) |
| Seguridad (tarea 55) | Contraseñas robustas, solo las cuentas previstas | OK: las 4 contraseñas cambiadas el 23/10 y guardadas en KeePassXC; en Ubuntu solo `administrador` y `gerente`, y solo `administrador` en `sudo`; la cuenta de instalación de Windows ya no existe | [Ubuntu](../evidencias/12-dual-boot/ubu-07-cuentas-y-contrasenas.txt), [Windows](../evidencias/12-dual-boot/win-05-cuentas-y-administradores.png) |
| RG-05 Ubuntu | `ufw status verbose`: activo, deny entrante | OK | [ufw](../evidencias/12-dual-boot/ubu-03-ufw-y-auto-upgrades.png) |
| RG-05 Ubuntu | `20auto-upgrades` con las dos opciones a `"1"` | OK | [auto-upgrades](../evidencias/12-dual-boot/ubu-03-ufw-y-auto-upgrades.png) |
| Preparación | BitLocker desactivado | OK | [BitLocker](../evidencias/12-dual-boot/win-01-bitlocker-desactivado.png) |
| Preparación | Inicio rápido e hibernación no disponibles | OK | [powercfg](../evidencias/12-dual-boot/win-02-powercfg-sin-inicio-rapido.png) |

## 7. Decisiones y problemas encontrados

- **`admin` está reservado en Ubuntu.** El instalador lo rechaza («Ese nombre está reservado para uso del sistema», [captura](../evidencias/12-dual-boot/ubu-01-admin-reservado.png)) porque existe un grupo `admin` heredado de versiones antiguas. Por eso la cuenta de mantenimiento se llama `admin` en Windows y `administrador` en Ubuntu ([captura](../evidencias/12-dual-boot/ubu-02-cuenta-administrador.png)).
- **Mensaje de `sudo` en Ubuntu.** Al intentar `sudo` con `gerente`, aparece «I'm sorry gerente. I'm afraid I can't do that». Las versiones recientes de Ubuntu usan **sudo-rs** (reimplementación de `sudo` en Rust), y ese es su mensaje cuando el usuario no está en sudoers.
- **Disco de Windows lleno.** Tras instalar, `C:` tenía 13 GB y solo 53 MB libres. Se amplió con «Extender volumen» antes de instalar Ubuntu, porque Windows sin espacio libre no puede instalar actualizaciones.
- **BitLocker desactivado: el equipo del gerente queda sin cifrar.** Se desactiva para instalar Ubuntu, porque con el disco cifrado Ubuntu no puede reducir ni leer la partición de Windows. Pero dejarlo así va contra la seguridad por defecto: si roban el mini PC, se leen los datos. **Después de instalar los dos sistemas** hay que:
  1. Activar **BitLocker** en `C:` (Windows 10 Pro lo incluye) y guardar la clave de recuperación en KeePassXC, no en el equipo. GRUB arranca Windows Boot Manager igual; BitLocker solo pedirá la clave de recuperación si cambia la cadena de arranque, así que hay que probar un arranque desde GRUB después de activarlo.
  2. En Ubuntu, cifrar los datos del gerente: una partición o un contenedor **LUKS** para `/home/gerente`, o reinstalar Ubuntu con «cifrado de disco» si se repite la instalación.
  En la VM no se ha hecho todavía (pendiente, sección 9).
- **Inicio rápido.** La opción no aparece en las opciones de energía porque la VM no admite hibernación. Aun así se ejecutó `powercfg /h off` para dejarlo garantizado.

## 8. Entrega de la máquina virtual

Exportación actual: **23/10/2026**, después de cambiar las contraseñas (tarea 55).

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

- [ ] Apuntar la versión exacta de Ubuntu y la ISO usada (sección 2).
- [ ] Conectar la VM a internet, instalar las actualizaciones acumulativas de Windows y repetir la evidencia de Windows Update (RG-05 queda **parcial** hasta entonces).
- [ ] Cifrar después de instalar: BitLocker en Windows y LUKS en los datos de Ubuntu (sección 7).
- [ ] Subir a Drive el `.vmdk` y el `.kdbx` nuevos y **borrar de Drive el `.txt` antiguo** con las contraseñas débiles; revisar quién tiene acceso a la carpeta.
