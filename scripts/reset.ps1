$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root
Write-Host "RESET: This will stop services and remove runtime data (DB, Node-RED data, broker data)." -ForegroundColor Red
$confirm = Read-Host "Type YES to continue"
if ($confirm -ne "YES") { Write-Host "Aborted."; exit 1 }

docker compose down -v
Remove-Item -Force -ErrorAction SilentlyContinue "database\*.db"
if (Test-Path "nodered\data") { Remove-Item -Recurse -Force "nodered\data\*" }
if (Test-Path "broker\data") { Get-ChildItem "broker\data" -Exclude ".gitkeep" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path "broker\log") { Get-ChildItem "broker\log" -Exclude ".gitkeep" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue }

Write-Host "Runtime state cleared. Restarting..."
docker compose up -d
Write-Host "Reset complete."
