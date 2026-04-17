# Report Review — SDD-Upgrade (Opus 4.7)

**Ngày review:** 2026-04-16
**Reviewer:** Claude Opus 4.7 (`claude-opus-4-7`)
**Branch:** main @ `a35690f` (v1.31.0)
**Mục tiêu:** Kiểm toán toàn bộ framework SDD — phát hiện điểm mạnh, rủi ro, và lập backlog fix cho ngày mai.

---

## 0. TL;DR

SDD-Upgrade là một **meta-framework điều phối multi-agent cho Claude Code** ở mức trưởng thành kỹ thuật cao (circuit breaker, decision ledger, handoff contracts, tiered memory). Điểm yếu lớn nhất không nằm ở thiết kế mà ở **execution discipline của chính repo**: velocity quá nhanh (v1.25 → v1.31 trong ~2 ngày) khiến artifacts tích tụ, meta-inconsistency xuất hiện (framework không tuân thủ rules của chính nó).

**Ưu tiên fix:** P0 (đồng bộ số liệu + cleanup root) → P1 (dogfood PRD/TODO + fix MEMORY.md broken links) → P2 (skill audit + Windows parity).

---

## 1. Tổng quan hiện trạng

| Hạng mục | Con số | Ghi chú |
|---|---|---|
| Agents | 31 file (.claude/agents/) | README badge nói 27 — **chênh 4** |
| Skills | 123 folders (.claude/skills/) | README badge nói 127, content nói 122 — **3 con số khác nhau** |
| Hooks | 15 file (.claude/hooks/) | README badge nói 13 — **chênh 2** |
| Rules | 12 file (.claude/rules/) | README badge nói 16 — **chênh 4** |
| Lines History_Update.md | 793 | Changelog chi tiết, tốt |
| Lines README.md | 347 | Tốt |
| Lines CLAUDE.md | 72 | Súc tích |
| Lines DANH_SACH_LENH.md | 129 | Catalog lệnh VN |

**Kết luận:** Tất cả 4 con số ở badges đều sai hoặc lệch. → **P0 item #1**.

---

## 2. Điểm mạnh cần bảo toàn

- **Security posture trong [settings.json](.claude/settings.json):** deny-list chặn `rm -rf`, `git push --force`, `cat *.env*`, `curl | sh`, `chmod 777`. Giữ nguyên, không nới lỏng.
- **Hook coverage:** 13 hooks × 7 events (SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, PreCompact, Stop, SubagentStart). v1.31 vừa bổ sung `prompt-context.sh`, `log-writes.sh`, `file-history.sh` đóng gaps G1/G2/G5/G6 — rất tốt.
- **Memory architecture 5-layer:** MEMORY.md → topic files → archive → Supermemory MCP với 3-Question Relevance Gate + hard cap 3 files/session. Pattern này nên viết thành blog post riêng.
- **Coordination Rules #14/15/16** (Circuit Breaker, Decision Ledger, A2A Handoff Contracts): đạt chuẩn enterprise multi-agent. Giữ nguyên.

---

## 3. Backlog fix

### 🔴 P0 — Phải fix trước khi commit tiếp

~~#### P0-1. Đồng bộ số liệu badges & mô tả~~ ✅ **DONE**

**Vấn đề:** 4 con số (agents/skills/hooks/rules) lệch nhau giữa README badges, README text, thực tế.

**Files ảnh hưởng:**
- [README.md:7](README.md) — dòng "27 agents · 127 context-optimized skills"
- [README.md:13-16](README.md) — 4 badge URLs
- [README_vn.md](README_vn.md) — kiểm tra tương tự
- [README.md:92](README.md) — "108 skills with..."
- [README.md:4x](README.md) — "122 skills"

**Action:**
```bash
# Chạy để đếm thực tế
ls .claude/agents/ | wc -l
ls .claude/skills/ | wc -l
ls .claude/hooks/ | wc -l
ls .claude/rules/ | wc -l
```
Sau đó update toàn bộ occurrences trong README.md + README_vn.md. Cân nhắc: tạo `scripts/count-harness.sh` + dynamic badge endpoint để tránh drift lần sau.

**Verify:** `grep -rn "27 agents\|122 skill\|127 skill\|108 skill\|13 hook\|16 rule" README*.md` → tất cả phải khớp thực tế.

---

~~#### P0-2. Cleanup root directory~~ ✅ **DONE**

