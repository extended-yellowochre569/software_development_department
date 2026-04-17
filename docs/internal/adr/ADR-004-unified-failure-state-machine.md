# ADR-004: Unified Failure State Machine

**Status:** Accepted  
**Date:** 2026-04-17  
**Deciders:** Chief Architect (Audit Report v4), User  
**Related:** §1.3 Coordination Rules Conflict — Report `report_upgrade_ver4_opus47.md`

---

## Context

The SDD framework currently has **three overlapping failure/retry mechanisms** that can conflict:

| Mechanism                     | Location                             | Retry Logic                                                                 |
| ----------------------------- | ------------------------------------ | --------------------------------------------------------------------------- |
| Rule 6 — Layered Recovery     | `.claude/docs/coordination-rules.md` | 3 recovery layers (agent → session → human)                                 |
| Rule 14 — Circuit Breaker     | `.claude/docs/coordination-rules.md` | 3 retries with exponential backoff (2s/4s/8s), OPEN/CLOSED/HALF-OPEN states |
| Diminishing Returns Detection | `.claude/docs/coordination-rules.md` | 3 retry threshold, stop if no progress                                      |

**Problem:** An agent can legitimately retry up to **9+ times** (3 × 3) or stop too early (first mechanism that triggers wins). There is no single source of truth for failure state, no hook that creates/reads the required state files.

Specific gaps found in audit:
- `production/session-state/circuit-state.json` — **no hook creates or reads this file**
- `production/traces/decision_ledger.jsonl` — **no ledger writer hook exists**
- `.tasks/handoffs/` — **`/handoff` command has no handler hook**

---

## Decision

**Adopt a single Unified Failure State Machine (UFSM).** All three mechanisms are merged into one.

### UFSM States

```
CLOSED ──(fail)──► HALF_OPEN ──(3rd fail)──► OPEN
   ▲                   │                        │
   └───(success)───────┘        60min TTL       │
                                cooldown         │
                        ◄────────────────────────┘
```

### State File

**Location:** `.claude/memory/circuit-state.json`  
*(Moved from `production/session-state/` — production/ path was never created)*

```jsonc
{
  "state": "CLOSED",          // CLOSED | HALF_OPEN | OPEN
  "fail_count": 0,            // resets on CLOSED
  "last_fail_ts": null,       // ISO8601
  "last_success_ts": null,    // ISO8601
  "open_reason": null,        // string, set when → OPEN
  "retry_backoff_s": 0        // 0 | 2 | 4 | 8
}
```

### Transition Rules (replaces Rule 6, Rule 14, Diminishing Returns)

| Event                                    | From State | Action                        | To State                           |
| ---------------------------------------- | ---------- | ----------------------------- | ---------------------------------- |
| Tool/agent success                       | any        | reset fail_count=0, backoff=0 | CLOSED                             |
| Tool/agent failure                       | CLOSED     | fail_count++                  | if count<3: CLOSED, else HALF_OPEN |
| Tool/agent failure                       | HALF_OPEN  | fail_count++                  | if count<3+1: HALF_OPEN, else OPEN |
| TTL 60min elapsed                        | OPEN       | auto-transition               | HALF_OPEN                          |
| Human `/reset-circuit`                   | OPEN       | force reset                   | CLOSED                             |
| No progress (same output 2× consecutive) | any        | counts as failure             | same                               |

### Backoff Schedule

- Failure 1: wait 2s before retry
- Failure 2: wait 4s before retry  
- Failure 3: wait 8s before retry → transition to HALF_OPEN
- OPEN state: no retries until TTL or human reset

---

## Hook Implementation Plan

### Phase 1 — State reader (PreToolUse:Task)

```bash
# .claude/hooks/circuit-guard.sh
# Read circuit-state.json; if OPEN → block Task tool with exit 2
STATE=$(jq -r '.state' .claude/memory/circuit-state.json 2>/dev/null || echo "CLOSED")
if [ "$STATE" = "OPEN" ]; then
    REASON=$(jq -r '.open_reason // "unknown"' .claude/memory/circuit-state.json)
    echo "[CIRCUIT] BLOCKED: Circuit is OPEN. Reason: $REASON. Use /reset-circuit to force." >&2
    exit 2
fi
```

### Phase 2 — Decision ledger writer (PostToolUse:Task)

```bash
# .claude/hooks/decision-ledger.sh
# Append decision to .claude/memory/traces/decision_ledger.jsonl
```

### Phase 3 — Failure recorder  

Any hook that does `exit 2` (block) should also update `circuit-state.json` fail_count.

---

## Consequences

**Positive:**
- Single counter, single state file, deterministic behavior
- Hooks actually enforce rules (not just documentation)
- Circuit-state is readable/auditable by humans at any time

**Negative:**
- Need to implement 3 new hooks (circuit-guard, decision-ledger, circuit-updater)
- Existing Rule 6/14/Diminishing-Returns text in coordination-rules.md must be updated to reference UFSM

**Neutral:**
- Rule 14 "OPEN/CLOSED/HALF-OPEN" naming preserved for familiarity
- Rule 6 "Layered Recovery" becomes escalation path when OPEN → human notified

---

## Migration

1. ~~Rule 6, 14, Diminishing Returns in coordination-rules.md~~ → Add `See ADR-004 UFSM` note
2. Create `.claude/memory/circuit-state.json` with initial `CLOSED` state
3. Implement `circuit-guard.sh` hook → register in `settings.json` PreToolUse:Task
4. Implement `decision-ledger.sh` hook → register in `settings.json` PostToolUse:Task
5. Release as part of **SDD v1.33.0**

---

## References

- `report_upgrade_ver4_opus47.md` §1.3 — Coordination Rules conflict diagnosis
- `.claude/docs/coordination-rules.md` — Rule 6, 14, Diminishing Returns (current)
- `.claude/memory/circuit-state.json` — state file (to be created, Phase 1)
