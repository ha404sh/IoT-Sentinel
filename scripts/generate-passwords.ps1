# Generate Mosquitto password file (requires mosquitto_passwd or Docker)
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$PassFile = "broker\config\passwordfile"
$Users = @(
    @{u="temp01"; p="Temp01-SecPass!"},
    @{u="hum01"; p="Hum01-SecPass!"},
    @{u="motion01"; p="Motion01-SecPass!"},
    @{u="door01"; p="Door01-SecPass!"},
    @{u="camera01"; p="Camera01-SecPass!"},
    @{u="light01"; p="Light01-SecPass!"},
    @{u="nodered"; p="NodeRed-SecPass!"}
)

Write-Host "Generating passwordfile via Docker mosquitto image..." -ForegroundColor Cyan
# Use temporary container to run mosquitto_passwd
$first = $true
foreach ($entry in $Users) {
    $flag = if ($first) { "-c" } else { "-b" }
    docker run --rm -v "${PWD}/broker/config:/mosquitto/config" eclipse-mosquitto:2.0.18 `
        mosquitto_passwd $flag -b /mosquitto/config/passwordfile $entry.u $entry.p
    if ($LASTEXITCODE -ne 0) { throw "mosquitto_passwd failed for $($entry.u)" }
    $first = $false
}
Write-Host "passwordfile created. Do NOT commit this file." -ForegroundColor Green
Write-Host "Update simulator to use these credentials when MQTT_ALLOW_ANONYMOUS=false"
