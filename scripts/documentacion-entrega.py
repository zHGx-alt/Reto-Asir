#!/usr/bin/env python3
"""Junta toda la documentación del reto en un único PDF para la entrega.

Uso:
    python3 scripts/documentacion-entrega.py          # genera entrega/Almi-Chain-documentacion.pdf
    python3 scripts/documentacion-entrega.py --html   # deja también el HTML (para revisarlo)

Necesita Docker (imagen pandoc/core:3.5) y Google Chrome o Chromium para pasar
el HTML a PDF. Los diagramas Mermaid se dibujan con mermaid.js, que se descarga
de jsdelivr al generar el PDF (hace falta red).

El orden de los documentos está en PARTES. Si se añade un .md nuevo en docs/
y no se mete en PARTES, el script avisa y no genera nada: así el PDF no se
queda sin un documento.
"""
import argparse
import base64
import json
import datetime as dt
import html
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
SALIDA = RAIZ / "entrega" / "Almi-Chain-documentacion.pdf"
GITHUB = "https://github.com/zHGx-alt/Reto-Asir/blob/main/"
PANDOC = "pandoc/core:3.5"
MERMAID = "https://cdn.jsdelivr.net/npm/mermaid@11.4.1/dist/mermaid.min.js"

# (título de la parte, [documentos en orden])
PARTES = [
    ("Presentación del proyecto", [
        "README.md",
        "LOGICA_RETO.md",
    ]),
    ("Gestión del proyecto", [
        "docs/gestion/anexo-I-contrato-equipo.md",
        "docs/gestion/anexo-II-11-pasos.md",
        "docs/gestion/roles.md",
        "docs/gestion/gantt.md",
        "docs/gestion/maquinas-virtuales.md",
        "docs/gestion/registro-ia.md",
        "CONTRIBUTING.md",
    ]),
    ("Hardware, software y presupuesto (tareas 7-11)", [
        "docs/hardware/07-necesidades-equipos.md",
        "docs/hardware/08-tabla-hardware.md",
        "docs/hardware/09-tabla-software-licencias.md",
        "docs/hardware/10-presupuesto-hardware.md",
        "docs/diagramas/11-arquitectura-equipos/DIAGRAMA.md",
    ]),
    ("Sistemas operativos e impresora (tareas 12-15, 37 y 64)", [
        "docs/so/12-dual-boot.md",
        "docs/so/13-tpv/Tarea13_Markdown_GitHub/13-bastionado-tpv-windows.md",
        "docs/so/13-tpv/DOCUMENTACION.md",
        "docs/so/14-impresora/DOCUMENTACION.md",
    ]),
    ("Máquina recreativa (tareas 16-18, 51, 53 y 54)", [
        "docs/arcade/16-recreativa-mame/DOCUMENTACION.md",
        "docs/arcade/16-recreativa-mame/STICK-ARDUINO.md",
        "docs/arcade/16-batocera/NOTAS.md",
        "docs/arcade/17-rendimiento-mame/DOCUMENTACION.md",
        "docs/arcade/18-monitorizacion-recreativa.md",
        "docs/arcade/53-recreativa-fisica/DOCUMENTACION.md",
        "docs/arcade/54-medidas-equipo-real/DOCUMENTACION.md",
    ]),
    ("Arcade stick con Arduino (tareas 19-21, 50 y 59)", [
        "arduino/mando-joystick/README.md",
        "arduino/mando-joystick/batocera/README.md",
    ]),
    ("Redes (tareas 22-26)", [
        "docs/redes/22-comparativa-wan.md",
        "docs/redes/23-plano-direccionamiento.md",
        "docs/redes/23-packet-tracer-red-local.md",
        "docs/redes/24-red-segura/DOCUMENTACION.md",
        "docs/redes/24-red-segura/configurar-red-segura.md",
        "docs/redes/25-wds/DOCUMENTACION.md",
        "docs/redes/26-analisis-conectividad/DOCUMENTACION.md",
    ]),
    ("Página web y hosting en AWS (tareas 27-31)", [
        "docs/web/27-wireframes.md",
        "docs/web/30-hosting-aws.md",
        "iac/README.md",
    ]),
    ("ERP y TPV: Odoo (tareas 32-37, 52 y 63)", [
        "docs/erp/32-comparativa-erp.md",
        "docs/erp/33-odoo-docker/DOCUMENTACION.md",
        "docs/erp/34-configurar-odoo/DOCUMENTACION.md",
        "docs/erp/35-factura-automatica/DOCUMENTACION.md",
        "docs/erp/36-importar-exportar/DOCUMENTACION.md",
        "docs/erp/52-https-odoo/DOCUMENTACION.md",
        "docs/erp/52-https-odoo/RUNBOOK.md",
        "docs/erp/63-uso-modulos/GUIA.md",
    ]),
    ("Base de datos del establecimiento (tareas 38-42, 56 y 57)", [
        "docs/bd/38-modelo-er.md",
        "docs/bd/39-modelo-logico-3fn.md",
        "docs/bd/40-scripts-ddl.md",
        "docs/bd/57-integracion-odoo.md",
    ]),
    ("Disco redundante, copias y restauración (tareas 43-45, 48 y 60)", [
        "docs/backup/43-raid1/DOCUMENTACION.md",
        "docs/backup/44-backup-3-2-1/DOCUMENTACION.md",
        "docs/backup/45-restauracion/DOCUMENTACION.md",
        "docs/backup/48-documentacion-final-restauracion.md",
    ]),
    ("Seguridad en toda la solución (tarea 46)", [
        "docs/seguridad/46-revision-seguridad/DOCUMENTACION.md",
    ]),
    ("Digitalización: tecnologías habilitadoras (tarea 58)", [
        "docs/digitalizacion/58-tecnologias-habilitadoras.md",
    ]),
    ("Pruebas, verificación y evaluación", [
        "docs/gestion/47-tabla-pruebas.md",
        "docs/gestion/verificacion.md",
        "docs/gestion/rubrica-anexo-VI.md",
        "CORRECIONES.md",
    ]),
]

