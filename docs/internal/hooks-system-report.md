# Hook System Report - SDD Framework
> Bản chuyển thể Việt hóa nhẹ: giữ nguyên technical English terms, chỉ thêm một phần giải thích tiếng Việt để đọc nhanh.
> Source of truth: `.claude/settings.json` + `.claude/hooks/`
> Workspace: `E:\SDD-Upgrade`
> Updated: `2026-04-19`
> Snapshot: `main @ d522efa`

---

## Executive Summary / Tóm tắt nhanh

The SDD hook layer is now a real control plane, not just a collection of shell helpers.
At the time of this report, the repository contains:

Nói ngắn gọn bằng tiếng Việt: hook layer hiện tại đã đóng vai trò như một **control plane** thực thụ cho runtime lifecycle, không còn chỉ là các shell script rời rạc.

- `23` files under `.claude/hooks/`
- `18` registered runtime hooks in `.claude/settings.json`
- `2` bash utility scripts that are not direct lifecycle hooks
- `3` PowerShell parity scripts that exist on disk but are not currently registered

The important shift since earlier hook documentation is that the system now includes:

Điểm thay đổi quan trọng so với tài liệu cũ:

- a two-hook `UserPromptSubmit` path: context injection plus deterministic memory persistence
- a full circuit-breaker pair: `circuit-guard.sh` on `PreToolUse:Task` and `circuit-updater.sh` on `PostToolUse:Task`
- ledger logging on both `Task` and `git commit` paths
- session-state bootstrap in `session-start.sh`, not just passive recovery

The hook system is best understood as four layers:

1. Prevention: block or warn before risky actions run.
2. Enrichment: inject runtime context so the model reasons with local state.
3. Observability: log writes, subagent starts, commits, and task decisions.
4. Recovery and hygiene: preserve state across compaction and session boundaries.

Bản Việt hóa rất ngắn:

1. Prevention: chặn/cảnh báo trước khi action rủi ro chạy.
2. Enrichment: bơm thêm runtime context để model suy nghĩ đúng ngữ cảnh.
3. Observability: ghi log cho write, subagent, commit, task decision.
4. Recovery and hygiene: giữ state và dọn dẹp memory qua các lần compact và stop.

---

## Current Inventory / Tồn kho hiện tại

### Registered Runtime Hooks / Hooks đang được đăng ký

These are the scripts actually wired into Claude Code via `.claude/settings.json`.
Đây là danh sách hook có hiệu lực runtime thực sự.

| Lifecycle event | Hook(s) |
|---|---|
| `SessionStart` | `session-start.sh`, `detect-gaps.sh` |
| `UserPromptSubmit` | `prompt-context.sh`, `persist-memory.sh` |
| `PreToolUse:Bash` | `bash-guard.sh`, `validate-commit.sh`, `validate-push.sh` |
| `PreToolUse:Task` | `circuit-guard.sh` |
| `PreToolUse:Write|Edit` | `pre-refactor-impact.sh` |
| `PreToolUse:Read` | `file-history.sh` |
| `PostToolUse:Write|Edit` | `log-writes.sh`, `validate-assets.sh` |
| `PostToolUse:Bash` | `log-commit.sh` |
| `PostToolUse:Task` | `decision-ledger-writer.sh`, `circuit-updater.sh` |
| `PreCompact` | `pre-compact.sh` |
| `Stop` | `session-stop.sh` |
| `SubagentStart` | `log-agent.sh` |

### Utility Scripts In `.claude/hooks/` / Script phụ trợ

These live in the hooks folder but are not direct lifecycle hooks.
Tức là nằm trong cùng folder, nhưng không phải hook event được register trực tiếp.

| Script | Current role |
|---|---|
| `auto-dream.sh` | Maintenance utility invoked by `session-stop.sh` when memory hygiene conditions are met |
| `fork-join.sh` | Worktree helper script; allowed explicitly in `settings.json` permissions but not registered as a hook |

### PowerShell Parity Scripts / Script parity cho Windows

These exist for Windows-native parity, but are not currently registered in `.claude/settings.json`.
Hiện tại runtime truth vẫn là Bash-first.

