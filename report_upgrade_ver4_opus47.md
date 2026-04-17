# 🏛️ AUDIT KIẾN TRÚC SDD — Báo cáo của Kiến trúc sư trưởng

> **Reviewer:** Anthropic Chief Architect (Claude Opus 4.7)
> **Ngày:** 2026-04-17
> **Phiên bản dự án:** SDD v1.32.0 (commit `af29124`)
> **Phương pháp:** 4 audit song song — Architecture / Security / Skills / Memory — sau đó tổng hợp

## 📌 Changelog báo cáo

| Ngày       | Hành động                                   | Chi tiết                                                                                                                                                                                                                                                                                 |
| ---------- | ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-04-17 | ✅ A1 — Xóa dream archive trùng              | 40 file xóa, giữ `2026-04-17_13-51_dream.md`                                                                                                                                                                                                                                             |
| 2026-04-17 | ✅ A2 — Fix `$TIMESTAMP_dream` bug           | [auto-dream.sh:17](.claude/hooks/auto-dream.sh) + thêm idempotency guard (dòng 89-107)                                                                                                                                                                                                   |
| 2026-04-17 | ✅ A3 — Cooldown 60 phút                     | [session-stop.sh:177-184](.claude/hooks/session-stop.sh)                                                                                                                                                                                                                                 |
| 2026-04-17 | ✅ A4 — Bắt buộc `jq` trong 4 hooks          | [bash-guard.sh](.claude/hooks/bash-guard.sh), [validate-commit.sh](.claude/hooks/validate-commit.sh), [validate-push.sh](.claude/hooks/validate-push.sh), [prompt-context.sh](.claude/hooks/prompt-context.sh) — exit 1 nếu thiếu jq (exit 0 cho prompt-context để không block workflow) |
| 2026-04-17 | ✅ A5 — Fix deny-list `.env*` bypass (C2+L1) | [settings.json](.claude/settings.json) — thêm explicit entries: `cat .env`, `cat .env.*`, `cat *.env`, `cat *.env.*`, `Read(**/.env)`, `Read(**/.env.*)`, `rm -rf ./`, `rm -rf .`                                                                                                        |
| 2026-04-17 | ✅ A6 — ADR Unified Failure State Machine    | [ADR-004](docs/internal/adr/ADR-004-unified-failure-state-machine.md) — gộp Rule 6/14/Diminishing Returns; initial `circuit-state.json` created; 3 hooks cần implement (Phase 2)                                                                                                         |
| 2026-04-17 | ✅ A7 — Skills bloat (§1.5)                  | Xóa `nodejs-backend-patterns/`; clarify boundary `frontend-patterns` ↔ `senior-frontend`; viết [`skills-precedence.md`](.claude/docs/skills-precedence.md); update `backend-developer.md`, `DANH_SACH_LENH.md`, `CLAUDE.md`. **117 → 116 skills.**                                       |
| 2026-04-17 | ✅ A8 — Trim `MEMORY.md` <40 lines           | 46 lines → 36 lines: Tier 2.5 list chuyển sang [`.claude/memory/structure.md`](.claude/memory/structure.md). Root cause dream loop (>40 trigger) đã giải quyết.                                                                                                                          |
| 2026-04-17 | ✅ A9 — Rewrite `fastapi-pro/SKILL.md`       | 197 dòng boilerplate → ~295 dòng production code: Pydantic V2 Settings, SQLAlchemy 2.0 async session, JWT OAuth2PasswordBearer, pytest-asyncio, Gunicorn+Uvicorn, pitfalls table                                                                                                         |
| 2026-04-17 | ✅ A10 — Expand `diagnose/SKILL.md`          | 42 dòng → 170 dòng: trigger conditions, artifact schemas (investigation.json / verification.json / solution.json), escalation matrix, tích hợp Rule 14/15/16, ví dụ flaky-checkout-e2e                                                                                                   |

