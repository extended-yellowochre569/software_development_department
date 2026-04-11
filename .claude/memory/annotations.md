---
name: annotations
description: "Persistent gotchas, caveats, and learned lessons about APIs, libraries, and project-specific behaviors. Auto-annotated by agents when they discover bugs, quirks, or undocumented behavior. Survives across sessions."
type: reference
trigger: [api, sdk, library, gotcha, caveat, quirk, bug, workaround, integration, webhook, auth, token, limit, rate limit, version, compatibility, deprecated]
---

# 📌 Project Annotations

> Curated by agents during development. Each entry is a **learned lesson** — a gotcha,
> caveat, or non-obvious behavior discovered while working on this project.
>
> **Agent rule:** When you discover unexpected API behavior, add an entry here immediately.
> Format: `- [YYYY-MM-DD] <description>` under the relevant service/library section.

## Anthropic — Claude Managed Agents API (Beta)

- **[2026-04-10]** API có 3 objects riêng biệt: `agents`, `environments`, `sessions` — không phải tạo session trực tiếp với model/system/tools. Thứ tự: `agents.create()` → `environments.create()` → `sessions.create(agent=id, environment_id=id)`.
- **[2026-04-10]** Stream API: `sessions.events.stream(session_id)` + `sessions.events.send(session_id, events=[...])`. Mở stream TRƯỚC, gửi message SAU (API buffers events).
- **[2026-04-10]** Tool type `agent_toolset_20260401` bật toàn bộ built-in tools cùng lúc. Dùng khi muốn full access, config từng tool riêng khi cần least privilege.
- **[2026-04-10]** Agent và Environment là **persistent objects** (có `id` + `version`), không phải ephemeral. Tạo 1 lần, reuse qua nhiều sessions.
- **[2026-04-10]** Beta header `managed-agents-2026-04-01` bắt buộc trên mọi request. SDK inject tự động — không cần set thủ công.
- **[2026-04-10]** CLI `ant` (anthropic-cli) — tool riêng để quản lý agents/environments/sessions. Cài qua Homebrew (macOS) hoặc curl (Linux/WSL).
- **[2026-04-10]** `agents.update()` array fields (`tools`, `mcp_servers`, `skills`, `callable_agents`) bị **REPLACE hoàn toàn**, không merge. Phải include lại tất cả tools muốn giữ khi update.
- **[2026-04-10]** `agents.update()` yêu cầu truyền `version` hiện tại (optimistic locking). Nếu không match → lỗi.
- **[2026-04-10]** Fast mode syntax: `model={"id": "claude-opus-4-6", "speed": "fast"}` — phải là object, không phải string.
- **[2026-04-10]** `metadata` update là merged (key-level), không replace. Xóa key bằng cách set value = `""`.
- **[2026-04-10]** Agent archive: `archived_at != null` → read-only. Existing sessions vẫn chạy, new sessions không thể reference.
- **[2026-04-10]** No-op detection: nếu update không thay đổi gì → không tạo version mới, trả về version hiện tại.
- **[2026-04-10]** Tools: `default_config: {enabled: false}` + per-tool `enabled: true` = whitelist pattern (chỉ bật tools cụ thể). Ngược lại là blacklist (`configs: [{name: X, enabled: false}]`).
- **[2026-04-10]** Custom tools: model chỉ emit `agent.tool_use` event, KHÔNG tự thực thi. App phải xử lý rồi gửi lại `tool_result` event với `tool_use_id`.
- **[2026-04-10]** Custom tool descriptions phải cực kỳ chi tiết (3-4 câu+). Đây là yếu tố ảnh hưởng nhất đến tool selection accuracy.
- **[2026-04-10]** Skills load theo 3 levels: metadata (~100 tokens, luôn load) → SKILL.md body (<5k, khi triggered) → bundled files/scripts (0 tokens cho đến khi truy cập). Scripts được *execute* không *load*, nên không tiêu context.
- **[2026-04-10]** Skills (API platform) không có network access và không install packages runtime. Chỉ dùng pre-installed packages. Claude.ai có thể install npm/PyPI.
- **[2026-04-10]** Skills không sync cross-surface: API upload ≠ claude.ai ≠ Claude Code. Phải manage riêng từng platform.
- **[2026-04-10]** Skills max 20 per session (tính gộp tất cả agents trong multi-agent session).
- **[2026-04-10]** Skills không được ZDR. Skill content và execution data được retain theo standard policy.
- **[2026-04-10]** SKILL.md description phải viết third person. First/second person gây discovery problems vì được inject vào system prompt.
- **[2026-04-10]** File references trong SKILL.md phải 1 level deep. Nested references (SKILL.md → A.md → B.md) khiến Claude đọc không đầy đủ (dùng `head -100` thay vì full read).
- **[2026-04-10]** MCP trong Managed Agents: khai báo server trên Agent (không có credentials), cung cấp credentials qua `vault_ids` ở Session creation — secrets không nằm trong agent definition.
- **[2026-04-10]** Vault credentials là write-only (`token`, `access_token`, `refresh_token`, `client_secret`). Không bao giờ được trả về trong API responses.
- **[2026-04-10]** 1 vault = 1 end-user. Vaults là workspace-scoped — ai có API key đều có thể dùng. Phải protect API key như protect user credentials.
- **[2026-04-10]** `mcp_server_url` trong credential là immutable sau khi tạo. Muốn đổi URL → archive credential cũ, tạo mới.
- **[2026-04-10]** Chỉ 1 active credential per `mcp_server_url` per vault. Tạo cái thứ 2 cho cùng URL → 409 Conflict.
- **[2026-04-10]** MCP auth failure trong session không block session. Emit `session.error` event, session tiếp tục (app tự quyết định xử lý).
- **[2026-04-10]** MCP toolset mặc định permission policy `always_ask` (cần user approval mỗi tool call). Khác với agent_toolset mặc định `always_allow`.

---

## How to Add an Annotation

Run `/annotate` skill or write directly:

```
## <Service or Library Name>
- [YYYY-MM-DD] <what was discovered> — <workaround if any>
```

---

## Node.js / Runtime

*(no annotations yet)*

---

## Git / Version Control

*(no annotations yet)*

---

## External APIs

*(no annotations yet — add as you integrate services)*

---

## Database

*(no annotations yet)*

---

## Framework-specific

*(no annotations yet)*

---

## Security / Auth

*(no annotations yet)*

---

## Performance

*(no annotations yet)*

---

> **Tips for good annotations:**
> - Be specific: "Stripe webhook needs raw body BEFORE JSON.parse" not just "Stripe quirk"
> - Include the date — stale annotations (6+ months) may no longer apply
> - If a workaround exists, write it explicitly
> - If the issue is fixed in a newer version, note the fixed version
