---
name: skill-technical-document
description: Generate polished internal technical HTML documents following the SDD visual design system — sidebar nav, layered sections, hook/reference tables, callouts, priority lists, and dark-canvas code diagrams.
type: skill
version: 1.0.0
author: SDD Framework
---

# Skill: Technical Document Generator

## When to Use

Activate this skill when asked to:
- Generate a **technical reference page** for any SDD subsystem (hooks, memory, agents, ADRs, etc.)
- Create an **HTML report** from audit findings, architecture decisions, or system maps
- Produce **internal documentation** that should be readable in a browser with a fixed sidebar

**Trigger phrases:** `tạo tài liệu kỹ thuật`, `technical doc`, `visual report`, `HTML reference`, `generate doc`, `tạo report HTML`

---

## Design System

All documents must following these tokens exactly — do not deviate.

### Color Palette (CSS Custom Properties)

```css
:root {
    --bg:          #F7F4EF;   /* warm off-white page background */
    --surface:     #FFFFFF;   /* cards, sidebar, table bg */
    --surface-2:   #F2EEE8;   /* table header, code inline bg */
    --border:      #E3DDD5;   /* subtle dividers */
    --border-2:    #D0C9BF;   /* stronger dividers, nav dots */
    --text:        #1A1614;   /* primary text */
    --text-2:      #4A4440;   /* secondary text, descriptions */
    --text-3:      #7A7068;   /* muted text, labels, metadata */

    /* Accent — orange (brand) */
    --orange:      #CF6631;
    --orange-dim:  #F5E6DF;
    --orange-mid:  #E8CDB8;

    /* Semantic colors */
    --green:       #1A6B3C;   --green-dim:   #DFF0E8;
    --red:         #A4161A;   --red-dim:     #FCE8E8;
    --blue:        #1B5FA8;   --blue-dim:    #E0ECFA;
    --purple:      #5E2D91;   --purple-dim:  #EEE5FB;
    --amber:       #92540A;   --amber-dim:   #FEF3E0;
}
```

### Typography

```css
--mono: 'JetBrains Mono', 'Fira Code', 'Cascadia Code', monospace;
--sans: 'Inter', system-ui, -apple-system, sans-serif;
```

**Google Fonts import (required):**
```html
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
```

**Type scale:**
| Role                   | Size                                          | Font | Weight |
| ---------------------- | --------------------------------------------- | ---- | ------ |
| Page title             | `clamp(1.75rem, 3vw, 2.25rem)`                | sans | 700    |
| Section heading (`h2`) | `1.25rem`                                     | sans | 700    |
| Body text              | `0.9375rem`                                   | sans | 400    |
| Table header           | `0.65rem`, uppercase, `letter-spacing: 0.1em` | mono | 500    |
| Code/filename          | `0.8125rem`                                   | mono | 500    |
| Brand label / eyebrow  | `0.65–0.7rem`, uppercase                      | mono | 500    |
| Body label / meta      | `0.8rem`                                      | sans | 400    |

### Spacing & Radius

```
--radius-sm: 4px    /* badges, inline code */
--radius:    8px    /* callouts */
--radius-lg: 12px   /* tables, diagram blocks */

Main content padding: 56px 64px
Sidebar width: 224px
Section gap: 56px
```

---

## Page Layout

Every document must use this two-column shell:

```html
<div class="shell">          <!-- display: flex -->
  <nav class="sidebar">      <!-- sticky, 224px wide -->
    <!-- brand + nav links + footer -->
  </nav>
  <main class="main">        <!-- flex: 1, max-width: 900px -->
    <!-- doc-header + sections + footer -->
  </main>
</div>
```

---

## Component Reference

### 1. Sidebar

```html
<nav class="sidebar">
  <div class="sidebar-brand">
    <div class="brand-label">PROJECT · subsystem</div>
    <div class="brand-title">Document<br>Title</div>
  </div>

  <div class="nav-group-label">Mục lục</div>
  <a href="#section-id" class="nav-link">
    <span class="nav-dot [green|red|blue|purple]"></span>
    Section Name
  </a>
  <!-- repeat nav-link for each section -->

  <div class="sidebar-footer">
    meta line 1<br>
    meta line 2<br>
    path info
  </div>
</nav>
```

**Nav dot color convention:**
- `green` → lifecycle / session hooks
- `red` → security / blocking hooks
- `blue` → enrichment / read-path
- `purple` → observability / logging
- _(no class)_ → neutral sections (matrix, deployment, summary)

