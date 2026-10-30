# Tareas 13 y 15: Bastionado de los TPV y scripts de Windows

- **Bloque:** 2 SO
- **Responsable:** Iker
- **Requisitos que cubre:** RT-01, RT-04, RT-05 y RT-06 de la [tarea 7](../../hardware/07-necesidades-equipos.md)
- **Estado:** scripts listos (24/10/2026): sintaxis comprobada y `comprobar-tpv.ps1` probado en un Windows 11 sin bastionar (da FALLO donde debe). **Falta ejecutarlos en la VM del TPV** (sección 6).


> **Dos documentos de la tarea 13.** Este explica los scripts (tareas 13 y 15). Lo que se hizo a mano en los TPV el 26/10, con capturas, está en [13-bastionado-tpv-windows.md](Tarea13_Markdown_GitHub/13-bastionado-tpv-windows.md) (Markel); lo que falta de los scripts en esos TPV es el hallazgo S-20 de la [tarea 46](../../seguridad/46-revision-seguridad/DOCUMENTACION.md).

## 1. Qué se consigue

El enunciado pide que los TPV estén «lo más restringidos posible en cuanto a permisos y funcionalidades, aplicando el principio de mínimos privilegios y una configuración segura por defecto», con documentación que permita repetir la instalación. Al terminar, cada TPV:

| Requisito (tarea 7) | Cómo |
|---|---|
| RT-01 Solo el TPV de Odoo, a pantalla completa | Acceso asignado (modo quiosco) de Windows con Microsoft Edge en el TPV de Odoo (paso 4) |
| RT-04 Usuario estándar, sin consola, sin instalar | Cuenta `cajero` estándar; UAC deniega cualquier elevación; Administrador e Invitado integrados desactivados |
| RT-05 USB de almacenamiento bloqueado | `USBSTOR` desactivado y directiva *Denegar todos los dispositivos extraíbles*. Teclado, pantalla táctil e impresora USB siguen funcionando (no son almacenamiento) |
| RT-06 Salida solo a Odoo, DNS y actualizaciones | Firewall con entrada **y salida** bloqueadas por defecto, y 12 reglas de salida: Edge solo al servidor, DNS y DHCP al router, NTP, y los servicios de Windows Update, Defender y Edge Update por 80/443. Además, Edge solo abre la URL de Odoo (lista blanca) |
| Seguridad por defecto | Windows Update diario a las 3:00 sin reiniciar con sesión abierta; Defender en tiempo real; sin Escritorio remoto ni SMBv1; contraseñas de 12 caracteres y bloqueo tras 10 intentos |

## 2. Archivos

| Archivo | Qué hace |
|---|---|
| [`configurar-tpv.ps1`](configurar-tpv.ps1) | Aplica todo lo anterior salvo el quiosco. Idempotente. Deja un registro en `C:\ProgramData\AlmiChain\` |
| [`comprobar-tpv.ps1`](comprobar-tpv.ps1) | Solo lee: 16 comprobaciones con OK / FALLO por requisito. Con `-Salida` guarda la evidencia |

Los dos llevan BOM UTF-8 para que Windows PowerShell 5.1 (el de Windows 10) lea bien los acentos.

## 3. Antes de empezar

- **Edición de Windows:** Pro, Enterprise o **IoT Enterprise LTSC 2021** (la recomendada en la [tarea 10](../../hardware/10-presupuesto-hardware.md), apartado 4.1, por su soporte hasta 2032). Home no sirve: no tiene Acceso asignado.
- **VM de pruebas:** Windows 10 x64, 2 vCPU, 4 GB, 64 GB de disco, red puenteada o en la misma red NAT que la VM `ServidorERP` (para llegar a Odoo). Crear durante la instalación una cuenta de administración (por ejemplo `admin-tpv`) con contraseña de KeePassXC.
- **Contraseña de `cajero`:** generarla en KeePassXC antes (el script la pide sin mostrarla).
- **IP del servidor:** si en la VM no es `192.168.10.10`, pasarla con `-Servidor`.

## 4. Procedimiento (unos 15 minutos por TPV)

1. Entrar con la cuenta de administración y copiar la carpeta `docs/so/13-tpv` (por ejemplo, con `git clone` o un USB **antes** de bloquearlos).
2. PowerShell **como administrador**:
   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   ```
   ```powershell
   .\configurar-tpv.ps1 -NumeroTpv 1
   ```
   En la VM, si el servidor tiene otra IP: `.\configurar-tpv.ps1 -NumeroTpv 1 -Servidor 192.168.56.10`.
