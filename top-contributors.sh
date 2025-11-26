#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${1:-.}"
SINCE="${SINCE:-3 months ago}"
TOP="${TOP:-}"

cd "$REPO_DIR"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "error: $REPO_DIR is not a git repository" >&2
  exit 1
fi

# Built-in bot filter
BASE_FILTER="bot|\\[bot\\]|-bot|ci|actions"

# User-specified extra exclusions (e.g., EXCEPT="Brock|myemail@")
if [ -n "${EXCEPT:-}" ]; then
  FILTER="$BASE_FILTER|$EXCEPT"
else
  FILTER="$BASE_FILTER"
fi

list="$(git shortlog -sne --since="$SINCE" --no-merges \
  | grep -Eiv "$FILTER")"

if [ -n "$TOP" ]; then
  echo "$list" | head -n "$TOP"
else
  echo "$list"
fi