IMAGEN = re.compile(r"\.(png|jpe?g|gif|svg|webp)$", re.I)


def slug(ruta):
    return "doc-" + re.sub(r"[^a-z0-9]+", "-", ruta.lower()).strip("-")


def comprobar_completo():
    """Todo .md de docs/ (y los README sueltos) tiene que estar en PARTES."""
    incluidos = {d for _, docs in PARTES for d in docs}
    faltan = [d for d in incluidos if not (RAIZ / d).is_file()]
    sobran = sorted(
        str(p.relative_to(RAIZ))
        for p in list((RAIZ / "docs").rglob("*.md"))
        + list((RAIZ / "arduino").rglob("*.md"))
        + list((RAIZ / "iac").rglob("*.md"))
        if str(p.relative_to(RAIZ)) not in incluidos
    )
    if faltan or sobran:
        for d in faltan:
            print(f"ERROR: está en PARTES pero no existe: {d}", file=sys.stderr)
        for d in sobran:
            print(f"ERROR: documento sin meter en PARTES: {d}", file=sys.stderr)
        sys.exit(1)
    return incluidos


def reescribir_destino(destino, carpeta, incluidos):
    """Ajusta un enlace relativo de un documento al PDF único."""
    if re.match(r"^[a-z]+:|^#|^//", destino, re.I):
        return destino
    camino, _, frag = destino.partition("#")
    if not camino:
        return destino
    absoluto = (carpeta / camino).resolve()
    try:
        rel = absoluto.relative_to(RAIZ).as_posix()
    except ValueError:
        return destino
    if IMAGEN.search(camino):
        return absoluto.as_uri()
    if rel in incluidos:
        return "#" + slug(rel)
    return GITHUB + rel + (("#" + frag) if frag else "")


