# Git Flow — Conventional Commits Reference

## Tools

- `git` CLI
- `husky` (git hooks in `.husky/`)
- `@commitlint/cli` (commit message validation)

## Conventional Commits Format

```
<type>(<scope>): <short description>

<body (optional)>

<footer (optional)>
```

## Allowed Types

| Type       | When to use                                |
| ---------- | ------------------------------------------ |
| `feat`     | New feature                                |
| `fix`      | Bug fix                                    |
| `refactor` | Code restructuring without behavior change |
| `docs`     | Documentation only                         |
| `revert`   | Reverting a previous commit                |

## Scope

- Use the feature or module name (e.g., `registration`, `auth`, `core`, `profile`).
- If multiple features are involved, use the most relevant one.

## Rules

- Short description: imperative mood, lowercase, no period, max 72 characters.
- Body: explain WHAT changed and WHY (not HOW), wrap at 100 characters.
- Footer: reference issue/ticket if available (e.g., `Refs: #123`).
- Breaking changes: add `BREAKING CHANGE:` in the footer.
- Husky hooks (`pre-commit`, `commit-msg`, `post-commit`) are triggered automatically by Git. Do NOT execute them manually.
- You MUST stop and ask for human confirmation at specific steps. Do NOT proceed to the next step without explicit user approval.

