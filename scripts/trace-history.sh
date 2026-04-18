#!/usr/bin/env bash
# trace-history.sh — Query & render production/traces/decision_ledger.jsonl
# Backs the /trace-history skill (.claude/skills/trace-history/SKILL.md).
#
# Usage:
#   bash scripts/trace-history.sh [flags]
#
# Flags (all optional):
#   --agent <name>          filter by agent_id
#   --risk <High|Medium|Low> filter by risk_tier
#   --task <id>             filter by task_id (substring match)
#   --outcome <pass|fail|blocked|skipped>
#   --since <YYYY-MM-DD>    only entries with ts >= this date
#   --last <N>              show last N entries after other filters (default 20)
#   --format <pretty|json>  output format (default pretty)
#
# Exit:
#   0 = rendered (even if empty)
#   1 = invalid arg value

set -u

LEDGER_FILE="production/traces/decision_ledger.jsonl"

# ─── Defaults ────────────────────────────────────────────────────────────────
F_AGENT=""
F_RISK=""
F_TASK=""
F_OUTCOME=""
F_SINCE=""
F_LAST="20"
F_FORMAT="pretty"

while [ $# -gt 0 ]; do
    case "$1" in
        --agent)   F_AGENT="$2"; shift 2 ;;
        --risk)    F_RISK="$2"; shift 2 ;;
        --task)    F_TASK="$2"; shift 2 ;;
        --outcome) F_OUTCOME="$2"; shift 2 ;;
        --since)   F_SINCE="$2"; shift 2 ;;
        --last)    F_LAST="$2"; shift 2 ;;
        --format)  F_FORMAT="$2"; shift 2 ;;
        -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
        *) echo "Unknown flag: $1" >&2; exit 1 ;;
    esac
done

case "$F_RISK"    in ""|High|Medium|Low) ;; *) echo "--risk must be High|Medium|Low" >&2; exit 1 ;; esac
case "$F_OUTCOME" in ""|pass|fail|blocked|skipped) ;; *) echo "--outcome invalid" >&2; exit 1 ;; esac
case "$F_FORMAT"  in pretty|json) ;; *) echo "--format must be pretty|json" >&2; exit 1 ;; esac

# ─── Require node (jq as alt not used here — rendering is easier in JS) ──────
if ! command -v node >/dev/null 2>&1; then
    echo "[trace-history] ERROR: node is required for rendering." >&2
    exit 1
fi

# ─── Empty ledger short-circuit ──────────────────────────────────────────────
if [ ! -s "$LEDGER_FILE" ]; then
    echo "📭 Decision ledger is empty — no decisions have been traced yet."
    echo "   Entries are appended automatically on commits and by agents"
    echo "   making Medium/High risk choices per coordination-rules.md Rule 15."
    exit 0
fi

# ─── Delegate filtering + rendering to Node ──────────────────────────────────
LEDGER_FILE="$LEDGER_FILE" \
F_AGENT="$F_AGENT" F_RISK="$F_RISK" F_TASK="$F_TASK" \
F_OUTCOME="$F_OUTCOME" F_SINCE="$F_SINCE" F_LAST="$F_LAST" \
F_FORMAT="$F_FORMAT" \
node -e '
const fs = require("fs");
const path = process.env.LEDGER_FILE;
const raw = fs.readFileSync(path, "utf8").trim();
if (!raw) { console.log("📭 Ledger empty."); process.exit(0); }

const entries = raw.split("\n")
    .map(l => { try { return JSON.parse(l); } catch { return null; } })
    .filter(Boolean)
    // Drop legacy entries (no ts/agent_id) from pretty rendering; keep for json
    .filter(e => process.env.F_FORMAT === "json" || (e.ts && e.agent_id));

const f = {
    agent:   process.env.F_AGENT,
    risk:    process.env.F_RISK,
    task:    process.env.F_TASK,
    outcome: process.env.F_OUTCOME,
    since:   process.env.F_SINCE,
};

let filtered = entries.filter(e => {
    if (f.agent   && e.agent_id   !== f.agent)   return false;
    if (f.risk    && e.risk_tier  !== f.risk)    return false;
    if (f.outcome && e.outcome    !== f.outcome) return false;
    if (f.task    && !(e.task_id || "").includes(f.task)) return false;
    if (f.since) {
        const entryDate = (e.ts || "").slice(0,10);
        if (entryDate < f.since) return false;
    }
    return true;
});

// Apply --last (keep newest N)
const lastN = Math.max(1, parseInt(process.env.F_LAST || "20", 10) || 20);
filtered = filtered.slice(-lastN);

if (process.env.F_FORMAT === "json") {
    console.log(JSON.stringify(filtered, null, 2));
    process.exit(0);
}

if (filtered.length === 0) {
    console.log("📭 No ledger entries match the filter.");
    process.exit(0);
}

const riskBadge = { High: "🔴", Medium: "🟡", Low: "🟢" };
const outcomeEmoji = { pass: "✅", fail: "❌", blocked: "⛔", skipped: "⏭️" };

const appliedFilters = Object.entries(f)
    .filter(([k,v]) => v)
    .map(([k,v]) => `${k}=${v}`)
    .join(" · ") || "all entries";

console.log(`📋 Decision Trace — ${appliedFilters}`);
console.log("━".repeat(60));
console.log();

for (const e of filtered) {
    const badge = riskBadge[e.risk_tier] || "⚪";
    const oEmoji = outcomeEmoji[e.outcome] || "•";
    const ts = (e.ts || "").replace("T", " ").replace("Z","");
    console.log(`${ts} ${badge} @${e.agent_id} · task:${e.task_id}`);
    if (e.request)   console.log(`  Request  : ${e.request}`);
    if (e.reasoning) console.log(`  Reasoning: ${e.reasoning}`);
    console.log(`  Choice   : ${e.choice}`);
    console.log(`  Outcome  : ${oEmoji} ${e.outcome}${e.duration_s ? ` (${e.duration_s}s)` : ""}`);
    console.log("─".repeat(60));
}

const counts = { High: 0, Medium: 0, Low: 0 };
filtered.forEach(e => counts[e.risk_tier] && counts[e.risk_tier]++ || (counts[e.risk_tier] = (counts[e.risk_tier]||0)+1));
// recount cleanly
counts.High = filtered.filter(e => e.risk_tier === "High").length;
counts.Medium = filtered.filter(e => e.risk_tier === "Medium").length;
counts.Low = filtered.filter(e => e.risk_tier === "Low").length;

console.log();
console.log(`Total: ${filtered.length} decisions · ${counts.High} High · ${counts.Medium} Medium · ${counts.Low} Low`);

const failed = filtered.filter(e => e.outcome === "fail" || e.outcome === "blocked");
if (failed.length > 0) {
    console.log();
    console.log(`💡 ${failed.length} failed/blocked decisions above — run /resume-from <task_id> to recover.`);
}
'