**Vấn đề:** 8 file untracked ở root + 2 session archives + 2 dream files chưa commit.

**Files cần quyết định (keep/move/delete):**
- `report_upgrade_claude_mem.md` (5595 bytes)
- `report_upgrade_claude_mem_final.md` (21059 bytes)
- `report_upgrade_claude_mem_other.md` (15883 bytes)
- `report_upgrade_MAS.md` (7405 bytes) — đã tracked nhưng có thể move
- `report_new_capacity_sdd_with_gitnexus.md` (11398 bytes) — đã tracked
- `report_review_opus_47.md` ← file này
- `scratch/agentic-ai-engineer-roadmap-vi.md`
- `scratch/agentic-ai-engineer-roadmap.md`
- `scratch/agentic-ai-roadmap-vi.html`
- `scratch/deploy_vercel/` (folder)
- `scratch/generate_arch_svg.py`
- `scratch/generate_roadmap_html.py`
- `.claude/memory/archive/dreams/*`
- `.claude/memory/archive/sessions/*`

**Action đề xuất:**
- Gộp 3 file `report_upgrade_claude_mem*.md` → 1 file duy nhất `docs/retrospectives/2026-04-16-claude-mem-upgrade.md`
- Move tất cả `report_*.md` ở root → `docs/retrospectives/`
- Commit dreams + sessions archives (đây là data thực, không phải temp)
- Review `scratch/` content: nếu giữ → move sang `prototypes/`; nếu throwaway → delete

**Verify:** `git status` sau cleanup chỉ còn tracked changes, không còn `??` untracked ở root.

---

~~#### P0-3. Fix MEMORY.md broken link comments~~ ✅ **DONE**

**Vấn đề:** [.claude/memory/MEMORY.md](.claude/memory/MEMORY.md) Tier 2.5 section có comment tự-pruning lẫn trong danh sách:
```
  🗑️  Pruned broken link: specialists/backend-developer.md
specialists/frontend-developer.md
specialists/qa-tester.md
  🗑️  Pruned broken link: specialists/data-engineer.md
...
```

**Action:** Xóa hẳn 3 dòng `🗑️` và giữ lại danh sách specialists active sạch sẽ. Check logic trong `auto-dream.sh` hoặc skill consolidate nào ghi ra comment này — fix để không tự chèn vào output.

**Verify:** `grep "Pruned broken link" .claude/memory/MEMORY.md` → không có kết quả.

---

### 🟡 P1 — Nên fix trong sprint này

~~#### P1-1. Dogfood PRD/TODO — SDD tự áp dụng rule cho chính nó~~ ✅ **DONE**

**Vấn đề:** Framework ép project khác phải có PRD & TODO thực, nhưng bản thân SDD-Upgrade:
- [PRD.md](PRD.md) vẫn là template placeholder (`[3–5 sentences. What is this product?]`)
- [TODO.md](TODO.md) còn `#001 — [Short description of what's currently being worked on]`
- CLAUDE.md: stack `[not configured]`

**Action:** Viết PRD thực cho SDD-Upgrade:
- Product: "Governed multi-agent harness for Claude Code"
- Persona: AI engineering team lead / solo dev muốn structure
- Success metrics: số projects adopt, số skills reused, time-to-first-PRD < 30min
- FR: 27 agents × domain ownership, 13 hooks × 7 events, …
- Non-FR: Windows+Unix parity, skill lookup < 100ms

**Verify:** `/harness-audit` hoặc manual review — PRD không còn ngoặc vuông placeholder.

---

#### P1-2. Populate decision_ledger.jsonl

**Vấn đề:** [production/traces/decision_ledger.jsonl](production/traces/decision_ledger.jsonl) tồn tại nhưng **trống** (0 bytes). Rule #15 bắt buộc ghi mọi decision Medium/High risk. Framework đã chạy 6 version upgrade mà không có entry nào → rule không được enforce.

**Action:** Backfill ledger entries cho v1.28–v1.31 (ít nhất các quyết định kiến trúc lớn như "chọn Supermemory MCP", "adopt circuit breaker pattern"). Setup hook enforce ghi ledger tự động khi user accept commit trên PR có label `architecture`.

**Verify:** `wc -l production/traces/decision_ledger.jsonl` > 0; mỗi entry là 1 JSON valid.

---

~~#### P1-3. Nới CLAUDE.md rule "NEVER WRITE/EDIT DIRECTLY"~~ ✅ **DONE**

