#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

Write-Host "==> SQL Practice Lab - Oracle XE Setup" -ForegroundColor Cyan

& "$PSScriptRoot\generate-seed.ps1"

if (-not (Test-Path "seed\data\customers.csv")) {
    throw "Seed CSV files not found. Generation may have failed."
}

Write-Host "Starting Oracle XE container (first boot can take 2-5 minutes)..." -ForegroundColor Cyan
docker compose -f docker-compose.oracle.yml up -d

Write-Host "Waiting for Oracle XE to be healthy..."
$maxAttempts = 60
$attempt = 0
$healthy = $false

while ($attempt -lt $maxAttempts) {
    $status = docker inspect --format='{{.State.Health.Status}}' sql-practice-oracle 2>$null
    if ($status -eq "healthy") {
        $healthy = $true
        break
    }
    Start-Sleep -Seconds 5
    $attempt++
    if ($attempt % 6 -eq 0) {
        Write-Host "  still waiting... ($($attempt * 5)s elapsed)"
    }
}

if (-not $healthy) {
    throw "Oracle XE did not become healthy within $($maxAttempts * 5) seconds. Check: docker compose -f docker-compose.oracle.yml logs oracle-xe"
}

Write-Host "Oracle XE is healthy. Schema, dimensions, and DQ fixtures were loaded automatically on first init." -ForegroundColor Green

Write-Host "Installing Python dependencies for the Oracle loader..."
$Python = Get-Command python -ErrorAction SilentlyContinue
if (-not $Python) { $Python = Get-Command python3 -ErrorAction SilentlyContinue }
if (-not $Python) { throw "Python not found. Install Python 3.11+ and add it to PATH." }

& $Python.Source -m pip install -q -r "oracle\seed\requirements.txt"

Write-Host "Loading bulk seed data into Oracle (this can take a few minutes)..." -ForegroundColor Cyan
& $Python.Source "oracle\seed\load_oracle.py"

# Load .env for connection details to print
Get-Content ".env" | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
        [System.Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), "Process")
    }
}
$oraPass = if ($env:ORACLE_PASSWORD) { $env:ORACLE_PASSWORD } else { "OraclePractice2024!" }
$oraPort = if ($env:ORACLE_PORT)     { $env:ORACLE_PORT }     else { "1521" }

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "  Host:         localhost"
Write-Host "  Port:         $oraPort"
Write-Host "  Service name: XEPDB1"
Write-Host "  User:         sqlstudent"
Write-Host "  Password:     $oraPass"
Write-Host ""
Write-Host "Connect with SQL*Plus:"
Write-Host "  docker exec -it sql-practice-oracle sqlplus sqlstudent/$oraPass@XEPDB1"
Write-Host ""
Write-Host "Sample query:"
Write-Host "  SELECT * FROM v_order_summary FETCH FIRST 10 ROWS ONLY;"
