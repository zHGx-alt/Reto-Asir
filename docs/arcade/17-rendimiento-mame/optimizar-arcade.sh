#!/usr/bin/env bash
# Tarea 17 · Optimización de la recreativa (después de instalar-arcade.sh de la tarea 16)
#
# Objetivo: que MAME tenga la máquina para él solo. Se quitan tareas en segundo plano que pueden
# dar tirones en mitad de una partida y se libera disco y RAM. No se toca la seguridad: AppArmor y SSH siguen
# activos y las actualizaciones de seguridad automáticas se mantienen, a las 5:00.
#
# Uso:  sudo ./optimizar-arcade.sh        (idempotente: se puede ejecutar varias veces)
set -euo pipefail

log() { printf '\n==> %s\n' "$*"; }

[[ $EUID -eq 0 ]] || { echo "Ejecuta el script con sudo: sudo $0" >&2; exit 1; }

log "1/7 Desactivando tareas programadas que no hacen falta en una recreativa"
# man-db: regenera el índice de las páginas de manual.
# e2scrub_all / e2scrub_reap: solo sirven para volúmenes LVM, y aquí no hay LVM.
# dpkg-db-backup: copia diaria de la base de datos de paquetes.
# apt-daily y apt-daily-upgrade NO se quitan: se mueven fuera del horario del local (paso 2).
for unidad in man-db.timer e2scrub_all.timer dpkg-db-backup.timer e2scrub_reap.service; do
  systemctl disable --now "$unidad" 2>/dev/null && echo "  desactivado: $unidad" || echo "  (no existe: $unidad)"
done

log "2/7 Actualizaciones de seguridad automáticas a las 5:00, con el local cerrado"
# Seguridad por defecto: la recreativa está en la Wi-Fi de clientes y no puede quedarse sin parches.
# Las descargas e instalaciones dan tirones, así que se hacen de madrugada y no durante las partidas.
# Si a esa hora está apagada, Persistent=true las lanza al arrancar (unos minutos, antes de abrir).
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq unattended-upgrades >/dev/null
cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
for t in apt-daily:04:30 apt-daily-upgrade:05:00; do
  mkdir -p "/etc/systemd/system/${t%%:*}.timer.d"
  cat > "/etc/systemd/system/${t%%:*}.timer.d/90-recreativa.conf" <<EOF
[Timer]
OnCalendar=
OnCalendar=*-*-* ${t#*:}
RandomizedDelaySec=0
Persistent=true
EOF
done
systemctl daemon-reload
systemctl enable --now apt-daily.timer apt-daily-upgrade.timer
echo "  apt-daily a las 04:30 y apt-daily-upgrade (unattended-upgrades) a las 05:00"

log "3/7 Desactivando cron (sus tareas diarias ya las llevan los timers de systemd)"
systemctl disable --now cron.service 2>/dev/null && echo "  desactivado: cron.service" || true

log "4/7 Ajustando memoria: evitar que MAME acabe en swap"
cat > /etc/sysctl.d/90-recreativa.conf <<'EOF'
# Recreativa: usar la swap solo cuando la RAM esté casi llena (por defecto 60)
vm.swappiness = 10
EOF
sysctl -q --system
echo "  vm.swappiness = $(cat /proc/sys/vm/swappiness)"

log "5/7 Limitando el tamaño de los logs"
mkdir -p /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/90-recreativa.conf <<'EOF'
[Journal]
SystemMaxUse=50M
EOF
systemctl restart systemd-journald
journalctl --vacuum-size=50M -q || true

log "6/7 CPU a máximo rendimiento (solo en máquinas físicas con cpufreq)"
if [[ -d /sys/devices/system/cpu/cpu0/cpufreq ]]; then
  cat > /etc/systemd/system/cpu-rendimiento.service <<'EOF'
[Unit]
Description=Gobernador de CPU en modo performance (recreativa)

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance > "$g"; done'

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  systemctl enable --now cpu-rendimiento.service
  echo "  gobernador: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
else
  echo "  Sin cpufreq (máquina virtual): se omite."
fi

log "7/7 Liberando disco (paquetes y kernels que ya no se usan, caché de apt)"
DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge -y -qq
apt-get clean

log "Resumen"
echo "Servicios en marcha: $(systemctl list-units --type=service --state=running --no-legend | wc -l)"
echo "Timers activos:      $(systemctl list-timers --no-legend | wc -l)"
echo "Disco usado:         $(df -h / | awk 'NR==2{print $3}')"
echo
echo "Listo. Reinicia para medir el resultado:  sudo reboot"
