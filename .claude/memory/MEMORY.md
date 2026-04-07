# 🧠 SDD Memory Index (Tier 1 — Always Loaded)

> **HARD LIMIT:** This file MUST stay under 50 lines. No frontmatter. Index only.
> **Auto-consolidation:** If this file exceeds 40 lines → trigger `/dream` immediately.

## Active Project State

<!-- Agents update this section on every significant decision -->

- Stack: [not configured] — run `/start` to populate
- Last session: _(auto-updated by session-stop.sh)_
- Current focus: _(agent fills in at session start)_

## Tier 2 — Load On Demand
<!-- Only load these files when the task explicitly requires them -->
<!-- Trigger keywords shown in [brackets] -->
- [User Profile](user_role.md) — [user preferences, coding style, personalization]
- [Tech Decisions](project_tech_decisions.md) — [architecture, stack choice, infrastructure]
- [Feedback Rules](feedback_rules.md) — [do/don't, code review, repeated mistakes]
- [Reference Links](reference_links.md) — [staging URL, external tools, credentials]
- [GitNexus Registry](gitnexus-registry.md) — [gitnexus, impact analysis, repo index]

## Tier 3 — Search Archive (Do NOT load proactively)
<!-- Located in .claude/memory/archive/ — only search when user explicitly asks -->
<!-- Use grep to find relevant entries: grep -r "keyword" .claude/memory/archive/ -->
- Session logs: `.claude/memory/archive/sessions/`
- Consolidated decisions: `.claude/memory/archive/decisions/`
- Dream consolidation history: `.claude/memory/archive/dreams/`


## Loading Rules for Agents

1. **Tier 1** (this file): Always in context. Never exceed 50 lines.
2. **Tier 2**: Read a file ONLY if current task matches its trigger keywords.
3. **Tier 3**: Never load proactively. Only grep-search when user asks "what did we decide about X".
4. **Promotion**: If you write new info to Tier 3, add a 1-line summary to Tier 2 file.
5. **Compaction signal**: If context > 70% full, compress Tier 2 reads to bullet summaries.