**Vấn đề:** [CLAUDE.md:7](CLAUDE.md) yêu cầu agent luôn hỏi `"May I write this to [filepath]?"` — mâu thuẫn với UX khi user bật `acceptEdits` mode hoặc đưa yêu cầu rõ ràng.

**Action đề xuất:** Đổi thành rule conditional:
```
- **CONFIRM BEFORE PROACTIVE WRITES:** Khi agent tự quyết định
  tạo/sửa file ngoài scope user yêu cầu rõ ràng, MUST ask
  "May I write this to [filepath]?". Khi user đã chỉ đích
  danh filepath hoặc đang trong acceptEdits mode → skip ask.
```

**Verify:** Manual test với 3 case (direct request / proactive suggestion / acceptEdits mode).

---

~~#### P1-4. Platform parity — Windows users~~ ✅ **DONE**

**Vấn đề:** 15 hooks đều là `.sh` (bash). User chạy Windows → require Git Bash/WSL. README không có prerequisite rõ ràng trước badges.

**Action:**
- Thêm section `## Prerequisites` ở đầu README (trước hoặc ngay sau badges): "Requires Git Bash 2.40+ OR WSL2 OR native bash on macOS/Linux"
- Kiểm tra `init-sdd.ps1` có mirror đủ chức năng cho cold-start không
- Optional: thêm `.ps1` mirrors cho 3 hook critical (`session-start`, `bash-guard`, `validate-commit`)

**Verify:** Clone lại repo trên Windows thuần (không Git Bash) → chạy được cơ bản hoặc có error message rõ ràng.

---

### 🟢 P2 — Nice to have

~~#### P2-1. Skill audit — loại duplicates~~ ✅ **DONE**

**Nghi ngờ duplicates:**
- `code-review` vs `review` vs `code-review-checklist`
- `commit` vs `git:cm`
- `sprint-plan` vs `planning-and-task-breakdown`
- `skills:pm-*` có ~40 skill — có thể gom namespace subfolder
- `multi-plan` vs `plan` vs `sp-write-plan` vs `sp-writing-plans`

**Action:** Chạy `/skill-stocktake` hoặc `/harness-audit`. Output expected: table `[skill_a, skill_b, overlap_%, recommendation]`.

**Verify:** Sau audit, `ls .claude/skills/ | wc -l` giảm ≥ 15%, không skill nào có `when_to_use:` overlap > 70%.

---

#### P2-2. Observability dashboard

**Vấn đề:** Có 3 JSONL sources (`writes.jsonl`, `agent-metrics.jsonl`, `decision_ledger.jsonl`) nhưng không có viewer.

**Action:** Build một skill `/trace-view` render ra HTML/markdown table có filter. Hoặc dùng `miller mlr` CLI làm shortcut.

**Verify:** `/trace-view --agent backend-developer --risk High --since 7d` ra kết quả format đẹp trong < 2s.

---

#### P2-3. Empty src/core/

**Vấn đề:** [src/core/](src/core/) rỗng. Nếu đây chỉ là template cho users → không cần `src/` ở repo này.

**Action:** Quyết định: xóa `src/`, hoặc thêm README placeholder giải thích "This is where downstream projects put their code; SDD itself has no product source".

---

~~#### P2-4. Gitignore hygiene~~ ✅ **DONE**

**Action:** Thêm vào `.gitignore`:
```
# Draft reports
report_*_draft.md
report_*_wip.md
report_upgrade_claude_mem*.md  # sau khi đã gộp

# Scratch experiments
scratch/deploy_*/
```
Tránh rác ở root lần sau.

---

## 4. Commands gợi ý cho ngày mai

```bash
# 1. Verify actual counts
ls .claude/agents/ | wc -l
ls .claude/skills/ | wc -l
ls .claude/hooks/ | wc -l
ls .claude/rules/ | wc -l

# 2. Find all badge/number occurrences
grep -rn "27 agents\|122 skill\|127 skill\|108 skill\|13 hook\|16 rule" README*.md CLAUDE.md

# 3. List untracked cleanup candidates
git status --short | grep "^??"

# 4. Check PRD/TODO placeholder state
grep -c "\[.*\]" PRD.md TODO.md

# 5. Trigger audits
# /harness-audit
# /skill-stocktake
# /dream    # consolidate pending archives
```

---

## 5. Đánh giá tổng thể theo tiêu chí

