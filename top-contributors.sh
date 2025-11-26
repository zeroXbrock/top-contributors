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

# Regex of authors to ignore (case-insensitive).
# Add more with BOT_FILTER="foo|bar|baz"
BOT_FILTER="${BOT_FILTER:-bot|\\[bot\\]|-bot|ci|actions}"

# Produce list, filter out bots.
list="$(git shortlog -sne --since="$SINCE" --no-merges \
  | grep -Eiv "$BOT_FILTER")"

if [ -n "$TOP" ]; then
  echo "$list" | head -n "$TOP"
else
  echo "$list"
fi
