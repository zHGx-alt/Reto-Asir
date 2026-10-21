# Guía de Git del equipo

Cómo trabajar en este repositorio sin pisarnos y sin complicarnos. Si solo vas a leer una sección, lee **[3. El día a día](#3-el-día-a-día)**.

## 0. Ideas básicas

| Concepto | Qué es |
|---|---|
| **Repositorio** | La carpeta del proyecto con todo su historial. Hay una copia en GitHub (*remoto*, `origin`) y una en tu ordenador (*local*). |
| **Commit** | Una "foto" guardada de los cambios, con un mensaje que dice qué has hecho. Queda en el historial con tu nombre. |
| **Push / Pull** | `push` sube tus commits a GitHub. `pull` baja los commits de los demás. |
| **Rama** (*branch*) | Una copia paralela del proyecto donde haces tu tarea sin tocar la versión buena. |
| **`main`** | La rama principal. Siempre debe funcionar. **Nadie trabaja directamente en ella.** |
| **Pull Request (PR)** | La petición en GitHub para unir tu rama a `main`. Otra persona la revisa y la aprueba. |

Por qué lo hacemos así: el profesor evalúa que **todos** tengan commits propios (Anexo IX), y las ramas + PR evitan que alguien rompa el trabajo de otro.

## 1. Preparación (una sola vez)

### 1.1 Cuenta y acceso

1. Crea una cuenta en [github.com](https://github.com) si no tienes.
2. Pásale tu usuario a Adrian para que te invite al repo.
3. Acepta la invitación que te llega por correo (o en github.com → icono de notificaciones).

### 1.2 Instalar Git

- **Windows:** instala [Git for Windows](https://git-scm.com/download/win) con las opciones por defecto. Usa la terminal *Git Bash* para los comandos de esta guía.
- **Linux (Ubuntu/Debian):** `sudo apt install git`

### 1.3 Decirle a Git quién eres

Con el mismo correo de tu cuenta de GitHub, para que los commits cuenten como tuyos:

```bash
git config --global user.name "Tu Nombre"
```

```bash
git config --global user.email "tu-correo-de-github@ejemplo.com"
```

Y para que `git pull` no se queje cuando tú y otra persona habéis subido cambios a la vez:

```bash
git config --global pull.rebase false
```

### 1.4 Clonar el repositorio

```bash
git clone https://github.com/zHGx-alt/Reto-Asir.git
```

```bash
cd Reto-Asir
```

```bash
./scripts/instalar-hooks.sh
```

El último comando activa un control que impide subir contraseñas o claves por error (ver [6. Secretos](#6-secretos)).

La primera vez que hagas `push`, Git te pedirá iniciar sesión en GitHub: en Windows se abre una ventana del navegador; acepta y listo. En Linux, lo más cómodo es una clave SSH ([guía de GitHub](https://docs.github.com/es/authentication/connecting-to-github-with-ssh)).

### ¿Prefieres no usar la terminal?

**VS Code** tiene Git integrado (icono de ramas en la barra lateral, "Source Control"): permite crear ramas, hacer commit, push y pull con botones. **GitHub Desktop** es otra opción sencilla. El flujo de trabajo es el mismo que el de esta guía; solo cambia que pulsas botones en vez de escribir comandos.

## 2. Normas

1. **Una rama por tarea**, con el nombre `bloque/descripcion-corta`: `redes/plan-ip`, `web/slideshow`, `bd/modelo-er`.
2. **Nunca** se hace commit ni push directamente a `main`.
3. Todo entra en `main` mediante **Pull Request**, aprobado por el revisor que indica el [Gantt](docs/gestion/gantt.md).
4. Commits **pequeños y frecuentes**, mejor varios al día que uno enorme al final.
5. Mensajes con el formato `bloque: qué cambia` (ver [5. Mensajes de commit](#5-mensajes-de-commit)).
6. **Nada de contraseñas, claves ni tokens** en el repositorio.

## 3. El día a día

Ejemplo: Eneko.P empieza la tarea *Plano del local y plan de direccionamiento IP*.

**1. Ponerse al día antes de empezar**

```bash
git switch main
```

```bash
git pull
```

**2. Crear la rama de la tarea** (solo el primer día de la tarea)

```bash
git switch -c redes/plan-ip
```

**3. Trabajar normalmente** — crear y editar ficheros en su carpeta (`docs/`, `web/`, `scripts/`…).

**4. Ver qué ha cambiado**

```bash
git status
```

**5. Guardar los cambios en un commit**

```bash
git add .
```

```bash
git commit -m "redes: añade plan de direccionamiento IP por VLAN"
```

**6. Subirlo a GitHub**

La primera vez en esa rama:

```bash
git push -u origin redes/plan-ip
```

Las siguientes veces basta con:

```bash
git push
```

Repite 3-6 tantas veces como quieras mientras dure la tarea.

**7. Al terminar: abrir el Pull Request**

1. Entra en el repo en GitHub. Aparecerá un aviso amarillo *"redes/plan-ip had recent pushes"* → **Compare & pull request**.
2. Título: el nombre de la tarea. Descripción: qué has hecho y dónde están las evidencias.
3. A la derecha, en **Reviewers**, añade a tu revisor (columna *Revisa* del Gantt).
4. **Create pull request**.

**8. Revisión y merge**

- El revisor abre el PR, mira la pestaña **Files changed**, y pulsa **Review changes → Approve** o deja comentarios.
- Si hay comentarios, el autor corrige en su rama, hace commit y push: el PR se actualiza solo.
- Una vez aprobado: **Merge pull request** → **Delete branch**.

**9. Volver a `main` para la siguiente tarea**

```bash
git switch main
```

```bash
git pull
```

## 4. Problemas habituales

| Situación | Solución |
|---|---|
| `git push` dice *rejected* / *fetch first* | Alguien subió cambios antes. Haz `git pull` y vuelve a hacer `git push`. |
| He empezado a trabajar en `main` sin crear rama (sin commit aún) | `git switch -c bloque/nombre` — tus cambios se vienen a la nueva rama. |
| Necesito los últimos cambios de `main` en mi rama | Desde tu rama: `git pull origin main` |
| **Conflicto** al hacer pull o merge | Git marca en el fichero las dos versiones entre `<<<<<<<`, `=======` y `>>>>>>>`. Deja el contenido correcto, borra las marcas y luego `git add .` y `git commit`. En VS Code aparecen botones *Accept Current / Incoming / Both*. Si no lo ves claro, pide ayuda antes de forzar nada. |
| Mensaje del último commit mal escrito (aún sin push) | `git commit --amend -m "mensaje correcto"` |
| No sé en qué rama estoy | `git status` (primera línea) |
| Quiero descartar los cambios de un fichero sin commitear | `git restore ruta/del/fichero` (se pierden esos cambios) |
| El hook dice *Posible secreto detectado* | Quita la contraseña/clave del fichero y vuelve a hacer el commit. |

Para evitar conflictos: cada uno trabaja en los ficheros de su tarea, y se hace `pull` de `main` a menudo.

**No uses nunca** `git push --force` ni `git reset --hard` sin consultarlo con el equipo: pueden borrar trabajo de otros.

## 5. Mensajes de commit

```
bloque: qué cambia, en presente
```

| Bien | Mal |
|---|---|
| `web: añade slideshow de platos estrella` | `cambios` |
| `bd: crea DDL de la tabla pedidos` | `aaa` |
| `docs: documenta instalación de Odoo con Docker` | `ya funciona` |

Bloques: `gestion`, `hardware`, `so`, `arcade`, `arduino`, `redes`, `web`, `iac`, `erp`, `bd`, `backup`, `seguridad`, `docs`.

## 6. Secretos

- Nunca se suben contraseñas, claves AWS, tokens ni ficheros `.env`. El `.gitignore` ya bloquea los más comunes.
- Las credenciales del proyecto se guardan en el gestor de contraseñas del equipo (Bitwarden/KeePassXC) o en AWS Secrets Manager / SSM.
- Para documentar qué variables hacen falta, se sube un `.env.example` con valores falsos.
- Hay dos controles con [gitleaks](https://github.com/gitleaks/gitleaks): uno en tu ordenador al hacer commit (si lo tienes instalado) y otro en GitHub en cada push.
- Si se sube un secreto por error: **avisa y cámbialo inmediatamente** (contraseña nueva, clave revocada). Borrarlo del historial no es suficiente.

## 7. Chuleta

| Quiero… | Comando |
|---|---|
| Bajar lo último | `git pull` |
| Empezar una tarea | `git switch main` → `git pull` → `git switch -c bloque/tarea` |
| Ver qué he cambiado | `git status` |
| Guardar cambios | `git add .` → `git commit -m "bloque: mensaje"` |
| Subirlos | `git push` (la primera vez: `git push -u origin bloque/tarea`) |
| Cambiar de rama | `git switch nombre-rama` |
| Ver el historial | `git log --oneline` |

## 8. Uso de IA

Anótalo en [docs/gestion/registro-ia.md](docs/gestion/registro-ia.md).