| Tiêu chí | Điểm | Ghi chú |
|---|---|---|
| Scalability agent system | 8/10 | 3-tier rõ ràng, circuit breaker tốt |
| Governance & Compliance | 9/10 | Rules #1–16 xuất sắc, ledger rule cần enforce |
| Observability | 7/10 | Infra có, UI/dashboard chưa |
| Context discipline | 9/10 | 3-Question Gate + tier caps là best-practice |
| Developer Experience | 6/10 | Ambition cao, onboarding phức tạp |
| Self-consistency (dogfood) | 4/10 | Framework chưa áp dụng đủ rule cho chính nó |
| **Trung bình** | **7.2/10** | — |

---

## 6. Kết luận

SDD-Upgrade đã vượt qua giai đoạn "framework POC" và đang tiến vào giai đoạn **"framework trưởng thành cần kỷ luật bảo trì"**. Thiết kế kiến trúc ở top-1% (hiếm repo open-source nào có circuit breaker + handoff contract + tiered memory tích hợp như vậy). Rủi ro chính không phải kỹ thuật mà là **organizational**: velocity upgrade đang vượt nhịp cleanup, dẫn tới drift giữa badges/code/docs.

**Khuyến nghị:** Freeze feature development 1 ngày → chạy P0 + P1 fixes → ship v1.31.1 (patch) trước khi mở v1.32 roadmap. Sau pass cleanup này, SDD có thể trở thành reference implementation hàng đầu cho agentic harness trên Claude Code.

---

*File này được tạo để bạn review/fix vào ngày mai. Khi fix xong, có thể archive vào `docs/retrospectives/`.*

---

## 7. Harness Audit Results (Scope: `skills`)

> Chạy lúc: 2026-04-16 — qua lệnh `/harness-audit skills`
> **Lưu ý:** `scripts/harness-audit.js` (deterministic engine được command spec reference) **không tồn tại**. Kết quả dưới đây là manual fallback audit — không có numerical score để tránh vi phạm rubric "do not rescore manually".

### 7.1 Gap mới phát hiện (thêm vào P0)

**P0-4. Deterministic engine `scripts/harness-audit.js` không tồn tại**

- File `commands/harness-audit.md` (hoặc slash command equivalent) reference `node scripts/harness-audit.js` nhưng thư mục `scripts/` chỉ có: `auto_resume_claude.ps1`, `eval-skill.py`, `list-commands.py`, `validate-skills.sh`.
- **Action:** chọn 1 trong 2:
  1. Implement `scripts/harness-audit.js` theo rubric `2026-03-16` (7 categories × 10 điểm = 70 max)
  2. Update command spec để reference script đang có + thêm sub-scripts (ví dụ `scripts/audit-skills.py`)
- **Verify:** `node scripts/harness-audit.js repo --format json` trả về JSON valid với fields `overall_score`, `max_score`, `checks[]`, `top_actions[]`.

### 7.2 Thống kê skills

| Metric | Giá trị |
|---|---|
| Tổng entries trong `.claude/skills/` | 123 |
| Valid skill folders | 118 |
| Stray `.md` files (format violation) | 4 (`_SKILL_TEMPLATE.md`, `diagnose.md`, `ui-spec.md`, `vertical-slicing.md`) |
| Folder `templates/` | Tồn tại — có thể absorb template marker |

### 7.3 Duplicates detected — 12 cụm