**Trạng thái §1.1 (Dream loop):** 🟢 **FULLY FIXED** (A1+A2+A3+A8 hoàn tất — MEMORY.md 36 lines < 40 threshold)
**Trạng thái §1.3 (Coordination Rules):** 🟡 ADR-004 written, Phase 2 hooks pending
**Trạng thái §1.4 (Security — C1/C2/L1):** 🟢 **FIXED** (A4 jq required + A5 deny-list expanded)
**Trạng thái §1.5 (Skills bloat):** 🟢 FIXED (A7 + A9 + A10 hoàn tất)

---

## 0. Phạm vi & Quy mô khảo sát

| Hạng mục                        | Số lượng                                          |
| ------------------------------- | ------------------------------------------------- |
| Tổng file trong `.claude/`      | **357**                                           |
| Agent definitions               | **31**                                            |
| Skills                          | **117** (sau khi bỏ stub/template)                |
| Hooks (sh + ps1)                | **16**                                            |
| Coordination rules              | **16**                                            |
| Memory tiers                    | **4** (Tier 1 / 2 / 2.5 / 3 + Tier 4 Supermemory) |
| Dream consolidation files (24h) | **39**                                            |
| Session archive files (24h)     | **39**                                            |

**Verdict tổng thể:** 🟡 **AMBITIOUS BUT BROKEN** — Tham vọng enterprise-grade SDLC orchestration, nhưng *enforcement gap* và *empty-content* đang biến framework thành "documentation theater".

---

## 1. 🔴 5 LỖI CHÍ TỬ (P0 — Phải fix trước)

### 1.1 Vòng lặp Dream vô tận — Memory system đang quay không tải 🟢 **MOSTLY FIXED** (2026-04-17)

**Bằng chứng:**
- ~~39 dream files trong 24h, 3 file gần nhất (`2026-04-17_12-18`, `12-31`, `12-51`) **byte-for-byte giống nhau** (`Files assessed: 7, Stale archived: 0`).~~ ✅ Đã xóa 40 file trùng, chỉ giữ lại `2026-04-17_13-51_dream.md`.
- `MEMORY.md` cố định ở **45 lines**, vượt ngưỡng trigger 40 lines. ⚠️ *Vẫn chưa trim — xem Fix #2.*

**Root cause:**
- ~~[.claude/hooks/auto-dream.sh:17](.claude/hooks/auto-dream.sh) — bug `$TIMESTAMP_dream` (biến rỗng, shell hiểu là `${TIMESTAMP_dream}` không phải `${TIMESTAMP}_dream`).~~ ✅ Đã sửa thành `${TIMESTAMP}_dream.md`.
- ~~[.claude/hooks/session-stop.sh](.claude/hooks/session-stop.sh) — Condition 1 (`MEMORY_LINES > 40`) luôn true vì dream **không write back** vào MEMORY.md → loop deterministic mỗi session.~~ ✅ Đã thêm cooldown 60 phút — Condition 1 vẫn có thể true nhưng không trigger liên tục.
- ~~Condition 2 (`SESSION_COUNT % 5 == 0`) cũng tự kích hoạt liên tục.~~ ✅ Cooldown chặn luôn Condition 2.

**Fix:**
1. ~~Thêm cooldown ≥60 phút giữa các dream (đọc timestamp file gần nhất).~~ ✅ Done — [session-stop.sh:177-184](.claude/hooks/session-stop.sh).
2. ⚠️ **Trim `MEMORY.md` về <40 lines (move Tier 2.5 specialist list ra `structure.md`).** — *Còn open. Root cause thật sự vẫn tồn tại: sau 60 phút cooldown, Condition 1 sẽ lại trigger nếu MEMORY.md vẫn >40 lines.*
3. ~~Idempotency check — skip nếu `Stale=0 && Pruned=0`.~~ ✅ Done — [auto-dream.sh:89-107](.claude/hooks/auto-dream.sh) skip ghi log khi `ARCHIVED=0 && PRUNED=0 && LARGE=0`.

