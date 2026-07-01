#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

Write-Host "==> SQL Practice Lab - Reset Database" -ForegroundColor Yellow
Write-Host "This will remove the PostgreSQL volume and recreate everything."

$confirm = Read-Host "Continue? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Cancelled."
    exit 0
}

Write-Host "Stopping containers and removing volume..."
docker compose down -v

Write-Host "Re-running full setup..."
& "$PSScriptRoot\setup.ps1"
