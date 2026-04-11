---
name: freeze
description: "Locks the codebase to prevent unintended writes during a freeze period such as before a release or during an incident. Use when the user mentions freezing, code lock, or release lockdown."
argument-hint: "[reason]"
user-invocable: true
allowed-tools: Read, Write, Bash
effort: 1
agent: release-manager
when_to_use: "Trước release cut, hotfix deployment, hoặc khi cần stabilization period"
---

# Code Freeze

Lock codebase để chuẩn bị release. Tạo file `.freeze` chứa thông tin freeze.

## Workflow

### 1. Đọc trạng thái hiện tại

Kiểm tra `.freeze` đã tồn tại chưa bằng cách đọc file đó. Nếu đã tồn tại, hiển thị thông tin và hỏi:
> "Codebase đang bị freeze bởi: [REASON]. Bạn có muốn override freeze hiện tại không? (yes/no)"

Nếu không, dừng lại.

### 2. Lấy lý do freeze

Nếu không có argument, hỏi:
> "Lý do freeze là gì? (vd: 'Release v2.1.0', 'Hotfix deployment', 'Sprint end')"

### 3. Tạo file `.freeze`

Ghi nội dung:

```
FROZEN=true
REASON=[lý do]
FROZEN_AT=[ISO timestamp]
BRANCH=[current branch từ git rev-parse --abbrev-ref HEAD]
```

### 4. Thông báo

Hiển thị:

```
🔒 CODEBASE FROZEN
Reason : [lý do]
Time   : [timestamp]
Branch : [branch]

Non-critical merges bị chặn. Chỉ hotfix được phép.
Để mở khóa: /unfreeze
```

### 5. Gợi ý bước tiếp theo

- `/release-checklist` — Chạy release checklist đầy đủ
- `/guard` — Kiểm tra trạng thái freeze bất kỳ lúc nào
- `/unfreeze` — Mở khóa sau khi release xong

## Edge Cases

- **Freeze đang tồn tại**: Hỏi xác nhận override trước khi ghi đè
- **Không có git**: Vẫn tạo `.freeze` nhưng bỏ qua field BRANCH

## Related Skills

- `/guard` — Kiểm tra freeze trước khi merge/deploy
- `/unfreeze` — Gỡ bỏ freeze sau release
- `/release-checklist` — Workflow release đầy đủ
- `/hotfix` — Deploy fix khẩn cấp trong khi đang freeze
