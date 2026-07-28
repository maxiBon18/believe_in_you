---
name: git-flow
description: "Stage, commit, and push following Conventional Commits, with human approval before the commit and before the push. Use when asked to commit changes, write a commit message, or push work."
disable-model-invocation: true
---

# Git Flow Skill

Stage → approve message → commit → approve push → push. Two hard stops, neither skippable.

- Conventional Commits rules: [reference.md](reference.md)
- Commit message examples from this project: [examples.md](examples.md)

## Commit Message Format

```text
<type>(<scope>): <short description>

<body (optional)>

<footer (optional)>
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `revert`.
Scope: feature or module name — `entry`, `history`, `export`, `settings`, `onboarding`, `core` examples.

## Instructions

### Step 1 — Confirm the repository and stage

- Run `git rev-parse --show-toplevel` and confirm it is the `believe_in_you` project root. If it is
  not, stop.
- Run `git status --short` **before staging**. If anything unexpected is untracked — build output,
  `.env`, an editor scratch file, a database dump — list it and ask before continuing. `git add .`
  stages whatever is there, and `.gitignore` does not cover files nobody has thought about yet.
- Stage with `git add .` from the project root once that check is clean.

### Step 2 — Analyze changes

- `git status` — staged files.
- `git diff --cached --stat` — summary.
- `git diff --cached` — the actual changes. Read them; the message describes what happened, not
  what was asked for.

### Step 3 — Generate commit message

- Follow the format above and the rules in [reference.md](reference.md).
- If the diff touches a data-integrity invariant or a migration, say so in the body. That is the
  line a future bisect is looking for.

#### 🛑 STOP 1 — Human Review (Commit Message)

**Stop and show the generated commit message to the user.**
Ask: "Do you approve this commit message? (y / edit / n)"

- **y** → proceed to Step 4.
- **edit** → ask what to change, regenerate, and stop again for approval.
- **n** → abort the flow. Leave the changes staged.

### Step 4 — Execute commit

- Run `git commit -m "<approved_message>"` (use repeated `-m` for the body rather than embedding
  newlines).
- Two Husky hooks run automatically. Do not invoke either by hand:
  1. `pre-commit` → `npm test`.
  2. `commit-msg` → `commitlint --edit`, validating the message against
     `@commitlint/config-conventional`.
- If a hook fails, show its output verbatim and stop. A commitlint failure means the message is
  malformed — fix the message, do not bypass the hook. Never pass `--no-verify`.

#### 🛑 STOP 2 — Human Review (Pre-Push)

**Stop and show the commit result.**
Run `git log --oneline -1`.
Ask: "Ready to push to `origin`? (y / n)"

- **y** → proceed to Step 5.
- **n** → abort. The commit stays local.

### Step 5 — Push

- Run `git push`. If the branch has no upstream, use
  `git push --set-upstream origin <branch>` and say which branch you set it on.
- Show the result. If the push is rejected, show the error and stop — do not force-push, and do not
  rebase without asking.