3. Reiniciar (el nombre del equipo cambia a `TPV1`).
4. **Modo quiosco** (manual, Windows no deja hacerlo bien por script en la edición Pro). Con la cuenta de administración:
   1. *Configuración → Cuentas → Familia y otros usuarios → Configurar un quiosco → Comenzar*.
   2. Nombre de la cuenta de quiosco: elegir la cuenta existente `cajero`.
   3. Aplicación: **Microsoft Edge**.
   4. Modo: **«Como señal digital o pantalla interactiva»** (pantalla completa, sin barra de direcciones).
   5. URL: `http://192.168.10.10:8069/pos/ui` (o `https://192.168.10.10/pos/ui` cuando esté el proxy HTTPS, tarea 52).
   6. Reiniciar tras inactividad: **No** (el cajero tiene la caja abierta).
5. Cerrar sesión: el equipo entra solo como `cajero` y abre el TPV de Odoo. Para salir del quiosco: `Ctrl+Alt+Supr` → cambiar de usuario → cuenta de administración.
6. Comprobar y guardar la evidencia (como administrador):
   ```powershell
   .\comprobar-tpv.ps1 -Salida ..\..\evidencias\13-tpv\tpv1-comprobacion.txt
   ```
   Tiene que acabar con **16 OK, 0 FALLO**.
7. Repetir en el TPV 2 con `-NumeroTpv 2`.

## 5. Pruebas manuales (capturas para la evidencia)

| # | Prueba (tarea 7, sección 7) | Resultado esperado |
|---|---|---|
| 1 | Reiniciar el TPV | Entra solo como `cajero` y abre el TPV de Odoo a pantalla completa (RT-01) |
| 2 | Con `cajero`, `Win+R`, `Ctrl+Esc` o intentar abrir otra aplicación | No hay escritorio ni menú Inicio (RT-01, RT-04) |
| 3 | Como `cajero` (fuera del quiosco, para la prueba): abrir `cmd` como administrador o instalar un programa | Se deniega sin pedir contraseña (RT-04) |
| 4 | Conectar una memoria USB | No aparece en el Explorador (RT-05) |
| 5 | Desde Edge, abrir `https://www.google.com` | Bloqueada por la directiva (RT-06) |
| 6 | Cobrar una venta en el TPV de Odoo | Funciona (tarea 34, sección 8.2) |
| 7 | `comprobar-tpv.ps1` | 16 OK |

## 6. Pendiente

- [ ] Crear la VM del TPV y ejecutar el procedimiento de la sección 4; guardar `tpv1-comprobacion.txt` y las capturas de la sección 5 en `docs/evidencias/13-tpv/`.
- [x] Edición de Windows de los TPV: **IoT Enterprise LTSC 2021**, apuntada en las tareas 9 y 10 con su precio (30/10). Las VM de pruebas llevan Windows 11 Pro y la simulan (tarea 10, 4.1).
- [ ] Impresión del ticket sin diálogo: con Edge en quiosco, el ticket abre el diálogo de impresión del navegador. Si se quiere imprimir directamente, en **IoT Enterprise** se puede lanzar Edge con `--kiosk ... --kiosk-printing` (Shell Launcher); en Pro se queda el diálogo (tareas 14 y 37).

## 7. Decisiones

- **Firewall de salida en «bloquear».** Es lo que pide RT-06 y lo más restrictivo. Windows no filtra por nombre de dominio, así que las actualizaciones se permiten **por servicio** (`wuauserv`, `BITS`, `UsoSvc`, `DoSvc`, `CryptSvc`, `WinDefend`, `edgeupdate`) y solo a los puertos 80 y 443: un programa cualquiera, aunque lo ejecutara el cajero, no tiene salida.
- **Edge con lista blanca.** Aunque alguien saliera del quiosco, el navegador solo abre el servidor Odoo. Sin descargas, sin InPrivate, sin herramientas de desarrollo y sin guardar contraseñas.
- **Actualizaciones a las 3:00 y sin reinicio con sesión abierta.** Windows 10 sin ESU no recibe parches; con IoT Enterprise LTSC sí, hasta 2032. Que se instalen de madrugada evita cortes durante el servicio.
- **El quiosco es manual.** En Windows 10 Pro, el asistente de *Configurar un quiosco* es la forma soportada de poner Edge en Acceso asignado; por script hace falta el puente WMI de MDM ejecutado como SYSTEM, más frágil. Son 6 clics y quedan documentados.
