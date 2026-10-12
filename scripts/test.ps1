# IoT Sentinel - Acceptance Validation (final version)
$ErrorActionPreference = "Continue"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$resultsDir = Join-Path $Root "tests\results"
New-Item -ItemType Directory -Force -Path $resultsDir | Out-Null

$script:failed = 0

function Log($m) { Write-Host $m }

function Assert-Result($testName, $command, $assertion, $actual, $ok) {
    $status = if ($ok) { "PASS" } else { "FAIL" }
    if (-not $ok) { $script:failed++ }
    Log "----------------------------------------"
    Log "Test: $testName"
    Log "Command: $command"
    Log "Assertion: $assertion"
    Log "Observed: $actual"
    Log "Verdict: $status"
}

Log "========================================"
Log " IoT SENTINEL FINAL VALIDATION"
Log " $(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')"
Log "========================================"

# --- Docker ---
$dockerOk = $false
try { docker info 2>$null | Out-Null; $dockerOk = ($LASTEXITCODE -eq 0) } catch {}

if (-not $dockerOk) { Log "SKIPPED - Docker unavailable. Unit tests only." }

# --- Unit tests ---
Log ""
Log ">>> UNIT TESTS"
$unitExit = 1
try {
    python -m pytest tests/unit -v --tb=line 2>&1 | Out-Host
    $unitExit = $LASTEXITCODE
} catch { $unitExit = 1 }
Assert-Result "Unit tests (pytest)" "python -m pytest tests/unit -v" "exit == 0" "exit=$unitExit" ($unitExit -eq 0)

if (-not $dockerOk) {
    Log "========================================"
    Log " RESULT: PARTIAL (unit only) - exit 2"
    Log "========================================"
    exit 2
}

# --- Containers ---
Log ""
Log ">>> INFRASTRUCTURE"
docker compose up -d 2>&1 | Out-Null
Start-Sleep -Seconds 20
$mosq = docker ps --filter "name=iot-sentinel-mosquitto" --format "{{.Status}}" 2>$null
$nr   = docker ps --filter "name=iot-sentinel-nodered" --format "{{.Status}}" 2>$null
Assert-Result "Mosquitto container" "docker ps" "Up" "$mosq" ($mosq -match "Up")
Assert-Result "Node-RED container" "docker ps" "Up" "$nr" ($nr -match "Up")

# --- ACL file ---
$aclType = docker exec iot-sentinel-mosquitto sh -c "if [ -f /mosquitto/config/aclfile ]; then echo FILE; elif [ -d /mosquitto/config/aclfile ]; then echo DIR; else echo MISSING; fi" 2>$null
Assert-Result "ACL is regular file" "docker exec ..." "FILE" "$aclType" ($aclType -match "FILE")

if (Test-Path "scripts\init-db.ps1") { & ".\scripts\init-db.ps1" 2>&1 | Out-Null }

# --- Clear JSONL ---
$jsonlPath = Join-Path $Root "database\events.jsonl"
$jsonlTel  = Join-Path $Root "database\telemetry.jsonl"
if (Test-Path $jsonlPath) { Clear-Content $jsonlPath -Force }
if (Test-Path $jsonlTel)  { Clear-Content $jsonlTel  -Force }
Start-Sleep -Seconds 2

# --- Restart Node-RED to clear in-memory state ---
docker restart iot-sentinel-nodered 2>&1 | Out-Null
Start-Sleep -Seconds 50

# --- Normal traffic ---
Log ""
Log ">>> NORMAL TELEMETRY (30s)"
$simJob = Start-Job -ScriptBlock {
    param($r)
    Set-Location $r
    python -m simulator.cli normal --duration 30 --interval 5 2>&1
} -ArgumentList $Root
Start-Sleep -Seconds 35
Stop-Job $simJob -ErrorAction SilentlyContinue
Receive-Job $simJob -ErrorAction SilentlyContinue | Out-Null
Remove-Job $simJob -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 2
$telCount = 0
if (Test-Path $jsonlTel) { $telCount = (Get-Content $jsonlTel).Count }
Assert-Result "TEST-001 Normal telemetry stored" "simulator.cli normal 30s" "telemetry.jsonl rows >= 1" "count=$telCount" (($telCount -as [int]) -ge 1)

# --- Active devices ---
$dbPath = Join-Path $Root "database\iot_sentinel.db"
$activeCount = 0
if (Test-Path $dbPath) {
    $pyFile = Join-Path $env:TEMP "iot_active_count.py"
    $pyCode = "import sqlite3, sys`nc = sqlite3.connect(sys.argv[1])`nprint(c.execute(`"SELECT COUNT(*) FROM devices WHERE status='ACTIVE'`").fetchone()[0])"
    Set-Content -Path $pyFile -Value $pyCode -Encoding ASCII
    $out = python $pyFile $dbPath 2>$null
    if ($out) { $activeCount = [int]$out }
    Remove-Item $pyFile -Force -ErrorAction SilentlyContinue
}
Assert-Result "Devices ACTIVE (seed)" "SELECT COUNT(*)" "== 6" "active=$activeCount" (($activeCount -as [int]) -eq 6)

# --- Attack helper ---
function Run-Attack($testName, $attackArgs, $eventType) {
    Log ""
    Log ">>> $testName"
    $cmd = "python -m simulator.cli attack $attackArgs"
    Invoke-Expression $cmd 2>&1 | Out-Null
    Start-Sleep -Seconds 10
    $cnt = 0
    if (Test-Path $jsonlPath) {
        $hits = Select-String -Path $jsonlPath -Pattern "`"event_type`":`"$eventType`"" -SimpleMatch -ErrorAction SilentlyContinue
        $cnt = @($hits).Count
    }
    Assert-Result $testName $cmd "events.jsonl has event_type='$eventType'" "count=$cnt" (($cnt -as [int]) -gt 0)
}

