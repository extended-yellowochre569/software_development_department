#!/bin/bash
# Claude Code SubagentStart hook: Structured JSONL audit log
# Logs agent invocations with session_id, timestamp, branch for queryability.
#
# Input schema (SubagentStart):
# { "session_id": "...", "agent_id": "...", "agent_name": "..." }

INPUT=$(cat)

# Parse fields -- require jq (logging best-effort, exit 0 if missing)
# Regex fallback omitted: silent wrong logs are harder to diagnose than missing logs.
if ! command -v jq >/dev/null 2>&1; then
    exit 0
fi

AGENT_NAME=$(echo "$INPUT" | jq -r '.agent_name // "unknown"' 2>/dev/null)
AGENT_ID=$(echo "$INPUT"   | jq -r '.agent_id   // "unknown"' 2>/dev/null)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
LOG_DIR="production/session-logs"
JSONL_FILE="$LOG_DIR/agent-audit.jsonl"
TEXT_FILE="$LOG_DIR/agent-audit.log"

mkdir -p "$LOG_DIR" 2>/dev/null

# ─── JSONL entry (jq-safe, no manual escaping) ────────────────────────────────
LOG_ENTRY=$(jq -n \
    --arg ev "SubagentStart" \
    --arg ts "$TIMESTAMP" \
    --arg sid "$SESSION_ID" \
    --arg aid "$AGENT_ID" \
    --arg an "$AGENT_NAME" \
    --arg b "$BRANCH" \
    '{event: $ev, timestamp: $ts, session_id: $sid, agent_id: $aid, agent_name: $an, branch: $b}' \
    --compact-output)

# ─── ATOMIC WRITE: flock prevents race conditions from parallel subagents ──────
# Without flock, concurrent appends can interleave partial lines in JSONL.
if command -v flock >/dev/null 2>&1; then
    (
        flock -x 200
        echo "$LOG_ENTRY" >> "$JSONL_FILE"
        echo "$TIMESTAMP | $AGENT_NAME ($AGENT_ID) | branch: $BRANCH | session: $SESSION_ID" \
            >> "$TEXT_FILE"
    ) 200>"${JSONL_FILE}.lock" 2>/dev/null
else
    # flock not available (Windows/some platforms) — append without lock
    echo "$LOG_ENTRY" >> "$JSONL_FILE" 2>/dev/null
    echo "$TIMESTAMP | $AGENT_NAME ($AGENT_ID) | branch: $BRANCH | session: $SESSION_ID" \
        >> "$TEXT_FILE" 2>/dev/null
fi

exit 0