| Script | Notes |
|---|---|
| `bash-guard.ps1` | Older PowerShell equivalent of bash guard |
| `session-start.ps1` | Older PowerShell equivalent of session start |
| `validate-commit.ps1` | Older PowerShell equivalent of commit validator |

---

## Lifecycle Map / Sơ đồ vòng đời

```text
Claude Code
   |
   +-- SessionStart
   |     +-- session-start.sh
   |     +-- detect-gaps.sh
   |
   +-- UserPromptSubmit
   |     +-- prompt-context.sh
   |     +-- persist-memory.sh
   |
   +-- PreToolUse:Bash
   |     +-- bash-guard.sh
   |     +-- validate-commit.sh
   |     +-- validate-push.sh
   |
   +-- PreToolUse:Task
   |     +-- circuit-guard.sh
   |
   +-- PreToolUse:Write|Edit
   |     +-- pre-refactor-impact.sh
   |
   +-- PreToolUse:Read
   |     +-- file-history.sh
   |
   +-- PostToolUse:Write|Edit
   |     +-- log-writes.sh
   |     +-- validate-assets.sh
   |
   +-- PostToolUse:Bash
   |     +-- log-commit.sh
   |
   +-- PostToolUse:Task
   |     +-- decision-ledger-writer.sh
   |     +-- circuit-updater.sh
   |
   +-- PreCompact
   |     +-- pre-compact.sh
   |
   +-- Stop
   |     +-- session-stop.sh
   |           +-- auto-dream.sh (conditional utility call)
   |
   +-- SubagentStart
         +-- log-agent.sh
```

---

## Hook Details / Chi tiết từng hook

### Session Lifecycle / Nhóm hook theo session

#### `session-start.sh`
Event: `SessionStart`

Role:

- prints boot context for the new session
- shows current branch and recent commits
- surfaces active sprint and milestone if present
- counts open `BUG-*.md` files
- reports TODO/FIXME density in `src/`
- recovers prior session state if `production/session-state/active.md` exists
- bootstraps a fresh `production/session-state/active.md` if it does not exist
- lists indexed GitNexus repos when available

Giải thích nhanh: đây là hook "vào ca" - nó cho model biết branch nào đang chạy, có state cũ không, và có cần bootstrap `active.md` hay không.

Important current behavior:

- this script no longer only previews `active.md`
- it can create the session-state file on first run, which makes the live-checkpoint contract operational
- the file may still be absent in a static repo snapshot because `session-stop.sh` archives and removes it at shutdown

Nói dễ hiểu: nếu bạn chỉ nhìn repo snapshot thì có thể thấy `active.md` không tồn tại, nhưng trong runtime nó vẫn được tạo ra và archive đúng lifecycle.

#### `detect-gaps.sh`
Event: `SessionStart`

Role:

- performs a lightweight health scan at startup
- identifies missing documentation relative to code shape
- suggests commands such as `/start` or `/reverse-document`

Current checks:

- fresh project detection
- large codebase with sparse design docs
- undocumented prototypes
- missing architecture docs for core systems
- API/business subsystems without corresponding design docs

#### `session-stop.sh`
Event: `Stop`

Role:

- archives live session state
- compiles human-readable session logs
- writes session summaries into Tier 3 archive under `.claude/memory/archive/sessions/`
- updates the "Last session" line in `.claude/memory/MEMORY.md`
- conditionally invokes `auto-dream.sh`

Giải thích nhanh: đây là hook "tan ca" - tổng hợp session, đẩy archive, cập nhật memory, rồi mới gọi cleanup utility nếu cần.

Current outputs:

- `production/session-logs/session-log.md`
- `.claude/memory/archive/sessions/YYYY-MM-DD_HH-MM_session.md`

Important current behavior:

- reads both `agent-audit.jsonl` and `writes.jsonl` for accurate session stats
- removes `production/session-state/active.md` after archiving it
- is the practical bridge between ephemeral runtime state and durable memory archive

#### `auto-dream.sh`
Called from: `session-stop.sh` conditionally

Role:

- performs memory hygiene and consolidation
- archives stale or low-value memory artifacts
- prunes broken links from `MEMORY.md`
- avoids producing no-op dream logs

