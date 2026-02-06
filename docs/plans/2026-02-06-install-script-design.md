# Install Script Design

## Overview

Single `curl | bash` install script for beadspace. Replaces the current 9-step manual process.

## Usage

```bash
# Default (.beadspace/)
curl -sL https://raw.githubusercontent.com/cameronsjo/beadspace/main/install.sh | bash

# Custom directory
BEADSPACE_DIR=my/dashboard curl -sL https://raw.githubusercontent.com/cameronsjo/beadspace/main/install.sh | bash

# Or downloaded
./install.sh [target-dir]
```

## Behavior

| Step | Action |
|------|--------|
| 1 | Resolve target dir: `BEADSPACE_DIR` env > `$1` arg > `.beadspace` default |
| 2 | Validate: MUST be in a git repo |
| 3 | `mkdir -p $target` and `.github/workflows/` |
| 4 | `curl` `index.html` from raw.githubusercontent.com to `$target/` |
| 5 | `curl` `beadspace.yml` from raw.githubusercontent.com to `.github/workflows/` |
| 6 | `sed` workflow to replace `docs/beadspace` with `$target` |
| 7 | If `.beads/issues.jsonl` exists: convert JSONL to JSON array. Else: write `[]` |
| 8 | Print summary and next steps |

## Edge Cases

- **Not a git repo**: Fail with message
- **Target exists**: Overwrite (idempotent)
- **curl fails**: Fail with connection error
- **No `.beads/`**: Write empty `issues.json` (`[]`)
- **JSONL conversion**: Use `python3` (no `jq` dependency)
- **owner/repo for Pages hint**: Parse from `git remote`

## No Remote Side Effects

Script MUST NOT: commit, push, or call GitHub APIs. Print the Pages command, don't run it.
