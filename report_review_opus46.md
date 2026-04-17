# Review Dự án SDD-Upgrade

**Ngày review:** 2026-04-16
**Reviewer:** Claude Sonnet 4.6 (claude-sonnet-4-6)
**Version tại thời điểm review:** v1.31.0

---

## Điểm mạnh

| Hạng mục | Đánh giá |
|----------|----------|
| Hook coverage | 15 scripts, 6 lifecycle events — đầy đủ nhất từ trước đến nay |
| Memory system | MEMORY.md 49/50 dòng — đúng giới hạn, cấu trúc Tier rõ ràng |
| Security deny list | 12 rules ngăn lệnh nguy hiểm, allow-list 41 entries |
| MAS Infrastructure | Circuit breaker, decision ledger, A2A handoff đều có files thực |
| CLAUDE.md | Critical Rules + Process Shields rõ ràng, không ambiguous |

---

## Vấn đề phát hiện

### 🔴 Cao

**1. `docs/technical/ARCHITECTURE.md` không tồn tại**

`coordination-rules.md` và `DECISIONS.md` đều reference file này nhưng nó chưa được tạo. Claude sẽ bị confused khi cần đọc kiến trúc hệ thống.

- File path cần tạo: `docs/technical/ARCHITECTURE.md`
- Nội dung tối thiểu: System overview, department hierarchy, data flow giữa agents

**2. Specialist files Tier 2.5 bị broken links**

3 files trong MEMORY.md đã bị prune nhưng các agent tương ứng vẫn tồn tại và hoạt động:

```
🗑️ Pruned broken link: specialists/backend-developer.md
🗑️ Pruned broken link: specialists/data-engineer.md
🗑️ Pruned broken link: specialists/technical-director.md
```

`backend-developer` và `data-engineer` là 2 trong số core agents được dùng nhiều nhất. Thiếu specialist memory file = mất toàn bộ context accumulation cho các agent này.

- Files cần restore/tạo lại: `.claude/memory/specialists/backend-developer.md`, `data-engineer.md`, `technical-director.md`
- Template có sẵn: xem `specialists/frontend-developer.md` làm mẫu

---

### 🟡 Trung bình

**3. `fork-join.sh` (8.1KB) không được đăng ký trong `settings.json`**

File tồn tại trong `.claude/hooks/` nhưng không có event nào trigger nó tự động. Có 2 hướng xử lý:

- Nếu muốn giữ: đăng ký vào event phù hợp trong `settings.json`
- Nếu không dùng: xóa hoặc chuyển sang `.claude/docs/` làm reference script

**4. Root directory bị clutter — 4 items untracked**

```
report_upgrade_claude_mem.md
report_upgrade_claude_mem_final.md
report_upgrade_claude_mem_other.md
scratch/  (7 files)
```

Hướng xử lý: nếu là working notes thì thêm vào `.gitignore`; nếu có giá trị tham khảo thì commit vào `docs/` hoặc `scratch/`.

**5. `decision_ledger.jsonl` và `agent-metrics.jsonl` gần như trống**

MAS Infrastructure v1.30.0 đã tạo các files này nhưng:

- `decision_ledger.jsonl`: 233 bytes (gần như rỗng)
- `agent-metrics.jsonl`: 171 bytes (gần như rỗng)

Rule 15 (ghi ledger cho mọi quyết định Medium/High risk) và agent-health tracking chưa được thực thi trên thực tế. Cần enforce qua workflow hoặc hook.

**6. UserPromptSubmit timeout = 5s — có thể tight**

`prompt-context.sh` grep qua toàn bộ `.claude/memory/` mỗi prompt. Với 150 skill files và nhiều memory files, 5s có thể không đủ trên disk chậm hoặc Windows.

- Fix: tăng timeout từ `5` lên `10` trong `settings.json` cho `UserPromptSubmit`

---

### 🔵 Thấp

**7. Technology stack vẫn `[not configured]`**

`CLAUDE.md` và `.claude/docs/technical-preferences.md` đều còn placeholder:

```
- Language: [not configured]
- Frontend Framework: [not configured]
- Backend Framework: [not configured]
```

Nếu đây là production instance thì cần chạy `/start`. Nếu là template distribution thì bỏ qua.

**8. MEMORY.md timestamp lỗi thời**

Hiển thị `Last session: 2026-04-15 16:31` — sẽ tự cập nhật khi session kết thúc qua `session-stop.sh`. Không cần fix thủ công.

---

## Checklist fix (theo thứ tự ưu tiên)

- [ ] **[CAO]** Tạo `docs/technical/ARCHITECTURE.md`
- [ ] **[CAO]** Restore `.claude/memory/specialists/backend-developer.md`
- [ ] **[CAO]** Restore `.claude/memory/specialists/data-engineer.md`
- [ ] **[CAO]** Restore `.claude/memory/specialists/technical-director.md`
- [ ] **[TB]** Làm rõ `fork-join.sh` — register vào settings.json hoặc xóa/move
- [ ] **[TB]** Dọn root clutter → thêm vào `.gitignore` hoặc commit vào đúng thư mục
- [ ] **[TB]** Tăng UserPromptSubmit timeout: `5` → `10` trong `settings.json`
- [ ] **[TB]** Enforce Rule 15 — bắt đầu ghi decision ledger thực sự
- [ ] **[THẤP]** Cấu hình technology stack nếu là production instance (`/start`)

---

*Report tạo bởi Claude Sonnet 4.6 — review session 2026-04-16*
