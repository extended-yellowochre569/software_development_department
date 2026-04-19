# CSS Template — SDD Technical Document Design System

Copy the entire `<style>` block below into every generated document.
The `<link>` tag goes in `<head>` BEFORE `<style>`.

---

## Google Fonts (required in `<head>`)

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
```

---

## Design Tokens (readable reference)

```css
:root {
    /* Backgrounds */
    --bg:          #F7F4EF;   /* warm off-white page */
    --surface:     #FFFFFF;   /* cards, sidebar, table bg */
    --surface-2:   #F2EEE8;   /* table header, code bg */
    --border:      #E3DDD5;   /* subtle divider */
    --border-2:    #D0C9BF;   /* stronger divider, nav dots */

    /* Text */
    --text:        #1A1614;   /* primary */
    --text-2:      #4A4440;   /* secondary / description */
    --text-3:      #7A7068;   /* muted / labels / metadata */

    /* Brand accent — orange */
    --orange:      #CF6631;
    --orange-dim:  #F5E6DF;
    --orange-mid:  #E8CDB8;

    /* Semantic colors */
    --green:       #1A6B3C;   --green-dim:   #DFF0E8;
    --red:         #A4161A;   --red-dim:     #FCE8E8;
    --blue:        #1B5FA8;   --blue-dim:    #E0ECFA;
    --purple:      #5E2D91;   --purple-dim:  #EEE5FB;
    --amber:       #92540A;   --amber-dim:   #FEF3E0;

    /* Typography */
    --mono: 'JetBrains Mono', 'Fira Code', 'Cascadia Code', monospace;
    --sans: 'Inter', system-ui, -apple-system, sans-serif;

    /* Radius */
    --radius-sm: 4px;
    --radius:    8px;
    --radius-lg: 12px;

    --sidebar-w: 224px;
}
```

---

## Full Minified `<style>` Block (paste as-is)

```css
:root{--bg:#F7F4EF;--surface:#FFFFFF;--surface-2:#F2EEE8;--border:#E3DDD5;--border-2:#D0C9BF;--text:#1A1614;--text-2:#4A4440;--text-3:#7A7068;--orange:#CF6631;--orange-dim:#F5E6DF;--orange-mid:#E8CDB8;--green:#1A6B3C;--green-dim:#DFF0E8;--red:#A4161A;--red-dim:#FCE8E8;--blue:#1B5FA8;--blue-dim:#E0ECFA;--purple:#5E2D91;--purple-dim:#EEE5FB;--amber:#92540A;--amber-dim:#FEF3E0;--mono:'JetBrains Mono','Fira Code',monospace;--sans:'Inter',system-ui,sans-serif;--radius-sm:4px;--radius:8px;--radius-lg:12px;--sidebar-w:224px}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
html{scroll-behavior:smooth;font-size:16px}
body{background:var(--bg);color:var(--text);font-family:var(--sans);font-size:.9375rem;line-height:1.6;min-height:100vh}
.shell{display:flex;min-height:100vh}
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
.main{flex:1;min-width:0;padding:56px 64px;max-width:900px}
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
.diagram-block{background:var(--text);border-radius:var(--radius-lg);padding:28px 32px;margin-bottom:48px;overflow-x:auto}
.diagram-caption{font-family:var(--mono);font-size:.65rem;font-weight:500;color:var(--orange);letter-spacing:.14em;text-transform:uppercase;margin-bottom:16px}
pre.diagram{font-family:var(--mono);font-size:.8125rem;line-height:1.7;color:#D4C8BC;white-space:pre}
pre.diagram .hl{color:#F5A673}
pre.diagram .dim{color:#6B6058}
.section{margin-bottom:56px}
.section-anchor{scroll-margin-top:32px}
.section-heading{display:flex;align-items:center;gap:12px;margin-bottom:6px}
.section-num{font-family:var(--mono);font-size:.65rem;font-weight:500;color:var(--text-3);letter-spacing:.06em}
h2{font-size:1.25rem;font-weight:700;letter-spacing:-.015em;color:var(--text)}
.section-desc{font-size:.875rem;color:var(--text-3);margin-bottom:24px;padding-left:36px}
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
.callout{display:flex;gap:12px;padding:14px 16px;border-radius:var(--radius);margin-bottom:16px;font-size:.85rem}
.callout-warn{background:var(--amber-dim);border:1px solid #F0D090}
.callout-icon{font-size:.9rem;flex-shrink:0;line-height:1.5}
.callout-body{line-height:1.5;color:var(--text-2)}
.callout-body strong{color:var(--text)}
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
hr.section-sep{border:none;border-top:1px solid var(--border);margin:48px 0}
.doc-footer{padding-top:32px;border-top:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;font-family:var(--mono);font-size:.7rem;color:var(--text-3)}
```
