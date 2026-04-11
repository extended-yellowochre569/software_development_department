---
name: unfreeze
description: "Unlocks the codebase after a release freeze or incident freeze period to resume normal development. Use when a freeze period ends or when the user mentions unfreezing or lifting the code freeze."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Write, Bash, Edit
effort: 1
agent: release-manager
when_to_use: "Sau khi release thành công hoặc khi muốn tiếp tục development bình thường"
---

# Code Unfreeze

Gỡ bỏ code freeze, cho phép merge và development tiếp tục.

## Workflow

### 1. Kiểm tra trạng thái

Đọc `.freeze`. Nếu không tồn tại, thông báo và dừng:
> "✅ Codebase hiện không bị freeze. Không cần unfreeze."

### 2. Hiển thị thông tin freeze hiện tại

```
🔒 Freeze hiện tại:
Reason     : [REASON từ .freeze]
Frozen at  : [FROZEN_AT]
Branch     : [BRANCH]
Duration   : [tính từ FROZEN_AT đến thời điểm hiện tại]
```

### 3. Xác nhận

Hỏi:
> "Bạn có chắc muốn unfreeze? Release/deployment đã hoàn thành chưa? (yes/no)"

Nếu "no", dừng lại.

### 4. Xóa `.freeze`

Dùng Bash để xóa file: `rm .freeze`

### 5. Log vào session state

Append vào `production/session-state/active.md` (nếu tồn tại):

```markdown
## Unfreeze Log — [timestamp]
- Unfrozen at: [timestamp]
- Was frozen for: [duration]
- Reason was: [reason]
```

### 6. Thông báo

```
✅ CODEBASE UNFROZEN
Development có thể tiếp tục bình thường.
Tất cả merges và deployments đã được cho phép.
```

## Edge Cases

- **Không có freeze**: Thông báo rõ ràng, không làm gì thêm
- **active.md không tồn tại**: Bỏ qua bước log, không báo lỗi

## Related Skills

- `/freeze` — Lock codebase lại
- `/guard` — Kiểm tra trạng thái hiện tại
- `/release-checklist` — Workflow release đầy đủ
