$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root
Write-Host "Stopping IoT Sentinel..." -ForegroundColor Yellow
docker compose down
Write-Host "Stopped."
