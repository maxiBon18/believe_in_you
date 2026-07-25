---
name: code-review
description: "Run a structured code review on Dart files. Use when asked to review code, review a PR, check code quality, or audit changes in lib/**/*.dart. Covers architecture, code quality, null safety, widgets, state management, error handling, performance, security, responsiveness, and dependencies."
disable-model-invocation: true
---

# Code Review Skill

Run a structured, 10-area code review on modified Dart files and produce a prioritized report.

- For security, dependency, and output-format rules, see [reference.md](reference.md).
- For review output examples, see [examples.md](examples.md).

Every `dart`/`flutter` command in this skill takes the `fvm` prefix (see `CLAUDE.md`).

## Scope

- **Target files:** `lib/**/*.dart`
- **Exclude generated files:** skip `*.g.dart`, `*.freezed.dart`, `*.gen.dart`, `*.mocks.dart`, and files with a `// GENERATED CODE` header.

## Severity Levels

- **✅ Passed** — compliant.
- **⚠️ Warning** — suggestion, non-blocking.
- **🔴 Violation** — must fix before push.

## Instructions

### Step 1 — Identify files in scope

- Determine which `.dart` files in `lib/` are modified or under review.
- Exclude generated files (see Scope above).
- If you are unsure which files to review, ask the user for a list and review those.
- Stop conditions:
  - If all files are generated, stop and report: "All target files are generated — no review needed."
  - If no files are in scope, stop and report: "No reviewable Dart files found."

### Step 2 — Architecture & layer separation

- Read `CLAUDE.md` §§ Architecture, Dependency rule, Where things live.
- Verify each file respects layer boundaries (data, domain, presentation) and the inward
  dependency direction.

### Step 3 — Dart code quality

- Read `.claude/rules/code/coding-conventions.md`.
- Check naming, typing, immutability, size limits, and general Dart idioms.

### Step 4 — Null safety

- Read `.claude/rules/code/coding-conventions.md` § Null safety.
- Verify no unnecessary nullable types, no `!` force-unwraps without a documented reason, and
  correct null-aware operator usage.

### Step 5 — Flutter widget quality

- Read `.claude/rules/code/presentation-layer-rules.md` §§ Naming and placement, Composition.
- Check widget decomposition, `const` constructors, `Key` usage, and `build()` complexity.

### Step 6 — State management (Riverpod)

- Read `.claude/rules/code/viewmodel-rules.md` § Riverpod.
- Verify provider lifetime, `ref.watch` vs `ref.read`, `AsyncValue` modeling, and async-gap guards.

### Step 7 — Error handling

- Read `.claude/rules/code/coding-conventions.md` § Error handling.
- Additionally verify every user-facing error produces UI feedback (dialog, snackbar, or error widget).

### Step 8 — Performance

- Read `.claude/rules/code/presentation-layer-rules.md` § Performance.
- Check for unnecessary rebuilds, missing `const`, and expensive work in build methods.

### Step 9 — Security

- Apply the security rules in [reference.md](reference.md) § Security.
- Check for hardcoded credentials, sensitive data in logs, unsanitized input, and unencrypted
  persisted data.

### Step 10 — Platform & responsiveness

- Read `.claude/rules/code/presentation-layer-rules.md` § Responsive and accessible.
- Check for hardcoded dimensions, missing adaptive layouts, and platform-specific assumptions.

### Step 11 — Dependencies & imports

- Apply the rules in [reference.md](reference.md) § Dependencies & Imports.
- Check import order, unused dependencies, circular dependencies, and unjustified new packages.

### Step 12 — Produce report

- Generate the output following [reference.md](reference.md) § Output Format.
- Use [examples.md](examples.md) to calibrate structure and level of detail.
- List the summary table first, then every 🔴 Violation with file, line, rule violated, and
  suggested fix, then every ⚠️ Warning.
- If no violations or warnings exist, state "All checks passed" and briefly list what was verified.
