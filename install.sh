#!/usr/bin/env bash
set -euo pipefail

# Beadspace installer
# Usage:
#   curl -sL https://raw.githubusercontent.com/cameronsjo/beadspace/main/install.sh | bash
#   BEADSPACE_DIR=custom/path curl -sL ... | bash
#   ./install.sh [target-dir]

REPO_RAW="https://raw.githubusercontent.com/cameronsjo/beadspace/main"
TARGET="${BEADSPACE_DIR:-${1:-.beadspace}}"

# --- Preconditions ---

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: not a git repo. Run from your project root." >&2
    exit 1
fi

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
TARGET_ABS="${PROJECT_ROOT}/${TARGET}"

# --- Download files ---

mkdir -p "${TARGET_ABS}" "${PROJECT_ROOT}/.github/workflows"

echo "Downloading index.html..."
if ! curl -fsSL "${REPO_RAW}/index.html" -o "${TARGET_ABS}/index.html"; then
    echo "Error: couldn't download index.html. Check your connection." >&2
    exit 1
fi

echo "Downloading workflow..."
if ! curl -fsSL "${REPO_RAW}/workflows/beadspace.yml" -o "${PROJECT_ROOT}/.github/workflows/beadspace.yml"; then
    echo "Error: couldn't download beadspace.yml. Check your connection." >&2
    exit 1
fi

# --- Patch workflow paths ---

sed -i.bak \
    -e "s|docs/beadspace|${TARGET}|g" \
    "${PROJECT_ROOT}/.github/workflows/beadspace.yml"
rm -f "${PROJECT_ROOT}/.github/workflows/beadspace.yml.bak"

# --- Generate issues.json ---

ISSUE_COUNT=0
JSONL="${PROJECT_ROOT}/.beads/issues.jsonl"

if [ -f "${JSONL}" ]; then
    ISSUE_COUNT=$(python3 -c "
import json, sys
issues = [json.loads(l) for l in open(sys.argv[1]) if l.strip()]
json.dump(issues, open(sys.argv[2], 'w'))
print(len(issues))
" "${JSONL}" "${TARGET_ABS}/issues.json")
else
    echo "[]" > "${TARGET_ABS}/issues.json"
fi

# --- Detect owner/repo for Pages hint ---

REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
OWNER_REPO=""
if [[ "${REMOTE_URL}" =~ github\.com[:/]([^/]+/[^/.]+) ]]; then
    OWNER_REPO="${BASH_REMATCH[1]}"
fi

# --- Summary ---

echo ""
echo "Done!"
echo "  Created ${TARGET}/index.html"
echo "  Created .github/workflows/beadspace.yml"
echo "  Generated ${TARGET}/issues.json (${ISSUE_COUNT} issues)"
echo ""
echo "Next steps:"
echo "  git add ${TARGET} .github/workflows/beadspace.yml"
echo "  git commit -m \"feat: add beadspace dashboard\""
echo "  git push"
echo ""
if [ -n "${OWNER_REPO}" ]; then
    echo "To enable GitHub Pages:"
    echo "  gh api repos/${OWNER_REPO}/pages -X POST -f \"build_type=workflow\""
else
    echo "To enable GitHub Pages:"
    echo "  gh api repos/{owner}/{repo}/pages -X POST -f \"build_type=workflow\""
fi
