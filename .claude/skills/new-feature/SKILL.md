---
name: new-feature
description: "Scaffold the Clean Architecture directories for a new feature under lib/ and test/. Use when asked to create a new feature module or set up a feature's folder structure."
disable-model-invocation: true
---

# New Feature Skill

Scaffold a new feature directory structure using the project's Clean Architecture template.

Creating a feature module is **confirm-first**. Step 1 is that confirmation — do not
skip it because the feature name is already obvious from the conversation.

## Step 1 — Get and check the feature name

### 🛑 STOP — Human Input

Ask: "What is the name of the new feature?"

The feature name:

- MUST NOT be empty.
- MUST be `snake_case`.
- MUST NOT match an existing directory in `lib/`.

## Step 2 — Create directories

Run from the project root:

```bash
bash .claude/skills/new-feature/scripts/create_clean_arch_folders.sh <feature_name>
```

The script creates the `lib/<feature>/` tree, a mirrored `test/<feature>/` tree, and the shared
`assets/` directories. Each leaf gets a `.gitkeep`, because Git does not track empty directories and
the scaffold would otherwise not survive a commit.

## Step 3 — Confirm

Show the created directory tree:

```bash
find lib/<feature_name> test/<feature_name> -type d | sort
```

## Step 4 — Say what is not done

The scaffold is directories only. Name what still needs a decision rather than filling it in:

- DI registration in `lib/<feature>/shared/controllers/di.dart` (`di-rules.md`).
- Route configs, if the feature has a destination — confirm-first (`routing-rules.md`).
- Whether any domain service here carries a data-integrity invariant
  (`data-integrity-rules.md`, `CLAUDE.md` § Invariants).
