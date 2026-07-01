#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

Write-Host "==> SQL Practice Lab - Reset Oracle XE" -ForegroundColor Yellow
Write-Host "This will remove the Oracle XE volume and recreate everything (2-5 min first boot)."

$confirm = Read-Host "Continue? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Cancelled."
    exit 0
}

Write-Host "Stopping container and removing volume..."
docker compose -f docker-compose.oracle.yml down -v

Write-Host "Re-running full Oracle setup..."
& "$PSScriptRoot\setup-oracle.ps1"
