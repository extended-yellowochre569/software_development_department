#!/bin/bash
# Claude Code Stop hook: Archive session state + stats summary
# Reads JSONL agent log to compute session stats before archiving.

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
    SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)
else
    SESSION_ID=$(echo "$INPUT" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | \
        sed 's/"session_id"[[:space:]]*:[[:space:]]*"//;s/"$//')
    [ -z "$SESSION_ID" ] && SESSION_ID="unknown"
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SESSION_LOG_DIR="production/session-logs"
mkdir -p "$SESSION_LOG_DIR" 2>/dev/null

# ─── Compute session stats from JSONL agent log ───────────────────────────────
AGENTS_INVOKED=0
AGENT_NAMES=""
JSONL_LOG="$SESSION_LOG_DIR/agent-audit.jsonl"

if [ -f "$JSONL_LOG" ]; then
    if command -v jq >/dev/null 2>&1; then
        AGENTS_INVOKED=$(jq -r --arg sid "$SESSION_ID" \
            'select(.session_id == $sid) | .agent_name' \
            "$JSONL_LOG" 2>/dev/null | wc -l | tr -d ' ')
        AGENT_NAMES=$(jq -r --arg sid "$SESSION_ID" \
            'select(.session_id == $sid) | .agent_name' \
            "$JSONL_LOG" 2>/dev/null | sort | uniq | tr '\n' ',' | sed 's/,$//')
    else
        AGENTS_INVOKED=$(grep -c "\"session_id\":\"$SESSION_ID\"" "$JSONL_LOG" 2>/dev/null || echo 0)
    fi
fi

# ─── Git activity this session ────────────────────────────────────────────────
RECENT_COMMITS=$(git log --oneline --since="8 hours ago" 2>/dev/null)
MODIFIED_FILES=$(git diff --name-only 2>/dev/null)
COMMIT_COUNT=$(echo "$RECENT_COMMITS" | grep -c . 2>/dev/null || echo 0)
[ "$RECENT_COMMITS" = "" ] && COMMIT_COUNT=0

# ─── Archive active session state ─────────────────────────────────────────────
STATE_FILE="production/session-state/active.md"
if [ -f "$STATE_FILE" ]; then
    {
        echo "## Archived Session State: $TIMESTAMP"
        echo "Session ID: $SESSION_ID"
        cat "$STATE_FILE"
        echo "---"
        echo ""
    } >> "$SESSION_LOG_DIR/session-log.md" 2>/dev/null
    rm "$STATE_FILE" 2>/dev/null
fi

# ─── Write session summary to log ─────────────────────────────────────────────
{
    echo "## Session End: $TIMESTAMP"
    echo "Session ID: $SESSION_ID"
    echo ""
    echo "### Stats"
    echo "Agents invoked : $AGENTS_INVOKED"
    [ -n "$AGENT_NAMES" ] && echo "Agent names    : $AGENT_NAMES"
    echo "Commits made   : $COMMIT_COUNT"

    if [ -n "$RECENT_COMMITS" ]; then
        echo ""
        echo "### Commits"
        echo "$RECENT_COMMITS"
    fi
    if [ -n "$MODIFIED_FILES" ]; then
        echo ""
        echo "### Uncommitted Changes"
        echo "$MODIFIED_FILES"
    fi
    echo "---"
    echo ""
} >> "$SESSION_LOG_DIR/session-log.md" 2>/dev/null

# ─── Print summary to stdout (visible in Claude's context) ───────────────────
echo "=== Session Complete ==="
echo "Agents invoked : $AGENTS_INVOKED"
[ -n "$AGENT_NAMES" ] && echo "Agents         : $AGENT_NAMES"
echo "Commits        : $COMMIT_COUNT"
echo "========================"

exit 0
