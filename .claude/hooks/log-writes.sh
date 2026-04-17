#!/bin/bash
# Claude Code PostToolUse hook: Log file writes/edits to JSONL immediately
# Gives session-stop.sh an accurate per-file timeline instead of relying on git diff,
# which misses committed files and lacks timestamps.
#
# Input: { "session_id": "...", "tool_name": "Write|Edit", "tool_input": { "path": "..." } }
# Exit 0: always (logging is best-effort, must not block workflow)

INPUT=$(cat)

# ─── REQUIRE jq (logging is best-effort — exit 0 if missing) ───────────────────
# Regex fallback is omitted: log corruption is better than silently wrong logs.
if ! command -v jq >/dev/null 2>&1; then
    exit 0
fi

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.path // .tool_input.file_path // ""')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

[ -z "$FILE_PATH" ] && exit 0

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
LOG_DIR="production/session-logs"
LOG_FILE="$LOG_DIR/writes.jsonl"
mkdir -p "$LOG_DIR" 2>/dev/null

# Create safe JSON entry
LOG_ENTRY=$(jq -n \
    --arg ev "$TOOL_NAME" \
    --arg ts "$TIMESTAMP" \
    --arg sid "$SESSION_ID" \
    --arg f "$FILE_PATH" \
    --arg b "$BRANCH" \
    '{event: $ev, timestamp: $ts, session_id: $sid, file: $f, branch: $b}' \
    --compact-output)

# ─── ATOMIC WRITE: flock prevents race conditions from parallel subagents ────────
# Without flock, concurrent appends corrupt JSONL (partial lines interleaved).
if command -v flock >/dev/null 2>&1; then
    (
        flock -x 200
        echo "$LOG_ENTRY" >> "$LOG_FILE"
    ) 200>"${LOG_FILE}.lock" 2>/dev/null
else
    # flock not available (Windows/some platforms) — append without lock
    echo "$LOG_ENTRY" >> "$LOG_FILE" 2>/dev/null
fi

exit 0
