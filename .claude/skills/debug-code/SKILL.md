---
name: debug-code
description: "Diagnose and fix bugs in this Flutter project. Use when the user reports a bug, error, crash, unexpected behavior, or asks to debug an issue. Requires a problem description; optionally accepts error messages, stack traces, and screenshots."
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Edit, Bash
---

# Debug Skill

Diagnose a reported bug, identify the root cause, and produce a fix with minimal codebase scanning.

- For diagnostic strategy and this project's common failure modes, see [reference.md](reference.md).
- For expected output format, see [examples.md](examples.md).

## User Input

| Input               | Required | Description                                                |
| ------------------- | -------- | ---------------------------------------------------------- |
| Problem description | **Yes**  | What the user expects vs. what actually happens.           |
| Error + stack trace | No       | Console error, exception, or `fvm dart analyze` output.    |
| Screenshot          | No       | Visual evidence of the bug (UI glitch, wrong state, etc.). |
| Time and context    | No       | When it happened, and which time range or record — often decisive here. |

## Scope

- **Target:** full project — `lib/**/*.dart`, `test/**/*.dart`, scripts, configuration files.

## Instructions

### Step 1 — Validate input

- Confirm the user has provided a problem description. If missing, stop and ask:
  "Describe the problem: what do you expect to happen, and what actually happens?"
- Note whether an error/stack trace and/or screenshot were provided.

### Step 2 — Check whether this is intended behaviour

**Run this before scanning anything.** A significant share of reports in this project describe
invariants working correctly, and the right output is an explanation, not a fix.

Read `.claude/rules/code/data-integrity-rules.md` and `CLAUDE.md` § Invariants, and check the report
against both. The recurring shapes:

| Report | Verdict |
| --- | --- |
| "The line breaks where I have no data" | Intended — § 4. Gaps are never bridged. |
| "I can't enter something after the fact" | Intended if the project forbids retroactive writes — `CLAUDE.md` § Invariants. |
| "It won't let me correct an earlier value" | Intended once the write path has closed for it. |
| "The first period shows less than a full one" | Intended — what was never available is not something the user skipped. |
| "There's no streak counter / progress score" | Intended if the project excludes evaluative feedback — `CLAUDE.md` § Invariants. |
| "A partial period looks like a full one" | Bug **only** if the partial marker is missing. The aggregate itself is correct — § 4. |

If the report is intended behaviour, stop and say so, citing the rule. Offer the underlying
reasoning, not just the rule number — the user wrote the rule and may still be right that the
*presentation* needs work even when the *behaviour* does not.

### Step 3 — Ask for suspect files

- Ask the user: "Do you already know which files are involved? If so, list them."
- **If the user provides files** → read only those files. Go to Step 5.
- **If the user says no or is unsure** → proceed to Step 4.

### Step 4 — Progressive file scanning

Scan **one level at a time**. Stop as soon as the root cause is identified.

**Level 0 — Match against known failure modes:**

- Read [reference.md](reference.md) § Common failure modes. Most bugs in this app fall into one of
  seven categories, each with a small, known set of files. If the symptom matches a category, read
  those files first — this is usually cheaper than following a stack trace.

**Level 1 — Extract from error context:**

- **If stack trace provided:** extract project file paths from the stack frames (ignore
  framework/package frames). Read only those files.
- **If screenshot provided but no stack trace:** infer the screen involved. Use `Grep` to locate the
  matching widget class. Read only that file.
- **If neither provided:** search for relevant symbols with `Grep`. Read the top 1–3 matches.
- Attempt diagnosis. If found → go to Step 5.

**Level 2 — Imports of suspect files:**

- Read the `import` statements of the files from Level 1.
- Read only the imported project files (skip `dart:`, `package:flutter/`, third-party packages).
- Attempt diagnosis. If found → go to Step 5.

**Level 3 — Broader search (last resort):**

- Only if Level 2 failed.
- Use `Grep` and `Glob` to search for related symbols, providers, or error messages.
- Read the minimum number of files needed to complete the diagnosis.
- If the root cause still cannot be determined, stop and ask the user for:
  - Steps to reproduce, **including the time of day and which record or range**.
  - Device/platform details, and whether the device timezone changed.
  - Additional logs or context.

### Step 5 — Diagnose root cause

- Identify the single root cause. If multiple issues contribute, rank by impact (primary first).
- For any time-dependent symptom, state the boundary involved explicitly — which range, which side
  of it, which configuration was in effect.

### Step 6 — Assess data impact

Before writing a fix, answer: **did this bug write, alter, or destroy user data?**

- If yes, say so prominently in the report. A fix that stops future corruption does not repair rows
  already written, and the user needs to know which dates are affected before they act on anything
  the app generated from them.
- If a repair is needed, propose it separately from the fix and **do not run it without approval**.
- Never repair by inventing a plausible value. A corrupted record is deleted, not corrected.

### Step 7 — Produce fix

- Write the minimal code change that resolves the root cause.
- Apply the fix using `Edit`.
- If the fix touches multiple files, apply changes in dependency order (deepest layer first).
- **Never fix a bug by weakening an invariant.** If the only apparent fix relaxes a rule in
  `data-integrity-rules.md`, stop and raise it instead — the design is wrong somewhere else.
- A schema or migration change is confirm-first. Do not apply one silently.

### Step 8 — Verify

- Run `fvm dart analyze` to confirm no new issues introduced.
- If test files exist for the modified code, run `fvm flutter test <relevant_test_file>`.
- **Add a failing test first for any time-dependent bug**, driving the instants it needs, before
  applying the fix. A boundary bug that is not covered will come back.
- If verification fails, revise the fix and re-verify.

### Step 9 — Report

- Produce the output following the format in [examples.md](examples.md).
- The report contains:
  1. **Root Cause** — 1–2 sentences. What is broken and why.
  2. **Data Impact** — whether any user data was written, altered, or lost. State "none" explicitly
     if none; do not omit the section.
  3. **Fix** — what changed, which files, and why this resolves it.
- Append a **Files Read** count so the user can see the scanning cost.
