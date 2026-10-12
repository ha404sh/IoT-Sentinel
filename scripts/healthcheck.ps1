# IoT Sentinel Health Check
$ErrorActionPreference = "Continue"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$failed = 0
function Check($name, $ok) {
    if ($ok) { Write-Host ("{0,-25} PASS" -f $name) -ForegroundColor Green }
    else { Write-Host ("{0,-25} FAIL" -f $name) -ForegroundColor Red; $script:failed++ }
}

Write-Host "========================================"
Write-Host " IoT SENTINEL HEALTH CHECK"
Write-Host "========================================"

# Docker
$dockerOk = $false
try { docker info 2>$null | Out-Null; $dockerOk = ($LASTEXITCODE -eq 0) } catch {}
Check "Docker" $dockerOk

# Containers
$mosq = docker ps --filter "name=iot-sentinel-mosquitto" --format "{{.Status}}" 2>$null
$nr   = docker ps --filter "name=iot-sentinel-nodered" --format "{{.Status}}" 2>$null
Check "Mosquitto" ($mosq -match "Up")
Check "Node-RED"  ($nr -match "Up")

# MQTT port
$mqttOk = $false
try {
    $tcp = New-Object System.Net.Sockets.TcpClient
    $tcp.Connect("127.0.0.1", 1883)
    $mqttOk = $tcp.Connected
    $tcp.Close()
} catch {}
Check "MQTT reachable" $mqttOk

# Node-RED HTTP
$nrHttp = $false
try {
    $r = Invoke-WebRequest -Uri "http://localhost:1880" -UseBasicParsing -TimeoutSec 5
    $nrHttp = ($r.StatusCode -eq 200)
} catch {}
Check "Node-RED reachable" $nrHttp

# Database path
$dbPath = "database\iot_sentinel.db"
Check "Database path ready" (Test-Path "database")

Write-Host "========================================"
if ($failed -eq 0) {
    Write-Host " RESULT: PASS" -ForegroundColor Green
    exit 0
} else {
    Write-Host " RESULT: FAIL ($failed checks)" -ForegroundColor Red
    exit 1
}
