#!/bin/sh
input=$(cat)

# 디렉토리
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$cwd" ] && cwd=$(pwd)
dir=$(basename "$cwd")

# 모델명 단축 (Claude Sonnet 4.6 → S4.6 등)
model_raw=$(echo "$input" | jq -r '.model.display_name // empty')
if echo "$model_raw" | grep -qi "sonnet"; then
  ver=$(echo "$model_raw" | grep -oE '[0-9]+\.[0-9]+' | head -1)
  model="S${ver}"
elif echo "$model_raw" | grep -qi "opus"; then
  ver=$(echo "$model_raw" | grep -oE '[0-9]+\.[0-9]+' | head -1)
  model="O${ver}"
elif echo "$model_raw" | grep -qi "haiku"; then
  ver=$(echo "$model_raw" | grep -oE '[0-9]+\.[0-9]+' | head -1)
  model="H${ver}"
else
  model="$model_raw"
fi

# 컨텍스트 프로그레스 바
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  filled=$(( used_int * 10 / 100 ))
  empty=$(( 10 - filled ))
  bar=""
  i=0
  while [ $i -lt $filled ]; do bar="${bar}▓"; i=$(( i + 1 )); done
  i=0
  while [ $i -lt $empty ];  do bar="${bar}░"; i=$(( i + 1 )); done
  if [ "$used_int" -ge 80 ]; then
    ctx_str=" | \033[0;31m${bar} ${used_int}%\033[0m"
  else
    ctx_str=" | \033[0;90m${bar} ${used_int}%\033[0m"
  fi
else
  ctx_str=""
fi

# 현재 GitHub 이슈 (세션별 파일 우선, 없으면 공통 파일)
issue_str=""
git_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
base="${git_root:-$cwd}"
session_id=$(echo "$input" | jq -r '.session_id // empty')
if [ -n "$session_id" ] && [ -f "${base}/.claude/current-issue-${session_id}" ]; then
  issue_file="${base}/.claude/current-issue-${session_id}"
else
  issue_file="${base}/.claude/current-issue"
fi
if [ -f "$issue_file" ]; then
  issue_raw=$(cat "$issue_file")
  issue_num=$(echo "$issue_raw" | cut -d'|' -f1 | tr -d '[:space:]')
  issue_title=$(echo "$issue_raw" | cut -s -d'|' -f2-)
  if [ -n "$issue_title" ]; then
    short_title=$(echo "$issue_title" | cut -c1-20)
    [ ${#issue_title} -gt 20 ] && short_title="${short_title}…"
    issue_str=" | \033[0;35m#${issue_num} ${short_title}\033[0m"
  elif [ -n "$issue_num" ]; then
    issue_str=" | \033[0;35m#${issue_num}\033[0m"
  fi
fi

# git 브랜치 + dirty 표시
git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    if ! git -C "$cwd" diff --quiet 2>/dev/null || ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then
      branch="${branch}*"
    fi
    git_branch=" | \033[0;36m${branch}\033[0m"
  fi
fi

printf "\033[0;34m%s\033[0m%b%b | \033[0;33m%s\033[0m%b" \
  "$dir" "$git_branch" "$issue_str" "${model}" "${ctx_str}"
