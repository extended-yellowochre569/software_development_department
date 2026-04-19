#!/usr/bin/env bash

# portal-update.sh
# Updates the visual portal with latest ledger data.
# Usage: bash scripts/portal-update.sh

LEDGER_FILE="production/traces/decision_ledger.jsonl"
DATA_FILE="docs/internal/portal-data.js"

echo "Updating SDD Governance Portal..."

if [ ! -f "$LEDGER_FILE" ]; then
    echo "Error: $LEDGER_FILE not found."
    exit 1
fi

# Use Node.js for robust cross-platform NDJSON to JS Array conversion
# Sanitizes data and wraps in a window global variable
node -e "
const fs = require('fs');
const readline = require('readline');

async function processLedger() {
    const lines = [];
    const fileStream = fs.createReadStream('$LEDGER_FILE');
    const rl = readline.createInterface({
        input: fileStream,
        crlfDelay: Infinity
    });

    for await (const line of rl) {
        if (line.trim()) {
            try {
                lines.push(JSON.parse(line));
            } catch (e) {
                console.error('Skip invalid line:', line);
            }
        }
    }

    const output = 'window.LEDGER_DATA = ' + JSON.stringify(lines, null, 2) + ';';
    fs.writeFileSync('$DATA_FILE', output);
    console.log('Successfully updated portal data with', lines.length, 'records.');
}

processLedger();
"

echo "Portal updated: docs/internal/portal.html"