### 2. Document Header

```html
<header class="doc-header">
  <div class="doc-eyebrow">
    <span>SDD Framework</span>
    <span class="doc-eyebrow-sep">/</span>
    <span>Category</span>
    <span class="doc-eyebrow-sep">/</span>
    <span>Subsystem</span>
  </div>
  <h1 class="doc-title">Main Title<br>Second Line</h1>
  <p class="doc-subtitle">One or two sentences describing the document.</p>
  <div class="doc-meta">
    <div class="meta-stat">
      <span class="meta-num">23</span>
      <span class="meta-label">label for number</span>
    </div>
    <span class="meta-sep">·</span>
    <!-- repeat meta-stat for each stat -->
  </div>
</header>
```

### 3. Dark-Canvas Code Diagram

Use for execution flows, state machines, tree diagrams:

```html
<div class="diagram-block">
  <div class="diagram-caption">// flow caption</div>
  <pre class="diagram">
<span class="dim">context label</span>
  ├── <span class="hl">highlighted item</span>  →  detail
  └── <span class="dim">dimmed item</span>
  </pre>
</div>
```

- `.hl` → `#F5A673` (warm highlight)
- `.dim` → `#6B6058` (muted)
- Diagram background: `var(--text)` (dark canvas)

### 4. Section

```html
<section class="section section-anchor" id="section-id">
  <div class="section-heading">
    <span class="section-num">§ 01</span>
    <h2>Section Title</h2>
  </div>
  <p class="section-desc">Description text with optional <code>inline code</code>.</p>
  <!-- content: hook table / matrix / priority list / callout -->
</section>
<hr class="section-sep">
```

### 5. Hook / Reference Table

For any tabular data (hooks, agents, rules, artifacts):

```html
<div class="hook-table-wrap">
  <table class="hook-table">
    <thead>
      <tr><th>Name</th><th>Event</th><th>Description</th></tr>
    </thead>
    <tbody>
      <tr>
        <td class="col-name"><div class="hn">filename.sh</div></td>
        <td><span class="ev ev-green">SessionStart</span></td>
        <td class="col-desc">
          <strong>Bold summary sentence.</strong> Detail text.
          <ul class="behaviors">
            <li>Behavior one</li>
            <li>Behavior two with <code>inline code</code></li>
          </ul>
        </td>
      </tr>
    </tbody>
  </table>
</div>
```

**Event badge colors:**

| Class       | Color  | Use for                                 |
| ----------- | ------ | --------------------------------------- |
| `ev-green`  | green  | SessionStart                            |
| `ev-red`    | red    | PreToolUse (blocking)                   |
| `ev-blue`   | blue   | UserPromptSubmit, PreToolUse:Read/Write |
| `ev-purple` | purple | PostToolUse, SubagentStart, PreCompact  |
| `ev-orange` | orange | Stop, sub-process, utility              |
| `ev-amber`  | amber  | warnings, partial states                |

**Blocking badge** (append to event cell when hook can `exit 2`):
```html
<span class="blocks">blocks</span>
```

### 6. Callout

```html
<!-- Warning variant -->
<div class="callout callout-warn">
  <span class="callout-icon">⚠</span>
  <div class="callout-body">
    <strong>Label:</strong> Detail text with <code>inline code</code>.
  </div>
</div>
```

Only `callout-warn` is defined in the base system. Add `callout-info` (blue border) or `callout-note` (green border) for info/note variants if needed.

### 7. Cross-Reference Matrix Table

For CIA triad, coverage maps, or comparison grids:

```html
<div class="matrix-wrap">
  <table class="matrix-table">
    <thead>
      <tr>
        <th>Item</th>
        <th>Property A</th>
        <th>Property B</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>item-name</td>
        <td><span class="cell-yes">✓ Coverage note</span></td>
        <td><span class="cell-no">—</span></td>
      </tr>
    </tbody>
  </table>
</div>
```

### 8. Priority / Ranked List

For deployment order, priority rankings, or ordered recommendations:

```html
<div class="priority-list">
  <div class="priority-row">
    <div class="priority-idx">01</div>
    <div class="priority-body">
      <div class="priority-hook">item-name or title</div>
      <div class="priority-why">Rationale in 1–2 sentences.</div>
    </div>
    <span class="priority-badge badge-critical">Critical</span>
  </div>
</div>
```

**Badge variants:** `badge-critical` (red), `badge-high` (amber), `badge-medium` (blue)

### 9. Document Footer

