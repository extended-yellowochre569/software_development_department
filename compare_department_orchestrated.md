# So sánh: Development-Software-Department vs orchestrated-project-template

> **Ngày tạo**: 2026-03-29
> **Repos**:
> - [Development-Software-Department](D:\Development-Software-Department) — harness hiện tại
> - [orchestrated-project-template](https://github.com/josipjelic/orchestrated-project-template) — clone tại `D:\Orchestrated-project-template`

---

## 1. Tổng quan định hướng

| Tiêu chí | Development-Software-Department | orchestrated-project-template |
|---|---|---|
| **Định hướng** | Harness/framework dùng lại cho nhiều dự án | Template khởi động 1 dự án cụ thể |
| **Mục tiêu** | Xây dựng "phòng ban" ảo linh hoạt | Đưa 1 sản phẩm từ 0 → production |
| **Triết lý** | User-driven collaboration | PRD-driven, design-before-code |
| **Stack config** | Chưa cấu hình (placeholder) | Điền đầy đủ sau onboarding |
| **Tài liệu triết lý** | `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` | `SOUL.md` — giải thích tại sao template được xây dựng như vậy |

---

## 2. Agents

| | Department | Template |
|---|---|---|
| **Số lượng** | 18+ agents | 12 agents |
| **Phạm vi** | Tổng quát (accessibility, mobile, network, analytics, tools...) | Project-focused (architect, PM, frontend, backend, DB, QA, docs, cicd, docker, copywriter, react-native, ui-ux) |
| **Model routing** | Opus cho senior agents | Opus chỉ cho `systems-architect`, Haiku cho `documentation-writer`, Sonnet cho còn lại |
| **Ownership tài liệu** | Không khai báo trong agent definition | Mỗi agent khai báo rõ **Documents You Own** vs **Read-only** |

### Danh sách agents so sánh

| Department | Template | Ghi chú |
|---|---|---|
| `technical-director` | `systems-architect` | Template chạy Opus, Department chạy Opus |
| `producer` | `project-manager` | Tương đương nhau |
| `frontend-developer` | `frontend-developer` | Giống nhau |
| `backend-developer` | `backend-developer` | Giống nhau |
| `data-engineer` | `database-expert` | Tương đương nhau |
| `qa-lead` + `qa-tester` | `qa-engineer` | Department tách 2 agent |
| `tech-writer` | `documentation-writer` | Template chạy Haiku — tiết kiệm chi phí |
| `devops-engineer` | `cicd-engineer` | Tương đương nhau |
| `ux-designer` + `ux-researcher` | `ui-ux-designer` | Department tách 2 agent |
| `mobile-developer` | `react-native-developer` | Template chỉ hỗ trợ React Native |
| — | `docker-expert` | Template có agent riêng, Department không có |
| — | `copywriter-seo` | Template có agent riêng, Department không có |
| `accessibility-specialist` | — | Department có, Template không có |
| `ai-programmer` | — | Department có, Template không có |
| `analytics-engineer` | — | Department có, Template không có |
| `network-programmer` | — | Department có, Template không có |
| `performance-analyst` | — | Department có, Template không có |
| `security-engineer` | — | Department có, Template không có |
| `tools-programmer` | — | Department có, Template không có |
| `fullstack-developer` | — | Department có, Template không có |
| `ui-programmer` | — | Department có, Template không có |
| `community-manager` | — | Department có, Template không có |
| `prototyper` | — | Department có, Template không có |
| `release-manager` | — | Department có, Template không có |
| `cto` | — | Department có, Template không có |
| `lead-programmer` | — | Department có, Template không có |

---

## 3. Workflow & Orchestration

### Department — workflow do người dùng điều phối

```
/start → cấu hình stack → agents làm việc theo yêu cầu
```

Không có pipeline cố định. Mỗi task là 1 cuộc trò chuyện riêng biệt.

### Template — pipeline rõ ràng từ đầu đến cuối

```
/start (5 phases onboarding)
  → PRD.md (source of truth)
    → TODO.md + .tasks/ (backlog)
      → /orchestrate (wave execution)
        → feature branch → PR
```

### /orchestrate — điểm nổi bật của Template

Template có command `/orchestrate` mà Department không có tương đương:

1. **Phase 1** — Ground: đọc `CLAUDE.md`, `DECISIONS.md`, `ARCHITECTURE.md`, `TODO.md`, `PRD.md`
2. **Phase 2** — Task Decomposition: xác định agents cần thiết + deliverables
3. **Phase 3** — Dependency Analysis: sequential vs parallel (có rules cứng)
4. **Phase 4** — Wave Plan: trình bày kế hoạch → user confirm trước khi execute
5. **Phase 5** — Backlog Registration: `@project-manager` đăng ký task vào `TODO.md`
6. **Phase 5b** — Feature Branch: tự tạo `feature/<slug>`
7. **Phase 6** — Tracking: `TodoWrite` theo dõi tiến độ từng wave
8. **Phase 7** — Execute: chạy từng wave, dừng khi có lỗi, hỏi user
9. **Phase 8** — Synthesis: tổng hợp kết quả, đề xuất PR

**Hard sequential dependencies trong Template:**
- `systems-architect` → tất cả implementation agents
- `database-expert` → `backend-developer`
- `ui-ux-designer` → `frontend-developer`
- `backend-developer` → `frontend-developer` (khi cần API mới)
- `copywriter-seo` → `frontend-developer` (trang public)
- tất cả implementation → `documentation-writer`

---

## 4. Task & Backlog Management

| | Department | Template |
|---|---|---|
| **Backlog** | Không có | `TODO.md` làm living backlog |
| **Task files** | Không có | `.tasks/NNN-*.md` — 1 file/task với đầy đủ frontmatter |
| **PRD** | Không có | `PRD.md` — source of truth, được bảo vệ 3 lớp |
| **ICE scoring** | Không có | `@project-manager` dùng ICE để prioritize |
| **Dependency graph** | Không có | `blocks:` / `blocked_by:` trong task files |
| **Spike tasks** | Không có | PM đề xuất spike task để de-risk assumptions |

### Format task file của Template

```markdown
---
id: 003
title: User authentication schema
status: todo
area: database
agent: database-expert
created_at: 2026-03-29
prd_refs: [FR-001, FR-002]
blocks: [004, 005]
blocked_by: [001]
priority: high
---

## Description
...

## Acceptance Criteria
...

## Technical Notes
...

## History
| Date | Action | By |
```

### Cấu trúc TODO.md của Template

```markdown
## Up Next (3–5 tasks sẵn sàng)
- [ ] #001 — [title] [area: database] → .tasks/001-xxx.md

## Backlog
- [ ] #010 — [title] [area: frontend] → .tasks/010-xxx.md

## Completed
- [x] #000 — Initial project setup
```

---

## 5. Document Ownership System

Template khai báo rõ trong mỗi agent definition:

```markdown
## Documents You Own
- `docs/technical/ARCHITECTURE.md`
- `docs/technical/DECISIONS.md`

## Documents You Read (Read-Only)
- `PRD.md` — Read-only. Never modify.
- `CLAUDE.md`
```

Department không có cơ chế này — không rõ agent nào "sở hữu" tài liệu nào.

---

## 6. Tài liệu kỹ thuật dự án

| | Department | Template |
|---|---|---|
| `ARCHITECTURE.md` | Không có | `docs/technical/ARCHITECTURE.md` — C4 model |
| `DECISIONS.md` | Không có | `docs/technical/DECISIONS.md` — ADR log (append-only) |
| `API.md` | Không có | `docs/technical/API.md` |
| `DATABASE.md` | Không có | `docs/technical/DATABASE.md` |
| `USER_GUIDE.md` | Không có | `docs/user/USER_GUIDE.md` |
| `CONTENT_STRATEGY.md` | Không có | `docs/content/CONTENT_STRATEGY.md` |
| `PRD.md` | Không có | `PRD.md` — source of truth |

Department chỉ có docs về workflow harness (`docs/COLLABORATIVE-DESIGN-PRINCIPLE.md`, `docs/WORKFLOW-GUIDE.md`) — không có docs kỹ thuật cho project cụ thể.

---

## 7. Automation & Infrastructure

| | Department | Template |
|---|---|---|
| **Hooks** | 7 hooks | Không có |
| **Skills** | 200+ skills | 3 commands |
| **Rules files** | 9 files theo domain | Không có (quy tắc trong CLAUDE.md) |
| **settings.json** | Đầy đủ permissions, tool config | Không có |
| **Session management** | session-state, session-logs, compaction protocol | Không có |
| **statusline.sh** | Có | Không có |

### Hooks của Department

| Hook | Trigger | Chức năng |
|---|---|---|
| `session-start.sh` | Bắt đầu session | Phát hiện documentation gaps, hiển thị active.md |
| `session-stop.sh` | Kết thúc session | Log session summary |
| `pre-compact.sh` | Trước khi compact | Lưu context trước khi nén |
| `validate-commit.sh` | Trước khi commit | Kiểm tra commit message format |
| `validate-push.sh` | Trước khi push | Kiểm tra trước khi đẩy code |
| `log-agent.sh` | Sau khi dùng agent | Ghi audit log |
| `detect-gaps.sh` | Định kỳ | Phát hiện thiếu documentation |
| `validate-assets.sh` | Khi tạo/sửa assets | Kiểm tra assets |

### Rules files của Department

| File | Áp dụng cho |
|---|---|
| `api-code.md` | `src/api/**`, `src/routes/**` |
| `database-code.md` | `src/db/**`, `src/models/**` |
| `frontend-code.md` | `src/frontend/**`, `src/components/**` |
| `secrets-config.md` | `.env*`, `*.config.*` |
| `ai-code.md` | AI/ML code |
| `design-docs.md` | Design documentation |
| `network-code.md` | Networking code |
| `prototype-code.md` | `prototypes/**` |
| `test-standards.md` | `tests/**` |
| `ui-code.md` | UI components |
| `data-files.md` | Data files |

---

## 8. Onboarding Protocol

### Department — /start skill

Gọi skill `/start` tổng quát. Không có quy trình chi tiết bắt buộc.

### Template — START_HERE.md (5 phases bắt buộc)

**Phase 1** — Gather Project Information (24 câu hỏi theo 6 nhóm):
- Group 1: Project basics (tên, mô tả, users, vấn đề)
- Group 2: Tech stack (frontend, backend, DB, ORM, hosting, package manager)
- Group 3: Conventions (formatter, test runner, commands)
- Group 4: Product requirements (features v1, NFRs, out of scope)
- Group 5: Content & SEO (nếu có public pages)
- Group 6: Goals & open questions

**Phase 2** — Fill in Documentation (7 files):
- Copy templates từ `.claude/templates/` vào đúng chỗ
- Điền `CLAUDE.md`, `README.md`, `PRD.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `CONTENT_STRATEGY.md`

**Phase 3** — Build Initial Backlog:
- Derive tasks từ PRD
- Tạo TODO.md + .tasks/ files
- Xóa placeholder items

**Phase 4** — Review với user: structured summary report

**Phase 5** — Xóa `START_HERE.md` sau khi user confirm

---

## 9. Model Cost Optimization

### Department
- Senior agents (technical-director, producer, cto): Opus
- Phần lớn agents: không khai báo rõ (mặc định Sonnet)

### Template
- `systems-architect`: **Opus** — "architectural decisions deserve more deliberation"
- `documentation-writer`: **Haiku** — "writing user guides requires clarity, not compute"
- Còn lại: **Sonnet**

Template tiết kiệm chi phí hơn vì phân loại rõ độ phức tạp của từng loại task.

---

## 10. Sync Template

Template có command `/sync-template` để cập nhật từ upstream repo — useful khi template được cập nhật. Department không có cơ chế tương tự.

---

## Tổng kết: Điểm mạnh mỗi bên

### Department mạnh hơn ở:

- **Automation**: hooks chạy tự động (session, commit, push, audit)
- **Skills ecosystem**: 200+ skills plug-and-play
- **Agent breadth**: nhiều specialization hơn (mobile, network, analytics, accessibility, security...)
- **Rules system**: tách biệt theo domain, dễ maintain
- **Context management**: session-state, compaction protocol có hệ thống
- **Reusability**: dùng được cho nhiều dự án khác nhau mà không cần setup lại

### Template mạnh hơn ở:

- **Pipeline rõ ràng**: PRD → Task → Execute → PR (end-to-end)
- **/orchestrate**: wave-based execution thực sự mạnh, có dependency analysis
- **Document ownership**: mỗi agent biết mình "sở hữu" gì, không đụng vào gì
- **Task management**: TODO.md + .tasks/ — backlog có cấu trúc, traceability tốt
- **PRD protection**: source of truth được bảo vệ 3 lớp
- **Onboarding protocol**: 5 phases chi tiết, đảm bảo đủ context trước khi build
- **Model cost optimization**: Haiku cho docs, Opus chỉ cho architect
- **ADR system**: DECISIONS.md append-only — institutional memory
- **Triết lý rõ ràng**: SOUL.md giải thích tại sao

---

## Gợi ý tích hợp

Hai hệ thống bổ sung cho nhau. Những gì Department có thể mượn từ Template:

| Tính năng | Từ Template | Ưu tiên |
|---|---|---|
| Document ownership trong agent definitions | Thêm `## Documents You Own` vào mỗi `.claude/agents/*.md` | Cao |
| TODO.md + .tasks/ system | Thêm vào directory structure | Cao |
| PRD.md template | Thêm vào `.claude/docs/` | Cao |
| /orchestrate command | Port thành skill | Trung bình |
| Model routing tối ưu | Dùng Haiku cho tech-writer, docs agents | Trung bình |
| ADR system (DECISIONS.md) | Thêm vào docs/ | Trung bình |
| /sync-template mechanism | Thêm vào skills | Thấp |

Ngược lại, Template có thể mượn từ Department:

| Tính năng | Từ Department | Ưu tiên |
|---|---|---|
| Hook system | session-start, validate-commit | Cao |
| Rules files theo domain | api-code.md, database-code.md... | Cao |
| Skills ecosystem | Tích hợp 200+ skills | Trung bình |
| Context management protocol | session-state, compaction | Trung bình |
| Agent breadth | security, accessibility, performance | Thấp |
