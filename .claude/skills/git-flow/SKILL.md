---
name: git-flow
description: "Automate git add, commit, and push following Conventional Commits with human review steps"
disable-model-invocation: true
---

# Git Flow Skill

Automate the git add, commit, and push flow with AI-generated commit messages.

- For detailed Conventional Commits rules, see [reference.md](reference.md)
- For commit message examples, see [examples.md](examples.md)

## Commit Message Format

```text
<type>(<scope>): <short description>

<body (optional)>

<footer (optional)>
```

Allowed types: `feat`, `fix`, `refactor`, `docs`, `revert`.
Scope: feature or module name (e.g., `registration`, `auth`, `core`).

## Instructions

### Step 1 — Stage files

- Run `git add .` from the project root **ONLY FOR believe_in_you git**.

### Step 2 — Analyze changes

- Run `git status` to see staged files.
- Run `git diff --cached --stat` for a summary.
- Run `git diff --cached` to read the actual changes.

### Step 3 — Generate commit message

- Based on the diff, generate a commit message following the format above and the rules in [reference.md](reference.md).

#### 🛑 STOP 1 — Human Review (Commit Message)

**Stop and show the generated commit message to the user.**
Ask: "Do you approve this commit message? (y/edit/n)"

- **y** → proceed to Step 4.
- **edit** → ask what to change, regenerate, and stop again for approval.
- **n** → abort the flow.

### Step 4 — Execute commit

- Run `git commit -m "<approved_message>"`.
- Husky hooks execute automatically:
  1. `commit-msg` → commitlint validation.
  2. `post-commit` → notification with commit result.
- If any hook fails, show the error and stop.

#### 🛑 STOP 2 — Human Review (Pre-Push)

**Stop and show the commit result.**
Run `git log --oneline -1` to display the committed change.
Ask: "Ready to push to remote? (y/n)"

- **y** → proceed to Step 5.
- **n** → abort (commit preserved locally).

### Step 5 — Push

- Run `git push`.
- Show the push result.
- If push fails (e.g., conflicts), show the error and stop.
