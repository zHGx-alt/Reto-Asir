#!/usr/bin/env bash
# Tarea 43 · Simulación de fallo de un disco del RAID **con Odoo funcionando** (sección 7 de DOCUMENTACION.md).
# Requisito: la BD ya está en el RAID (mover-docker-al-raid.sh). Comprueba que, con un disco averiado,
# Odoo sigue respondiendo y guardando ventas, y que el espejo se reconstruye solo al volver a añadir el disco.
#
#   sudo ./simular-fallo-con-odoo.sh 2>&1 | tee fallo-con-odoo.log
set -euo pipefail

MD=/dev/md0
RAID=/srv/datos
DIR_ODOO=/opt/odoo
falla() { echo "ERROR: $*" >&2; exit 1; }
paso() { printf '\n==> %s  (%s)\n' "$1" "$(date '+%T')"; }
login() { curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8069/web/login || true; }
sql() { (cd "$DIR_ODOO" && docker compose exec -T db sh -c "psql -U \"\$POSTGRES_USER\" -d tienda -tAc \"$1\""); }
recuento() { sql "select (select count(*) from pos_order) || ' pedidos TPV, ' || (select count(*) from sale_order) || ' pedidos de venta, ' || (select count(*) from account_move where state='posted') || ' asientos/facturas'"; }

[[ $EUID -eq 0 ]] || falla "ejecuta con sudo"

paso "1/6 Estado inicial"
estado=$(awk '/^md/{getline; print $NF; exit}' /proc/mdstat)
raiz=$(docker info --format '{{.DockerRootDir}}')
echo "RAID: $estado · Docker en: $raiz · login de Odoo: $(login)"
[[ $estado == "[UU]" ]] || falla "el RAID no está sano"
[[ $raiz == "$RAID/docker" ]] || falla "la BD no está en el RAID: antes, sudo ./mover-docker-al-raid.sh"
echo "Datos: $(recuento)"
mdadm --detail $MD | grep -E 'State :|Active Devices|/dev/sd'

AVERIADO=$(mdadm --detail $MD | awk '/active sync/{d=$NF} END{print d}')
paso "2/6 Avería de $AVERIADO"
mdadm $MD --fail "$AVERIADO"
sleep 2
cat /proc/mdstat
mdadm --detail $MD | grep -E 'State :|Active Devices|Failed Devices'

paso "3/6 Odoo con el RAID degradado"
echo "Login de Odoo: $(login) (esperado 200)"
echo
echo ">>> Haz AHORA una venta (TPV de barra o factura_automatica.py de la tarea 35) y pulsa Enter."
read -r _ </dev/tty
echo "Datos tras la venta: $(recuento)"
sql "checkpoint" >/dev/null && echo "CHECKPOINT de PostgreSQL: escrito en disco sin errores"
dmesg | grep -E 'md/raid1|md0' | tail -3 || true

paso "4/6 Cambio del disco (se vuelve a añadir el mismo, como si fuera uno nuevo)"
mdadm $MD --remove "$AVERIADO"
wipefs -a "$AVERIADO" >/dev/null
mdadm $MD --add "$AVERIADO"

paso "5/6 Reconstrucción"
inicio=$(date +%s)
while grep -qE 'recovery|resync' /proc/mdstat || ! grep -q '\[UU\]' /proc/mdstat; do
  grep -oE '(recovery|resync) = *[0-9.]+%' /proc/mdstat || true
  sleep 5
done
echo "Reconstruido en $(( $(date +%s) - inicio )) s"
cat /proc/mdstat

paso "6/6 Estado final"
mdadm --detail $MD | grep -E 'State :|Active Devices|Failed Devices|/dev/sd'
echo "Login de Odoo: $(login) · Datos: $(recuento)"
echo
echo "Listo: Odoo siguió funcionando y guardando con un disco averiado, y el espejo volvió a [UU]."