---

### 1.2 Tier 2 memory là EMPTY STUBS — 0 knowledge thực được persist

**Bằng chứng:**
- `feedback_rules.md`, `project_tech_decisions.md`, `user_role.md`, `specialists/*.md`, `consensus/merged-decisions.md` đều chỉ chứa frontmatter + 1 câu placeholder.
- Sau **24h × 39 sessions** vẫn không có **1 quyết định thực** nào được lưu.

**Hệ quả:**
- Toàn bộ "context engineering" 250 dòng trong [.claude/docs/context-management.md](.claude/docs/context-management.md) đang dạy LLM cách chọn 3-trong-0 file rỗng.
- 3-Question Relevance Gate, Decision Matrix, Namespace Isolation Rules — vô nghĩa khi không có data.
- Description fields viết dạng label thay vì query (vi phạm rule riêng của file).

**Fix:**
1. Bật hook `PostToolUse` ghi nhận decision tự động (extract từ tool result).
2. Hoặc bỏ Tier 2/2.5 hoàn toàn cho đến khi có dữ liệu thực.
3. Sửa description fields về dạng search query.

---

### 1.3 14 Coordination Rules là ASPIRATIONAL — không có hook enforcement

**Bằng chứng:**
- **Rule 14 (Circuit Breaker):** Yêu cầu `production/session-state/circuit-state.json` với states OPEN/CLOSED/HALF-OPEN. **Không hook nào tạo/đọc file này.**
- **Rule 15 (Decision Ledger):** Yêu cầu append `production/traces/decision_ledger.jsonl`. **Không có ledger writer.**
- **Rule 16 (A2A Handoff):** Yêu cầu `/handoff` command sinh contract trong `.tasks/handoffs/`. **Command không có handler hook.**

**Mâu thuẫn nội tại:**
- Rule 6 (Layered Recovery, 3 lớp) ↔ Rule 14 (Circuit Breaker, 3 retry với backoff 2s/4s/8s) ↔ Diminishing Returns Detection (3 retry) → **3 counter chồng nhau**, agent có thể retry 9+ lần hoặc dừng quá sớm.

**Fix:**
1. Hợp nhất thành **một Failure State Machine** duy nhất (1 counter, 1 state file, transitions documented).
2. Viết hook enforcement (`PreToolUse` cho Task tool: đọc circuit-state, append ledger).
3. Hoặc downgrade từ "MUST" → "Recommended Practice" và xóa khỏi safety-critical rules.

---

### 1.4 Bash-guard / deny-list bypass dễ dàng (CRITICAL Security)

