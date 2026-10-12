#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
failed=0
pass() { echo -e "$1\tPASS"; }
fail() { echo -e "$1\tFAIL"; failed=$((failed+1)); }

docker info >/dev/null 2>&1 && pass "Docker" || fail "Docker"
docker ps --filter name=iot-sentinel-mosquitto --format '{{.Status}}' 2>/dev/null | grep -q Up && pass "Mosquitto" || fail "Mosquitto"
docker ps --filter name=iot-sentinel-nodered --format '{{.Status}}' 2>/dev/null | grep -q Up && pass "Node-RED" || fail "Node-RED"
(echo >/dev/tcp/127.0.0.1/1883) >/dev/null 2>&1 && pass "MQTT" || fail "MQTT"
curl -sf -o /dev/null http://127.0.0.1:1880/ && pass "Node-RED HTTP" || fail "Node-RED HTTP"
[ -d database ] && pass "Database dir" || fail "Database dir"

if [ "$failed" -eq 0 ]; then echo "RESULT: PASS"; exit 0; else echo "RESULT: FAIL"; exit 1; fi
