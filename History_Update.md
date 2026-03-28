# History Update Log

Tài liệu này ghi lại lịch sử cập nhật tài liệu và source code của **Software Development Department** template.

---

## 🗓️ Lịch sử cập nhật

---

### [v1.3.0] - 2026-03-28

**Chủ đề:** Bổ sung Mobile Development & Collaborative Design Principle

#### 📄 Tài liệu cập nhật
- `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` — Bổ sung nguyên tắc thiết kế cộng tác cho phát triển phần mềm; cập nhật ví dụ từ game design sang software engineering (auth API, JWT, database schema)
- `README.md` — Cập nhật nội dung hướng dẫn sử dụng template bằng tiếng Việt
- `README_en.md` — Cập nhật nội dung hướng dẫn sử dụng template bằng tiếng Anh
- `.claude/docs/agent-roster.md` — Cập nhật danh sách agent
- `.claude/docs/quick-start.md` — Cập nhật hướng dẫn bắt đầu nhanh

#### ✨ Tính năng mới
- `feat(mobile)`: Thêm **mobile-developer** agent và các mobile skills
- `.claude/docs/templates/app-store-submission-checklist.md` — Template checklist submit lên App Store
- `.claude/docs/templates/mobile-architecture.md` — Template kiến trúc ứng dụng mobile
- `.claude/rules/secrets-config.md` — Quy tắc quản lý secrets và config bảo mật

---

### [v1.2.0] - 2026-03-27

**Chủ đề:** Cải thiện Skills — Feature Spec & Brainstorming

#### 📄 Tài liệu cập nhật
- `fix(feature-spec)`: Viết lại skill **design-system** để phù hợp với feature specification phần mềm
- `fix(brainstorm)`: Viết lại skill **brainstorm** cho ngữ cảnh phát triển sản phẩm phần mềm

---

### [v1.1.0] - 2026-03-27

**Chủ đề:** Hoàn thiện Documentation & Hướng dẫn người dùng

#### 📄 Tài liệu cập nhật
- `docs`: Đổi tên `README` → `README_en` và `user_guide` → `README`
  (Hướng dẫn tiếng Việt trở thành README chính)
- `docs`: Thêm `user_guide.md` (README tiếng Việt) — hướng dẫn đầy đủ về cách sử dụng template
- `docs`: Cập nhật `README.md` — thêm URL clone chính xác và thông tin tác giả
- `LICENSE` — Cập nhật tên tác giả bản quyền

---

### [v1.0.0] - 2026-03-27

**Chủ đề:** Ra mắt — Chuyển đổi từ Game Studio → Software Department

#### 📄 Tài liệu khởi tạo
- `init`: Khởi tạo **Claude Code Software Development Department** template
- `cleanup`: Xóa toàn bộ tài liệu tham chiếu các game engine (Godot, Unity, Unreal Engine)
- `chore`: Chuyển đổi template từ "Game Studio" sang "Software Department":
  - Thay thế các vai trò game (Game Designer, Level Designer, VFX Artist) bằng vai trò phần mềm (CTO, Product Manager, Frontend/Backend/Fullstack Developer, Data Engineer, UX Researcher)
  - Cập nhật tất cả skills, workflows, và agent definitions sang ngữ cảnh software engineering
  - Cập nhật WORKFLOW-GUIDE.md với ví dụ thực tế về phát triển phần mềm

---

## 📌 Ghi chú

- **Versioning**: Theo [Semantic Versioning](https://semver.org/) — `MAJOR.MINOR.PATCH`
- **Format**: Mỗi entry ghi rõ ngày, chủ đề, và danh sách file thay đổi cụ thể
- **Mục đích**: Giúp team theo dõi tiến độ cập nhật tài liệu và hiểu lý do thay đổi

---

*Last Updated: 2026-03-28*
