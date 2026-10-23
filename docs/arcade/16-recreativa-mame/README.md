# Tarea 16 · SO ligero y MAME con arranque directo

**Responsable:** Iker · **Revisa:** Markel · **Fechas:** 26–28 oct

Objetivo: al encender la recreativa arranca directamente MAME a pantalla completa, sin escritorio,
sin pedir usuario ni contraseña y sin dar privilegios de administrador al usuario que juega.

## Decisiones (para justificar en la documentación)

| Decisión | Por qué |
|---|---|
| **Debian 13 sin escritorio** | Estable, gratis y muy ligero: sin GNOME/KDE arranca en segundos y deja toda la RAM y la CPU para MAME. |
| **MAME desde los repos de Debian** | Se instala y actualiza con `apt`, sin compilar nada. |
| **X11 sin gestor de ventanas** | X solo abre MAME. No hay escritorio que el jugador pueda tocar. |
| **Autologin en tty1 con el usuario `arcade`** | Arranque directo sin teclado. La cuenta no tiene sudo ni contraseña (mínimos privilegios). |
| **MAME dentro de un bucle** | Si alguien sale de MAME con Esc, vuelve a abrirse solo. |
| **GRUB con timeout 0** | Se elimina la espera del menú de arranque. |

## Pasos

### 1. Instalar Debian 13 (≈20 min)
1. Descarga la ISO **netinst** de <https://www.debian.org/download> y grábala en un USB (con Balena Etcher o `dd`).
2. Arranca desde el USB y elige **Install** (el modo de texto vale).
3. Durante la instalación:
   - **Contraseña de root: déjala en blanco.** Así el usuario que crees ahora tendrá `sudo`.
   - Crea el usuario administrador, por ejemplo `tecnico` (⚠️ `admin` no vale: Debian lo tiene reservado).
   - En **Selección de programas**, **desmarca** "Entorno de escritorio" y "GNOME" y deja solo **"Utilidades estándar del sistema"**.
4. Termina la instalación, quita el USB y reinicia.

> 💡 Si todavía no tenéis la máquina física, haz todo esto antes en una máquina virtual (VirtualBox) para probarlo.

### 2. Ejecutar el script (≈5 min)
Inicia sesión como `tecnico`, copia `instalar-arcade.sh` (con un USB, `scp` o `wget` desde el repo) y ejecuta:

```bash
chmod +x instalar-arcade.sh
sudo ./instalar-arcade.sh
```

### 3. Copiar ROMs legales
Usad solo ROMs con licencia para uso libre: <https://www.mamedev.org/roms/> (Gridlee, Robby Roto, Super Tank, Targ, Teeter Torture…). Si la web está caída, usad su copia en el Internet Archive (ver DOCUMENTACION.md).
Copia los `.zip` **sin descomprimir** en `/home/arcade/roms/`:

```bash
sudo cp *.zip /home/arcade/roms/
sudo chown arcade:arcade /home/arcade/roms/*.zip
```

### 4. Reiniciar y comprobar
```bash
sudo reboot
```
Debería aparecer el menú de MAME sin que nadie toque nada.

**Para administrar:** pulsa `Ctrl+Alt+F2` para ir a una consola normal e inicia sesión como `tecnico`. Con `Ctrl+Alt+F1` vuelves a MAME.

## Evidencias para la documentación y el Kanban
- [ ] Captura de la selección de programas del instalador, con el escritorio desmarcado
- [ ] Salida del paso "6/6 Comprobación" del script
- [ ] Vídeo o fotos del encendido hasta el menú de MAME, cronometrado (sirve como dato "antes" para la tarea 17)
- [ ] `id arcade` para demostrar que no está en el grupo `sudo`
- [ ] Captura de un juego funcionando
- [ ] Script subido al repo (sirve también para la tarea 15, scripts reproducibles)

## Para la tarea 17 (rendimiento antes y después)
Guarda ya las medidas de partida, porque luego no podrás volver al estado inicial:

```bash
systemd-analyze                  # tiempo de arranque
free -h                          # RAM libre
sudo -u arcade mame -rompath /home/arcade/roms -bench 60 gridlee   # rendimiento de MAME
```

## Si algo falla
| Problema | Solución |
|---|---|
| Pantalla negra y vuelve a la consola una y otra vez | En `Ctrl+Alt+F2`, mira `/home/arcade/.local/share/xorg/Xorg.0.log`. Suele faltar un driver de vídeo: `sudo apt install xserver-xorg-video-all`. |
| MAME dice que no encuentra el juego | El `.zip` debe tener el nombre exacto (por ejemplo `gridlee.zip`), estar sin descomprimir y estar en `/home/arcade/roms`. |
| No hay sonido | `sudo -u arcade alsamixer`: sube el volumen y quita el silencio (tecla `M`). |
| Va lento en la máquina virtual | Es normal sin aceleración 3D. Activa la aceleración 3D en VirtualBox o pruébalo en la máquina real. |
