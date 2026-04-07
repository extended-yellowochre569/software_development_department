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
