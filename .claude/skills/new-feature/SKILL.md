---
name: new-feature
description: "Create all directories for a new feature following Clean Architecture"
disable-model-invocation: true
---

# New Feature Skill

Scaffold a new feature directory structure using the project's Clean Architecture template.

## Instructions

### Step 1 — Get feature name

#### 🛑 STOP — Human Input

Ask the user: "What is the name of the new feature? (e.g., `payment`, `profile`, `settings`)"

The feature name:
- MUST NOT be empty.
- MUST be `snake_case`.
- MUST NOT match an existing directory in `lib/`.

### Step 2 — Create directories

Run from the project root:

```bash
bash .claude/skills/new-feature/scripts/create_clean_arch_folders.sh <feature_name>
```

Replace `<feature_name>` with the user's input.

### Step 3 — Confirm

Show the created directory tree:

```bash
find lib/<feature_name> -type d | sort
```
