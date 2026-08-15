#!/usr/bin/env bash
# fix-compile-commands.sh
# Rewrite a compile_commands.json produced on a Linux build server so the
# absolute paths point at your local macOS checkout, letting clangd navigate.
#
# Usage:
#   ./fix-compile-commands.sh /path/to/compile_commands.json
#
# Edit SERVER_ROOT and LOCAL_ROOT below to match your setup.

set -euo pipefail

SERVER_ROOT="/home/you/project"      # source-tree root ON THE BUILD SERVER
LOCAL_ROOT="$HOME/project"           # source-tree root ON YOUR MAC

DB="${1:-compile_commands.json}"

if [[ ! -f "$DB" ]]; then
  echo "error: $DB not found" >&2
  exit 1
fi

# jq is the safe way to edit JSON. brew install jq
if ! command -v jq >/dev/null 2>&1; then
  echo "error: jq not installed. Run: brew install jq" >&2
  exit 1
fi

tmp="$(mktemp)"
jq --arg from "$SERVER_ROOT" --arg to "$LOCAL_ROOT" '
  map(
    .directory |= gsub($from; $to)
    | .file |= gsub($from; $to)
    | if has("command") then .command |= gsub($from; $to) else . end
    | if has("arguments") then .arguments |= map(gsub($from; $to)) else . end
  )
' "$DB" > "$tmp"

mv "$tmp" "$DB"
echo "rewrote $SERVER_ROOT -> $LOCAL_ROOT in $DB"
