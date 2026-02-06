# CLAUDE.md — Beadspace Dashboard

Instructions for Claude (or any AI assistant) to customize this dashboard.

## Architecture

This is a **single HTML file** (`index.html`) that fetches `issues.json` at load time and renders a dashboard. Zero build tools, zero external JS dependencies (fonts are the only CDN resource, and they degrade gracefully).

### Data Flow

```
issues.json (JSON array of beads issues)
    |
    v
fetch() in index.html
    |
    v
Client-side JS renders dashboard + issues table
```

### File Roles

| File | Purpose |
|------|---------|
| `index.html` | The entire dashboard — HTML, CSS, JS all inline |
| `issues.json` | Data file — JSON array, same schema as `bd export` |
| `workflows/beadspace.yml` | GitHub Action template — installed by `install.sh` |
| `install.sh` | One-command installer (`curl \| bash`) |

## Issue Schema

Each issue in `issues.json` has this shape:

```json
{
    "id": "prefix-xxx",
    "title": "Issue title",
    "status": "open" | "in_progress" | "closed",
    "priority": 0-4,
    "issue_type": "task" | "bug" | "feature",
    "labels": ["label1", "label2"],
    "description": "optional longer text",
    "created_at": "ISO 8601 datetime",
    "updated_at": "ISO 8601 datetime",
    "closed_at": "ISO 8601 datetime or null",
    "close_reason": "optional",
    "owner": "email or username",
    "created_by": "display name",
    "comments": [{"text": "...", "author": "...", "created_at": "..."}],
    "dependencies": [{"depends_on_id": "...", "type": "blocks"}]
}
```

## How to Modify

### Changing the Theme

All colors are CSS custom properties in the `:root` block at the top of `<style>`. Key variables:

- `--bg-deep`, `--bg-surface`, `--bg-elevated`: Background layers (dark to light)
- `--accent`, `--accent-bright`: Primary accent color (currently indigo)
- `--p0` through `--p4`: Priority colors (red, orange, yellow, blue, gray)
- `--status-open`, `--status-wip`, `--status-closed`: Status indicator colors
- `--type-bug`, `--type-feature`, `--type-task`: Issue type badge colors

### Changing Fonts

Fonts are loaded via Google Fonts in the `<link>` tag. Current fonts:

- **Syne**: Headings and brand — architectural, geometric
- **DM Sans**: Body text — clean, readable
- **JetBrains Mono**: Monospace for IDs, ages, code

To change: update the Google Fonts URL and the `font-family` references in CSS.

### Adding a New Dashboard Panel

1. Create a render function following the pattern of existing panels
2. Return an HTML string using the `.panel` / `.panel-header` / `.panel-body` structure
3. Insert it into the dashboard grid inside `renderDashboard()`

Example:

```javascript
// In renderDashboard(), add to the sidebar or main column:
'<div class="panel">' +
'<div class="panel-header"><span class="panel-title">My Panel</span></div>' +
'<div class="panel-body padded">' + myContentHtml + '</div></div>'
```

### Adding a New View (Tab)

1. Add a nav button: `<button class="nav-tab" data-view="myview">My View</button>`
2. Create a render function returning `<div id="view-myview" class="view">...</div>`
3. Call it in the bootstrap `.then()` chain after `renderIssuesView()`
4. Navigation binding is automatic (it uses `data-view` attribute)

### Modifying Triage Suggestions

The `triageSuggestions()` function contains the heuristic rules. Each rule:
- Checks a condition on non-closed issues
- Pushes a suggestion with `{ id, title, reason, severity }`
- Severity: `alert` (red), `warning` (amber), `info` (indigo)

Add new rules by following the existing pattern. Suggestions auto-dedupe by issue ID, keeping the highest severity.

### XSS Safety

- The issues table uses **DOM methods** (`createElement`, `textContent`) — inherently XSS-safe
- The dashboard view uses the `esc()` helper for HTML string building — escapes `& < > " '`
- All data originates from local `bd export` (trusted), but defense-in-depth is maintained
- **MUST NOT** use `.innerHTML` with unescaped user data

## Testing Locally

```bash
# Generate test data
bd export | jq -s '.' > issues.json

# Serve (fetch requires HTTP, won't work from file://)
python3 -m http.server 8080
```

## Design Principles

- **Zero dependencies**: No npm, no bundler, no runtime libraries
- **Data-driven**: All rendering from `issues.json`, no hardcoded content
- **Triage-first**: Dashboard prioritizes actionable information (open items, suggestions)
- **Dark theme**: Developer-tool aesthetic, high contrast, dense but readable
- **Offline-capable**: Works without internet after initial font load (fonts degrade to system)
