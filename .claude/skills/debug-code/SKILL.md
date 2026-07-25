---
name: debug-code
description: "Diagnose and fix bugs in a Flutter/Dart project. Use when the user reports a bug, error, crash, unexpected behavior, or asks to debug an issue. Requires a problem description; optionally accepts error messages, stack traces, and screenshots."
disable-model-invocation: true
---

# Debug Skill

Diagnose a reported bug, identify the root cause, and produce a fix with minimal codebase scanning.

- For diagnostic strategy, see [reference.md](reference.md).
- For expected output format, see [examples.md](examples.md).

## User Input

| Input               | Required | Description                                                |
| ------------------- | -------- | ---------------------------------------------------------- |
| Problem description | **Yes**  | What the user expects vs. what actually happens.           |
| Error + stack trace | No       | Console error, exception, or `fvm dart analyze` output.    |
| Screenshot          | No       | Visual evidence of the bug (UI glitch, wrong state, etc.). |

## Scope

- **Target:** full project — `lib/**/*.dart`, `test/**/*.dart`, scripts, configuration files.

## Instructions

### Step 1 — Validate input

- Confirm the user has provided a problem description. If missing, stop and ask:
  "Describe the problem: what do you expect to happen, and what actually happens?"
- Note whether an error/stack trace and/or screenshot were provided.

### Step 2 — Ask for suspect files

- **Before scanning anything**, ask the user:
  "Do you already know which files are involved? If so, list them."
- **If the user provides files** → read only those files. Go to Step 4.
- **If the user says no or is unsure** → proceed to Step 3.

### Step 3 — Progressive file scanning

Scan **one level at a time**. Stop as soon as the root cause is identified.

**Level 1 — Extract from error context:**
- **If stack trace provided:** extract project file paths from the stack frames (ignore framework/package frames). Read only those files.
- **If screenshot provided but no stack trace:** analyze the visual evidence to infer the screen/widget involved. Use `Grep` to locate the matching widget class. Read only that file.
- **If neither provided:** use the problem description to search for relevant symbols with `Grep`. Read the top 1–3 matching files.
- Attempt diagnosis. If found → go to Step 4.

**Level 2 — Imports of suspect files:**
- Read the `import` statements of the files from Level 1.
- Read only the imported project files (skip `dart:`, `package:flutter/`, third-party packages).
- Attempt diagnosis. If found → go to Step 4.

**Level 3 — Broader search (last resort):**
- Only if Level 2 failed to identify the root cause.
- Use `Grep` and `Glob` to search for related symbols, providers, or error messages across the project.
- Read the minimum number of files needed to complete the diagnosis.
- If the root cause still cannot be determined, stop and ask the user for:
  - Steps to reproduce.
  - Device/platform details.
  - Additional logs or context.

### Step 4 — Diagnose root cause

- Identify the single root cause. If multiple issues contribute, rank by impact (primary cause first).

### Step 5 — Produce fix

- Write the minimal code change that resolves the root cause.
- Apply the fix using `Edit`.
- If the fix touches multiple files, apply changes in dependency order (deepest layer first).

### Step 6 — Verify

- Run `fvm dart analyze` to confirm no new issues introduced.
- If test files exist for the modified code, run `fvm flutter test <relevant_test_file>`.
- If verification fails, revise the fix and re-verify.

### Step 7 — Report

- Produce the output following the format in [examples.md](examples.md).
- The report must contain exactly two sections:
  1. **Root Cause** — 1–2 sentences. What is broken and why.
  2. **Fix** — brief explanation of what was changed, which files were modified, and why this resolves the issue.
- Append a **Files Read** count so the user can see the scanning cost.