| ID  | Severity | File:Line                                                                                      | Vấn đề                                                                                                                                                                                               |
| --- | -------- | ---------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| C1  | Critical | [bash-guard.sh:16](.claude/hooks/bash-guard.sh)                                                | Regex fallback parse JSON khi thiếu `jq` → command chứa `"` hoặc escape sequence bypass mọi `block_if_match`. Cùng pattern ở `validate-commit.sh:14`, `validate-push.sh:14`, `prompt-context.sh:16`. |
| C2  | Critical | [settings.json:50](.claude/settings.json)                                                      | `Bash(cat *.env*)` **không** chặn `cat .env.production` (glob literal mismatch trong Claude Code permission engine).                                                                                 |
| H1  | High     | [log-writes.sh:47](.claude/hooks/log-writes.sh), [log-agent.sh:36](.claude/hooks/log-agent.sh) | Race condition — nhiều subagent ghi append vào cùng JSONL không có `flock` → corrupt entries.                                                                                                        |
| H2  | High     | [prompt-context.sh:64](.claude/hooks/prompt-context.sh)                                        | Prompt injection nội bộ — memory files inject thẳng vào additionalContext, escape chỉ xử lý `\` và `"`, không sanitize markdown/instruction patterns.                                                |
| H3  | High     | [fork-join.sh:125](.claude/hooks/fork-join.sh)                                                 | Branch name chứa `;` hoặc `$()` → command injection trong commit message string.                                                                                                                     |
| M2  | Medium   | validate-commit.sh, validate-push.sh                                                           | **Fail-open** khi timeout (15s không đủ với gitnexus + ruff lớn).                                                                                                                                    |
| M3  | Medium   | settings.json                                                                                  | Cross-platform: chỉ chạy `bash ...`. Windows native (không Git Bash/WSL) **mất TOÀN BỘ guards** không cảnh báo.                                                                                      |
| M4  | Medium   | [session-stop.sh:66](.claude/hooks/session-stop.sh)                                            | Log full commit messages vào file không gitignored mặc định.                                                                                                                                         |
| M5  | Medium   | validate-push.sh:65                                                                            | Secret scan chỉ kiểm tra `git diff --cached`, không quét history → secret committed trước đó lọt qua.                                                                                                |
| L1  | Low      | [bash-guard.sh:47](.claude/hooks/bash-guard.sh)                                                | Pattern chỉ block `rm -rf /` (absolute) và `rm -rf *`. Không chặn `rm -rf ./` hoặc `rm -rf .`.                                                                                                       |

**Fix ưu tiên:**
1. Bắt buộc `jq` (exit 1 nếu thiếu, không fallback regex).
2. Thêm explicit deny entries: `Bash(cat .env*)`, `Bash(cat *.env)`, `Bash(rm -rf .*)`.
3. `flock -x` cho mọi log write.
4. PowerShell counterpart cho 5 hook critical.

---

### 1.5 Skills bloat + chồng chéo — không discovery, không gating 🟢 **FIXED** (2026-04-17)

**Trùng lặp rõ rệt:**

| Domain                  | Skills trùng                                                                                               | Khuyến nghị                        | Status                                                                                                                                               |
| ----------------------- | ---------------------------------------------------------------------------------------------------------- | ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| Backend                 | ~~`backend-patterns` ≡ `nodejs-backend-patterns` (cùng paths, cùng framework)~~                            | ~~Gộp thành 1~~                    | ✅ **DONE** — xóa `nodejs-backend-patterns/` (stub 45 dòng), giữ `backend-patterns` (162 dòng content thật)                                           |
| Frontend                | ~~`frontend-patterns` ≡ `senior-frontend`~~ Thực tế: scope khác nhau (React generic vs Next.js App Router) | Clarify boundary trong description | ✅ **DONE** — cả 2 description đã loại trừ scope nhau, thêm "Use X instead"                                                                           |
| Backend (orchestrator)  | `backend-architect`, `team-backend`, `backend-patterns`                                                    | Định nghĩa precedence rõ           | ✅ **DONE** — xem [`.claude/docs/skills-precedence.md`](.claude/docs/skills-precedence.md)                                                            |
| Frontend (orchestrator) | `frontend-design`, `team-frontend`, `senior-frontend`, `frontend-patterns`, `frontend-ui-dark-ts`          | Hợp nhất 3 trong 5                 | ⚠️ **PARTIAL** — mới clarify 2/5 (frontend-patterns + senior-frontend). `frontend-design`, `team-frontend`, `frontend-ui-dark-ts` còn cần audit riêng |

