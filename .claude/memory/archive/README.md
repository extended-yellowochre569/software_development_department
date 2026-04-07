# 📦 Memory Archive (Tier 3)

This directory is the **long-term cold storage** for SDD project memory.

> **⚠️ Agents: Do NOT load files from this directory proactively.**
> Only search here when the user explicitly asks about past decisions or history.

## Structure

```
archive/
├── sessions/       # Saved session summaries (one file per session)
│                   # Format: YYYY-MM-DD_HH-MM_topic.md
│                   # Populated by: session-stop.sh
│
├── decisions/      # Major architectural or process decisions
│                   # Format: YYYY-MM-DD_decision-title.md
│                   # Agents write here when a significant decision is made
│
└── dreams/         # Dream consolidation outputs
                    # Format: YYYY-MM-DD_dream.md
                    # Populated by: /dream command or auto-dream in session-stop.sh
```

## How to Search

From Claude Code CLI:
```bash
# Search across all archives
grep -r "keyword" .claude/memory/archive/

# Search specific category
grep -r "authentication" .claude/memory/archive/decisions/

# List recent sessions
ls -lt .claude/memory/archive/sessions/ | head -10
```

## Promotion Policy

If an archived item becomes frequently referenced → **promote** it to a Tier 2 file
by adding a summary entry to the relevant `.claude/memory/*.md` file.
