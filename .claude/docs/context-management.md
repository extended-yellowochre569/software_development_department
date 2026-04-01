# Context Management

Context is the most critical resource in a Claude Code session. Manage it actively.

**The file is the memory, not the conversation.** Conversations are ephemeral and
will be compacted or lost. Files on disk persist across compactions and session crashes.

> For examples, rationale, and deep-dive patterns, see `context-management-guide.md`.

## Recovery After Session Crash

If a session dies ("prompt too long") or you start a new session to continue work:

1. The `session-start.sh` hook will detect and preview `active.md` automatically
2. Read the full state file for context
3. Read the partially-completed file(s) listed in the state
4. Continue from the next incomplete section or task

## Proactive Compaction

- **Compact proactively** at ~60-70% context usage, not reactively at the limit
- **Use `/clear`** between unrelated tasks, or after 2+ failed correction attempts
- **Natural compaction points:** after writing a section to file, after committing,
  after completing a task, before starting a new topic
- **Focused compaction:** `/compact Focus on [current task] — sections 1-3 are
  written to file, working on section 4`
- Insert `<!-- COMPACT: timestamp | Task: ... -->` boundary marker before new STATUS
- After recovery, skip everything above the last COMPACT marker

## Compaction Instructions

When context is compacted, preserve the following in the summary:

- Reference to `production/session-state/active.md` (read it to recover state)
- List of files modified in this session and their purpose
- Architectural decisions made and their rationale
- Active sprint tasks and their current status
- Agent invocations and their outcomes (success/failure/blocked)
- Test results (pass/fail counts, specific failures)
- Unresolved blockers or questions awaiting user input
- Current task and what step we are on
- Which sections of the current document are written to file vs. still in progress

**After compaction:** Read `production/session-state/active.md` and any files being
actively worked on to recover full context. The files contain the decisions; the
conversation history is secondary.

## Session State File

Maintain `production/session-state/active.md` as a living checkpoint. Update it
after each significant milestone (design approved, architecture decision made,
implementation milestone reached, test results obtained).

Contents: current task, progress checklist, key decisions made, files being
worked on, and open questions.

Requirements:
- YAML frontmatter with `session`, `branch`, `tags`, `started`, `lastActive` fields
- After every `/compact` or session resume, re-append `<!-- STATUS -->` block to
  the END of `active.md` (tail-first re-append, mirrors `reAppendSessionMetadata()`)
- The **last** `<!-- STATUS -->` block in the file always wins
- Do NOT delete old status blocks — simply append a new one below
- After any disruption (compaction, crash, `/clear`), read the state file first
- Maintain `## Files This Session` section tracking created/modified/deleted files
- Log partial file reads in `## Partial Reads This Session`
- Mark cached decisions as potentially stale in `## Cached Decisions (may be stale)`

## Context Budgets by Task Type

- Light (read/review): ~3k tokens startup
- Medium (implement feature): ~8k tokens
- Heavy (multi-system refactor): ~15k tokens

## Subagent Delegation

Use subagents for research and exploration to keep the main session clean.
Subagents run in their own context window and return only summaries:

- **Use subagents** when investigating across multiple files, exploring unfamiliar code,
  or doing research that would consume >5k tokens of file reads
- **Use direct reads** when you know exactly which 1-2 files to check
- Subagents do not inherit conversation history — provide full context in the prompt
- Restrict tool access per agent type (memory: Write only to `.claude/memory/`,
  docs: Write only to `docs/`, summarization: read-only)
- Log subagent outcomes to `## Subagent Log` in `active.md`

### Diminishing Returns Detection

If the same task has been retried **3+ times** without measurable progress (no new
files written, no new decisions made, same error recurring):

- **Stop the retry loop immediately** — do NOT attempt a 4th retry
- Log all blockers in `active.md` under `## Open Questions`
- Surface a diagnosis to the user with every attempted step documented

## Memory System

For enduring knowledge (user preferences, technical directives, architecture
decisions), use Claude's native memory in `.claude/memory/`.

- **`MEMORY.md` (Index):** Root pointer read every session via `CLAUDE.md`.
  Format: `- [Title](filename.md) - One-line hook`. **Line 201+ silently dropped
  without warning.** Keep under 200 lines always.
- **Recall limit:** At most 5 topic files injected per query. Design each file
  to be independently useful — do not split one concept across multiple files.
- **Topic files:** Must include YAML frontmatter with `name`, `description`, `type`.
  Write `description` as a search query, not a label
  (e.g. `"When to use monorepo vs multi-repo"` not `"Repo structure"`).
- **Types:** `user` (pilot info), `feedback` (do's/don'ts — highest ROI),
  `project` (tech decisions), `reference` (external pointers).
- **Never save to memory:** API keys, tokens, passwords, PII, raw source code.
  Save insights only. If unsure — skip it.
- If `MEMORY.md` gets too long, trigger `/dream` to auto-consolidate.

## Incremental File Writing

When creating multi-section documents:

1. Create the file immediately with a skeleton (all section headers, empty bodies)
2. Discuss and draft one section at a time in conversation
3. Write each section to the file as soon as it's approved
4. Update the session state file after each section
5. After writing a section, previous discussion can be safely compacted
