# portal-update.ps1
# Updates the visual portal with latest ledger data using PowerShell.

$LedgerFile = "production/traces/decision_ledger.jsonl"
$DataFile = "docs/internal/portal-data.js"

Write-Host "Updating SDD Governance Portal..." -ForegroundColor Cyan

if (-not (Test-Path $LedgerFile)) {
    Write-Error "Error: $LedgerFile not found."
    exit 1
}

# Read NDJSON and convert to JS Array using Node
# Using Node ensures consistency between platforms for JSON parsing
$nodeCommand = @"
const fs = require('fs');
const ledger = fs.readFileSync('$($LedgerFile.Replace('\', '/'))', 'utf8')
    .split('\n')
    .filter(line => line.trim())
    .map(line => JSON.parse(line));
const output = 'window.LEDGER_DATA = ' + JSON.stringify(ledger, null, 2) + ';';
fs.writeFileSync('$($DataFile.Replace('\', '/'))', output);
console.log('Successfully updated portal data with ' + ledger.length + ' records.');
"@

node -e $nodeCommand

Write-Host "Portal updated: docs/internal/portal.html" -ForegroundColor Green
