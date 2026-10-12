# Initialize SQLite database from schema + seed
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$db = "database\iot_sentinel.db"
if (Test-Path $db) { Remove-Item $db -Force }

# Prefer sqlite3 CLI if present, else Python
$sqlite = Get-Command sqlite3 -ErrorAction SilentlyContinue
if ($sqlite) {
    Get-Content database\schema.sql, database\seed.sql | sqlite3 $db
} else {
    python -c @"
import sqlite3
conn = sqlite3.connect(r'$db')
for path in [r'database\schema.sql', r'database\seed.sql']:
    with open(path, encoding='utf-8') as f:
        conn.executescript(f.read())
conn.close()
print('Database initialized:', r'$db')
"@
}
Write-Host "DB ready: $db" -ForegroundColor Green
