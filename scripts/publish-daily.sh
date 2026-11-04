#!/usr/bin/env bash
set -euo pipefail

# Publish only one validated daily Textile report from work-progress.
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
DATE="${1:-$(TZ=Asia/Taipei date +%F)}"

if [[ ! "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || \
   [[ "$(TZ=Asia/Taipei date -d "$DATE" +%F 2>/dev/null)" != "$DATE" ]]; then
    echo "[work-log] ERROR: Invalid date (expected YYYY-MM-DD): $DATE" >&2
    exit 1
fi

REL_PATH="daily/${DATE}.textile"
FILE="${REPO_DIR}/${REL_PATH}"
if [[ "$(git -C "$REPO_DIR" branch --show-current)" != "main" ]]; then
    echo "[work-log] ERROR: Switch to main before publishing." >&2
    exit 1
fi
if [[ ! -f "$FILE" ]]; then
    echo "[work-log] ERROR: Daily report not found: $FILE" >&2
    exit 1
fi

EXPECTED_HEADER="h1. ${DATE//-/\/}"
IFS= read -r FIRST_LINE < "$FILE" || true
if [[ "$FIRST_LINE" != "$EXPECTED_HEADER" ]] || ! grep -qE '^\* ' "$FILE"; then
    echo "[work-log] ERROR: Textile report header/content check failed." >&2
    exit 1
fi

# Never combine any pre-existing staged changes with the report.
if ! git -C "$REPO_DIR" diff --cached --quiet; then
    echo "[work-log] ERROR: Existing staged changes; refusing to include them." >&2
    exit 1
fi
# Do not pull or publish while an unrelated tracked file has local modifications.
while IFS= read -r other_path; do
    if [[ -n "$other_path" && "$other_path" != "$REL_PATH" ]]; then
        echo "[work-log] ERROR: Uncommitted tracked changes outside today's report: $other_path" >&2
        exit 1
    fi
done < <(git -C "$REPO_DIR" diff --name-only)

# Pull before staging. Conflicting remote changes cause a safe failure.
git -C "$REPO_DIR" pull --ff-only origin main
git -C "$REPO_DIR" add -- "$REL_PATH"

if git -C "$REPO_DIR" diff --cached --quiet; then
    echo "[work-log] Nothing new to publish for ${DATE}."
    exit 0
fi

git -C "$REPO_DIR" commit -m "daily: update ${DATE} work log"
git -C "$REPO_DIR" push origin main

echo "[work-log] Published ${REL_PATH}."
