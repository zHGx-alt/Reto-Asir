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
if [[ -x "$PIO" ]]; then pio_() { "$PIO" "$@"; }
else
  for py in python3 python; do                    # instalado con pip (pip install platformio)
    if $py -m platformio --version >/dev/null 2>&1; then PY_PIO=$py; pio_() { "$PY_PIO" -m platformio "$@"; }; break; fi
  done
fi
if declare -F pio_ >/dev/null; then
  (cd arduino/mando-joystick && pio_ run -s) >/dev/null 2>&1 && ok "compila para Leonardo" || mal "no compila"
else salta "compilación" "no hay PlatformIO"; fi

# Pruebas de la BD (tareas 40-42). psql_ <usuario> <argumentos de psql>; $S = carpeta de los scripts.
probar_bd() {
  psql_ postgres -c "CREATE DATABASE almi_chain" >/dev/null
  for s in 01-crear-tablas 02-reglas 03-roles; do psql_ postgres -d almi_chain -f "$S/$s.sql" >/dev/null 2>&1 && ok "$s.sql" || mal "$s.sql"; done
  n=$(psql_ postgres -d almi_chain -f "$S/05-pruebas.sql" 2>&1 | grep -c 'OK ')
  [[ "$n" -eq 33 ]] && ok "05-pruebas.sql: 33/33" || mal "05-pruebas.sql: $n/33"
  psql_ postgres -d almi_chain -f "$S/06-datos.sql" >/dev/null 2>&1 && ok "06-datos.sql" || mal "06-datos.sql"
  n=$(psql_ postgres -d almi_chain -tAc "SELECT count(*) FROM factura")
  [[ "$n" -eq 8 ]] && ok "06-datos.sql: 8 facturas cargadas" || mal "06-datos.sql: $n facturas (se esperaban 8)"
  psql_ postgres -d almi_chain -f "$S/07-consultas.sql" >/dev/null 2>&1 && ok "07-consultas.sql: 12 consultas sin errores" || mal "07-consultas.sql"
  psql_ postgres -d almi_chain -v pass_tpv=verif -v pass_informes=verif -f "$S/08-usuarios.sql" >/dev/null 2>&1     && ok "08-usuarios.sql" || mal "08-usuarios.sql"
  for u in tpv_app informes; do
    n=$(psql_ "$u" -d almi_chain -v cuenta="$u" -f "$S/09-pruebas-usuarios.sql" 2>&1 | grep -c 'OK  ')
    [[ "$n" -eq 9 ]] && ok "09-pruebas-usuarios.sql como $u: 9/9" || mal "09-pruebas-usuarios.sql como $u: $n/9"
  done
}

echo "== Base de datos"
if hay docker; then
  docker rm -f verif-pg >/dev/null 2>&1
  docker run -d --name verif-pg -e POSTGRES_PASSWORD=verif -v "$PWD/docs/bd/scripts:/s:ro" postgres:16 >/dev/null
  until docker exec verif-pg pg_isready -U postgres -q 2>/dev/null; do sleep 1; done; sleep 2
  S=/s
  psql_() { local u=$1; shift; docker exec verif-pg psql -U "$u" -v ON_ERROR_STOP=1 -q "$@" </dev/null; }
  probar_bd
  docker rm -f verif-pg >/dev/null
else
  # Sin Docker: un clúster temporal de PostgreSQL en otro puerto (no toca el servidor que haya instalado).
  PGBIN=$(dirname "$(command -v initdb 2>/dev/null || ls -d /c/Program\ Files/PostgreSQL/*/bin/initdb.exe 2>/dev/null | tail -1)")
  if [[ -x "$PGBIN/initdb" || -x "$PGBIN/initdb.exe" ]]; then
    TMPPG=$(mktemp -d)
    "$PGBIN/initdb" -D "$TMPPG/datos" -U postgres -A trust -E UTF8 --locale=C >/dev/null 2>&1
    "$PGBIN/pg_ctl" -D "$TMPPG/datos" -o "-p 55433" -l "$TMPPG/log" -w start >/dev/null
    S=docs/bd/scripts
    psql_() { local u=$1; shift; "$PGBIN/psql" -h localhost -p 55433 -U "$u" -v ON_ERROR_STOP=1 -q "$@" </dev/null; }
    probar_bd
    "$PGBIN/pg_ctl" -D "$TMPPG/datos" -m fast -w stop >/dev/null; rm -rf "$TMPPG"
  else salta "SQL" "no hay Docker ni PostgreSQL"; fi
fi

if ! hay docker; then
  salta "shellcheck, W3C y gitleaks" "no hay Docker"
else
  echo "== shellcheck (errores)"
  if docker run --rm -v "$PWD:/m:ro" -w /m koalaman/shellcheck:v0.10.0 -S error $(git ls-files '*.sh') >/dev/null; then
    ok "sin errores"; else mal "shellcheck encuentra errores"; fi

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
