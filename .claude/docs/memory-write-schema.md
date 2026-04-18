# Memory Write Schema (Tier 2 auto-persist)

Specifies how `persist-memory.sh` (PostToolUse hook) detects, extracts, and appends
user-surfaced insights into Tier 2 memory files. Deterministic — no LLM classification.

## Why deterministic?

LLM-based insight extraction is expensive per-prompt, non-reproducible, and tends to
pollute memory with low-signal observations. Explicit markers put the user in control:
if they want something remembered, they signal it. Everything else is ignored.

## Trigger → File routing

The hook scans the user prompt (or tool result content) for case-insensitive markers.
First match wins; subsequent markers in the same prompt are ignored (1 insight per prompt).

| Marker (case-insensitive) | Routed to | Type |
| :--- | :--- | :--- |
| `feedback:` | `feedback_rules.md` | feedback |
| `don't ` / `stop doing ` / `never ` (at sentence start) | `feedback_rules.md` | feedback |
| `từ giờ ` / `đừng ` (at sentence start, Vietnamese) | `feedback_rules.md` | feedback |
| `from now on ` | `feedback_rules.md` | feedback |
| `decision:` | `project_tech_decisions.md` | project |
| `we chose ` / `we adopted ` / `we decided ` | `project_tech_decisions.md` | project |
| `quyết định:` / `chọn dùng ` | `project_tech_decisions.md` | project |
| `i prefer ` / `i use ` / `i am a ` | `user_role.md` | user |
| `tôi là ` / `tôi dùng ` / `tôi thích ` | `user_role.md` | user |
| `ref:` / `see also:` | `reference_links.md` | reference |
| `remember:` / `nhớ rằng ` / `nhớ là ` | (route by type keyword after marker) | mixed |

**No match → hook exits 0 silently.** Do not guess intent.

## Payload extraction

1. Find first marker match in prompt/content. Record:
   - `marker` (the exact matched phrase)
   - `body` (the rest of the sentence containing the marker, up to next `.`, `!`, `?`, `\n`)
2. Trim whitespace. Reject if `body.length < 10` chars (too short, likely noise).
3. Reject if `body.length > 400` chars (too long, likely not a rule — paste dump).

## Append format

Each matched insight appends one Markdown block to the end of the target file:

```markdown
## 2026-04-18 — <auto-title>
**Trigger:** "<marker>"
**Source:** user-prompt
<body>
```

Where `<auto-title>` is the first 60 chars of `body` with punctuation stripped.

## Dedup rule

Before appending, the hook checks the existing target file for an exact substring match
of `body` (case-insensitive). If found → skip (exit 0 silently). Prevents spam when the
same rule is repeated across sessions.

## Size guard

If the target file exceeds 300 lines after append, the hook appends a trailing comment:

```markdown
<!-- size-warning: file is >300 lines, consider /dream to consolidate -->
```

It does NOT auto-run `/dream` — that is a user-facing decision. Only warns once per
session (guarded by checking if the comment already exists).

## Fail-open policy (Rule 9)

- `jq`/`node` missing → exit 0 silently (insight dropped, never blocks user)
- Target file missing → create with empty frontmatter + append
- Write error → log to `production/session-logs/memory-write-errors.log`, exit 0
- Dedup check fails → skip append, exit 0

The hook must NEVER:
- Block the user prompt (exit 2)
- Modify files outside `.claude/memory/`
- Use more than 2 seconds of runtime (timeout 5s budget)

## Ledger integration

When a marker of type `feedback` or `project` is extracted AND the body contains any
of: `security`, `migrate`, `break`, `prod`, `critical` — append a **High-risk** ledger
entry via `scripts/ledger-append.sh`:

```
--agent persist-memory
--task-id mem-<sha1-of-body>
--choice "<first-60-chars-of-body>"
--outcome pass
--risk High
--reasoning "Auto-persisted High-signal memory entry"
```

All other memory writes get no ledger entry (too noisy otherwise).

## Out of scope

- LLM-based classification of prompt intent
- Auto-consolidation of Tier 2 files (that is `/dream`'s job)
- Writing to Tier 1 `MEMORY.md` (index-only, managed separately)
- Extracting insights from tool results (scope creep — user prompts only for now)
- Cross-session dedup beyond exact substring match

## Testing

Validation inputs for `persist-memory.sh` test harness:

| Input | Expected file | Expected body snippet |
| :--- | :--- | :--- |
| `"feedback: don't auto-commit without asking"` | `feedback_rules.md` | `don't auto-commit without asking` |
| `"we chose pg over pg-promise for TS types"` | `project_tech_decisions.md` | `pg over pg-promise for TS types` |
| `"I prefer bun over npm for local dev"` | `user_role.md` | `bun over npm for local dev` |
| `"fix the bug"` (no marker) | none | (silent skip) |
| `"feedback:"` (body too short) | none | (silent skip, <10 chars) |
| `"feedback: a"` (after trim, body empty) | none | (silent skip) |
