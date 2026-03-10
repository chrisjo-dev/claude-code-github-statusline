#!/bin/sh
set -e

REPO_URL="https://raw.githubusercontent.com/chrisjo-dev/claude-code-github-statusline/main"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"

echo "Installing claude-code-github-statusline..."

# 필수 의존성 확인
if ! command -v jq > /dev/null 2>&1; then
  echo "Error: jq is required. Install with: brew install jq"
  exit 1
fi

mkdir -p "$CLAUDE_DIR"

# 스크립트 다운로드
curl -sSL "${REPO_URL}/statusline-command.sh" -o "$CLAUDE_DIR/statusline-command.sh"
curl -sSL "${REPO_URL}/extract-issue.sh"      -o "$CLAUDE_DIR/extract-issue.sh"
chmod +x "$CLAUDE_DIR/statusline-command.sh"
chmod +x "$CLAUDE_DIR/extract-issue.sh"

# settings.json 없으면 생성
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

# settings.json에 statusLine + hooks 병합 (기존 설정 보존)
tmp=$(mktemp)
jq '
  .statusLine = {
    "type": "command",
    "command": "bash \($home)/.claude/statusline-command.sh"
  } |
  .hooks.UserPromptSubmit = ([
    (.hooks.UserPromptSubmit // [])[] | select(.hooks[0].command | test("extract-issue") | not)
  ] + [{
    "hooks": [{
      "type": "command",
      "command": "bash \($home)/.claude/extract-issue.sh"
    }]
  }])
' --arg home "$HOME" "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"

echo ""
echo "Done! Restart Claude Code to apply."
echo ""
echo "Usage:"
echo "  - Mention an issue in chat: #43, issues/43, or a GitHub URL"
echo "  - Statusline shows: dir | branch | #43 Issue title | S4.6 | ▓▓░░░░░░░░ 20%"
echo ""
echo "Optional: Install gh CLI for issue title fetching"
echo "  brew install gh && gh auth login"