Status:

- utility script, not registered directly as a hook
- still part of the effective session shutdown path

---

### Security and Guard Rails / Lớp bảo vệ runtime

#### `bash-guard.sh`
Event: `PreToolUse:Bash`

Role:

- blocks high-risk shell commands before execution
- complements the declarative `deny` list in `.claude/settings.json`

Nói ngắn gọn: `bash-guard.sh` là lớp chặn năng động, còn `deny` list trong `settings.json` là lớp chặn khai báo; hai lớp bổ sung cho nhau.

Current hard blocks include:

- fork bombs
- `rm -rf` variants on `/`, `*`, `.` and `./`
- `tee` or direct redirection into `.env`
- disk formatting and raw disk write patterns
- destructive cron deletion
- accidental `twine upload`

Current posture:

- requires `jq`; if `jq` is missing, it blocks rather than silently regex-parsing
- also emits soft warnings for destructive SQL, `git reset --hard`, `git clean`, and volume deletion

#### `validate-commit.sh`
Event: `PreToolUse:Bash` when the command is `git commit`

Role:

- validates staged commit contents before commit executes
- warns on quality issues and blocks invalid JSON payloads in `assets/data`
- runs a staged Python lint pass with Ruff when available
- emits GitNexus blast-radius summary when the repo is indexed

Important current behavior:

- the dead `exit 0` bug from older audits is gone
- uses a 25-second self-timeout watchdog so failure degrades visibly and fail-open, rather than being silently killed by the outer hook timeout

Ý nghĩa thực tế: khi validation quá lâu, hook sẽ fail-open có cảnh báo rõ ràng, thay vì chết im lặng.

#### `validate-push.sh`
Event: `PreToolUse:Bash` when the command is `git push`

Role:

- warns when pushing to protected branches such as `main`, `master`, or `develop`
- scans staged diff content for likely secrets before push

Current secret coverage includes:

- Anthropic and OpenAI keys
- GitHub tokens
- Slack tokens
- private key blocks
- password and secret assignments
- `DATABASE_URL`
- AWS keys
- bearer tokens
- Google API keys
- Azure-style storage account keys

#### `circuit-guard.sh`
Event: `PreToolUse:Task`

Role:

- enforces the read-path of ADR-004 unified failure state machine
- blocks `Task` when the circuit is `OPEN`
- allows probe traffic in `HALF_OPEN`
- auto-transitions `OPEN -> HALF_OPEN` after TTL when conditions are met

State file:

- `.claude/memory/circuit-state.json`

Important current behavior:

- creates the state file if it does not exist
- blocks only `Task`, not Bash, Read, or Write tools
- depends on `jq`, but skips fail-open if `jq` is unavailable

---

### Enrichment and Memory Injection / Lớp nạp thêm context và memory

#### `prompt-context.sh`
Event: `UserPromptSubmit`

Role:

- loads up to three relevant memory files based on prompt keywords
- injects them as `additionalContext`
- clearly labels injected content as read-only data, not instructions

Current safeguards:

- requires `jq`
- sanitizes memory content for instruction-like patterns such as `ignore previous instructions`, `act as`, or role prefixes
- wraps injected content in fenced `memory` blocks with a data-only header

#### `persist-memory.sh`
Event: `UserPromptSubmit`

Role:

- deterministically persists Tier 2 memory from explicit prompt markers
- maps prompt patterns into specific target files such as `feedback_rules.md`, `project_tech_decisions.md`, `reference_links.md`, or `user_role.md`
- appends structured dated sections without using an LLM

Implementation notes:

- delegates parsing and file writing to embedded Node.js for UTF-8 and regex safety
- deduplicates existing memory entries
- can auto-create missing target memory files with minimal frontmatter
- can attach high-signal entries to the decision ledger via `scripts/ledger-append.sh`

This hook is one of the biggest differences from older documentation. The `UserPromptSubmit` path is now both:

- read path: `prompt-context.sh`
- write path: `persist-memory.sh`

Tóm tắt: trước đây `UserPromptSubmit` chủ yếu là read-path; hiện tại nó đã thành cả read-path lẫn write-path.

