---
name: dart-review
description: "Run a structured 12-area code review on Mood Diary Dart files. Use when asked to review code, check code quality, or audit changes in lib/**/*.dart. Covers data integrity, architecture, time correctness, code quality, null safety, widgets, state management, error handling, performance, privacy, accessibility, and dependencies."
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash
---

# Dart Review Skill

Run a structured, 12-area code review on modified Dart files and produce a prioritized report.

- For privacy, dependency, and output-format rules, see [reference.md](reference.md).
- For review output examples, see [examples.md](examples.md).

Every `dart`/`flutter` command in this skill takes the `fvm` prefix (see `CLAUDE.md`).

## Scope

- **Target files:** `lib/**/*.dart`
- **Exclude generated files:** skip `*.g.dart`, `*.freezed.dart`, `*.drift.dart`, `*.gen.dart`,
  `*.mocks.dart`, and files with a `// GENERATED CODE` header.

## Severity Levels

- **✅ Passed** — compliant.
- **⚠️ Warning** — suggestion, non-blocking.
- **🔴 Violation** — must fix before push.

**Data-integrity findings are always 🔴.** They are never downgraded to a warning, never deferred,
and never accepted with a TODO. The output of this app is read by a clinician; a fabricated or
distorted value is a correctness bug of the most serious kind. See `data-integrity-rules.md`.

## Instructions

### Step 1 — Identify files in scope

- Determine which `.dart` files in `lib/` are modified or under review.
- Exclude generated files (see Scope above).
- If you are unsure which files to review, ask the user for a list and review those.
- Run `fvm dart analyze` once, before reading anything. Everything it reports is already known —
  do not re-report lint findings as review findings. This review is for what the analyzer cannot
  see. A file that does not analyze cleanly is reported as one line and reviewed anyway.
- Stop conditions:
  - If all files are generated, stop and report: "All target files are generated — no review needed."
  - If no files are in scope, stop and report: "No reviewable Dart files found."

### Step 2 — Data integrity

**Run this first.** It is the area where a finding blocks everything else, so there is no point
reviewing formatting in a file that fabricates a mood value.

- Read `.claude/rules/code/data-integrity-rules.md`.
- Check every one of the eight invariants against the files in scope. The recurring shapes are:
  - `??` or a default parameter supplying a scale, emotion set, or timestamp
  - a read path that writes — row creation during a fetch, an upsert inside a query
  - a persisted `status`, or a stored `skipped`/`backfilled` flag
  - missing values treated as zero in an average, or a chart interpolating across a gap
  - a save path still reachable after the window has closed
  - streak counters, progress rings, celebratory or admonishing copy
  - anything with a transport dependency
  - a migration that drops or recreates without copying

### Step 3 — Architecture & layer separation

- Read `CLAUDE.md` §§ Architecture, Dependency rule, Where things live.
- Verify each file respects layer boundaries (data, domain, presentation) and the inward dependency
  direction. Check specifically that domain logic — window computation, status derivation,
  averaging — has not migrated into a ViewModel or a widget.
- If the file navigates, read `.claude/rules/code/routing-rules.md`. Flag any `Navigator.push` with
  a widget literal, any `MaterialPageRoute` outside the router, any `AppRouter` held by a ViewModel,
  and any `default` branch in a `switch` over `AppRoute`.

### Step 4 — Time correctness

- Read `CLAUDE.md` § Time handling and `.claude/rules/code/domain-layer-rules.md` § Services.
- Verify no `DateTime.now()`, `DateTime.timestamp()`, or bare `Timer` in `domain/` or `data/`, and
  none in a ViewModel used to decide slot state — instants arrive as parameters.
- Flag anything that introduces a time-source abstraction: that decision is open and confirm-first.
- Verify window arithmetic uses local wall-clock time and that the IANA timezone is carried.
- Flag any comparison between timestamps from different zones without normalization.

### Step 5 — Dart code quality

- Read `.claude/rules/code/coding-conventions.md`.
- Check naming, typing, immutability, size limits, and general Dart idioms.
- Verify sealed types — slot status above all — are handled with exhaustive `switch`, not `if`
  chains, and that no `default` branch swallows a new variant.

### Step 6 — Null safety

- Read `.claude/rules/code/coding-conventions.md` § Null safety.
- Verify no unnecessary nullable types, no `!` force-unwraps without a documented reason, and
  correct null-aware operator usage.
- A `??` supplying a recorded value is a data-integrity violation, not a null-safety warning —
  report it under Step 2.

### Step 7 — Flutter widget quality

- Read `.claude/rules/code/presentation-layer-rules.md` §§ Naming and placement, Composition.
- Check widget decomposition, `const` constructors, `Key` usage, and `build()` complexity.

### Step 8 — State management (Riverpod)

- Read `.claude/rules/code/viewmodel-rules.md`.
- Verify provider lifetime, `ref.watch` vs `ref.read`, `AsyncValue` modeling, and async-gap guards.
- Flag any Riverpod code generation: `@riverpod` / `@Riverpod`, a `_$` notifier superclass, or a
  `part '*.g.dart';` in a ViewModel. Providers are declared by hand in this project.
- Check the entry ViewModel rules specifically: explicit save, no autosave, no optimistic clear, no
  default scale in initial state.

### Step 9 — Error handling

- Read `.claude/rules/code/coding-conventions.md` § Error handling.
- Verify every user-facing error produces UI feedback (dialog, snackbar, or error widget).
- Verify a failed save leaves the form intact and retryable rather than silently discarding input.

### Step 10 — Performance

- Read `.claude/rules/code/presentation-layer-rules.md` § Performance.
- Check for unnecessary rebuilds, missing `const`, aggregation inside `build()`, and anything
  blocking on the path to first frame — cold start is part of the 20-second entry budget.

### Step 11 — Privacy & security

- Apply the rules in [reference.md](reference.md) § Privacy & Security.
- Check for secrets, unguarded note text or scale values in logs (a `kDebugMode` guard clears the
  line), unencrypted persistence, and any package that could carry data off-device.

### Step 12 — Accessibility & responsiveness

- Read `.claude/rules/code/presentation-layer-rules.md` § Responsive and accessible.
- Check text scaling on the scale selector and emotion chips, 48x48 targets, semantics on the scale
  faces, and that colour is never the sole carrier of meaning.
- Flag any red-to-green mood ramp — see reference.md § Privacy & Security for why it is reviewed
  here rather than treated as styling.

### Step 13 — Dependencies & imports

- Apply the rules in [reference.md](reference.md) § Dependencies & Imports.
- Check import order, unused dependencies, circular dependencies, and unjustified new packages.

### Step 14 — Produce report

Read [reference.md](reference.md) § Output Format and follow it. Read [examples.md](examples.md)
here — not earlier — to calibrate depth; it is only useful once there are findings to write up.

If no violations or warnings exist, state "All checks passed" and briefly list what was verified.