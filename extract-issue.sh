#!/bin/sh
# UserPromptSubmit 훅: 프롬프트에서 GitHub 이슈 번호 추출 후 .claude/current-issue에 기록

input=$(cat)
prompt=$(echo "$input" | jq -r '.prompt // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')

# 패턴 매칭 (우선순위 순)
# 1. GitHub URL: .../issues/43
issue=$(echo "$prompt" | grep -oE 'issues/[0-9]+' | grep -oE '[0-9]+' | head -1)

# 2. #43 형태
[ -z "$issue" ] && issue=$(echo "$prompt" | grep -oE '#[0-9]+' | grep -oE '[0-9]+' | head -1)

# 3. "이슈 43" / "Issue 43" 형태
[ -z "$issue" ] && issue=$(echo "$prompt" | grep -oiE '이슈\s*[0-9]+|issue\s*[0-9]+' | grep -oE '[0-9]+' | head -1)

if [ -n "$issue" ]; then
  cwd=$(pwd)
  git_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
  base="${git_root:-$cwd}"
  mkdir -p "${base}/.claude"

  # gh CLI로 이슈 제목 fetch (실패하면 번호만 저장)
  title=""
  if command -v gh > /dev/null 2>&1; then
    title=$(gh issue view "$issue" --json title -q '.title' 2>/dev/null)
  fi

  # session_id 있으면 세션별 파일, 없으면 공통 파일
  filename="current-issue"
  [ -n "$session_id" ] && filename="current-issue-${session_id}"

  if [ -n "$title" ]; then
    echo "${issue}|${title}" > "${base}/.claude/${filename}"
  else
    echo "${issue}" > "${base}/.claude/${filename}"
  fi
fi
