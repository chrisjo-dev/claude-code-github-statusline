#!/bin/sh
set -e

CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"

echo "Uninstalling claude-code-github-statusline..."

# 스크립트 제거
rm -f "$CLAUDE_DIR/statusline-command.sh"
rm -f "$CLAUDE_DIR/extract-issue.sh"

# settings.json에서 관련 항목 제거
if [ -f "$SETTINGS" ] && command -v jq > /dev/null 2>&1; then
  tmp=$(mktemp)
  jq '
    del(.statusLine) |
    .hooks.UserPromptSubmit = (
      [(.hooks.UserPromptSubmit // [])[] | select(.hooks[0].command | test("extract-issue") | not)]
    ) |
    if (.hooks.UserPromptSubmit | length) == 0 then del(.hooks.UserPromptSubmit) else . end |
    if (.hooks | length) == 0 then del(.hooks) else . end
  ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
fi

echo "Done. Restart Claude Code to apply."
