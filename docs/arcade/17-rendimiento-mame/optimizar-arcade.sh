#!/usr/bin/env bash
# Tarea 17 · Optimización de la recreativa (después de instalar-arcade.sh de la tarea 16)
#
# Objetivo: que MAME tenga la máquina para él solo. Se quitan tareas en segundo plano que pueden
# dar tirones en mitad de una partida y se libera disco y RAM. No se toca la seguridad (AppArmor y SSH siguen activos).
#
# Uso:  sudo ./optimizar-arcade.sh        (idempotente: se puede ejecutar varias veces)
set -euo pipefail

log() { printf '\n==> %s\n' "$*"; }

[[ $EUID -eq 0 ]] || { echo "Ejecuta el script con sudo: sudo $0" >&2; exit 1; }

log "1/6 Desactivando tareas programadas que no hacen falta en una recreativa"
# apt-daily / apt-daily-upgrade: descargan e instalan actualizaciones en segundo plano (CPU, disco y red durante la partida).
#   Las actualizaciones se hacen a mano en el mantenimiento: sudo apt update && sudo apt full-upgrade
# man-db: regenera el índice de las páginas de manual.
# e2scrub_all / e2scrub_reap: solo sirven para volúmenes LVM, y aquí no hay LVM.
# dpkg-db-backup: copia diaria de la base de datos de paquetes.
for unidad in apt-daily.timer apt-daily-upgrade.timer man-db.timer e2scrub_all.timer dpkg-db-backup.timer e2scrub_reap.service; do
  systemctl disable --now "$unidad" 2>/dev/null && echo "  desactivado: $unidad" || echo "  (no existe: $unidad)"
done

log "2/6 Desactivando cron (sus tareas diarias ya las llevan los timers de systemd)"
systemctl disable --now cron.service 2>/dev/null && echo "  desactivado: cron.service" || true

log "3/6 Ajustando memoria: evitar que MAME acabe en swap"
cat > /etc/sysctl.d/90-recreativa.conf <<'EOF'
# Recreativa: usar la swap solo cuando la RAM esté casi llena (por defecto 60)
vm.swappiness = 10
EOF
sysctl -q --system
echo "  vm.swappiness = $(cat /proc/sys/vm/swappiness)"

log "4/6 Limitando el tamaño de los logs"
mkdir -p /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/90-recreativa.conf <<'EOF'
[Journal]
SystemMaxUse=50M
EOF
systemctl restart systemd-journald
journalctl --vacuum-size=50M -q || true

log "5/6 CPU a máximo rendimiento (solo en máquinas físicas con cpufreq)"
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

log "6/6 Liberando disco (paquetes y kernels que ya no se usan, caché de apt)"
DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge -y -qq
apt-get clean

log "Resumen"
echo "Servicios en marcha: $(systemctl list-units --type=service --state=running --no-legend | wc -l)"
echo "Timers activos:      $(systemctl list-timers --no-legend | wc -l)"
echo "Disco usado:         $(df -h / | awk 'NR==2{print $3}')"
echo
echo "Listo. Reinicia para medir el resultado:  sudo reboot"
