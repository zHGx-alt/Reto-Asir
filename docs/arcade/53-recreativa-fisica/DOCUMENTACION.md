# Tarea 53 · Instalar la recreativa en el equipo real (1 núcleo, 1 GB)

**Responsable:** Eneko.S · **Fechas:** 29–30/10/2026 · **Depende de:** tareas 16 (recreativa en VM) y 51 (decisión: Debian 13 + MAME)
**Estado:** ⏳ Guía y preseed del equipo físico preparados el 27/10. Falta ejecutarla en el aula con el equipo real.

Objetivo: repetir en el ordenador físico de la recreativa lo que la [tarea 16](../16-recreativa-mame/DOCUMENTACION.md) hizo en una VM. Al encender, Debian entra solo con el usuario `arcade` y abre MAME a pantalla completa, sin escritorio y sin privilegios de administrador para quien juega. Se usan **el mismo preseed y el mismo script** que en la VM; solo cambia lo que en la VM hacía VirtualBox.

## 1. Qué cambia respecto a la VM

| En la VM (tarea 16) | En el equipo real |
|---|---|
| `VBoxManage unattended install` mete la contraseña en el preseed | [`preparar-preseed-fisico.sh`](preparar-preseed-fisico.sh) la pide y guarda solo su **hash** SHA-512 |
| El disco es siempre `/dev/sda` | Se elige al generar el preseed (`/dev/sda`, `/dev/nvme0n1`…) |
| El preseed se carga solo | Se sirve desde un portátil por HTTP y se indica su URL en el instalador (sección 4) |
| Red NAT de VirtualBox, SSH por el puerto 2222 | Cable para instalar; después, Wi-Fi de invitados (sección 6) |
| Recursos fijados en la VM | Hay que comprobar los del equipo (sección 3) |

## 2. Antes de ir al aula (en casa)