**Placeholder/rỗng:**
- ~~⚠️ [fastapi-pro/SKILL.md](.claude/skills/fastapi-pro/SKILL.md) — 197 dòng: header + phần đầu là boilerplate generic, phần giữa có content FastAPI thật. **Flag for content rewrite** — chưa delete vì còn dùng được.~~ ✅ **A9 DONE** — rewrite xong ~295 dòng production patterns (Pydantic V2 Settings, SQLAlchemy 2.0 async, JWT OAuth2PasswordBearer, pytest-asyncio, Gunicorn+Uvicorn).
- ~~⚠️ `diagnose/SKILL.md` — 42 dòng, sơ sài; references `investigator/verifier/solver` agents. Cần expand.~~ ✅ **A10 DONE** — expand thành 170 dòng với artifact schemas (investigation/verification/solution JSON), escalation matrix, tích hợp Rule 14/15/16, ví dụ flaky-checkout-e2e.
- ⚠️ `templates/` — chỉ chứa `SKILL.md.tmpl`, không phải skill thực. Nên move ra `.claude/docs/templates/`. *(Còn open — nhưng rủi ro thấp, không gấp.)*

**Conflict trigger:**
- ~~Implicit commands `/plan /spec /tdd /diagnose /vertical-slice /ui-spec` trong CLAUDE.md trùng tên với skills cùng tên — **không có precedence rule**.~~ ✅ **DONE** — đã viết [`.claude/docs/skills-precedence.md`](.claude/docs/skills-precedence.md) với rule "Commands CHỨA Skills, không thay thế" + reference trong CLAUDE.md.
- ~~`startup-business/` có 10 sub-skill lồng nhau, **phá convention flat** của 116 skill còn lại.~~ ℹ️ **NON-ISSUE** — verified: các skill nested dùng `name:` frontmatter flat (`mvp`, `pricing`...), Claude Code invoke qua frontmatter name, không qua path. Directory nesting chỉ là organizational grouping (Minimalist Entrepreneur framework). Không cần flatten.

**Fix:**
1. ~~Cắt ngay ~15 skills trùng/rỗng.~~ ✅ Xóa 1 skill + rewrite 2 skill (`fastapi-pro` A9, `diagnose` A10). Còn lại `templates/` cần move (rủi ro thấp).
2. ~~Định nghĩa: **"commands = workflow gates (stage), skills = domain expertise (content)"**.~~ ✅ **DONE** — written in [`.claude/docs/skills-precedence.md`](.claude/docs/skills-precedence.md).
3. ⬜ Audit skills theo telemetry usage — cần hook `log-agent.sh` log skill invocations vào `skill-usage.jsonl` (future work).

**Tổng skill count:** Trước: 117 → Sau: **116** (xóa 1 duplicate).

**Tác động:**
- [`.claude/agents/backend-developer.md:7`](.claude/agents/backend-developer.md) — loại `nodejs-backend-patterns`, thêm `backend-patterns`.
- [`docs/reference/DANH_SACH_LENH.md:83`](docs/reference/DANH_SACH_LENH.md) — xóa entry `/nodejs-backend-patterns`.
- [`CLAUDE.md`](CLAUDE.md) — thêm reference đến skills-precedence.md.

---

## 2. 🟡 P1 — Vấn đề kiến trúc dài hạn

| #   | Vấn đề                                                                                                                                                      | File ảnh hưởng                                                                                | Khuyến nghị                                                                               |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| 6   | Chồng chéo CTO ↔ Technical Director ↔ Lead Programmer ↔ Fullstack-Developer. Ranh giới "system architecture" vs "code-level architecture" không định lượng. | [.claude/agents/cto.md](.claude/agents/cto.md), `technical-director.md`, `lead-programmer.md` | Decision-rights RACI matrix; merge `qa-lead`+`qa-tester` thành 1 agent với mode parameter |
| 7   | Memory 4-tier + 3-question gate gây cognitive overload. File dạy "no stuffing" đang stuff 250 dòng.                                                         | [.claude/docs/context-management.md](.claude/docs/context-management.md)                      | Gộp Tier 2+2.5; chuyển relevance gate thành deterministic hook `pre-load-memory.sh`       |
| 8   | Implicit workflow commands chồng skills. Không rõ khi nào invoke command vs skill.                                                                          | CLAUDE.md, `.claude/skills/`                                                                  | Precedence: command *trigger* skill, không thay thế                                       |
| 9   | `validate-push.sh` chỉ scan staged diff. Secret committed trước đó lọt qua.                                                                                 | [.claude/hooks/validate-push.sh:65](.claude/hooks/validate-push.sh)                           | Dùng `gitleaks` quét toàn branch diff                                                     |
| 10  | `session-stop.sh` log full commit messages vào file không gitignored.                                                                                       | [.claude/hooks/session-stop.sh:66](.claude/hooks/session-stop.sh)                             | Add to `.gitignore`, mask PII patterns                                                    |
| 11  | Description fields trong Tier 2 files viết dạng label, không phải query (vi phạm rule riêng)                                                                | `.claude/memory/*.md`                                                                         | Refactor về dạng search query                                                             |
| 12  | Tier 2.5 namespace isolation rules có 5 sub-rules nhưng không có hook enforcement                                                                           | `.claude/docs/context-management.md`                                                          | Implement detection trong `prompt-context.sh`                                             |

