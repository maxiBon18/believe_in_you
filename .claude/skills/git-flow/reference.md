# Git Flow — Conventional Commits Reference

## Tools

- `git` CLI
- `husky` — git hooks in `.husky/`
- `@commitlint/cli` + `@commitlint/config-conventional` — message validation, configured in `commitlint.config.js`

## Hooks that actually exist

Check `.husky/` rather than trusting this list if something behaves unexpectedly.

| Hook | Runs | Note |
| --- | --- | --- |
| `pre-commit` | `npm test` | `package.json`'s `test` script is currently empty, so this passes trivially. It is a placeholder for `fvm flutter test`, not a safety net — do not treat a green commit as a green suite. |
| `commit-msg` | `npx --no -- commitlint --edit "$1"` | Rejects a message that is not a valid Conventional Commit. |

There is no `post-commit` hook. Hooks fire from Git; never run them by hand, and never pass
`--no-verify`.

## Conventional Commits Format

```text
<type>(<scope>): <short description>

<body (optional)>

<footer (optional)>
```

## Allowed Types

| Type       | When to use                                   |
| ---------- | --------------------------------------------- |
| `feat`     | New user-visible behaviour                    |
| `fix`      | Bug fix                                       |
| `refactor` | Restructuring with no behaviour change        |
| `docs`     | Documentation, including `.claude/` config    |
| `test`     | Adding or changing tests only                 |
| `chore`    | Tooling, dependencies, build config           |
| `revert`   | Reverting a previous commit                   |

`config-conventional` accepts more types than this. The narrower list is a project convention, so commitlint will not catch a stray `style:` or `perf:` — you have to.

## Scope

Use the feature or module name as it exists under `lib/` (`CLAUDE.md` § Architecture), or `core` for
shared code and `config` for tooling and repo configuration. If more than one is involved, use the
most relevant.

## Rules

- Short description: imperative mood, lowercase, no trailing period, max 72 characters.
- Body: WHAT changed and WHY, not HOW. Wrap at 100 characters.
- Footer: `Refs: #123` for an issue.
- Breaking changes: `BREAKING CHANGE:` in the footer.
- Use the words the code uses. A commit that names a concept by a word the code does not use makes
  the history unsearchable by the term the code does use.

## What the body is for in this project

Most commits do not need one. These do:

- A change touching a data-integrity invariant — name the invariant and say which way it moved.
- A schema change or migration — say what the migration preserves.
- A change to a time boundary or to status derivation — say which boundary case moved.
- A deliberate non-fix, where the behaviour looks wrong and is specified.