| ✓ | Qué | Cómo |
|---|---|---|
| ☐ | **USB 1 (instalador):** ISO *netinst* de Debian 13 | Descargar de <https://www.debian.org/download> y grabarla con Balena Etcher o `dd`. La netinst descarga los paquetes: hará falta **cable con internet** al instalar. |
| ☐ | **USB 2 (ficheros):** scripts y ROMs | Copiar `docs/arcade/16-recreativa-mame/instalar-arcade.sh`, `docs/arcade/17-rendimiento-mame/*.sh` y `scripts/arcade/*.sh` (los dos últimos, para la tarea 54) y la carpeta `roms/` del paso siguiente. Formato FAT32. |
| ☐ | **ROMs legales** (las 5 de la tarea 16) | Con el mismo bucle de la [tarea 16, apartado 4.5](../16-recreativa-mame/DOCUMENTACION.md#45-instalar-roms-legales), en una carpeta `roms/` del USB 2. No se suben a Git (`.gitignore`). |
| ☐ | **Contraseña de `tecnico`** | Generarla en KeePassXC (frase larga) y guardarla en la base del equipo. En la VM de 1 GB nadie la conocía (tarea 17): que no vuelva a pasar. |
| ☐ | **Preseed del equipo real** | `bash docs/arcade/53-recreativa-fisica/preparar-preseed-fisico.sh` (ver abajo) |
| ☐ | Adaptador Wi-Fi USB, si el equipo no tiene Wi-Fi | Presupuestado en la tarea 10 (sección 12) |

**Generar el preseed.** En tu PC, dentro del repositorio:

```bash
bash docs/arcade/53-recreativa-fisica/preparar-preseed-fisico.sh             # disco /dev/sda
bash docs/arcade/53-recreativa-fisica/preparar-preseed-fisico.sh /dev/nvme0n1 # si el disco es NVMe
```

Pide dos veces la contraseña de `tecnico` (no se ve al escribir), añade tu clave SSH pública (`~/.ssh/id_ed25519.pub`, si existe) y crea `preseed-local.cfg` con permisos 600. Ese fichero lleva el hash de la contraseña: **no se sube a Git** (está en `.gitignore`) y se borra después de instalar. Si en el aula resulta que el disco es otro, se vuelve a generar allí en un minuto.

## 3. Ficha del equipo (rellenar en el aula)

Arrancar el USB 1 y, antes de instalar, abrir una consola (`Ctrl+Alt+F2` en el instalador) o, ya instalado, entrar como `tecnico`:

| Dato | Comando | Valor |
|---|---|---|
| Marca y modelo | Pegatina del equipo | |
| Procesador y núcleos | `lscpu \| grep -E 'Model name\|^CPU\(s\)'` | |
| Memoria | `free -m` | |
| Disco | `lsblk -d -o NAME,SIZE,MODEL` | |
| Firmware | `[ -d /sys/firmware/efi ] && echo UEFI \|\| echo BIOS` | |
| Red por cable y Wi-Fi | `ip link` y `lsusb` | |

**Si el equipo tiene más de 1 núcleo o 1 GB.** El enunciado pide 1 núcleo y 1 GB. Se puede limitar al arrancar, sin tocar el hardware, si el profesor lo acepta:

```bash
sudo sed -i 's/^GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="maxcpus=1 mem=1024M"/' /etc/default/grub
sudo update-grub && sudo reboot
nproc && free -m        # 1 núcleo y algo menos de 1024 MB (el núcleo reserva una parte)
```

## 4. Instalar Debian 13 (≈15-20 min)

> ⚠️ El preseed **borra el disco entero** del equipo. Confirmar antes que es el de la recreativa y que no tiene nada que conservar.

1. Conectar el **cable de red** y el USB 1. Arrancar desde el USB (tecla del menú de arranque: F12, F11, F8 o Esc, según la marca).
2. En el portátil (misma red), en la carpeta donde está `preseed-local.cfg`:
   ```bash
   python3 -m http.server 8000
   ```
   Apuntar la IP del portátil (`ip -4 addr`).
3. En el menú del instalador: **Advanced options → Automated install**. Cuando pida la ubicación del preseed, escribir:
   ```
   http://IP_DEL_PORTATIL:8000/preseed-local.cfg
   ```
   *Alternativa:* en el menú, pulsar `e` (UEFI) o `Tab` (BIOS) sobre **Install** y añadir al final de la línea del kernel `auto=true priority=critical url=http://IP_DEL_PORTATIL:8000/preseed-local.cfg`.
4. Esperar: instala sin preguntar y reinicia. **Parar el servidor del portátil** (`Ctrl+C`) en cuanto el instalador haya descargado el preseed.
5. Quitar el USB 1. Debe aparecer el `login:` de Debian.

**Si el preseed no se puede cargar** (sin portátil o sin red entre ambos): instalar a mano con las mismas decisiones, siguiendo el [README de la tarea 16](../16-recreativa-mame/README.md) (root en blanco, usuario `tecnico`, solo «Utilidades estándar» y «Servidor SSH»). Después, dejar SSH solo con clave:
```bash
printf 'PasswordAuthentication no\nKbdInteractiveAuthentication no\nPermitRootLogin no\n' | sudo tee /etc/ssh/sshd_config.d/90-recreativa.conf
sudo systemctl restart ssh
```

## 5. Convertirla en recreativa (≈5 min)

Entrar como `tecnico`, conectar el USB 2 y montarlo:

```bash
lsblk                                  # el USB suele ser sdb1 (o sdc1)
sudo mount /dev/sdb1 /mnt
cp /mnt/instalar-arcade.sh ~ && chmod +x ~/instalar-arcade.sh
sudo ~/instalar-arcade.sh 2>&1 | tee ~/salida-instalar-arcade.log
sudo cp /mnt/roms/*.zip /home/arcade/roms/ && sudo chown arcade:arcade /home/arcade/roms/*.zip
sudo -u arcade /usr/games/mame -rompath /home/arcade/roms -verifyroms gridlee robby supertnk targ teetert
```

Lo último debe acabar en `5 romsets found, 5 were OK`. Copiar `~/salida-instalar-arcade.log` al USB 2 para las evidencias y reiniciar: `sudo reboot`.

## 6. Conectarla a la Wi-Fi de invitados

En el local, la recreativa va a la Wi-Fi de invitados, aislada de la LAN. Seguir la [tarea 16, sección 6](../16-recreativa-mame/DOCUMENTACION.md#6-conexión-a-la-wi-fi-de-invitados) y **apuntar aquí el adaptador y su chip** (`lsusb`). Si en el aula todavía no está el router de la tarea 24 con la red de invitados, dejar la recreativa por cable y anotarlo como pendiente.

| Dato | Valor |
|---|---|
| Adaptador Wi-Fi y chip | |
| Paquete de firmware instalado | |
| IP recibida en la red de invitados | |

## 7. Comprobaciones

Resultado en la última columna (✅ / ❌ y la salida o la foto). Las pruebas por consola, en `Ctrl+Alt+F2` como `tecnico`.

| # | Prueba | Cómo | Esperado | Resultado |
|---|---|---|---|---|
| P1 | Arranque directo | Encender y cronometrar con el móvil hasta ver el menú de MAME | MAME sin tocar nada, sin pedir contraseña | |
| P2 | Tiempos de arranque | `systemd-analyze` | Apuntar kernel y userspace (comparar con 4,7 s de la VM) | |
| P3 | Recursos | `nproc` y `free -m` | 1 núcleo y ≈1 GB | |
| P4 | Juegos | Menú de MAME | Solo los 5 juegos; una partida con moneda y start | |
| P5 | MAME se vuelve a abrir | Salir de MAME con `Esc` | Se abre de nuevo solo | |
| P6 | `arcade` sin privilegios | `sudo -l -U arcade` y `passwd -S arcade` | «not allowed to run sudo» y estado `L` (bloqueada) | |
| P7 | Carpetas privadas | `ls /home/arcade` como `tecnico` | «Permiso denegado» | |
| P8 | SSH solo con clave | `sudo sshd -T \| grep -Ei 'passwordauth\|permitroot'` | `passwordauthentication no` y `permitrootlogin no` | |
| P9 | GRUB sin espera | `grep GRUB_TIMEOUT /etc/default/grub` | `GRUB_TIMEOUT=0` | |
| P10 | Stick Arduino (si está montado, tareas 19 y 50) | `grep -i arduino /proc/bus/input/devices` y jugar | Aparece el Leonardo y mueve en MAME | |
| P11 | Red de invitados | `ip -4 addr` | IP de la red de invitados, no `192.168.10.x` | |
| P12 | Aislamiento | `ping -c 4 192.168.10.31` y `ping -c 4 192.168.10.10` | Sin respuesta (pruebas 4 y 5 de la tarea 23) | |

## 8. Evidencias (en `evidencias/`)

| Fichero | Qué |
|---|---|
| `01-ficha-equipo.txt` | Salidas de la sección 3 |
| `02-instalando.jpg` | Foto del instalador trabajando sin preguntas |
| `03-salida-instalar-arcade.log` | Log del script (sección 5) |
| `04-verifyroms.txt` | `5 romsets found, 5 were OK` |
| `05-arranque-directo.jpg` | Foto del menú de MAME tras encender |
| `06-comprobaciones.txt` | Salidas de P2, P3, P6-P9, P11 y P12 |
| `07-partida-stick.jpg` | Partida con el stick (si está) |

> Antes de subir fotos, comprobar ampliándolas que no se lee ninguna contraseña (Wi-Fi, KeePassXC). gitleaks no mira dentro de las imágenes.

## 9. Seguridad

- `tecnico` con contraseña robusta guardada en KeePassXC; nunca en un `.txt` ni en el repositorio.
- `preseed-local.cfg` lleva el hash de esa contraseña: servirlo solo mientras dura la descarga y **borrarlo** después (`shred -u preseed-local.cfg`).
- SSH solo con clave y sin root (P8). En el local, la recreativa está en la red de invitados: desde la LAN no se llega a ella y se administra desde su consola (tarea 16, sección 7).
- Si se instaló con la versión antigua del preseed, borrar la clave `recreativa-claude` de `~tecnico/.ssh/authorized_keys` (tarea 16, corrección del 24/10). Con este preseed no hace falta.

## 10. Incidencias

| # | Incidencia | Causa | Solución |
|---|---|---|---|
| | | | |

## 11. Pendiente

- [ ] Ejecutar las secciones 3 a 7 en el equipo real y rellenar las tablas.
- [ ] Guardar las evidencias de la sección 8.
- [ ] Borrar `preseed-local.cfg` del portátil.
- [ ] Pasar a la tarea 54 (medidas en el equipo real).