def preparar(ruta, incluidos):
    """Lee un .md, baja un nivel sus títulos y arregla enlaces e imágenes."""
    carpeta = (RAIZ / ruta).parent
    salida, en_codigo, valla = [], False, ""
    for linea in (RAIZ / ruta).read_text(encoding="utf-8").splitlines():
        m = re.match(r"^\s*(```+|~~~+)", linea)
        if m:
            if not en_codigo:
                en_codigo, valla = True, m.group(1)
            elif linea.strip().startswith(valla):
                en_codigo = False
            salida.append(linea)
            continue
        if en_codigo:
            salida.append(linea)
            continue
        if re.match(r"^#{1,5} ", linea):
            linea = "#" + linea
        linea = re.sub(
            r"(\]\()([^)\s]+)",
            lambda m: m.group(1) + reescribir_destino(m.group(2), carpeta, incluidos),
            linea,
        )
        linea = re.sub(
            r'((?:src|href)=")([^"]+)',
            lambda m: m.group(1) + reescribir_destino(m.group(2), carpeta, incluidos),
            linea,
        )
        salida.append(linea)
    fuente = f"[{ruta}]({GITHUB}{ruta})"
    cabecera = (
        f'\n\n<div class="doc" id="{slug(ruta)}"></div>\n\n'
        f'<p class="fuente">Fuente en el repositorio: {fuente}</p>\n\n'
    )
    texto = "\n".join(salida)
    # El enlace de la fuente va como Markdown dentro de HTML: lo paso a HTML.
    cabecera = cabecera.replace(
        fuente, f'<a href="{GITHUB}{ruta}">{html.escape(ruta)}</a>'
    )
    if not re.search(r"^## ", texto, re.M):  # documento sin título propio
        texto = f"## {ruta}\n\n" + texto
    # La cabecera va justo después del primer título del documento.
    texto = re.sub(r"^(## .*)$", lambda m: m.group(1) + cabecera, texto, count=1, flags=re.M)
    return texto


def git(*args):
    return subprocess.run(["git", "-C", str(RAIZ), *args], capture_output=True,
                          text=True).stdout.strip()


def portada():
    hoy = dt.date.today().strftime("%d/%m/%Y")
    commit = git("rev-parse", "--short", "HEAD")
    return f"""<section class="portada">
<p class="curso">ASIR 1 · Curso 2026-2027</p>
<h1 class="titulo">Reto 1 · Almi-Chain</h1>
<p class="subtitulo">Solución informática para una cadena de restaurantes<br>Documentación completa del proyecto</p>
<p class="equipo"><strong>Equipo:</strong> Adrian, Iker, Eneko.S, Eneko.P, Markel y Peio</p>
<p class="datos">Repositorio: <a href="https://github.com/zHGx-alt/Reto-Asir">github.com/zHGx-alt/Reto-Asir</a><br>
Web publicada: <a href="https://almichain1.duckdns.org">almichain1.duckdns.org</a><br>
Generado el {hoy} desde el commit <code>{commit}</code></p>
</section>

<section class="leeme">
<h2 class="sin-indice">Cómo está organizado este documento</h2>
<p>Reúne en un solo archivo toda la documentación del repositorio, en el orden en que se monta la solución:
primero la visión de conjunto (qué pide el enunciado y qué pieza lo resuelve) y la gestión del equipo, y después
un capítulo por bloque técnico, con las guías de cada tarea tal y como están en el repositorio. Al final van la
tabla de pruebas, la verificación y la rúbrica.</p>
<p>Cada documento indica debajo de su título de qué archivo del repositorio sale. Los scripts, configuraciones,
registros de salida y evidencias en texto no se copian aquí para no duplicarlos: los enlaces llevan a ellos en GitHub.
Las capturas sí van dentro del documento.</p>
<p>Para el recorrido rápido: el capítulo <em>Lógica del reto Almi-Chain</em> (parte 1) explica cómo encajan todas
las piezas y su sección 15 dice cómo montarlo todo desde cero, en orden.</p>
</section>
"""


