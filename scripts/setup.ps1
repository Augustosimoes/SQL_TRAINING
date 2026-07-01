#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

Write-Host "==> SQL Practice Lab - Full Setup" -ForegroundColor Cyan

& "$PSScriptRoot\generate-seed.ps1"

if (-not (Test-Path "postgres\seed\data\customers.csv")) {
    throw "Seed CSV files not found. Generation may have failed."
}

Write-Host "Starting PostgreSQL container..."
docker compose up -d

Write-Host "Waiting for PostgreSQL to be healthy..."
$maxAttempts = 30
$attempt = 0
$healthy = $false

while ($attempt -lt $maxAttempts) {
    $status = docker inspect --format='{{.State.Health.Status}}' sql-practice-postgres 2>$null
    if ($status -eq "healthy") {
        $healthy = $true
        break
    }
    Start-Sleep -Seconds 2
    $attempt++
}

if (-not $healthy) {
    throw "PostgreSQL did not become healthy within $($maxAttempts * 2) seconds."
}

# Load .env for credentials
Get-Content ".env" | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
        [System.Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), "Process")
    }
}

$pgUser = if ($env:POSTGRES_USER) { $env:POSTGRES_USER } else { "sqlstudent" }
$pgDb   = if ($env:POSTGRES_DB)   { $env:POSTGRES_DB }   else { "retail_dw" }
$pgPort = if ($env:POSTGRES_PORT) { $env:POSTGRES_PORT } else { "5432" }

Write-Host "Loading bulk seed data..."
docker exec -i sql-practice-postgres psql -U $pgUser -d $pgDb -f /seed/load_bulk.sql

Write-Host ""
Write-Host "Verifying row counts..." -ForegroundColor Cyan
$verifySql = @"
SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM retail.customers) >= 1000 THEN 'OK'
        ELSE 'FAIL'
    END AS customers_check,
    CASE
        WHEN (SELECT COUNT(*) FROM retail.sales_orders) >= 5000 THEN 'OK'
        ELSE 'FAIL'
    END AS orders_check,
    CASE
        WHEN (SELECT COUNT(*) FROM retail.products) >= 500 THEN 'OK'
        ELSE 'FAIL'
    END AS products_check;
"@

$result = docker exec -i sql-practice-postgres psql -U $pgUser -d $pgDb -t -A -c $verifySql
Write-Host "Verification: $result"

if ($result -notmatch "OK\|OK\|OK") {
    Write-Host "WARNING: Some tables may not meet minimum row counts." -ForegroundColor Yellow
}

$pgPass = if ($env:POSTGRES_PASSWORD) { $env:POSTGRES_PASSWORD } else { "SqlPractice2024!" }

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "  Host:     localhost"
Write-Host "  Port:     $pgPort"
Write-Host "  Database: $pgDb"
Write-Host "  User:     $pgUser"
Write-Host "  Password: $pgPass"
Write-Host "  Schema:   retail"
Write-Host ""
Write-Host "Connect with psql:"
Write-Host "  docker exec -it sql-practice-postgres psql -U $pgUser -d $pgDb"
Write-Host ""
Write-Host "Sample query:"
Write-Host "  SELECT * FROM retail.v_order_summary LIMIT 10;"
