# Oracle XE

This lab uses **Oracle Database Express Edition (XE) 21c** running in Docker, loaded with the
full retail dataset (1,000+ customers, 500+ products, 5,000+ orders, and related tables).

## Quick Start

```powershell
cd C:\Users\ricar\Projects\sql-practice-lab
copy .env.example .env
.\scripts\setup-oracle.ps1
```

This will:
1. Generate the seed CSVs (`seed/generate_data.py`)
2. Start Oracle XE in Docker (first boot takes **2-5 minutes** -- Oracle has to expand its
   pre-built database files)
3. Auto-run `oracle/init/01_schema.sql`, `02_dimensions.sql`, `03_data_quality.sql` on first
   container init (schema, small reference tables, hand-crafted DQ fixtures)
4. Bulk-load customers/products/orders/items/inventory/payments via
   `oracle/seed/load_oracle.py` (Python, `python-oracledb` thin driver -- no Oracle Instant
   Client required)
5. Verify minimum row counts

Manual/step-by-step equivalent:

```powershell
docker compose -f docker-compose.oracle.yml up -d
docker compose -f docker-compose.oracle.yml ps          # wait for "healthy"
pip install -r oracle\seed\requirements.txt
python oracle\seed\load_oracle.py
```

## Connection Details

| Setting      | Value |
|--------------|-------|
| Host         | `localhost` |
| Port         | `1521` |
| Service name | `XEPDB1` |
| App user     | `sqlstudent` |
| Password     | `OraclePractice2024!` (from `.env`) |
| SYS/SYSTEM   | Same password as `ORACLE_PASSWORD` |

### SQL*Plus (inside container)

```powershell
docker exec -it sql-practice-oracle sqlplus sqlstudent/OraclePractice2024!@XEPDB1
```

### DBeaver / SQL Developer

- Driver: Oracle
- URL: `jdbc:oracle:thin:@localhost:1521/XEPDB1`
- User: `sqlstudent`

## Why gvenzl/oracle-xe, and the trade-offs of Oracle-via-Docker

Oracle Database is not distributed the way Postgres or MySQL are -- there's no minimal
"just run a binary" story, and until fairly recently there was no straightforward Docker
image at all (Oracle's own `Dockerfile` build scripts require you to download the installer
manually). Two viable Docker paths exist today:

| | **`gvenzl/oracle-xe`** (used here) | **Official Oracle image** (`container-registry.oracle.com/database/express`) |
|---|---|---|
| Publisher | Community (Gerald Venzl, Oracle ACE) | Oracle Corporation |
| Pull requires login | No -- public on Docker Hub | Yes -- free Oracle account + accept license via `docker login container-registry.oracle.com` |
| Image size (slim) | ~650 MB | ~1.9 GB (no slim variant) |
| First-boot time | 2-5 min (pre-expanded `-faststart` variants exist, ~30s) | 5-10 min |
| Init-script convention | `/container-entrypoint-initdb.d`, well documented, `APP_USER`/`APP_USER_PASSWORD` convenience env vars | `/opt/oracle/scripts/setup`, more manual |
| Maintenance | Actively maintained, used by Hibernate, Testcontainers, Spring Data, Apache Spark, etc. | Maintained by Oracle, updated less frequently |
| Support | None (community) | None for XE either -- XE itself carries no Oracle support contract |
| Best for | Local dev/learning, CI, this lab | Teams that specifically want an Oracle-published artifact for compliance/provenance reasons |

**Recommendation for this lab:** `gvenzl/oracle-xe:21-slim`, which is what
`docker-compose.oracle.yml` uses. No login wall, smaller pull, faster to get productive, and
it's the same underlying Oracle XE 21c binary either way -- the image only differs in how it's
packaged and distributed, not in SQL/PL-SQL behavior.

### XE itself has real limits (same on both images)

- 2 CPU threads, 2 GB RAM, 12 GB user data max -- enforced by Oracle, not the container
- No Real Application Clusters, Data Guard, partitioning, or other Enterprise Edition features
- These limits are irrelevant for a SQL practice lab (this dataset is well under 12 GB) but
  matter if you're evaluating Oracle features beyond straight SQL/PL-SQL

### Oracle XE is legacy; Oracle Database Free (23ai) is the successor

Oracle stopped updating XE at 21c and now ships **Oracle Database Free** (23ai+) as XE's
replacement, also available via `gvenzl/oracle-free`. It supports newer SQL (native `BOOLEAN`
in SQL, JSON relational duality, etc.) under the same free/no-support terms. This lab targets
XE 21c because interview and coursework environments still standardize on it and its syntax
(`ROWNUM`, no SQL-level booleans) is what you're most likely to be tested on. If you want to
practice on the newer engine instead, swap the image tag to `gvenzl/oracle-free:23-slim` --
the schema in `oracle/init/` is compatible with both with no changes required.

## SQL Syntax Differences (Quick Reference)

| Task | PostgreSQL | Oracle |
|------|------------|--------|
| Limit rows | `LIMIT 10` | `FETCH FIRST 10 ROWS ONLY` or `WHERE ROWNUM <= 10` |
| Null handling | `COALESCE(x, 0)` | `NVL(x, 0)` (or `COALESCE`, also supported) |
| Current date | `CURRENT_DATE` | `SYSDATE` / `SYSTIMESTAMP` |
| String concat | `\|\|` or `CONCAT()` | `\|\|` |
| Auto-increment | `SERIAL` / `GENERATED ... IDENTITY` | `GENERATED ALWAYS AS IDENTITY` (12c+) |
| Boolean columns | `BOOLEAN` | `NUMBER(1)` + `CHECK (col IN (0,1))` (native `BOOLEAN` in SQL only from 23c on) |
| Upsert | `ON CONFLICT` | `MERGE INTO` |
| Text blob | `TEXT` | `CLOB` |
| Row generation | `generate_series()` | `CONNECT BY LEVEL <= n` |

## Stopping / Resetting

```powershell
docker compose -f docker-compose.oracle.yml down       # stop, keep data
docker compose -f docker-compose.oracle.yml down -v     # stop, wipe data
.\scripts\reset-oracle.ps1                               # wipe + full rebuild
```

## Troubleshooting

**Container never reports healthy / init scripts didn't seem to run**
Init scripts (`oracle/init/*.sql`) only run on the *first* startup of a fresh volume. Check
progress with `docker compose -f docker-compose.oracle.yml logs -f oracle-xe` -- Oracle prints
its own startup banner and step-by-step init log, look for `CONTAINER: running ... 01_schema.sql`.

**`load_oracle.py` fails to connect**
The container can report `healthy` slightly before the listener is fully ready to accept
connections. The script retries 10 times with a 5s backoff; if it still fails, wait 30s and
rerun `python oracle\seed\load_oracle.py` (it's safe to rerun before any rows are loaded --
it checks for existing bulk-loaded rows and refuses to double-insert).

**`ORA-12154` / `ORA-12514`**
Service name mismatch. This lab uses `XEPDB1`, not `XE` (`XE` is the container database /
root, not the pluggable database the app user lives in).

**Port 1521 already in use**
Common if you have a local Oracle client or another container using it. Change `ORACLE_PORT`
in `.env` and reconnect using the new port.
