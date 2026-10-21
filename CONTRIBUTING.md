# Cómo trabajamos en el repo

## Primer uso

```bash
git clone <url-del-repo>
cd Reto-Asir
./scripts/instalar-hooks.sh
```

El hook `pre-commit` pasa [gitleaks](https://github.com/gitleaks/gitleaks) sobre lo que vas a commitear. Si no lo tienes instalado se salta, pero la GitHub Action lo comprueba en cada push.

## Ramas

- `main` siempre funciona: no se trabaja directamente en ella.
- Una rama por tarea: `bloque/descripcion-corta` (p. ej. `redes/plan-ip`, `web/slideshow`).
- Se integra con Pull Request revisado por otra persona.

## Mensajes de commit

```
<bloque>: <qué cambia, en presente>
```

Ejemplos: `web: añade slideshow de platos estrella`, `bd: crea DDL de la tabla pedidos`, `docs: documenta instalación de Odoo`.

Bloques: `gestion`, `hardware`, `so`, `arcade`, `arduino`, `redes`, `web`, `iac`, `erp`, `bd`, `backup`, `seguridad`, `docs`.

## Secretos

- Nunca se suben contraseñas, claves AWS, tokens ni `.env`.
- Se guardan en el gestor de contraseñas del equipo (Bitwarden/KeePassXC) o en AWS Secrets Manager / SSM.
- Para documentar variables, se sube un `.env.example` con valores falsos.
- Si se sube un secreto por error: **se revoca y se rota inmediatamente**; borrarlo del historial no basta.

## Uso de IA

Anótalo en [docs/gestion/registro-ia.md](docs/gestion/registro-ia.md).