CSS = """
@page { size: A4; margin: 18mm 16mm 18mm 16mm; }
body { font-family: "DejaVu Sans", "Liberation Sans", Arial, sans-serif; font-size: 10pt;
       line-height: 1.45; color: #1a1a1a; background: #fff; }
a { color: #0b5394; text-decoration: none; word-break: break-word; }
h1, h2, h3, h4 { color: #0d2e4f; line-height: 1.25; break-after: avoid; }
h1 { font-size: 22pt; break-before: page; border-bottom: 3px solid #0d2e4f; padding-bottom: 4px; }
h2 { font-size: 15pt; break-before: page; border-bottom: 1px solid #b7c7d8; padding-bottom: 3px; }
h3 { font-size: 12.5pt; } h4 { font-size: 11pt; } h5, h6 { font-size: 10pt; }
.parte-num { display: block; font-size: 11pt; color: #5a6f86; letter-spacing: .08em; text-transform: uppercase; }
p.fuente { font-size: 8.5pt; color: #5a6f86; margin-top: -4px; }
table { border-collapse: collapse; width: 100%; margin: 8px 0; font-size: 8.5pt; break-inside: auto; }
tr { break-inside: avoid; }
th, td { border: 1px solid #c9d3de; padding: 3px 5px; vertical-align: top; text-align: left; }
th { background: #e8eef5; }
pre { background: #f5f7f9; border: 1px solid #dde3ea; padding: 6px 8px; font-size: 8pt;
      white-space: pre-wrap; word-break: break-word; }
code { font-family: "DejaVu Sans Mono", "Liberation Mono", monospace; font-size: 8.5pt; }
pre.mermaid { background: none; border: none; text-align: center; white-space: pre; }
img, svg { max-width: 100%; height: auto; }
img { max-height: 210mm; display: block; margin: 6px auto; break-inside: avoid; }
blockquote { border-left: 3px solid #b7c7d8; margin: 8px 0; padding: 2px 10px; color: #333; background: #f7f9fb; }
.portada { height: 250mm; display: flex; flex-direction: column; justify-content: center; text-align: center; }
.portada .curso { font-size: 12pt; color: #5a6f86; letter-spacing: .1em; text-transform: uppercase; }
.portada .titulo { font-size: 36pt; border: none; break-before: avoid; margin: 10px 0; }
.portada .subtitulo { font-size: 15pt; color: #0d2e4f; }
.portada .equipo { font-size: 12pt; margin-top: 40px; }
.portada .datos { font-size: 10pt; color: #444; margin-top: 30px; }
.leeme h2, #TOC + h1 { break-before: page; }
nav#TOC { break-before: page; font-size: 10pt; }
nav#TOC > ul { list-style: none; padding-left: 0; }
nav#TOC > ul > li { margin-top: 8px; font-weight: bold; }
nav#TOC > ul > li > ul { font-weight: normal; list-style: none; padding-left: 16px; }
nav#TOC li li { margin: 1px 0; }
nav#TOC::before { content: "Índice"; display: block; font-size: 22pt; font-weight: bold;
                  color: #0d2e4f; border-bottom: 3px solid #0d2e4f; margin-bottom: 10px; }
"""


def chrome():
    for nombre in ("google-chrome", "chromium", "chromium-browser", "google-chrome-stable"):
        if shutil.which(nombre):
            return nombre
    sys.exit("ERROR: hace falta Google Chrome o Chromium para generar el PDF")


PIE = ('<div style="font-size:7.5pt;width:100%;padding:0 16mm;color:#5a6f86;'
       'display:flex;justify-content:space-between;font-family:sans-serif">'
       '<span>Reto 1 · Almi-Chain</span>'
       '<span><span class="pageNumber"></span> / <span class="totalPages"></span></span></div>')


