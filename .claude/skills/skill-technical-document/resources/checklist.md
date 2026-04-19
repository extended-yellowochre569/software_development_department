# Quality Checklist — SDD Technical Document

Run before saving the final `.html` file.

## Must-pass (hard gates)

- [ ] Google Fonts `<link>` included in `<head>` before `<style>`
- [ ] All CSS sourced from `resources/css_template.md` — no invented colors
- [ ] No external CSS framework (no Tailwind, Bootstrap, CDN links)
- [ ] Each section has `class="section section-anchor"` and a unique `id`
- [ ] Sidebar has `sidebar-footer` with ≥ 2 metadata lines
- [ ] Scroll-highlight `<script>` included at end of `<body>`
- [ ] All `doc-meta` stats are real numbers, not placeholders
- [ ] No Lorem ipsum or placeholder text anywhere

## Should-pass (quality gates)

- [ ] Section numbers are `§ 00`, `§ 01`, ... (space after §, zero-padded)
- [ ] Every table description cell leads with `<strong>Bold summary.</strong>`
- [ ] Bullet points inside `.col-desc` use `.behaviors`, not `<li>` directly
- [ ] Nav dot colors follow the semantic convention (green/red/blue/purple)
- [ ] Blocking hooks have both `.ev-red` badge AND `.blocks` badge
- [ ] Section count is between 2 and 7
- [ ] File saved to `docs/` with naming: `{topic}_visual_report.html` or `{topic}_reference.html`