---

## 3. 📊 Đánh giá theo trục

| Trục                              | Điểm       | Ghi chú                                                       |
| --------------------------------- | ---------- | ------------------------------------------------------------- |
| Vision & Documentation            | **8/10**   | Rất tham vọng, viết tốt, có ADR template, README/PRD song ngữ |
| Architecture coherence            | **4/10**   | Tier/role chồng chéo, rule mâu thuẫn                          |
| Enforcement (hook → rule binding) | **3/10**   | Rule 14/15/16 hoàn toàn aspirational                          |
| Security posture                  | **5/10**   | Có deny-list nhưng bypass dễ; cross-platform yếu              |
| Memory effectiveness              | **2/10**   | Loop + empty stubs                                            |
| Skill ecosystem health            | **5/10**   | Bloat + duplicates, thiếu telemetry                           |
| Cross-platform                    | **3/10**   | Windows native = no guards                                    |
| **Tổng trung bình**               | **4.3/10** | Tiềm năng cao nếu fix P0                                      |

---

## 4. 🎯 Roadmap khuyến nghị (4 tuần)

### Week 1 — STOP THE BLEEDING (P0 critical)
1. Fix dream loop:
   - ~~Cooldown ≥60 phút trong [session-stop.sh](.claude/hooks/session-stop.sh)~~ ✅ Done
   - Trim `MEMORY.md` xuống <40 lines (move Tier 2.5 list ra `structure.md`) ⬜
   - ~~Idempotency check trong [auto-dream.sh](.claude/hooks/auto-dream.sh)~~ ✅ Done
2. Fix C1/C2 security:
   - Bắt buộc `jq` trong tất cả hook parse JSON ⬜
   - Sửa deny-list patterns trong `settings.json` ⬜
   - `flock` cho log writes ⬜
3. ~~Xóa 39 dream archive trùng → giải phóng 39 file rác~~ ✅ Done (40 file xóa)
4. Fix M3: PowerShell counterpart cho `bash-guard`, `validate-commit`, `validate-push`, `session-start`, `session-stop` ⬜

### Week 2 — UNIFY (P1 architecture)
5. ✅ ADR: **Unified Failure State Machine** (gộp Rule 6/14/Diminishing Returns)
6. ✅ RACI matrix cho leadership tier (CTO / TD / Lead-Programmer / Fullstack)
7. ✅ Cắt 15 skill trùng/placeholder (`nodejs-backend-patterns`, `senior-frontend`, `fastapi-pro` rewrite, flatten `startup-business/*`)
8. ✅ Định nghĩa precedence: **commands ⊂ workflow gates**, **skills ⊂ domain expertise**

### Week 3 — ENFORCE (turn aspiration into reality)
9. ✅ Quyết định binary: implement Rule 14/15/16 với hook enforcement, **HOẶC** xóa khỏi MUST rules
10. ✅ Hook `PostToolUse` extract decision → append `decision_ledger.jsonl`
11. ✅ Hook `PreToolUse(Task)` đọc `circuit-state.json` để bypass agent OPEN
12. ✅ Bật telemetry skill usage để audit bloat tiếp