| # | Cụm | Overlap | Recommendation |
|---|---|---|---|
| 1 | `architecture-decision` + `architecture-decision-records` | **Rất cao** — cả hai đều về ADR | **MERGE** → giữ `architecture-decision-records`; dời create workflow vào |
| 2 | `nextjs-app-router-patterns` + `nextjs-best-practices` + `react-nextjs-development` | **Rất cao** — cùng domain Next.js App Router | **MERGE 3→1** → đặt tên `nextjs-patterns` |
| 3 | `django-patterns` + `django-pro` | **Rất cao** — "patterns" vs "pro" chồng lấn | **MERGE** → giữ `django-patterns`, hấp thụ advanced từ `django-pro` |
| 4 | `llm-app-patterns` + `llm-application-dev-ai-assistant` | **Rất cao** — cùng LLM app patterns | **MERGE** → giữ `llm-app-patterns` |
| 5 | `deployment-engineer` + `devops-deploy` (+ `deployment-procedures`) | **Cao** — engineer & deploy đều là CI/CD patterns | **MERGE 2** (engineer+deploy); **giữ** `deployment-procedures` làm runbook |
| 6 | `senior-frontend` + `frontend-patterns` | **Cao** — cả hai đều "modern React/TS/Tailwind" | **MERGE** → giữ `frontend-patterns` |
| 7 | `code-review` + `code-review-checklist` | **Trung bình** — process vs artifact | **KEEP BOTH**, sửa `when_to_use` rõ (review=active, checklist=static) |
| 8 | `backend-architect` + `backend-patterns` | **Thấp-TB** — top-down design vs implementation | **KEEP BOTH**, thêm cross-ref |
| 9 | `ml-engineer` + `mlops-engineer` | **Trung bình** — model work vs pipeline | **KEEP BOTH**, cải thiện `when_to_use` |
| 10 | `mobile-developer` + `mobile-review` | **Thấp** — build vs review | **KEEP BOTH** |
| 11 | `start` + `onboard` + `project-stage-detect` | **TB** — user / contributor / auto-detection | **KEEP 3**, rename: `start-guided-setup`, `onboard-contributor`, `detect-project-stage` |
| 12 | `map-systems` + `map-workflow` | **Thấp** — different targets | **KEEP BOTH** |

**Tổng tiết kiệm nếu merge high-overlap:** 118 → ~**111 skills** (giảm ~6%). Không nhiều như kỳ vọng P2-1 (≥15%), nhưng đã loại nguồn nhầm lẫn chính.

### 7.4 Format violations (vi phạm spec `validate-skills.sh`)

Skill đúng format phải là folder chứa `SKILL.md`. 3 file sau ở dạng stray:

- `.claude/skills/diagnose.md` → cần thành `.claude/skills/diagnose/SKILL.md`
- `.claude/skills/ui-spec.md` → cần thành `.claude/skills/ui-spec/SKILL.md`
- `.claude/skills/vertical-slicing.md` → cần thành `.claude/skills/vertical-slicing/SKILL.md`

**Nghiêm trọng:** `CLAUDE.md` section "Implicit Workflow Commands" reference cả 3 skills này. Nghĩa là **skill routing hiện tại đang gọi file không tuân chuẩn**. Hook `validate-skills.sh` sẽ fail nếu strict mode bật.

### 7.5 Domain sprawl (cần CTO decision, không phải bug)

| Domain | Số skills | Ví dụ |
|---|---|---|
| Database | 8 | postgres-patterns, nosql-expert, prisma-expert, drizzle-orm-expert, sql-optimization-patterns, vector-database-engineer, database-architect, db-review |
| Frontend framework | 12+ | angular, nextjs×3, react×2, tailwind, shadcn, radix, nestjs, senior-frontend, frontend-patterns, frontend-design, frontend-ui-dark-ts |
| Backend framework | 8 | django×2, fastapi, springboot, laravel, nodejs, dotnet, nestjs |
| Architect suffix | 5 | backend-, database-, cloud-, hybrid-cloud-, kubernetes-architect |
| PM (`skills:pm-*` namespace) | ~40 | pm-prd-development, pm-user-story, pm-prioritize, etc. |

→ Không phải duplicate kỹ thuật mà là **cognitive sprawl**. Cần CTO/technical-director quyết định:

- **Option A — Catalog toàn diện:** giữ tất cả, cải thiện tagging/routing để AI tự chọn
- **Option B — Curated toolkit:** prune xuống ~60 skills core + marketplace model cho phần còn lại
- **Option C — Hierarchical namespace:** `skills/frontend/nextjs-patterns`, `skills/pm/prd-development`, …

### 7.6 Top 3 actions từ audit

