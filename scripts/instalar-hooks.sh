#!/usr/bin/env bash
# Activa los hooks del repo (ejecutar una vez tras clonar).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
git config core.hooksPath scripts/git-hooks
chmod +x scripts/git-hooks/*
echo "Hooks activados (core.hooksPath = scripts/git-hooks)."
