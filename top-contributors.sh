#!/usr/bin/env bash
set -euo pipefail

# Check if npx is installed
if ! npx -h > /dev/null 2>&1; then
  echo "error: npx is not installed" >&2
  exit 1
fi

REPO_DIR="${1:-.}"
SINCE="${SINCE:-3 months ago}"
TOP="${TOP:-}"
OUTFILE="${OUTFILE:-$PWD/output.md}"
HERE=$PWD

cd "$REPO_DIR"

# Extract project name from REPO_DIR
PROJECT_NAME="$(basename "$(pwd)")"
echo "Loading top contributors for $PROJECT_NAME..."

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
  | grep -Eiv "$FILTER" \
  | sed 's/^[[:space:]]*//')"

# save results to file
echo "# Top *$PROJECT_NAME* contributors since $SINCE" > $OUTFILE
echo >> $OUTFILE
if [ -n "$TOP" ]; then
  echo -n "$list" | head -n "$TOP" >> $OUTFILE
else
  echo -n "$list" >> $OUTFILE
fi

echo "$list"

# generate a code snip image
npx carbon-now-cli $OUTFILE --save-as img --save-to $HERE --config $HERE/.carbon-now.json --preset hacker
