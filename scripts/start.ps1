# Start IoT Sentinel services
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

Write-Host "Starting IoT Sentinel..." -ForegroundColor Cyan
docker compose up -d
if ($LASTEXITCODE -ne 0) { throw "docker compose up failed" }

Write-Host "Waiting for health..."
Start-Sleep -Seconds 8
docker compose ps
Write-Host "Mosquitto MQTT :1883 (TLS :8883)"
Write-Host "Node-RED Dashboard: http://localhost:1880"
