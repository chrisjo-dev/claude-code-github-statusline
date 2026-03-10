# claude-code-github-statusline

Claude Code statusline that automatically tracks your current GitHub issue.

```
pakatalk | main* | #43 관리자 질문 뱅크 CR… | S4.6 | ▓▓░░░░░░░░ 20%
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
