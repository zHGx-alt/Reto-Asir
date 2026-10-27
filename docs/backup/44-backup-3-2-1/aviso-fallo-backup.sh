#!/usr/bin/env bash
# Tarea 44 · Aviso cuando la copia nocturna falla. Lo lanza systemd (OnFailure= de backup-odoo.service).
#
#   1. Siempre: mensaje de error en el journal (prioridad err) y fichero /var/lib/backup-odoo/ULTIMO-FALLO,
#      que se ve con "cat" y que el técnico revisa en el procedimiento semanal.
#   2. Siempre: mensaje a las sesiones abiertas en el servidor (wall).
#   3. Si en /etc/default/backup-odoo hay AVISO_CORREO=... y el servidor tiene "mail" (un MTA configurado),
#      correo con las últimas 40 líneas del log.
set -uo pipefail

ESTADO=/var/lib/backup-odoo
[[ -r /etc/default/backup-odoo ]] && source /etc/default/backup-odoo
LOG=$(journalctl -u backup-odoo.service -n 40 --no-pager -o cat 2>/dev/null)
MOTIVO=$(grep -E 'ERROR|Fatal|error' <<<"$LOG" | tail -1)
TEXTO="La copia de seguridad de Odoo ha FALLADO el $(date '+%d/%m/%Y a las %H:%M') en $(hostname). ${MOTIVO:-Ver: journalctl -u backup-odoo}"

logger -t backup-odoo -p user.err "$TEXTO"
install -d -m 700 "$ESTADO"
{ echo "$TEXTO"; echo; echo "$LOG"; } > "$ESTADO/ULTIMO-FALLO"
wall "$TEXTO" 2>/dev/null || true

if [[ -n ${AVISO_CORREO:-} ]]; then
  if command -v mail >/dev/null; then
    { echo "$TEXTO"; echo; echo "Últimas líneas:"; echo "$LOG"; } | mail -s "FALLO en la copia de Odoo ($(hostname))" "$AVISO_CORREO" \
      && logger -t backup-odoo "Aviso de fallo enviado a $AVISO_CORREO"
  else
    logger -t backup-odoo -p user.warning "AVISO_CORREO está puesto pero no hay 'mail' (falta un MTA): solo journal y $ESTADO/ULTIMO-FALLO"
  fi
fi
exit 0
