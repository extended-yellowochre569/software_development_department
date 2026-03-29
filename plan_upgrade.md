# Plan: Tích hợp orchestrated-project-template vào Development-Software-Department

> **Ngày tạo**: 2026-03-29
> **Nguồn phân tích**: [compare_department_orchestrated.md](compare_department_orchestrated.md)
> **Repo tham khảo**: `D:\Orchestrated-project-template` (clone từ https://github.com/josipjelic/orchestrated-project-template)
> **Trạng thái**: Chưa thực hiện — chờ review

---

## Tóm tắt

Tích hợp các tính năng project-management và agent-governance từ `orchestrated-project-template` vào harness hiện tại, bao gồm: PRD system, task backlog, document ownership, /orchestrate skill, ADR log, và model cost optimization.

**Tổng số file thay đổi**: ~35 files (27 agent definitions + 8 files mới/sửa)

---

## Phase 0 — Quyết định Governance (không thay đổi file)

Trước khi thực hiện, xác định rõ ownership:

- `@producer` → governor của `TODO.md` + `.tasks/` (tương đương `@project-manager` của Template)
- `@product-manager` → governor của `PRD.md`

**Handoff rule**: Khi `@product-manager` hoàn thiện PRD, `@producer` tạo các TODO items và `.tasks/` files tương ứng.

---

## Phase 1 — Foundation Documents

**Ưu tiên**: HIGH
**Phụ thuộc**: Không có
**3 việc có thể thực hiện song song**

### 1A. Tạo `PRD.md` ở root

- **File**: `PRD.md` (mới)
- **Nguồn**: Adapt từ `D:\Orchestrated-project-template\PRD.md`
- **Thay đổi cần thiết**:
  - Giữ nguyên `[!WARNING]` protection banner
  - Dùng format FR-numbered requirements (FR-001, FR-002...)
  - Thêm "Approvals" section với: Product Manager, Technical Director, CTO
  - Thêm placeholder cho project chưa cấu hình

### 1B. Tạo `TODO.md` + `.tasks/TASK_TEMPLATE.md`

- **File 1**: `TODO.md` ở root (mới)
- **Nguồn**: Adapt từ `D:\Orchestrated-project-template\TODO.md`
- **Thay đổi cần thiết**:
  - Đổi governor từ `@project-manager` → `@producer`
  - Mở rộng area tags: thêm `mobile`, `security`, `analytics`, `network`, `ai`
  - Cập nhật routing table để include đầy đủ 27 agents của Department

- **File 2**: `.tasks/TASK_TEMPLATE.md` (mới)
- **Nguồn**: Copy verbatim từ `D:\Orchestrated-project-template\.tasks\TASK_TEMPLATE.md`

**Format task entry trong TODO.md**:
```
- [ ] #NNN — Clear, outcome-focused description [area: tag] → [.tasks/NNN-short-title.md](.tasks/NNN-short-title.md)
```

**Format file `.tasks/NNN-*.md`**:
```yaml
---
id: NNN
title: ...
status: todo
area: backend
agent: backend-developer
created_at: YYYY-MM-DD
prd_refs: [FR-001, FR-002]
blocks: []
blocked_by: []
priority: high
---
## Description
## Acceptance Criteria
## Technical Notes
## History
```

### 1C. Cập nhật docs cấu trúc

- **File 1**: `.claude/docs/directory-structure.md` (sửa)
  - Thêm vào root: `PRD.md`, `TODO.md`, `.tasks/`
  - Thêm vào `docs/`: `technical/ARCHITECTURE.md`, `technical/DECISIONS.md`, `technical/API.md`, `technical/DATABASE.md`, `user/USER_GUIDE.md`

- **File 2**: `.claude/docs/quick-start.md` (sửa)
  - Thêm `TODO.md`, `PRD.md`, `.tasks/` vào file structure reference
  - Thêm vào "First Steps for a New Project"

---

## Phase 2 — Document Ownership trong Agent Definitions

**Ưu tiên**: HIGH
**Phụ thuộc**: Phase 1 hoàn thành
**27 agents cần sửa**, chia 3 nhóm

### Pattern chuẩn (từ Template)

Thêm ngay sau phần mở đầu của mỗi agent, trước "Working Protocol":

```markdown
## Documents You Own

- `path/to/file.md` — mô tả phạm vi ownership

## Documents You Read (Read-Only)

- `PRD.md` — **Read-only. Never modify.** Source of truth cho requirements.
- `CLAUDE.md` — Project conventions và rules

## Documents You Never Modify

- `PRD.md` — Human-approved edits only.
- Bất kỳ file nào trong `.claude/agents/` — Agent definitions là harness-level.
```

### Nhóm A — 6 agents ưu tiên cao (làm trước)

| Agent | Owns | Read-Only |
|---|---|---|
| `technical-director` | `docs/technical/DECISIONS.md`, `docs/technical/ARCHITECTURE.md` | `PRD.md`, `CLAUDE.md`, `docs/technical/API.md`, `docs/technical/DATABASE.md`, `TODO.md` |
| `data-engineer` | `docs/technical/DATABASE.md` | `PRD.md`, `CLAUDE.md`, `docs/technical/ARCHITECTURE.md`, `docs/technical/API.md` |
| `backend-developer` | `docs/technical/API.md` | `PRD.md`, `CLAUDE.md`, `docs/technical/ARCHITECTURE.md`, `docs/technical/DATABASE.md` |
| `tech-writer` | `docs/user/USER_GUIDE.md`, `README.md` (overview sections) | `PRD.md`, `CLAUDE.md`, `docs/technical/API.md`, `docs/technical/ARCHITECTURE.md` |
| `product-manager` | `PRD.md` (với explicit human-approval), per-feature PRDs | `TODO.md`, `CLAUDE.md`, `docs/technical/DECISIONS.md` |
| `producer` | `TODO.md`, `.tasks/NNN-*.md`, `production/` | `PRD.md`, `CLAUDE.md`, `docs/technical/DECISIONS.md`, `docs/technical/ARCHITECTURE.md` |

> **Lưu ý `producer`**: Cần thêm substantial content — full TODO.md governance protocol từ `@project-manager` của Template (sync rules, max WIP, sprint health signals).

### Nhóm B — 10 agents thứ yếu

| Agent | Owns | Read-Only |
|---|---|---|
| `cto` | Strategic ADRs trong `docs/technical/DECISIONS.md` (co-owns với technical-director) | `PRD.md`, `CLAUDE.md`, `TODO.md`, `docs/technical/ARCHITECTURE.md` |
| `lead-programmer` | Code-level ADRs trong `docs/technical/DECISIONS.md` (appending only) | `PRD.md`, `CLAUDE.md`, `docs/technical/ARCHITECTURE.md`, `docs/technical/API.md` |
| `devops-engineer` | CI/CD pipeline docs (nếu tạo `docs/technical/INFRASTRUCTURE.md`) | `PRD.md`, `CLAUDE.md`, `docs/technical/ARCHITECTURE.md`, `docs/technical/DECISIONS.md` |
| `security-engineer` | Security threat models trong `docs/technical/DECISIONS.md` (appending) | `PRD.md`, `CLAUDE.md`, `docs/technical/ARCHITECTURE.md`, `docs/technical/API.md` |
| `ux-designer` | `design/` directory — wireframes, user flows, specs | `PRD.md`, `CLAUDE.md`, `TODO.md` |
| `ux-researcher` | `design/research/` — research reports, usability findings | `PRD.md`, `CLAUDE.md`, `design/` |
| `frontend-developer` | `src/frontend/`, `src/components/` | `docs/technical/API.md`, `PRD.md`, `CLAUDE.md` |
| `qa-lead` | `tests/` (strategy, test plans) | `PRD.md`, `CLAUDE.md`, `docs/technical/API.md` |
| `qa-tester` | `tests/` (test cases, specs) | `PRD.md`, `CLAUDE.md`, `docs/technical/API.md` |
| `release-manager` | `production/`, `CHANGELOG.md` | `TODO.md`, `PRD.md` |

### Nhóm C — 11 agents nhẹ (chỉ cần Read-only declarations)

`performance-analyst`, `analytics-engineer`, `ai-programmer`, `network-programmer`, `tools-programmer`, `ui-programmer`, `mobile-developer`, `fullstack-developer`, `accessibility-specialist`, `prototyper`, `community-manager`

Tất cả đều cần:
- Owns: code domain trong `src/`
- Read-only: `PRD.md`, `CLAUDE.md`
- Never modify: `PRD.md`, `.claude/agents/`

---

## Phase 3 — ADR System Alignment

**Ưu tiên**: MEDIUM
**Phụ thuộc**: Phase 2 hoàn thành

### Giải pháp dual-track (không conflict với hệ thống ADR hiện có)

| Track | File | Format | Dùng cho |
|---|---|---|---|
| Compact log | `docs/technical/DECISIONS.md` | ADR ngắn gọn | Quick-reference, đọc bởi `/orchestrate` |
| Detailed ADR | `docs/architecture/adr-NNNN-*.md` | ADR đầy đủ | Major decisions, tạo qua `/architecture-decision` |

### Các thay đổi cần thực hiện

1. **Tạo `docs/technical/DECISIONS.md`** (mới)
   - Header + format instructions
   - Empty log (chưa có ADR nào)
   - Format mỗi entry:

```markdown
## ADR-NNN: [Short Title]

**Date**: YYYY-MM-DD
**Status**: Accepted
**Deciders**: [tên người / @technical-director]

### Context
[Tình huống hoặc vấn đề dẫn đến quyết định này]

### Decision
[Quyết định gì và lý do chính]

### Consequences
- **Positive**: [...]
- **Negative**: [...]
```

2. **Sửa `.claude/skills/architecture-decision/SKILL.md`** (sửa)
   - Thêm bước: sau khi lưu detailed ADR file, cross-post summary vào `docs/technical/DECISIONS.md`

---

## Phase 4 — Port `/orchestrate` thành Skill

**Ưu tiên**: MEDIUM
**Phụ thuộc**: Phase 1–3 hoàn thành

### File cần tạo

**`.claude/skills/orchestrate/SKILL.md`** (mới)

Frontmatter:
```yaml
---
name: orchestrate
description: "Orchestrate a multi-agent task — phân tích dependencies, lập wave execution plan, phối hợp với @producer, tạo feature branch, và chạy specialist agents theo parallel/sequential waves."
argument-hint: "<task description>"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash, Task, AskUserQuestion, TodoWrite
---
```

### Các thay đổi so với Template gốc

**Phase 1 (Ground Yourself)** — Gần như copy verbatim. Thêm bước đọc `.claude/docs/agent-roster.md` và `.claude/docs/agent-coordination-map.md`.

**Phase 2 (Task Decomposition)** — Viết lại routing table cho 27 agents:

```
| Task involves... | Agent |
|---|---|
| Architecture decisions, tech choices, NFR | `technical-director` (Opus) |
| Product requirements, user stories | `product-manager` |
| UX flows, interaction design | `ux-designer` |
| Database schema, migrations | `data-engineer` |
| API endpoints, business logic, auth | `backend-developer` |
| UI components, pages, client state | `frontend-developer` |
| Full-stack features | `fullstack-developer` |
| E2E tests, test strategy | `qa-tester` (Haiku) |
| QA strategy sign-off | `qa-lead` |
| Documentation, user guide, README | `tech-writer` (Haiku) |
| CI/CD, deployment pipelines | `devops-engineer` (Haiku) |
| Security review, threat modeling | `security-engineer` |
| Real-time, WebSockets, networking | `network-programmer` |
| Performance profiling | `performance-analyst` |
| AI/ML features, inference | `ai-programmer` |
| Mobile (React Native / native) | `mobile-developer` |
| User research, analytics | `ux-researcher` |
| Developer tooling, build scripts | `tools-programmer` (Haiku) |
| Release packaging | `release-manager` |
```

**Phase 3 (Dependency Analysis)** — Cập nhật sequential dependencies:
1. `technical-director` → tất cả implementation agents
2. `data-engineer` → `backend-developer`
3. `ux-designer` → `frontend-developer`
4. `backend-developer` → `frontend-developer` (khi cần API mới)
5. Tất cả implementation → `tech-writer`
6. `security-engineer` sau `backend-developer` khi có auth/sensitive data
7. `qa-lead` sau `qa-tester` trước synthesis

**Phase 5 (Backlog Registration)** — Đổi `@project-manager` → `@producer`

**Phases 6–8** — Copy gần như verbatim, giữ Conventional Commits format (đã có trong validate-commit.sh hook)

### Files bổ sung cần cập nhật

- `.claude/docs/skills-reference.md` — thêm `/orchestrate`
- `.claude/docs/quick-start.md` — thêm `/orchestrate` vào slash commands table
- `.claude/docs/agent-coordination-map.md` — thêm orchestration workflow

---

## Phase 5 — Model Cost Optimization

**Ưu tiên**: MEDIUM
**Phụ thuộc**: Phase 2 hoàn thành

| Agent | Trước | Sau | Lý do |
|---|---|---|---|
| `tech-writer` | `sonnet` | `haiku` | Doc writing không cần reasoning cao, tiết kiệm cost |

> `devops-engineer` đã là Haiku — không thay đổi.
> Các agents Sonnet còn lại giữ nguyên — cần reasoning capability.

**Files cần sửa**:
- `.claude/agents/tech-writer.md` — đổi `model: sonnet` → `model: haiku` trong frontmatter
- `.claude/docs/agent-roster.md` — cập nhật dòng `tech-writer`

---

## Phase 6 — `/sync-template` Skill

**Ưu tiên**: LOW
**Phụ thuộc**: Không có (độc lập)

- **File**: `.claude/skills/sync-template/SKILL.md` (mới)
- **Nguồn**: Adapt từ `D:\Orchestrated-project-template\.claude\commands\sync-template.md`
- **Thay đổi chính**: URL template không hardcode — skill hỏi user nếu chưa configure trong `CLAUDE.md`

---

## Thứ tự thực hiện

```
Phase 0  →  Quyết định governance (không file changes)
              ↓
Phase 1A + 1B + 1C  →  Parallel (Foundation Documents)
              ↓
Phase 2  →  27 agent ownership sections
         (Nhóm A trước → Nhóm B → Nhóm C)
              ↓
Phase 3  →  ADR system (DECISIONS.md + skill update)
              ↓
Phase 4  →  /orchestrate skill
              ↓
Phase 5  →  tech-writer → haiku  (có thể làm sau Phase 2)
Phase 6  →  /sync-template skill (độc lập, làm bất kỳ lúc nào)
```

---

## Risk Register

| # | Rủi ro | Mức | Cách xử lý |
|---|---|---|---|
| R1 | 2 ADR path mâu thuẫn (`docs/technical/DECISIONS.md` vs `docs/architecture/adr-*.md`) | Trung bình | Dual-track: compact log + detailed files (Phase 3) |
| R2 | `@producer` vs `@product-manager` handoff không rõ ràng | Trung bình | Thêm explicit handoff note trong cả 2 agent + `agent-coordination-map.md` |
| R3 | Skill `/orchestrate` routing table lỗi thời khi thêm agent mới | Thấp | Ghi chú maintenance trong skill body |
| R4 | `PRD.md` không có machine enforcement | Thấp | Warning banner + ownership sections đủ cho hiện tại; hook có thể thêm sau |
| R5 | TODO.md được tạo nhưng `@producer` thiếu governance protocol | Trung bình | Phase 2 phải thêm full governance content vào `producer.md`, không chỉ ownership section |
| R6 | `skills-reference.md`, `quick-start.md`, `agent-coordination-map.md` quên cập nhật | Thấp | Treat doc updates là acceptance criteria của Phase 4 |
| R7 | `devops-engineer` Haiku nhưng content kém (pre-existing) | Thấp | Ngoài scope tích hợp này |

---

## Ma trận nguồn gốc file

| File | Nguồn | Hành động |
|---|---|---|
| `PRD.md` | Template `PRD.md` | Mới — adapt |
| `TODO.md` | Template `TODO.md` | Mới — adapt |
| `.tasks/TASK_TEMPLATE.md` | Template `TASK_TEMPLATE.md` | Mới — copy verbatim |
| `docs/technical/DECISIONS.md` | Template agent format section | Mới — viết mới |
| `.claude/docs/directory-structure.md` | Hiện có | Sửa |
| `.claude/docs/quick-start.md` | Hiện có | Sửa |
| `.claude/agents/*.md` (27 files) | Pattern từ Template | Sửa — thêm ownership sections |
| `.claude/skills/orchestrate/SKILL.md` | Template `orchestrate.md` | Mới — adapt |
| `.claude/skills/sync-template/SKILL.md` | Template `sync-template.md` | Mới — adapt |
| `.claude/skills/architecture-decision/SKILL.md` | Hiện có | Sửa — thêm cross-post step |
| `.claude/docs/skills-reference.md` | Hiện có | Sửa |
| `.claude/docs/agent-roster.md` | Hiện có | Sửa |
| `.claude/agents/tech-writer.md` | Hiện có | Sửa frontmatter |
| `.claude/agents/producer.md` | Hiện có + Template PM protocol | Sửa — thêm governance content |
| `.claude/agents/product-manager.md` | Hiện có | Sửa — thêm ownership + PRD protection |
