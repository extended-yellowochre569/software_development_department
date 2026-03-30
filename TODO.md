# TODO / Backlog

> **Governor**: @producer — invoke for sprint planning, prioritization, and feature breakdown
> **Agents**: May add items to "Backlog" and move completed items to "Completed". Preserve section order. Never reorder items within a section — priority position is set by humans or @producer when explicitly asked.

---

## In Progress

- [ ] (WIP) #001 — [Short description of what's currently being worked on] [area: setup] → [.tasks/001-short-title.md](.tasks/001-short-title.md)

---

## Up Next (prioritized)

- [ ] #002 — [Short description] [area: backend] → [.tasks/002-short-title.md](.tasks/002-short-title.md)
- [ ] #003 — [Short description] [area: frontend] → [.tasks/003-short-title.md](.tasks/003-short-title.md)
- [ ] #004 — [Short description] [area: database] → [.tasks/004-short-title.md](.tasks/004-short-title.md)

---

## Backlog

- [ ] #005 — [Short description] [area: frontend] → [.tasks/005-short-title.md](.tasks/005-short-title.md)
- [ ] #006 — [Short description] [area: backend] → [.tasks/006-short-title.md](.tasks/006-short-title.md)
- [ ] #007 — [Short description] [area: docs] → [.tasks/007-short-title.md](.tasks/007-short-title.md)
- [ ] #008 — [Short description] [area: qa] → [.tasks/008-short-title.md](.tasks/008-short-title.md)

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
