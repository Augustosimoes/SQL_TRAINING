#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo "==> SQL Practice Lab - Full Setup"

bash "$SCRIPT_DIR/generate-seed.sh" 2>/dev/null || {
    # generate-seed inline if script missing
    if [[ ! -f .env ]]; then
        cp .env.example .env
    fi
    pip install -q -r postgres/seed/requirements.txt
    python3 postgres/seed/generate_data.py
}

if [[ ! -f postgres/seed/data/customers.csv ]]; then
    echo "ERROR: Seed CSV files not found."
    exit 1
fi

docker compose up -d

echo "Waiting for PostgreSQL..."
for i in $(seq 1 30); do
    if docker inspect --format='{{.State.Health.Status}}' sql-practice-postgres 2>/dev/null | grep -q healthy; then
        break
    fi
    sleep 2
done

source .env 2>/dev/null || true
PG_USER="${POSTGRES_USER:-sqlstudent}"
PG_DB="${POSTGRES_DB:-retail_dw}"

echo "Loading bulk seed data..."
docker exec -i sql-practice-postgres psql -U "$PG_USER" -d "$PG_DB" -f /seed/load_bulk.sql

echo ""
echo "Setup complete!"
echo "  docker exec -it sql-practice-postgres psql -U $PG_USER -d $PG_DB"