```html
<div class="doc-footer">
  <span>Project × Document Type</span>
  <span>stat1 · stat2 · date</span>
</div>
```

### 10. Sidebar Scroll Highlight (JS)

Always include this script at the end of `<body>` for active nav link tracking:

```html
<script>
  const sections = document.querySelectorAll('.section-anchor');
  const navLinks = document.querySelectorAll('.nav-link');
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const id = entry.target.id;
        navLinks.forEach(link => {
          link.classList.toggle('active', link.getAttribute('href') === '#' + id);
        });
      }
    });
  }, { rootMargin: '-30% 0px -60% 0px' });
  sections.forEach(s => observer.observe(s));
</script>
```

---

## Generation Workflow

When generating a technical document:

1. **Identify document type:**
   - Hook reference → use hook tables + deployment priority list
   - Architecture doc → use diagram + section tables
   - Audit/compliance doc → use matrix table + callouts
   - Memory/agent reference → use event badges + behavior lists

2. **Plan sections:** Map content to sections (`§ 00`, `§ 01`, ...). Maximum 7 sections before the document feels too long.

3. **Assign nav dot colors** logically: use color to communicate meaning, not decoration.

4. **Write content rules:**
   - Table cell descriptions: lead with **bold summary**, then detail + `<ul class="behaviors">`
   - Never use plain `<ul>` inside `.col-desc` — always `.behaviors`
   - Section descriptions use `<p class="section-desc">`, not a heading
   - Numbers in `doc-meta` must be meaningful stats (counts, dates, sizes)

5. **Output:** Single self-contained `.html` file.
   - Filename convention: `{topic}_visual_report.html` or `{topic}_reference.html`
   - Save to: `docs/` directory unless specified otherwise
   - No external JS dependencies; no CSS frameworks

---

## Full CSS Template

Paste this `<style>` block into every document:

