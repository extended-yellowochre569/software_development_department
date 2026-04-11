---
name: guard
description: "Enforces project safety constraints by blocking risky operations outside their approved scope during active development. Use when activating a safety guard or constraint for the current session."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Bash
effort: 1
agent: release-manager
when_to_use: "Trước khi merge PR, deploy, hoặc push lên main/develop khi không chắc có freeze không"
---

# Guard Check

Kiểm tra trạng thái freeze của codebase. Dùng như một gate check trước bất kỳ thao tác nào lên branch chính.

## Workflow

### 1. Đọc `.freeze`

**Nếu không tồn tại:**

```
✅ CLEAR — Không có freeze đang hoạt động.
Development và merge bình thường.
```

Dừng lại ở đây.

**Nếu tồn tại**, tiếp tục bước 2.

### 2. Hiển thị freeze warning

```
🔒 CODEBASE IS FROZEN

Reason  : [REASON từ .freeze]
Since   : [FROZEN_AT]
Branch  : [BRANCH]
Duration: [tính từ FROZEN_AT đến thời điểm hiện tại]

⚠️  Non-critical merges bị chặn trong freeze period.
```

### 3. Phân loại yêu cầu

Hỏi:
> "Thao tác của bạn thuộc loại nào?"
>
> **A) Hotfix khẩn cấp** — bug production, security patch
> **B) Release artifact** — changelog, version bump, release notes
> **C) Non-critical** — feature, refactor, chore, docs thường

**Nếu A hoặc B:** Cho phép tiếp tục với note:
> "⚠️ Được phép tiếp tục. Lưu ý đây là freeze period — chỉ thao tác cần thiết."

**Nếu C:** Chặn và hướng dẫn:
> "🚫 Non-critical changes phải đợi đến sau khi `/unfreeze`.
> Lưu work lại và tiếp tục sau khi release hoàn thành."

### 4. Gợi ý

- `/unfreeze` — Nếu release đã xong
- `/release-checklist` — Nếu đang trong quá trình release
- `/hotfix` — Nếu cần deploy fix khẩn cấp

## Edge Cases

- **Không có .freeze**: Chỉ báo CLEAR, không hỏi thêm
- **User không chắc loại thao tác**: Hỏi thêm để phân loại đúng trước khi quyết định

## Related Skills

- `/freeze` — Lock codebase
- `/unfreeze` — Gỡ bỏ freeze
- `/hotfix` — Deploy khẩn cấp khi đang freeze
- `/release-checklist` — Workflow release đầy đủ
