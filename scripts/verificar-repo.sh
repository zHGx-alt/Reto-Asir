#!/usr/bin/env bash
# Comprobaciones automáticas del repositorio (ver docs/gestion/verificacion.md).
# Uso: bash scripts/verificar-repo.sh
# Las pruebas que necesitan Docker o PlatformIO se saltan si no están instalados.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)"
fallos=0
ok()    { printf '  OK     %s\n' "$*"; }
mal()   { printf '  FALLO  %s\n' "$*"; fallos=$((fallos + 1)); }
salta() { printf '  --     %s (se salta: %s)\n' "$1" "$2"; }
hay()   { command -v "$1" >/dev/null 2>&1; }

echo "== Planificación"
if python3 scripts/gantt.py >/dev/null; then ok "backlog-kanban.csv válido y Gantt regenerado"; else mal "scripts/gantt.py"; fi

echo "== Enlaces relativos de los .md"
rotos=$(python3 - <<'EOF'
import re, subprocess, urllib.parse
from pathlib import Path
for f in subprocess.check_output(["git", "ls-files", "*.md"], text=True).split():
    p = Path(f)
    txt = re.sub(r"```.*?```", "", p.read_text(encoding="utf-8"), flags=re.S)
    for m in re.finditer(r"!?\[[^\]]*\]\(([^)\s]+)", txt):
        u = m.group(1)
        if re.match(r"[a-z]+:", u) or u.startswith("#"):
            continue
        destino = urllib.parse.unquote(u.split("#")[0])
        if destino and not (p.parent / destino).exists():
            print(f"{f}: {u}")
EOF
)
if [[ -z "$rotos" ]]; then ok "ningún enlace roto"; else mal "enlaces rotos:"; echo "$rotos" | sed 's/^/           /'; fi

echo "== Sintaxis de scripts"
for f in $(git ls-files '*.py'); do python3 -m py_compile "$f" 2>/dev/null && ok "$f" || mal "$f"; done
for f in $(git ls-files '*.sh'); do bash -n "$f" 2>/dev/null && ok "$f" || mal "$f"; done

echo "== Firmware del arcade stick"
PIO=$(command -v pio || echo "$HOME/.platformio/penv/bin/pio")
if [[ -x "$PIO" ]]; then
  (cd arduino/mando-joystick && "$PIO" run -s) >/dev/null 2>&1 && ok "compila para Leonardo" || mal "no compila"
else salta "compilación" "no hay PlatformIO"; fi

if ! hay docker; then
  salta "shellcheck, SQL, W3C y gitleaks" "no hay Docker"
else
  echo "== shellcheck (errores)"
  if docker run --rm -v "$PWD:/m:ro" -w /m koalaman/shellcheck:v0.10.0 -S error $(git ls-files '*.sh') >/dev/null; then
    ok "sin errores"; else mal "shellcheck encuentra errores"; fi

  echo "== Base de datos (PostgreSQL 16)"
  docker rm -f verif-pg >/dev/null 2>&1
  docker run -d --name verif-pg -e POSTGRES_PASSWORD=verif -v "$PWD/docs/bd/scripts:/s:ro" postgres:16 >/dev/null
  until docker exec verif-pg pg_isready -U postgres -q 2>/dev/null; do sleep 1; done; sleep 2
  psql_() { docker exec verif-pg psql -U postgres -v ON_ERROR_STOP=1 -q "$@" </dev/null; }
  psql_ -c "CREATE DATABASE almi_chain" >/dev/null
  for s in 01-crear-tablas 02-reglas 03-roles; do psql_ -d almi_chain -f "/s/$s.sql" >/dev/null 2>&1 && ok "$s.sql" || mal "$s.sql"; done
  n=$(psql_ -d almi_chain -f /s/05-pruebas.sql 2>&1 | grep -c 'OK ')
  [[ "$n" -eq 33 ]] && ok "05-pruebas.sql: 33/33" || mal "05-pruebas.sql: $n/33"
  psql_ -d almi_chain -f /s/06-datos.sql >/dev/null 2>&1 && ok "06-datos.sql" || mal "06-datos.sql"
  n=$(psql_ -d almi_chain -tAc "SELECT count(*) FROM factura")
  [[ "$n" -eq 8 ]] && ok "06-datos.sql: 8 facturas cargadas" || mal "06-datos.sql: $n facturas (se esperaban 8)"
  psql_ -d almi_chain -f /s/07-consultas.sql >/dev/null 2>&1 && ok "07-consultas.sql: 12 consultas sin errores" || mal "07-consultas.sql"
  psql_ -d almi_chain -c "CREATE ROLE verif_app LOGIN PASSWORD 'verif'; GRANT rol_aplicacion TO verif_app;" >/dev/null
  if docker exec verif-pg psql -U verif_app -d almi_chain -c "CREATE TABLE intruso(id int)" </dev/null >/dev/null 2>&1; then
    mal "rol_aplicacion puede crear tablas"; else ok "rol_aplicacion no puede hacer DDL"; fi
  docker rm -f verif-pg >/dev/null

  echo "== Web (validador Nu del W3C)"
  docker run --rm -v "$PWD/web:/w:ro" ghcr.io/validator/validator:latest vnu --errors-only /w/index.html >/dev/null 2>&1 \
    && ok "index.html" || mal "index.html"
  docker run --rm -v "$PWD/web:/w:ro" ghcr.io/validator/validator:latest vnu --css --errors-only /w/style.css >/dev/null 2>&1 \
    && ok "style.css" || mal "style.css"

  echo "== Secretos (gitleaks, todo el historial)"
  docker run --rm -v "$PWD:/repo:ro" zricethezav/gitleaks:v8.18.4 detect --source /repo \
    --config /repo/.gitleaks.toml --redact --no-banner >/dev/null 2>&1 && ok "sin secretos" || mal "gitleaks detecta secretos"
fi

echo
if [[ $fallos -eq 0 ]]; then echo "Todo correcto."; else echo "$fallos comprobación(es) fallida(s)."; fi
exit $(( fallos > 0 ))