Run-Attack "TEST-002 Unauthorized Device" "unauthorized-device" "UNAUTHORIZED_DEVICE"
Run-Attack "TEST-003 Abnormal Value" "abnormal-value --device TEMP-001 --value 150" "SENSOR_VALUE_ANOMALY"
Run-Attack "TEST-004 Flood" "flood --device CAM-001 --count 60" "MESSAGE_RATE_ANOMALY"
Run-Attack "TEST-006 Topic Abuse" "topic-abuse --device TEMP-001" "TOPIC_ABUSE"
Run-Attack "TEST-007 Spoofing" "spoofing --device DOOR-001" "DEVICE_SPOOFING"

# --- Auth failure (Stage B only) ---
Log ""
Log ">>> TEST-005 Auth Failure"
$allowAnon = $true
if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    if ($envContent -match "MQTT_ALLOW_ANONYMOUS\s*=\s*false") { $allowAnon = $false }
}
if ($allowAnon) {
    Log "Test: TEST-005"
    Log "Observed: Stage A active - SKIPPED"
    Log "Verdict: SKIPPED"
} else {
    Run-Attack "TEST-005 Auth Failure" "auth-failure" "AUTHENTICATION_ANOMALY"
}

# --- Correlation (use HUM-001) ---
Log ""
Log ">>> TEST-008 Correlated Attack on HUM-001"
python -m simulator.cli attack abnormal-value --device HUM-001 --value 200 2>&1 | Out-Null
Start-Sleep 2
python -m simulator.cli attack flood --device HUM-001 --count 40 2>&1 | Out-Null
Start-Sleep 2
python -m simulator.cli attack topic-abuse --device HUM-001 2>&1 | Out-Null
Start-Sleep 8
$corrCnt = 0
if (Test-Path $jsonlPath) {
    $hits = Select-String -Path $jsonlPath -Pattern '"event_type":"CORRELATED_SECURITY_INCIDENT"' -SimpleMatch -ErrorAction SilentlyContinue
    $corrCnt = @($hits).Count
}
Assert-Result "TEST-008 Correlation" "3 attacks on HUM-001" "CORRELATED count > 0" "count=$corrCnt" (($corrCnt -as [int]) -gt 0)

# --- Critical / Isolation ---
$critCnt = 0
if (Test-Path $jsonlPath) {
    $hits = Select-String -Path $jsonlPath -Pattern '"severity":"CRITICAL"' -SimpleMatch -ErrorAction SilentlyContinue
    $critCnt = @($hits).Count
    $hits2 = Select-String -Path $jsonlPath -Pattern '"action":"ISOLATE"' -SimpleMatch -ErrorAction SilentlyContinue
    $critCnt += @($hits2).Count
}
Assert-Result "TEST-009 Critical signals" "prior attacks" "CRITICAL or ISOLATE found" "count=$critCnt" (($critCnt -as [int]) -gt 0)

# --- Post-isolation (MOTION-001 forced to CRITICAL, then verify block) ---
Log ""
Log ">>> TEST-011 Post-Isolation on MOTION-001"

# Step 1: Force MOTION-001 to CRITICAL (flood + topic-abuse + spoofing)
python -m simulator.cli attack flood --device MOTION-001 --count 60 2>&1 | Out-Null
Start-Sleep 3
python -m simulator.cli attack topic-abuse --device MOTION-001 2>&1 | Out-Null
Start-Sleep 3
python -m simulator.cli attack spoofing --device MOTION-001 2>&1 | Out-Null
Start-Sleep 3

# Step 2: Wait past the isolation-gate cooldown (5s) - be generous
Log "  Waiting 15s for isolation + cooldown expiry..."
Start-Sleep 15

# Step 3: Send more messages - should be blocked by isolation gate
python -m simulator.cli attack flood --device MOTION-001 --count 5 2>&1 | Out-Null
Start-Sleep 10

# Step 4: Search for POST_ISOLATION_BLOCKED anywhere in the log
# (it may appear standalone OR embedded within a CORRELATED_SECURITY_INCIDENT description)
$blockCnt = 0
if (Test-Path $jsonlPath) {
    $hits = Select-String -Path $jsonlPath -Pattern 'POST_ISOLATION_BLOCKED' -ErrorAction SilentlyContinue
    $blockCnt = @($hits).Count
}
Assert-Result "TEST-011 Post-isolation block" "isolate MOTION-001, wait 15s, flood" "POST_ISOLATION_BLOCKED found in events.jsonl" "count=$blockCnt" (($blockCnt -as [int]) -gt 0)

# --- Results ---
$jsonObj = @{
    timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    docker_available = $true
    unit_tests_exit = $unitExit
    failed_assertions = $script:failed
    telemetry_jsonl_count = $telCount
    active_devices = $activeCount
} | ConvertTo-Json -Depth 5
Set-Content -Path (Join-Path $resultsDir "test-results.json") -Value $jsonObj -Encoding UTF8

$lines = @(
    "# Test Summary",
    "",
    "- Timestamp: " + (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"),
    "- Docker: available",
    "- Unit tests exit: $unitExit",
    "- Failed assertions: $($script:failed)",
    "- telemetry.jsonl rows: $telCount",
    "- Active devices: $activeCount"
)
Set-Content -Path (Join-Path $resultsDir "test-summary.md") -Value ($lines -join "`n") -Encoding UTF8

Log "========================================"
if ($script:failed -eq 0) {
    Log " RESULT: PASS"
    Log "========================================"
    exit 0
} else {
    Log " RESULT: FAIL ($($script:failed) assertions)"
    Log "========================================"
    exit 1
}