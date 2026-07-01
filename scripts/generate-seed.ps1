#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

Write-Host "==> SQL Practice Lab - Generate Seed Data" -ForegroundColor Cyan

if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "Created .env from .env.example"
    } else {
        throw ".env file not found. Copy .env.example to .env first."
    }
}

$Python = Get-Command python -ErrorAction SilentlyContinue
if (-not $Python) {
    $Python = Get-Command python3 -ErrorAction SilentlyContinue
}
if (-not $Python) {
    throw "Python not found. Install Python 3.11+ and add it to PATH."
}

Write-Host "Installing Python dependencies..."
& $Python.Source -m pip install -q -r "postgres\seed\requirements.txt"

Write-Host "Generating CSV files..."
& $Python.Source "postgres\seed\generate_data.py"

Write-Host "Seed data generation complete." -ForegroundColor Green