---

### Observability and Audit Trail / Lớp ghi nhận và audit trail

#### `log-writes.sh`
Event: `PostToolUse:Write|Edit`

Role:

- appends one JSONL row for every write or edit event
- preserves a timestamped audit trail of written files
- gives `session-stop.sh` a better source of truth than `git diff`

Current output:

- `production/session-logs/writes.jsonl`

Current safeguards:

- builds JSON with `jq`
- uses `flock` when available to avoid concurrent JSONL corruption

#### `log-agent.sh`
Event: `SubagentStart`

Role:

- logs subagent startup events for later analytics and session summaries

Current outputs:

- `production/session-logs/agent-audit.jsonl`
- `production/session-logs/agent-audit.log`

#### `log-commit.sh`
Event: `PostToolUse:Bash` when the command is `git commit`

Role:

- writes commit events into `production/traces/decision_ledger.jsonl`
- classifies commit risk from touched file paths
- delegates append mechanics to `scripts/ledger-append.sh`

This is now the Bash-path companion to `decision-ledger-writer.sh`, which logs `Task` outcomes.

#### `decision-ledger-writer.sh`
Event: `PostToolUse:Task`

Role:

- records one ledger entry per `Task` tool invocation
- writes `ledger/v1` JSON lines to `production/traces/decision_ledger.jsonl`
- classifies outcomes as `pass`, `blocked`, or `fail`
- estimates risk from task content

Important architectural note:

- this script and `log-commit.sh` now both feed the same ledger
- they are semantically aligned, but still separate writers
- this is one of the remaining structural-integrity areas called out by the architecture audit

Nói dễ hiểu: cùng một ledger, nhưng hiện vẫn có hai writer khác nhau. Đây là điểm đã tốt hơn trước, nhưng chưa phải mức "single writer" lý tưởng.

#### `circuit-updater.sh`
Event: `PostToolUse:Task`

Role:

- updates `.claude/memory/circuit-state.json` after each `Task` result
- implements the write-path of ADR-004 state machine

Current behavior:

- success resets the circuit to `CLOSED`
- repeated failures escalate `CLOSED -> HALF_OPEN -> OPEN`
- backoff is computed from failure count
- the state file is auto-created if missing

Together, `circuit-guard.sh` and `circuit-updater.sh` form a true two-part circuit breaker.

Có thể hiểu nhanh như sau:

- `circuit-guard.sh` = read-path enforcement
- `circuit-updater.sh` = write-path state transition

---

### Read, Write, and Compaction Helpers

#### `file-history.sh`
Event: `PreToolUse:Read`

Role:

- injects recent git history for the file being read
- explains recency, author, and nearby commits so the model sees local evolution rather than only current file contents

Current behavior:

- skips files smaller than 1 KB
- skips untracked files
- injects last author, relative last-modified time, and the five most recent commits touching the file

#### `pre-refactor-impact.sh`
Event: `PreToolUse:Write|Edit`

Role:

- emits a non-blocking warning before edits in `src/` when GitNexus is indexed
- nudges the operator toward running impact analysis before risky refactors

Status:

- warn-only by design
- part of the "legibility over autonomy" philosophy of the harness

#### `validate-assets.sh`
Event: `PostToolUse:Write|Edit`

Role:

- checks files under `assets/` after writes
- warns on naming violations
- validates JSON under `assets/data/*.json`

Current limitation:

- still uses a grep fallback for path extraction if `jq` is unavailable
- since it is `PostToolUse`, it can warn but not block

#### `pre-compact.sh`
Event: `PreCompact`

Role:

- dumps active session state before conversation compaction
- preserves working context so the next model state can recover task intent quickly

Typical data surfaced:

- active session-state contents
- working tree diff state
- WIP markers
- last intent signals and recent file activity

---

## Control Characteristics

