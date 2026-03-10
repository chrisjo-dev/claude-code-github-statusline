[English](#english) | [한국어](#한국어)

---

## English

# claude-code-github-statusline

Claude Code statusline that automatically tracks your current GitHub issue.

**Before**
```
chris@MacBook:pakatalk | main | Claude Sonnet 4.6 | ctx:12%
```

**After**
```
pakatalk | main* | #43 Fix login redirect loop | S4.6 | ▓▓░░░░░░░░ 12%
```

## Features

- **GitHub issue tracking** — mention an issue in chat and it appears in the statusline
- **Issue title fetch** — uses `gh` CLI to show the issue title (not just number)
- **Multi-session support** — multiple Claude windows on the same project each track their own issue
- **Context progress bar** — visual context usage with red warning at 80%+
- **Git dirty indicator** — `main*` when there are uncommitted changes
- **Short model name** — `S4.6` instead of `Claude Sonnet 4.6`

## Requirements

- [Claude Code](https://claude.ai/code)
- `jq` — `brew install jq`
- `gh` CLI (optional, for issue titles) — `brew install gh && gh auth login`

## Install

```sh
curl -sSL https://raw.githubusercontent.com/chrisjo-dev/claude-code-github-statusline/main/install.sh | bash
```

Then **restart Claude Code**.

## Uninstall

```sh
curl -sSL https://raw.githubusercontent.com/chrisjo-dev/claude-code-github-statusline/main/uninstall.sh | bash
```

## How it works

A `UserPromptSubmit` hook scans every message for issue references:

| Pattern | Example |
|--------|---------|
| GitHub URL | `https://github.com/owner/repo/issues/43` |
| Hash number | `#43` |
| Korean/English | `이슈 43` / `Issue 43` |

When detected, the issue number (and title via `gh`) is saved to `.claude/current-issue-{session_id}` in your project root. The statusline reads this file on each render.

## Clearing the current issue

```sh
rm .claude/current-issue*
```

---

## 한국어

# claude-code-github-statusline

현재 작업 중인 GitHub 이슈를 자동으로 Claude Code 상태바에 표시해주는 도구입니다.

**Before**
```
chris@MacBook:pakatalk | main | Claude Sonnet 4.6 | ctx:12%
```

**After**
```
pakatalk | main* | #43 Fix login redirect loop | S4.6 | ▓▓░░░░░░░░ 12%
```

## 기능

- **GitHub 이슈 추적** — 대화에서 이슈를 언급하면 상태바에 자동으로 표시
- **이슈 제목 표시** — `gh` CLI로 이슈 번호뿐 아니라 제목도 함께 표시
- **멀티 세션 지원** — 같은 프로젝트에서 여러 Claude 창을 열어도 각자 별도 이슈 추적
- **컨텍스트 프로그레스 바** — 컨텍스트 사용량 시각화, 80% 초과 시 빨간색 경고
- **Git dirty 표시** — 미커밋 변경사항 있으면 `main*` 으로 표시
- **모델명 단축** — `Claude Sonnet 4.6` → `S4.6`

## 필요 사항

- [Claude Code](https://claude.ai/code)
- `jq` — `brew install jq`
- `gh` CLI (선택, 이슈 제목 표시용) — `brew install gh && gh auth login`

## 설치

```sh
curl -sSL https://raw.githubusercontent.com/chrisjo-dev/claude-code-github-statusline/main/install.sh | bash
```

설치 후 **Claude Code를 재시작**하세요.

## 제거

```sh
curl -sSL https://raw.githubusercontent.com/chrisjo-dev/claude-code-github-statusline/main/uninstall.sh | bash
```

## 동작 방식

`UserPromptSubmit` 훅이 매 메시지마다 이슈 번호 패턴을 감지합니다:

| 패턴 | 예시 |
|------|------|
| GitHub URL | `https://github.com/owner/repo/issues/43` |
| 해시 번호 | `#43` |
| 한국어/영어 | `이슈 43` / `Issue 43` |

감지된 이슈 번호와 제목(`gh` 사용)은 프로젝트 루트의 `.claude/current-issue-{session_id}` 파일에 저장되며, 상태바가 렌더링될 때마다 이 파일을 읽어 표시합니다.

## 현재 이슈 초기화

```sh
rm .claude/current-issue*
```