### Week 4 — SHRINK (reduce cognitive load)
13. ✅ Cô đặc `context-management.md` xuống ≤100 dòng (chi tiết → `context-management-guide.md`)
14. ✅ Refactor description fields tier 2 về dạng search query
15. ✅ Implement `pre-load-memory.sh` deterministic relevance gate
16. ✅ Release SDD v1.33.0 với CHANGELOG đầy đủ + migration guide

---

## 5. 💡 Insight cuối — Triết lý cần thay đổi

> **Một rule được hook enforce đáng giá hơn 10 rule chỉ viết ra.**
> **Một dòng memory thật được persist đáng giá hơn 100 dòng schema rỗng.**
> **Một skill chất lượng đáng giá hơn 10 skill placeholder.**

SDD đang đi theo hướng **"framework càng phức tạp càng tốt"**. Hướng đúng phải là:
- ⬇️ Giảm **30% volume luật**
- ⬆️ Tăng **3× hook enforcement**
- ⬆️ Persist **100× knowledge thực**

Hiện tại framework đang **tự kiểm tra chính nó** (dream → archive → dream) thay vì kiểm tra code của user. Đây là **anti-pattern điển hình** của over-engineered automation: tool tốn nhiều resource cho self-maintenance hơn là làm việc thực.

---

## 6. 📋 Action Items ngay lập tức (cần user approval)

| #       | Action                                                                           | Risk           | Reversible?          | Status                                                                                                                       |
| ------- | -------------------------------------------------------------------------------- | -------------- | -------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| ~~A1~~  | ~~`git rm` 38 dream archive trùng (giữ 1 mới nhất)~~                             | ~~Low~~        | ~~Yes (git revert)~~ | ✅ **DONE** (40 file xóa, 13-51 kept)                                                                                         |
| ~~A2~~  | ~~Patch [auto-dream.sh:17](.claude/hooks/auto-dream.sh) bug `$TIMESTAMP_dream`~~ | ~~Low~~        | ~~Yes~~              | ✅ **DONE** (+ idempotency guard)                                                                                             |
| ~~A3~~  | ~~Patch [session-stop.sh](.claude/hooks/session-stop.sh) thêm cooldown 60min~~   | ~~Low~~        | ~~Yes~~              | ✅ **DONE** (dòng 177-184)                                                                                                    |
| ~~A4~~  | ~~Patch C1: bắt buộc `jq` trong 4 hook~~                                         | ~~Medium~~     | ~~Yes~~              | ✅ **DONE** (2026-04-17) — exit 1 cho bash-guard/validate-commit/validate-push; exit 0 warn cho prompt-context                |
| ~~A5~~  | ~~Patch C2+L1: explicit deny entries `.env*` + `rm -rf ./`~~                     | ~~Low~~        | ~~Yes~~              | ✅ **DONE** (2026-04-17) — settings.json expanded: cat .env, cat .env.*, Read(**/.env), rm -rf ./, rm -rf .                   |
| ~~A6~~  | ~~Viết ADR `unified-failure-state-machine.md`~~                                  | ~~None (doc)~~ | ~~Yes~~              | ✅ **DONE** (2026-04-17) — [ADR-004](docs/internal/adr/ADR-004-unified-failure-state-machine.md) + circuit-state.json created |
| ~~A7~~  | ~~Xóa skill `nodejs-backend-patterns/`, `senior-frontend/`~~                     | ~~Medium~~     | ~~Yes (git revert)~~ | ✅ **DONE** — xóa `nodejs-backend-patterns`; giữ `senior-frontend` (scope khác frontend-patterns, clarified)                  |
| ~~A8~~  | ~~**NEW:** Trim `MEMORY.md` <40 lines (move Tier 2.5 → `structure.md`)~~         | ~~Low~~        | ~~Yes~~              | ✅ **DONE** (2026-04-17) — 46 lines → 36 lines; [structure.md](.claude/memory/structure.md) created                           |
| ~~A9~~  | ~~**NEW:** Rewrite `fastapi-pro/SKILL.md` body (remove boilerplate)~~            | ~~Low~~        | ~~Yes~~              | ✅ **Done** (2026-04-17)                                                                                                      |
| ~~A10~~ | ~~**NEW:** Expand `diagnose/SKILL.md` (42 lines → proper workflow)~~             | ~~Low~~        | ~~Yes~~              | ✅ **Done** (2026-04-17)                                                                                                      |