def imprimir(html_final, pdf):
    """Imprime con Chrome por el protocolo de depuración (fd 3 y 4) para poner número de página."""
    leer_chrome, escribir_py = os.pipe()   # fd 3 de Chrome: lo que le mando
    leer_py, escribir_chrome = os.pipe()   # fd 4 de Chrome: lo que contesta
    perfil = tempfile.mkdtemp()

    def hijo():
        os.dup2(leer_chrome, 3)
        os.dup2(escribir_chrome, 4)

    proc = subprocess.Popen(
        [chrome(), "--headless=new", "--disable-gpu", "--remote-debugging-pipe",
         "--allow-file-access-from-files", f"--user-data-dir={perfil}", "about:blank"],
        pass_fds=(3, 4), preexec_fn=hijo,
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    os.close(leer_chrome)
    os.close(escribir_chrome)
    salida, entrada = os.fdopen(escribir_py, "wb"), os.fdopen(leer_py, "rb")
    pendiente, n = b"", 0

    def orden(metodo, sesion=None, **params):
        nonlocal pendiente, n
        n += 1
        msg = {"id": n, "method": metodo, "params": params}
        if sesion:
            msg["sessionId"] = sesion
        salida.write(json.dumps(msg).encode() + b"\0")
        salida.flush()
        while True:
            while b"\0" not in pendiente:
                trozo = entrada.read1(1 << 20)
                if not trozo:
                    sys.exit("ERROR: Chrome se ha cerrado")
                pendiente += trozo
            linea, pendiente = pendiente.split(b"\0", 1)
            r = json.loads(linea)
            if r.get("id") == n:
                if "error" in r:
                    sys.exit(f"ERROR de Chrome en {metodo}: {r['error']}")
                return r["result"]

    try:
        destino = orden("Target.createTarget", url=html_final.as_uri())["targetId"]
        sesion = orden("Target.attachToTarget", targetId=destino, flatten=True)["sessionId"]
        for _ in range(600):   # hasta 2 minutos para cargar imágenes y dibujar los Mermaid
            r = orden("Runtime.evaluate", sesion, expression="typeof window.listo")
            if r["result"].get("value") == "object":
                break
            time.sleep(0.2)
        orden("Runtime.evaluate", sesion, expression="window.listo", awaitPromise=True)
        r = orden("Page.printToPDF", sesion, printBackground=True, preferCSSPageSize=True,
                  displayHeaderFooter=True, headerTemplate="<span></span>", footerTemplate=PIE)
        pdf.write_bytes(base64.b64decode(r["data"]))
    finally:
        proc.kill()
        proc.wait()
        shutil.rmtree(perfil, ignore_errors=True)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--html", action="store_true", help="guardar también el HTML en entrega/")
    args = ap.parse_args()

    incluidos = comprobar_completo()
    trozos = []
    for n, (titulo, docs) in enumerate(PARTES, 1):
        trozos.append(f"\n\n# Parte {n} · {titulo}\n")
        trozos.extend(preparar(d, incluidos) for d in docs)
    markdown = "\n".join(trozos)

    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        (tmp / "todo.md").write_text(markdown, encoding="utf-8")
        subprocess.run(
            ["docker", "run", "--rm", "-u", f"{os.getuid()}:{os.getgid()}",
             "-v", f"{tmp}:/data", PANDOC, "todo.md", "-f", "gfm", "-t", "html5",
             "--standalone", "--metadata", "title=Almi-Chain", "--toc",
             "--toc-depth=2", "-o", "cuerpo.html"],
            check=True,
        )
        cuerpo = (tmp / "cuerpo.html").read_text(encoding="utf-8")
        # Con --standalone sale el índice (nav#TOC); me quedo con el <body> sin el título de pandoc.
        cuerpo = re.search(r"<body>(.*)</body>", cuerpo, re.S).group(1)
        cuerpo = re.sub(r'<header id="title-block-header">.*?</header>', "", cuerpo, flags=re.S)
        # Pandoc deja ```mermaid como <pre class="mermaid"><code>: mermaid quiere el texto directo.
        cuerpo = re.sub(r'<pre class="mermaid"><code>(.*?)</code></pre>',
                        r'<pre class="mermaid">\1</pre>', cuerpo, flags=re.S)
        # Un enlace (no una imagen incrustada) a una captura: mejor a GitHub que a una ruta local.
        cuerpo = re.sub(r'href="' + re.escape(RAIZ.as_uri()) + r'/([^"]+)"',
                        lambda m: f'href="{GITHUB}{m.group(1)}"', cuerpo)
        # «Parte N · Título»: el número en una línea aparte.
        cuerpo = re.sub(r'(<h1 id="[^"]*">)Parte (\d+) · ',
                        r'\1<span class="parte-num">Parte \2</span>', cuerpo)
        pagina = f"""<!doctype html>
<html lang="es"><head><meta charset="utf-8">
<title>Almi-Chain · Documentación completa</title>
<style>{CSS}</style>
<script src="{MERMAID}"></script>
</head><body>
{portada()}
{cuerpo}
<script>
mermaid.initialize({{ startOnLoad: false, theme: "neutral", securityLevel: "loose" }});
const cargada = new Promise(r => document.readyState === "complete" ? r() : addEventListener("load", r));
window.listo = Promise.all([cargada, mermaid.run({{ querySelector: "pre.mermaid" }}).catch(e => console.error(e))]);
</script>
</body></html>"""
        html_final = tmp / "documentacion.html"
        html_final.write_text(pagina, encoding="utf-8")

        SALIDA.parent.mkdir(exist_ok=True)
        imprimir(html_final, SALIDA)
        if args.html:
            shutil.copy(html_final, SALIDA.with_suffix(".html"))
    tam = SALIDA.stat().st_size / 1e6
    print(f"Generado {SALIDA.relative_to(RAIZ)} ({tam:.1f} MB) con "
          f"{sum(len(d) for _, d in PARTES)} documentos en {len(PARTES)} partes")


if __name__ == "__main__":
    main()