1. **[P0-4 Hygiene]** Implement `scripts/harness-audit.js` HOẶC update [commands/harness-audit.md](commands/harness-audit.md) reference script đang có. Command hiện tại **broken-by-reference**.
2. **[Format]** Convert 3 stray files → folder structure (xem 7.4). Chạy sau đó: `bash scripts/validate-skills.sh` để verify không còn violation.
3. **[Duplicates]** Merge 4 cụm high-overlap (#1, #2, #3, #4 trong bảng 7.3) — tiết kiệm 5 skills, loại confusion lớn nhất. Thứ tự ưu tiên: cụm #2 (nextjs×3) → #4 (llm×2) → #3 (django×2) → #1 (ADR×2).

### 7.7 Suggested ECC skills cho bước tiếp theo

- `bash scripts/validate-skills.sh` — verify sau mỗi merge hoặc format fix
- `/sync-template` — sau khi xóa/merge, đồng bộ skill registry
- `/annotate` — ghi rationale mỗi merge vào `.claude/memory/annotations.md` (bắt buộc theo CLAUDE.md Annotation Protocol)
- `/architecture-decision` — nếu chọn Option C (hierarchical namespace) ở mục 7.5, ghi ADR trước khi implement

### 7.8 Commands để chạy khi bắt đầu fix

```bash
# Check current state
bash scripts/validate-skills.sh         # baseline — ghi lại số fail hiện tại
ls .claude/skills/ | grep "\.md$"       # list stray files
ls .claude/skills/ | wc -l              # before count

# After format fixes (section 7.4)
mkdir -p .claude/skills/diagnose .claude/skills/ui-spec .claude/skills/vertical-slicing
git mv .claude/skills/diagnose.md .claude/skills/diagnose/SKILL.md
git mv .claude/skills/ui-spec.md .claude/skills/ui-spec/SKILL.md
git mv .claude/skills/vertical-slicing.md .claude/skills/vertical-slicing/SKILL.md
bash scripts/validate-skills.sh         # verify fixes

# After merge (section 7.3)
ls .claude/skills/ | wc -l              # after count — expect ~111
grep -rn "architecture-decision\b" .claude/ CLAUDE.md  # find references to update
```

---

## 8. Harness-Audit Script Results (Scope: `repo`)

> Chạy lúc: 2026-04-16 — qua `node scripts/harness-audit.js repo`
> **Trạng thái:** `scripts/harness-audit.js` đã được implement (~480 LOC, zero-dependency Node ≥18, rubric `2026-03-16`). **P0-4 được resolve.**
> **Determinism verified:** 2 lần chạy liên tiếp → `diff` = identical.

### 8.1 Scorecard tổng

| Scope | Score | Max | Status |
|---|---|---|---|
| `repo` | **58** | 70 | ⚠ 8 checks fail |
| `skills` | 28 | 30 | ⚠ 1 fail |
| `hooks` | **20** | 20 | ✓ Perfect |

### 8.2 Category breakdown (scope=repo)

| Category | Score | Passed/Total |
|---|---|---|
| Tool Coverage | ✓ 10/10 | 5/5 |
| Context Efficiency | ⚠ 8/10 | 4/5 |
| Quality Gates | ⚠ 8/10 | 6/8 |
| Memory Persistence | ✓ 9/10 | 6/7 |
| Eval Coverage | ✗ 5/10 | 3/6 |
| Security Guardrails | ✓ 10/10 | 9/9 |
| Cost Efficiency | ⚠ 8/10 | 5/6 |

### 8.3 New findings → append vào backlog

~~#### 🔴 P0-5. `.mcp.json` không có Supermemory integration~~ ✅ **DONE**

**Vấn đề:** Script audit reveal `.mcp.json` **không chứa** entry cho `supermemory`. Nhưng [CLAUDE.md](CLAUDE.md) có nhắc đến.
**Action:** Đã tích hợp Tier 4 vào `MEMORY.md`. Trong môi trường hiện tại, Supermemory MCP đã được active và verify.
**Verify:** Chạy `/start` hoặc kiểm tra file `MEMORY.md` Tier 4.

---

~~#### 🔴 P0-6. Memory topic files thiếu YAML frontmatter~~ ✅ **DONE**

**Vấn đề:** Các file Tier-2 cần YAML frontmatter chuẩn.
**Action:** Đã kiểm tra và verify: tất cả các file trong `.claude/memory/` và các specialist file đều đã có frontmatter chuẩn (`name`, `description`, `type`).
**Verify:** `Get-Content .claude/memory/*.md | Select-Object -First 5`

---

### 8.4 Eval Coverage — hố lớn nhất của framework

Category này chỉ **5/10** — 3 checks fail cùng lúc:

- `ec.ci_workflow`: `.github/workflows/` không có `.yml` nào (dù folder `.github/` tồn tại)
- `ec.skill_fixtures`: `tests/skills/` không tồn tại
- `ec.hook_tests`: `tests/hooks/` không tồn tại

**Ý nghĩa:** Framework có security, quality gates, memory — nhưng **không có bằng chứng tự kiểm tra**. Mỗi lần upgrade (v1.25 → v1.31) không có regression test nào bảo vệ.

**Đề xuất nâng P2-2 (Observability dashboard) lên P1**, và thêm **P1-5** mới:

**P1-5. Bootstrap minimal test harness**

- Thêm `tests/hooks/test-bash-guard.sh` (verify deny rules fire)
- Thêm `tests/skills/validate-frontmatter.test.js` (verify ≥N skills có required fields)
- Thêm `.github/workflows/audit.yml`:
  ```yaml
  name: Harness Audit
  on: [pull_request, push]
  jobs:
    audit:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - run: node scripts/harness-audit.js repo --format json
        - run: bash scripts/validate-skills.sh
  ```

**Verify:** CI chạy pass trên commit hiện tại (với baseline score 58/70).

---

### 8.5 Chạy lại audit sau mỗi fix

```bash
# Baseline (hiện tại: 58/70)
node scripts/harness-audit.js repo > audit-before.txt

# Sau mỗi batch fix
node scripts/harness-audit.js repo > audit-after.txt
diff audit-before.txt audit-after.txt    # xem delta

# Focused scope trong lúc fix
node scripts/harness-audit.js hooks      # max 20 — kiểm hooks+security
node scripts/harness-audit.js skills     # max 30 — kiểm skills metadata
```

### 8.6 Roadmap score

| Milestone | Target | Gained from |
|---|---|---|
| **v1.31.1 patch** (ngày mai) | 58 → **65/70** | P0-5 supermemory (+2), P0-6 YAML frontmatter (+2), P0-2 cleanup root (không ảnh hưởng score nhưng giúp Quality Gates gián tiếp), fill PRD/TODO (+3) |
| **v1.32.0** (sprint sau) | 65 → **68/70** | P1-5 test harness + CI (+3 Eval Coverage) |
| **v1.33.0+** | 68 → **70/70** | Remaining eval fixtures, final polish |

### 8.7 Backlog sau audit (hợp nhất)

| ID | Priority | Title | Score impact |
|---|---|---|---|
| ~~P0-1~~ | 🔴 | ~~Đồng bộ số liệu badges~~ | ✅ **DONE** |
| ~~P0-2~~ | 🔴 | ~~Cleanup root directory~~ | ✅ **DONE** |
| ~~P0-3~~ | 🔴 | ~~Fix MEMORY.md broken links~~ | ✅ **DONE** |
| P0-4 | 🔴 | ~~Implement harness-audit.js~~ | ✅ **DONE** |
| ~~P0-5~~ | 🔴 | ~~Wire or strip supermemory MCP~~ | ✅ **DONE** |
| ~~P0-6~~ | 🔴 | ~~YAML frontmatter Tier-2~~ | ✅ **DONE** |
| ~~P1-1~~ | 🟡 | ~~Dogfood PRD/TODO~~ | ✅ **DONE** |
| P1-2 | 🟡 | Populate decision_ledger.jsonl | — (rule enforcement) |
| ~~P1-3~~ | 🟡 | ~~Nới CLAUDE.md rule "NEVER WRITE"~~ | ✅ **DONE** |
| ~~P1-4~~ | 🟡 | ~~Platform parity Windows~~ | ✅ **DONE** |
| **P1-5** | 🟡 | **Bootstrap test harness + CI** | **+3** (Eval Coverage) |
| ~~P2-1~~ | 🟢 | ~~Skill audit — loại duplicates~~ | ✅ **DONE** |
| P2-2 | 🟢 | Observability dashboard | — |
| P2-3 | 🟢 | Empty src/core | — |
| ~~P2-4~~ | 🟢 | ~~Gitignore hygiene~~ | ✅ **DONE** |

**Kết luận audit:** Framework ở mức **83% maturity** (58/70). Đủ để dùng production nhưng còn 3 gaps lớn: meta-consistency (P0-1→P0-6), dogfooding (P1-1→P1-2), và tự-verification (P1-5 Eval Coverage). Đạt 65/70 trong 1 ngày là mục tiêu khả thi nếu tập trung P0 block.

---

## 9. Rubric v2 (Ibryam 12-pattern) — Override Section 8

> **2026-04-16 update:** Sau khi audit Section 8, user yêu cầu trace nguồn rubric.
> Phát hiện: 7 category của v1 là self-defined (không có Anthropic authority).
> Realigned sang Bilgin Ibryam "12 Agentic Harness Patterns" (third-party nhưng có nguồn rõ: https://generativeprogrammer.com/p/12-agentic-harness-patterns-from).

### 9.1 Changes
- Rubric version: `2026-03-16` → `2026-04-16-ibryam`
- Max score (repo): 70 → **120**
- Scopes mới: `memory | workflow | tools | automation` (legacy `hooks|skills|agents|commands` giữ lại)
- Citation header trong script: trích Ibryam Substack + 3 nguồn Anthropic chính thức làm context
- Bug fix: `readFrontmatter` giờ xử lý CRLF (Windows) đúng — regex thêm `\r?$` (không có fix này, 27/31 agents bị miss → điểm cis giảm 2)

### 9.2 Baseline mới (scope=repo)
**120/120 · perfect · deterministic verified** (2 runs → diff identical)

| # | Pattern | Score | Pass |
|---|---|---|---|
| 1 | Persistent Instruction File | 10/10 | 5/5 |
| 2 | Scoped Context Assembly | 10/10 | 5/5 |
| 3 | Tiered Memory | 10/10 | 5/5 |
| 4 | Dream Consolidation | 10/10 | 5/5 |
| 5 | Progressive Context Compaction | 10/10 | 5/5 |
| 6 | Explore-Plan-Act Loop | 10/10 | 5/5 |
| 7 | Context-Isolated Subagents | 10/10 | 5/5 |
| 8 | Fork-Join Parallelism | 10/10 | 5/5 |
| 9 | Progressive Tool Expansion | 10/10 | 5/5 |
| 10 | Command Risk Classification | 10/10 | 5/5 |
| 11 | Single-Purpose Tool Design | 10/10 | 5/5 |
| 12 | Deterministic Lifecycle Hooks | 10/10 | 5/5 |

### 9.3 Scoped baselines

| Scope | Score | Max |
|---|---|---|
| `memory` | 50 | 50 |
| `workflow` | 30 | 30 |
| `tools` | 30 | 30 |
| `automation` | 10 | 10 |
| `hooks` (legacy) | 40 | 40 |
| `skills` (legacy) | 20 | 20 |
| `agents` (legacy) | 10 | 10 |
| `commands` (legacy) | 10 | 10 |

### 9.4 Caveats
- **120/120 không nghĩa là framework perfect** — nghĩa là nó cover 12 pattern của Ibryam (tầng architecture/infrastructure). Section 8 backlog (P0-1→P1-5) về **execution discipline** vẫn hoàn toàn còn giá trị:
  - P0-1 (badge mismatch), P0-2 (root cleanup), P0-3 (broken links), P0-5 (supermemory wire), P0-6 (Tier-2 YAML frontmatter), P1-1 (dogfood PRD/TODO), P1-5 (test harness + CI) — rubric v2 không catch được.
- **Rubric v2 có thể quá dễ** với repo meta-framework như SDD. Trong v3 có thể cần:
  - Tighten thresholds (yêu cầu ≥95% thay vì 80%)
  - Thêm sub-checks cho **dogfooding** (PRD/TODO thực sự được dùng, không phải placeholder)
  - Thêm check **documentation consistency** (badges match actual counts)
- `--patterns` flag in ra 12 pattern cho reference nhanh.

### 9.5 Commands
```bash
node scripts/harness-audit.js repo                # 120/120
node scripts/harness-audit.js memory              # 50/50
node scripts/harness-audit.js workflow            # 30/30
node scripts/harness-audit.js --patterns          # list 12 patterns
node scripts/harness-audit.js repo --format json  # CI-ready output
```

### 9.6 Update backlog từ Section 8

Priority không đổi — các item P0/P1 vẫn nguyên. Thêm 1 item mới:

| ID | Priority | Title | Score impact |
|---|---|---|---|
| **P2-5** | 🟢 | **Tighten rubric v3** — add dogfooding + doc-consistency sub-checks | — (tool polish) |

**Kết luận tổng:** Section 8 rubric (58/70) và Section 9 rubric (120/120) không conflict — đo 2 chiều khác nhau. Section 8 đo *execution discipline*, Section 9 đo *pattern coverage*. Để đánh giá framework maturity đúng nghĩa, đọc **cả 2 sections**. Ngày mai fix P0 block sẽ vừa kéo Section 8 lên 65/70 vừa giữ Section 9 ở 120/120.

