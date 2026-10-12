# IoT Sentinel - Setup Script (Windows + Docker Desktop)
$ErrorActionPreference = "Stop"
Write-Host "=== IoT Sentinel Setup ===" -ForegroundColor Cyan

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

# .env
if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "Created .env from .env.example"
} else {
    Write-Host ".env already exists"
}

# Directories
@("broker/data", "broker/log", "nodered/data", "database", "certificates/ca", "certificates/server", "certificates/clients") | ForEach-Object {
    New-Item -ItemType Directory -Force -Path $_ | Out-Null
}

# Password file placeholder (real generation requires mosquitto_passwd)
if (-not (Test-Path "broker/config/passwordfile")) {
    Copy-Item "broker/config/passwordfile.example" "broker/config/passwordfile"
    Write-Host "Created passwordfile placeholder. Generate real credentials before enabling auth."
}

Write-Host "Setup complete."
Write-Host "Next: review .env, generate certificates (see docs), then run .\scripts\start.ps1"
