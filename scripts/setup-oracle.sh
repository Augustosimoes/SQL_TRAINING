#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo "==> SQL Practice Lab - Oracle XE Setup"

bash "$SCRIPT_DIR/generate-seed.sh"

if [[ ! -f postgres/seed/data/customers.csv ]]; then
    echo "ERROR: Seed CSV files not found."
    exit 1
fi

echo "Starting Oracle XE container (first boot can take 2-5 minutes)..."
docker compose -f docker-compose.oracle.yml up -d

echo "Waiting for Oracle XE to be healthy..."
for i in $(seq 1 60); do
    if docker inspect --format='{{.State.Health.Status}}' sql-practice-oracle 2>/dev/null | grep -q healthy; then
        break
    fi
    sleep 5
done

echo "Installing Python dependencies for the Oracle loader..."
pip install -q -r oracle/seed/requirements.txt

echo "Loading bulk seed data into Oracle (this can take a few minutes)..."
python3 oracle/seed/load_oracle.py

source .env 2>/dev/null || true
ORA_PASS="${ORACLE_PASSWORD:-OraclePractice2024!}"

echo ""
echo "Setup complete!"
echo "  docker exec -it sql-practice-oracle sqlplus sqlstudent/$ORA_PASS@XEPDB1"
