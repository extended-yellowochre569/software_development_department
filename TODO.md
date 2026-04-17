# TODO / Backlog

> **Governor**: @producer — invoke for sprint planning, prioritization, and feature breakdown
> **Agents**: May add items to "Backlog" and move completed items to "Completed". Preserve section order. Never reorder items within a section — priority position is set by humans or @producer when explicitly asked.

---

## In Progress

- [ ] (WIP) #001 — Perform P1-1 Dogfooding: Update PRD, TODO, and CLAUDE.md [area: setup] → [.tasks/001-dogfooding-setup.md](.tasks/001-dogfooding-setup.md)

---

## Up Next (prioritized)

- [ ] #002 — Sync badges and number occurrences across READMEs [area: docs] → [.tasks/002-sync-badges.md](.tasks/002-sync-badges.md)
- [ ] #003 — Cleanup root directory and move reports to docs/ [area: setup] → [.tasks/003-root-cleanup.md](.tasks/003-root-cleanup.md)
- [ ] #004 — Fix MEMORY.md broken link comments in Tier 2.5 [area: setup] → [.tasks/004-fix-memory-links.md](.tasks/004-fix-memory-links.md)
- [ ] #005 — Configure or strip Supermemory MCP in .mcp.json [area: tools] → [.tasks/005-supermemory-config.md](.tasks/005-supermemory-config.md)
- [ ] #006 — Add YAML frontmatter to Tier-2 memory topic files [area: setup] → [.tasks/006-memory-frontmatter.md](.tasks/006-memory-frontmatter.md)
- [ ] #007 — Bootstrap minimal test harness and CI workflow [area: qa] → [.tasks/007-test-harness.md](.tasks/007-test-harness.md)

---

## Backlog

- [ ] #008 — Populate decision_ledger.jsonl with backfilled entries [area: setup] → [.tasks/008-populate-ledger.md](.tasks/008-populate-ledger.md)
- [ ] #009 — Relax CLAUDE.md proactively writing rule [area: setup] → [.tasks/009-relax-write-rule.md](.tasks/009-relax-write-rule.md)
- [ ] #010 — Implement skill audit to remove duplicate skills [area: tools] → [.tasks/010-skill-audit.md](.tasks/010-skill-audit.md)
- [ ] #011 — Build observability dashboard/viewer for JSONL logs [area: tools] → [.tasks/011-obs-dashboard.md](.tasks/011-obs-dashboard.md)

---

## Completed

- [x] #000 — Initial project setup and harness configuration → [.tasks/000-initial-project-setup.md](.tasks/000-initial-project-setup.md)

---

## Item Format Guide

When adding new items, use this format:

```
- [ ] #NNN — Brief description of the task [area: tag] → [.tasks/NNN-short-title.md](.tasks/NNN-short-title.md)
```

Every TODO item must have a corresponding `.tasks/NNN-*.md` file. @producer creates both together.

**Area tags** help agents know which specialist to use:

| Area tag | Agent |
|---|---|
| `frontend` | @frontend-developer |
| `backend` | @backend-developer |
| `database` | @data-engineer |
| `design` | @ux-designer |
| `qa` | @qa-tester |
| `docs` | @tech-writer |
| `infra` | @devops-engineer |
| `mobile` | @mobile-developer |
| `security` | @security-engineer |
| `analytics` | @analytics-engineer |
| `network` | @network-programmer |
| `ai` | @ai-programmer |
| `performance` | @performance-analyst |
| `tools` | @tools-programmer |
| `setup` | general |

**Priority**: Items higher in "Up Next" are higher priority. Agents move completed items to "Completed" and may add new items to "Backlog". Only humans reorder items within a section to change priority, unless explicitly asked to reprioritize.
