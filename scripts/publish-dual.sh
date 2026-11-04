#!/usr/bin/env bash
set -euo pipefail

# Publish today's daily Textile report plus one or more reviewed technical documents
# in ONE Git commit. Never edits a source project or stages unrelated paths.
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"

if (( $# < 2 )); then
    echo "[work-log] Usage: bash scripts/publish-dual.sh YYYY-MM-DD topic-slug [topic-slug ...] (one or more topics; no fixed count limit)" >&2
    exit 1
fi

REPORT_DATE="$1"
shift
TODAY="$(TZ=Asia/Taipei date +%F)"
if [[ ! "$REPORT_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || \
   [[ "$(TZ=Asia/Taipei date -d "$REPORT_DATE" +%F 2>/dev/null)" != "$REPORT_DATE" ]]; then
    echo "[work-log] ERROR: Invalid date." >&2
    exit 1
fi
# Historical backfill stays daily-only; avoids assigning new technical work to old dates.
if [[ "$REPORT_DATE" != "$TODAY" ]]; then
    echo "[work-log] ERROR: Dual-write publishing is allowed only for today's Taipei date ($TODAY)." >&2
    exit 1
fi

DAILY="daily/$REPORT_DATE.textile"
PATHS=("$DAILY")
declare -A ALLOWED
ALLOWED["$DAILY"]=1

for SLUG in "$@"; do
    if [[ ! "$SLUG" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
        echo "[work-log] ERROR: Invalid topic slug: $SLUG" >&2
        exit 1
    fi
    PATH_NAME="technical/$SLUG.textile"
    if [[ -n "${ALLOWED[$PATH_NAME]+x}" ]]; then
        echo "[work-log] ERROR: Duplicate topic: $SLUG" >&2
        exit 1
    fi
    ALLOWED["$PATH_NAME"]=1
    PATHS+=("$PATH_NAME")
done

if [[ "$(git -C "$REPO_DIR" branch --show-current)" != "main" ]]; then
    echo "[work-log] ERROR: Refusing to publish outside the main branch." >&2
    exit 1
fi
if [[ -L "$REPO_DIR/daily" || -L "$REPO_DIR/technical" ]]; then
    echo "[work-log] ERROR: Daily/technical directory must not be a symlink." >&2
    exit 1
fi

DAILY_FILE="$REPO_DIR/$DAILY"
EXPECTED_HEADER="h1. ${REPORT_DATE//-/\/}"
if [[ -L "$DAILY_FILE" || ! -f "$DAILY_FILE" ]]; then
    echo "[work-log] ERROR: Missing or symlinked daily report: $DAILY" >&2
    exit 1
fi
IFS= read -r FIRST_LINE < "$DAILY_FILE" || true
if [[ "$FIRST_LINE" != "$EXPECTED_HEADER" ]] || ! grep -qE '^\* ' "$DAILY_FILE"; then
    echo "[work-log] ERROR: Daily report failed basic Textile validation." >&2
    exit 1
fi

for (( i=1; i<${#PATHS[@]}; i++ )); do
    FILE="$REPO_DIR/${PATHS[$i]}"
    if [[ -L "$FILE" || ! -f "$FILE" ]]; then
        echo "[work-log] ERROR: Missing or symlinked technical report: ${PATHS[$i]}" >&2
        exit 1
    fi
    IFS= read -r TITLE < "$FILE" || true
    if [[ ! "$TITLE" =~ ^h1\.\ .+ ]] || ! grep -qE '^h2\. ' "$FILE"; then
        echo "[work-log] ERROR: Technical report failed basic Textile validation: ${PATHS[$i]}" >&2
        exit 1
    fi
done

# Never absorb pre-existing staged changes or unrelated tracked-file edits.
if ! git -C "$REPO_DIR" diff --cached --quiet; then
    echo "[work-log] ERROR: Pre-existing staged changes; refusing to publish." >&2
    exit 1
fi
while IFS= read -r -d '' CHANGED; do
    if [[ -z "${ALLOWED[$CHANGED]+x}" ]]; then
        echo "[work-log] ERROR: Unrelated tracked modification: $CHANGED" >&2
        exit 1
    fi
done < <(git -C "$REPO_DIR" diff --name-only -z)

# Conflict-safe synchronization. A conflict must fail without force/reset.
git -C "$REPO_DIR" pull --ff-only origin main

# Require an actual new change for BOTH the daily report and every topic.
# A topic with no new content must be omitted; do not create empty commits.
for PATH_NAME in "${PATHS[@]}"; do
    if [[ -z "$(git -C "$REPO_DIR" status --porcelain=v1 --untracked-files=normal -- "$PATH_NAME")" ]]; then
        echo "[work-log] ERROR: No change in $PATH_NAME; use daily-only publisher or omit this topic." >&2
        exit 1
    fi
done

git -C "$REPO_DIR" add -- "${PATHS[@]}"
# Validate the exact staged scope after staging.
while IFS= read -r -d '' STAGED; do
    if [[ -z "${ALLOWED[$STAGED]+x}" ]]; then
        echo "[work-log] ERROR: Unexpected staged path: $STAGED" >&2
        exit 1
    fi
done < <(git -C "$REPO_DIR" diff --cached --name-only -z)

git -C "$REPO_DIR" commit -m "work-log: daily $REPORT_DATE with $# technical topic(s)"
git -C "$REPO_DIR" push origin main
echo "[work-log] Published daily and technical reports in one commit:"
printf '  %s\n' "${PATHS[@]}"
