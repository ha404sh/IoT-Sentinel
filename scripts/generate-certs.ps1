# Generate local development CA and broker certificates for IoT Sentinel
# Requires OpenSSL available in PATH
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$CaDir = "certificates\ca"
$ServerDir = "certificates\server"
$ClientsDir = "certificates\clients"

New-Item -ItemType Directory -Force -Path $CaDir, $ServerDir, $ClientsDir | Out-Null

Write-Host "Generating CA..." -ForegroundColor Cyan
if (-not (Test-Path "$CaDir\ca.key")) {
    openssl genrsa -out "$CaDir\ca.key" 4096
    openssl req -x509 -new -nodes -key "$CaDir\ca.key" -sha256 -days 3650 `
        -out "$CaDir\ca.crt" -subj "/CN=IoT-Sentinel-CA/O=IoT-Sentinel/C=US"
}

Write-Host "Generating broker certificate..." -ForegroundColor Cyan
openssl genrsa -out "$ServerDir\server.key" 2048
openssl req -new -key "$ServerDir\server.key" -out "$ServerDir\server.csr" `
    -subj "/CN=mosquitto/O=IoT-Sentinel/C=US"
# SAN for localhost and container name
@"
[req]
distinguished_name = req_distinguished_name
[req_distinguished_name]
[v3_ext]
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
DNS.2 = mosquitto
DNS.3 = iot-sentinel-mosquitto
IP.1 = 127.0.0.1
"@ | Out-File -Encoding ascii "$ServerDir\server.ext"
openssl x509 -req -in "$ServerDir\server.csr" -CA "$CaDir\ca.crt" -CAkey "$CaDir\ca.key" `
    -CAcreateserial -out "$ServerDir\server.crt" -days 825 -sha256 -extfile "$ServerDir\server.ext" -extensions v3_ext

Write-Host "Certificates generated under certificates/" -ForegroundColor Green
Write-Host "NOTE: Private keys must never be committed. Ensure .gitignore covers them."
