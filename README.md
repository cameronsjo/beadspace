# Beadspace

A drop-in dashboard for [Beads](https://github.com/steveyegge/beads) issue tracking. One HTML file, zero build tools, works on GitHub Pages.

![Dashboard](https://img.shields.io/badge/zero_dependencies-pure_HTML%2FCSS%2FJS-6366f1)

## What You Get

- **Dashboard**: Stats, triage suggestions (auto-flags misprioritized items), active issues sorted by priority
- **Issues Table**: Search, filter by status, sort by any column
- **Pure CSS charts**: Status donut, priority bars, label distribution — no Chart.js/D3
- **Fully dynamic**: Reads `issues.json` at page load, no build step to change the UI

## Quick Start (Local)

```bash
# Generate the data file
bd export | jq -s '.' > issues.json

# Serve locally (fetch won't work from file://)
python3 -m http.server 8080
# Open http://localhost:8080
```

## Drop Into Your Repo

### 1. Copy the files

```bash
mkdir -p docs/beadspace
cp index.html docs/beadspace/
```

### 2. Generate initial data

```bash
bd export | jq -s '.' > docs/beadspace/issues.json
```

### 3. Add the GitHub Action

Copy `workflows/beadspace.yml` to `.github/workflows/beadspace.yml` in your repo.

This auto-regenerates `issues.json` whenever `.beads/` changes on push.

### 4. Enable GitHub Pages

```bash
gh api repos/{owner}/{repo}/pages \
  -X POST \
  -f source.branch=main \
  -f source.path=/docs/beadspace
```

Or: Settings > Pages > Source: "Deploy from a branch" > `main` / `/docs/beadspace`.

Your dashboard will be at `https://{owner}.github.io/{repo}/`.

## How It Works

```
.beads/issues.jsonl  ──(bd export | jq -s)──>  issues.json  ──(fetch)──>  index.html
     (your data)            (GH Action)          (JSON array)            (dashboard)
```

- `index.html` is a static file — all logic runs client-side in vanilla JS
- `issues.json` is a JSON array of beads issues (same schema as `bd export` JSONL, just wrapped in `[]`)
- The GitHub Action reads `.beads/issues.jsonl` directly — no `bd` CLI needed in CI

## Triage Suggestions

The dashboard auto-flags potentially misprioritized items:

| Severity | Pattern | Example |
|----------|---------|---------|
| Alert | P0/P1 open > 3 days | Critical bug sitting untouched |
| Warning | Bug at P3+ | Bugs that probably need promotion |
| Info | plan-worthy with no description | Under-specified work |
| Info | Non-backlog open > 7 days | Stale items that need attention or demotion |

## Customization

Edit `index.html` directly — it's self-contained. See `CLAUDE.md` for instructions on having Claude customize it for you.

### CSS Variables

All colors, fonts, and spacing are controlled by CSS custom properties in `:root`. Change the theme by editing those values.

### Adding Views

The navigation system is data-driven. To add a view:

1. Add a `<button class="nav-tab" data-view="myview">` to the nav
2. Create a render function that returns HTML for `<div id="view-myview" class="view">`
3. Call it in the bootstrap `.then()` chain

## Attribution

Inspired by [beads-viz-prototype](https://github.com/mattbeane/beads-viz-prototype) by [@mattbeane](https://github.com/mattbeane). Original concept: visualize beads data as a single self-contained HTML file.

## License

MIT