**Tất cả Action Items đã hoàn thành.** Remaining work: Phase 2 ADR-004 hooks (circuit-guard.sh, decision-ledger.sh) — xem ADR.

---

## 7. 📎 Appendix — Files nổi bật cần review

**Cấu hình & Doc:**
- [CLAUDE.md](CLAUDE.md) — master config
- [.claude/settings.json](.claude/settings.json) — hook + permission
- [.claude/docs/coordination-rules.md](.claude/docs/coordination-rules.md) — 16 rules
- [.claude/docs/context-management.md](.claude/docs/context-management.md) — memory protocol

**Hooks cần fix gấp:**
- ~~[.claude/hooks/auto-dream.sh](.claude/hooks/auto-dream.sh) — bug dòng 17~~ ✅ Fixed 2026-04-17 (A2 + idempotency)
- ~~[.claude/hooks/session-stop.sh](.claude/hooks/session-stop.sh) — trigger logic~~ ✅ Fixed 2026-04-17 (A3 cooldown)
- [.claude/hooks/bash-guard.sh](.claude/hooks/bash-guard.sh) — regex fallback (A4)
- [.claude/hooks/prompt-context.sh](.claude/hooks/prompt-context.sh) — injection vector
- [.claude/hooks/fork-join.sh](.claude/hooks/fork-join.sh) — command injection

**Memory cần data thực:**
- [.claude/memory/MEMORY.md](.claude/memory/MEMORY.md) — đang ở 45 lines
- [.claude/memory/feedback_rules.md](.claude/memory/feedback_rules.md) — empty stub
- [.claude/memory/project_tech_decisions.md](.claude/memory/project_tech_decisions.md) — empty stub
- [.claude/memory/consensus/merged-decisions.md](.claude/memory/consensus/merged-decisions.md) — placeholder

**Skills cần cắt/rewrite:**
- ~~[.claude/skills/fastapi-pro/SKILL.md](.claude/skills/fastapi-pro/SKILL.md) — 197 dòng boilerplate (A9)~~ ✅ Rewrite hoàn tất
- ~~[.claude/skills/nodejs-backend-patterns/](.claude/skills/nodejs-backend-patterns/) — duplicate `backend-patterns`~~ ✅ **DELETED** 2026-04-17
- ~~[.claude/skills/senior-frontend/](.claude/skills/senior-frontend/) — duplicate `frontend-patterns`~~ ✅ **KEPT** — verified scope khác (Next.js App Router vs React generic), đã clarify boundary trong cả 2 descriptions
- ~~[.claude/skills/startup-business/](.claude/skills/startup-business/) — phá convention flat~~ ℹ️ **NON-ISSUE** — nested structure chỉ organizational, invocation qua frontmatter name đã flat
- ~~[.claude/skills/diagnose/SKILL.md](.claude/skills/diagnose/SKILL.md) — 42 dòng sơ sài (A10)~~ ✅ Expand hoàn tất

---

**End of report.** Phiên bản kế tiếp đề xuất: **SDD v1.33.0 — "The Great Pruning"**.

*Báo cáo này nên được archive trong `docs/internal/audits/` sau khi user review xong.*