| Hook | Main property |
|---|---|
| `bash-guard.sh` | destructive-command prevention |
| `validate-commit.sh` | staged-change validation and commit-time warnings |
| `validate-push.sh` | push-time secret screening |
| `circuit-guard.sh` | runtime safety gate for `Task` |
| `circuit-updater.sh` | runtime failure-state persistence |
| `prompt-context.sh` | memory read-path enrichment |
| `persist-memory.sh` | deterministic memory write-path |
| `file-history.sh` | read-time git provenance |
| `pre-refactor-impact.sh` | blast-radius warning |
| `log-writes.sh` | file-write observability |
| `log-agent.sh` | subagent observability |
| `log-commit.sh` | commit-to-ledger observability |
| `decision-ledger-writer.sh` | task-to-ledger observability |
| `session-start.sh` | session bootstrap and recovery |
| `session-stop.sh` | archival and durability |
| `detect-gaps.sh` | startup health scan |
| `validate-assets.sh` | asset-path and JSON hygiene |
| `pre-compact.sh` | compaction recovery support |

---

## Data Flow Between Hooks

```text
session-start.sh
   reads: git metadata, sprint files, milestone files, bug files
   reads/writes: production/session-state/active.md

prompt-context.sh
   reads: .claude/memory/*.md

persist-memory.sh
   reads: user prompt payload
   writes: .claude/memory/*.md
   optionally writes: production/traces/decision_ledger.jsonl via ledger helper

log-writes.sh
   writes: production/session-logs/writes.jsonl

log-agent.sh
   writes: production/session-logs/agent-audit.jsonl and agent-audit.log

log-commit.sh
   writes: production/traces/decision_ledger.jsonl

decision-ledger-writer.sh
   writes: production/traces/decision_ledger.jsonl

circuit-guard.sh
   reads: .claude/memory/circuit-state.json

circuit-updater.sh
   writes: .claude/memory/circuit-state.json

pre-compact.sh
   reads: production/session-state/active.md and current workspace state

session-stop.sh
   reads: writes.jsonl, agent-audit.jsonl, active.md, git status
   writes: production/session-logs/session-log.md
   writes: .claude/memory/archive/sessions/
   updates: .claude/memory/MEMORY.md
   calls: auto-dream.sh

auto-dream.sh
   reads: .claude/memory/*
   archives/prunes: .claude/memory/archive/dreams/ and MEMORY.md
```

---

## Current Gaps and Observations / Khoảng trống và nhận xét hiện tại

- The report from `2026-04-17` is no longer sufficient. The hook layer has grown from a simpler enforcement shell into a multi-path control plane.
- `settings.json` is the only authoritative source for registration order. Any future report should derive lifecycle routing from that file first.
- There are now two ledger writers and one shared ledger destination. That is workable, but still a candidate for later orchestration cleanup.
- `auto-dream.sh` is operationally important even though it is not a registered hook, because it is part of the `Stop` path.
- Windows parity scripts still exist, but current runtime truth is Bash-first. Documentation should treat PowerShell scripts as parity artifacts, not active lifecycle hooks.
- `fork-join.sh` belongs to the hook ecosystem operationally, but not to the registered lifecycle itself.

Đọc nhanh bằng tiếng Việt:

- `settings.json` là nguồn chân lý cho registration order.
- Ledger hiện có shared destination nhưng chưa có một writer duy nhất.
- PowerShell scripts nên xem là parity artifacts, không nên đọc nhầm thành active hooks.

---

## Bottom Line / Kết luận ngắn

The current hook system is strongest in three areas:

- pre-execution protection
- runtime observability
- session durability

Nói ngắn gọn: hiện tại hook system mạnh nhất ở **phòng ngự**, **ghi nhận**, và **giữ được state qua session**.

Its most important recent improvements are:

- deterministic memory persistence on prompt submit
- true circuit-breaker enforcement for `Task`
- commit and task decision logging into the same ledger family
- active session-state bootstrap instead of passive recovery only

The main documentation rule going forward should be simple:

- treat `.claude/settings.json` as the canonical runtime graph
- treat `.claude/hooks/` as the implementation inventory
- treat this file as a human-readable synthesis of those two

Nếu chỉ nhớ 1 câu thì nhớ câu này:

- `settings.json` nói "hook nào đang chạy"
- `.claude/hooks/` nói "hook đó được implement ra sao"
- file này chỉ nên đóng vai trò giải thích để con người đọc nhanh
