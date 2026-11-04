#!/usr/bin/env bash
set -euo pipefail

# Publish one or more reviewed technical reports, independent of daily reports.
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"

if (( $# < 1 )); then
    echo "[work-log] Usage: bash scripts/publish-technical.sh topic-slug [topic-slug ...]" >&2
    exit 1
fi

declare -A ALLOWED
PATHS=()
for SLUG in "$@"; do
    if [[ ! "$SLUG" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
        echo "[work-log] ERROR: Invalid topic slug: $SLUG" >&2
        exit 1
    fi
    REL_PATH="technical/$SLUG.textile"
    if [[ -n "${ALLOWED[$REL_PATH]+x}" ]]; then
        echo "[work-log] ERROR: Duplicate topic: $SLUG" >&2
        exit 1
    fi
    ALLOWED["$REL_PATH"]=1
    PATHS+=("$REL_PATH")
done

if [[ "$(git -C "$REPO_DIR" branch --show-current)" != "main" ]]; then
    echo "[work-log] ERROR: Refusing to publish outside main." >&2
    exit 1
fi
if [[ -L "$REPO_DIR/technical" ]]; then
    echo "[work-log] ERROR: technical directory must not be a symlink." >&2
    exit 1
fi

for REL_PATH in "${PATHS[@]}"; do
    FILE="$REPO_DIR/$REL_PATH"
    if [[ -L "$FILE" || ! -f "$FILE" ]]; then
        echo "[work-log] ERROR: Missing or symlinked report: $REL_PATH" >&2
        exit 1
    fi
    IFS= read -r FIRST_LINE < "$FILE" || true
    if [[ ! "$FIRST_LINE" =~ ^h1\.\ .+ ]] || ! grep -qE '^h2\. ' "$FILE"; then
        echo "[work-log] ERROR: Invalid Technical Textile structure: $REL_PATH" >&2
        exit 1
    fi
done

if ! git -C "$REPO_DIR" diff --cached --quiet; then
    echo "[work-log] ERROR: Pre-existing staged changes." >&2
    exit 1
fi
while IFS= read -r -d '' CHANGED; do
    if [[ -z "${ALLOWED[$CHANGED]+x}" ]]; then
        echo "[work-log] ERROR: Unrelated tracked change: $CHANGED" >&2
        exit 1
    fi
done < <(git -C "$REPO_DIR" diff --name-only -z)

git -C "$REPO_DIR" pull --ff-only origin main

for REL_PATH in "${PATHS[@]}"; do
    if [[ -z "$(git -C "$REPO_DIR" status --porcelain=v1 --untracked-files=normal -- "$REL_PATH")" ]]; then
        echo "[work-log] ERROR: No new change: $REL_PATH" >&2
        exit 1
    fi
done

git -C "$REPO_DIR" add -- "${PATHS[@]}"
while IFS= read -r -d '' STAGED; do
    if [[ -z "${ALLOWED[$STAGED]+x}" ]]; then
        echo "[work-log] ERROR: Unexpected staged path: $STAGED" >&2
        exit 1
    fi
done < <(git -C "$REPO_DIR" diff --cached --name-only -z)

git -C "$REPO_DIR" commit -m "technical: update $# topic(s)"
git -C "$REPO_DIR" push origin main
printf '[work-log] Published technical reports:\n'
printf '  %s\n' "${PATHS[@]}"