```css
/* DESIGN TOKENS */
:root {
    --bg:#F7F4EF;--surface:#FFFFFF;--surface-2:#F2EEE8;
    --border:#E3DDD5;--border-2:#D0C9BF;
    --text:#1A1614;--text-2:#4A4440;--text-3:#7A7068;
    --orange:#CF6631;--orange-dim:#F5E6DF;--orange-mid:#E8CDB8;
    --green:#1A6B3C;--green-dim:#DFF0E8;
    --red:#A4161A;--red-dim:#FCE8E8;
    --blue:#1B5FA8;--blue-dim:#E0ECFA;
    --purple:#5E2D91;--purple-dim:#EEE5FB;
    --amber:#92540A;--amber-dim:#FEF3E0;
    --mono:'JetBrains Mono','Fira Code',monospace;
    --sans:'Inter',system-ui,sans-serif;
    --radius-sm:4px;--radius:8px;--radius-lg:12px;
    --sidebar-w:224px;
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
html{scroll-behavior:smooth;font-size:16px}
body{background:var(--bg);color:var(--text);font-family:var(--sans);font-size:.9375rem;line-height:1.6;min-height:100vh}
.shell{display:flex;min-height:100vh}
/* Sidebar */
.sidebar{width:var(--sidebar-w);flex-shrink:0;position:sticky;top:0;height:100vh;overflow-y:auto;border-right:1px solid var(--border);background:var(--surface);padding:32px 0;display:flex;flex-direction:column}
.sidebar-brand{padding:0 20px 24px;border-bottom:1px solid var(--border);margin-bottom:20px}
.brand-label{font-family:var(--mono);font-size:.65rem;font-weight:500;color:var(--orange);letter-spacing:.12em;text-transform:uppercase;margin-bottom:4px}
.brand-title{font-size:.875rem;font-weight:700;color:var(--text);line-height:1.3}
.nav-group-label{font-family:var(--mono);font-size:.6rem;font-weight:500;color:var(--text-3);letter-spacing:.14em;text-transform:uppercase;padding:0 20px;margin:16px 0 6px}
.nav-link{display:flex;align-items:center;gap:8px;padding:6px 20px;font-size:.8125rem;color:var(--text-2);text-decoration:none;transition:background .15s,color .15s}
.nav-link:hover{background:var(--bg);color:var(--text)}
.nav-link.active{color:var(--orange);font-weight:600}
.nav-dot{width:6px;height:6px;border-radius:50%;flex-shrink:0;background:var(--border-2)}
.nav-dot.green{background:var(--green)}.nav-dot.red{background:var(--red)}.nav-dot.blue{background:var(--blue)}.nav-dot.purple{background:var(--purple)}
.sidebar-footer{margin-top:auto;padding:20px;border-top:1px solid var(--border);font-family:var(--mono);font-size:.65rem;color:var(--text-3);line-height:1.7}
/* Main */
.main{flex:1;min-width:0;padding:56px 64px;max-width:900px}
/* Doc header */
.doc-header{padding-bottom:40px;border-bottom:1px solid var(--border);margin-bottom:48px}
.doc-eyebrow{display:flex;align-items:center;gap:8px;font-family:var(--mono);font-size:.7rem;color:var(--text-3);letter-spacing:.08em;margin-bottom:16px}
.doc-eyebrow-sep{color:var(--border-2)}
.doc-title{font-size:clamp(1.75rem,3vw,2.25rem);font-weight:700;line-height:1.15;letter-spacing:-.025em;color:var(--text);margin-bottom:12px}
.doc-subtitle{font-size:1rem;color:var(--text-2);line-height:1.5;max-width:560px}
.doc-meta{display:flex;align-items:center;gap:24px;margin-top:24px;flex-wrap:wrap}
.meta-stat{display:flex;align-items:baseline;gap:6px}
.meta-num{font-size:1.375rem;font-weight:700;color:var(--text);font-variant-numeric:tabular-nums}
.meta-label{font-size:.8rem;color:var(--text-3)}
.meta-sep{color:var(--border-2);font-size:1.2rem}
/* Diagram */
.diagram-block{background:var(--text);border-radius:var(--radius-lg);padding:28px 32px;margin-bottom:48px;overflow-x:auto}
.diagram-caption{font-family:var(--mono);font-size:.65rem;font-weight:500;color:var(--orange);letter-spacing:.14em;text-transform:uppercase;margin-bottom:16px}
pre.diagram{font-family:var(--mono);font-size:.8125rem;line-height:1.7;color:#D4C8BC;white-space:pre}
pre.diagram .hl{color:#F5A673}
pre.diagram .dim{color:#6B6058}
/* Section */
.section{margin-bottom:56px}
.section-anchor{scroll-margin-top:32px}
.section-heading{display:flex;align-items:center;gap:12px;margin-bottom:6px}
.section-num{font-family:var(--mono);font-size:.65rem;font-weight:500;color:var(--text-3);letter-spacing:.06em}
h2{font-size:1.25rem;font-weight:700;letter-spacing:-.015em;color:var(--text)}
.section-desc{font-size:.875rem;color:var(--text-3);margin-bottom:24px;padding-left:36px}
/* Hook table */
.hook-table-wrap{border:1px solid var(--border);border-radius:var(--radius-lg);overflow:hidden;background:var(--surface)}
.hook-table{width:100%;border-collapse:collapse}
.hook-table thead tr{background:var(--surface-2);border-bottom:1px solid var(--border)}
.hook-table th{font-family:var(--mono);font-size:.65rem;font-weight:500;color:var(--text-3);letter-spacing:.1em;text-transform:uppercase;padding:11px 20px;text-align:left;white-space:nowrap}
.hook-table tbody tr{border-bottom:1px solid var(--border);transition:background .1s}
.hook-table tbody tr:last-child{border-bottom:none}
.hook-table tbody tr:hover{background:var(--bg)}
.hook-table td{padding:14px 20px;vertical-align:top;font-size:.875rem}
.hook-table td.col-name{white-space:nowrap}
.hn{font-family:var(--mono);font-size:.8125rem;font-weight:500;color:var(--text)}
/* Event badges */
.ev{display:inline-flex;align-items:center;font-family:var(--mono);font-size:.65rem;font-weight:500;padding:2px 7px;border-radius:var(--radius-sm);white-space:nowrap}
.ev-green{color:var(--green);background:var(--green-dim)}
.ev-red{color:var(--red);background:var(--red-dim)}
.ev-blue{color:var(--blue);background:var(--blue-dim)}
.ev-purple{color:var(--purple);background:var(--purple-dim)}
.ev-orange{color:var(--orange);background:var(--orange-dim)}
.ev-amber{color:var(--amber);background:var(--amber-dim)}
.blocks{display:inline-flex;align-items:center;gap:4px;font-family:var(--mono);font-size:.6rem;font-weight:600;color:var(--red);background:var(--red-dim);border:1px solid #F5C8C8;padding:1px 6px;border-radius:var(--radius-sm);letter-spacing:.06em;text-transform:uppercase;margin-left:6px}
.col-desc{color:var(--text-2);line-height:1.5;font-size:.8375rem}
.col-desc code{font-family:var(--mono);font-size:.78rem;color:var(--text);background:var(--surface-2);padding:1px 5px;border-radius:3px;border:1px solid var(--border)}
.col-desc strong{color:var(--text);font-weight:600}
.behaviors{list-style:none;margin-top:8px}
.behaviors li{font-size:.8125rem;color:var(--text-3);padding:1px 0 1px 16px;position:relative}
.behaviors li::before{content:'·';position:absolute;left:4px;color:var(--border-2);font-weight:700}
/* Callout */
.callout{display:flex;gap:12px;padding:14px 16px;border-radius:var(--radius);margin-bottom:16px;font-size:.85rem}
.callout-warn{background:var(--amber-dim);border:1px solid #F0D090;color:var(--amber)}
.callout-icon{font-size:.9rem;flex-shrink:0;line-height:1.5}
.callout-body{line-height:1.5;color:var(--text-2)}
.callout-body strong{color:var(--text)}
/* Matrix */
.matrix-wrap{border:1px solid var(--border);border-radius:var(--radius-lg);overflow:hidden;background:var(--surface)}
.matrix-table{width:100%;border-collapse:collapse}
.matrix-table thead tr{background:var(--surface-2);border-bottom:1px solid var(--border)}
.matrix-table th{font-family:var(--mono);font-size:.65rem;font-weight:500;color:var(--text-3);letter-spacing:.1em;text-transform:uppercase;padding:11px 18px;text-align:left}
.matrix-table th:not(:first-child){text-align:center}
.matrix-table tbody tr{border-bottom:1px solid var(--border)}
.matrix-table tbody tr:last-child{border-bottom:none}
.matrix-table tbody tr:hover{background:var(--bg)}
.matrix-table td{padding:12px 18px;font-size:.8375rem}
.matrix-table td:first-child{font-family:var(--mono);font-size:.8rem;color:var(--text)}
.matrix-table td:not(:first-child){text-align:center}
.cell-yes{color:var(--green);font-size:.75rem;font-weight:600}
.cell-no{color:var(--border-2);font-size:1rem;font-weight:300}
/* Priority list */
.priority-list{border:1px solid var(--border);border-radius:var(--radius-lg);overflow:hidden;background:var(--surface)}
.priority-row{display:grid;grid-template-columns:48px 1fr auto;align-items:start;gap:16px;padding:16px 20px;border-bottom:1px solid var(--border);transition:background .1s}
.priority-row:last-child{border-bottom:none}
.priority-row:hover{background:var(--bg)}
.priority-idx{font-family:var(--mono);font-size:1.25rem;font-weight:700;color:var(--orange-mid);line-height:1.3}
.priority-hook{font-family:var(--mono);font-size:.875rem;font-weight:500;color:var(--text);margin-bottom:3px}
.priority-why{font-size:.8125rem;color:var(--text-3);line-height:1.45}
.priority-badge{font-family:var(--mono);font-size:.6rem;font-weight:600;padding:2px 7px;border-radius:var(--radius-sm);text-transform:uppercase;letter-spacing:.08em;white-space:nowrap;align-self:start}
.badge-critical{color:var(--red);background:var(--red-dim);border:1px solid #F5C8C8}
.badge-high{color:var(--amber);background:var(--amber-dim);border:1px solid #F0D090}
.badge-medium{color:var(--blue);background:var(--blue-dim);border:1px solid #C8DCF5}
/* Footer & separator */
hr.section-sep{border:none;border-top:1px solid var(--border);margin:48px 0}
.doc-footer{padding-top:32px;border-top:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;font-family:var(--mono);font-size:.7rem;color:var(--text-3)}
```

---

## Quality Checklist

Before finalizing any generated document, verify:

- [ ] Google Fonts `<link>` included in `<head>`
- [ ] All CSS custom properties sourced from the token list above
- [ ] No external CSS framework (no Tailwind, Bootstrap, etc.)
- [ ] Sidebar has a `sidebar-footer` with relevant metadata
- [ ] Each section has `class="section section-anchor"` and a unique `id`
- [ ] Section numbers are `§ 00`, `§ 01`, ... (two digits, space after §)
- [ ] All table descriptions use `<strong>Bold summary.</strong>` pattern
- [ ] Behavior lists use `.behaviors`, not plain `<ul>`
- [ ] Scroll-highlight JS included at end of `<body>`
- [ ] File saved to `docs/` as `{topic}_visual_report.html` or `{topic}_reference.html`
