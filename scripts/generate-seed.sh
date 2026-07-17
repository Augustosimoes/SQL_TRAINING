#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo "==> Generating seed data..."

if [[ ! -f .env ]]; then
    cp .env.example .env
fi

pip install -q -r seed/requirements.txt
python3 seed/generate_data.py

echo "Done."
