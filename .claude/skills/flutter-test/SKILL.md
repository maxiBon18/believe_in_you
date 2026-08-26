---
name: flutter-test
description: "Analyze the Mood Diary app, build a test plan with rationale, get approval, then execute unit/widget/integration tests selectively. Use when asked to write tests, add test coverage, or build a test plan for Dart/Flutter code."
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

# Flutter Test Skill

Test plan → approval → execution. Only approved tests run.

Every `dart`/`flutter` command in this skill takes the `fvm` prefix (see `CLAUDE.md`). Structure
conventions are authoritative in `.claude/rules/code/testing-rules.md` — follow it where it and this
skill overlap. In particular, `test/` **mirrors `lib/`**; do not create `test/unit/`, `test/widget/`
trees.

- Testing rules & selection logic: [reference.md](reference.md)
- Plan & test case format: [examples.md](examples.md)

## Step 1 — Scan project

1. `find lib -type f -name "*.dart" | head -80`
2. `find test -type f -name "*.dart" 2>/dev/null | head -40`
3. `find integration_test -type f -name "*.dart" 2>/dev/null | head -20`
4. Read `pubspec.yaml` → confirm Riverpod version, Drift, and test deps.
   `pubspec.yaml` may still be the Flutter starter template with none of them present. That is not
   a blocker for planning — plan against the architecture, and let STOP 2 surface everything the
   plan needs installed. Do not silently reduce the plan to what happens to be installed.
   Riverpod ViewModels are tested with `ProviderContainer.test()` and provider overrides, not by
   mocking `ref` (see `.claude/rules/code/testing-rules.md`).

## Step 2 — Determine scope

- User specified features → scope to those.
- User said "test everything" → scan `lib/`, identify all testable units.
- Read source code of in-scope items: public API, dependencies, UI components, user flows.

## Step 3 — Clarify (if needed)

Stop and ask if ANY is unclear:

- Which features/modules to test (and priority order)?
- Critical user flows requiring integration tests?
- Existing test conventions to follow?
- Features to exclude?

## Step 4 — Select test types

Apply the **Selection Matrix** from [reference.md](reference.md) per feature. Include only justified
types. Document excluded types with reason.

## Step 5 — Generate test plan

Build the plan following the format in [examples.md](examples.md). Every test case needs: ID, Type,
Target, Description, **Rationale** (mandatory — what breaks without this test), Dependencies,
Priority.

For each feature, explicitly analyze **edge cases** using the Edge Case Checklist in
[reference.md](reference.md). Tag edge case IDs with suffix `-E`.

### Mandatory invariant coverage

Any plan touching entry, summary, or persistence **must** include the invariant suite in
[reference.md](reference.md) § Invariant suite. These are not optional and are not negotiable down
during plan review — they encode the rules in `data-integrity-rules.md`, which are the ones a future
refactor will quietly break. If a plan omits them, add them before presenting it.

### 🛑 STOP 1 — Approve Plan

Present the plan. Ask:

- **approve** → proceed to Step 6.
- **edit** → modify, re-present for approval.
- **reject** → abort.

Do NOT write test code before approval.

## Step 6 — Verify infrastructure

1. Check `dev_dependencies` for ALL packages required by the test plan.
2. Compare required vs. present. If ANY package is missing:

### 🛑 STOP 2 — Missing Packages

List every missing package with name, version, and which test cases require it.

Ask: **"These packages are required. Add them to pubspec.yaml? (y/n)"**

- **y** → add via `fvm flutter pub add dev:<package>` (which runs pub get), then proceed.
- **n** → remove dependent test cases from the plan, re-present the reduced plan for approval (go
  back to STOP 1).

Do NOT install packages without user approval. A package that transmits data is refused outright,
even in `dev_dependencies` — see `data-integrity-rules.md` § 6.

After STOP 2 resolves:

3. Verify `test/` and `integration_test/` dirs exist. Create with confirmation if needed.
4. Time-dependent cases are driven by instants the test declares and passes in. Do not add a
   time-source package or helper — that decision is open (`CLAUDE.md` § Time handling).

## Step 7 — Write tests

Order: **Unit → Widget → Integration.**

- Mirror `lib/` structure exactly, per `.claude/rules/code/testing-rules.md`.
- Use `group()`, Arrange-Act-Assert, descriptive names
  (`'returns skipped once the window has closed'`).
- Comment the test plan ID above each test: `// UT-001`.
- Every time-dependent test supplies its own instants. No `Future.delayed` to cross a boundary, no
  real `DateTime.now()`.
- Mocking strategy per [reference.md](reference.md).

## Step 8 — Execute

Run in order, narrowing to the directories in scope:

```bash
fvm flutter test test/ --reporter expanded
fvm flutter test integration_test/ --reporter expanded
```

On failure → stop, report details, ask: fix / skip / abort.

**Never make a failing invariant test pass by changing the assertion.** If an invariant test fails,
the code is wrong, not the test. Report it and stop.

## Step 9 — Report

### 🛑 STOP 3 — Final Report

| Type        | Total | Pass | Fail | Skip |
| ----------- | ----- | ---- | ---- | ---- |
| Unit        | x     | x    | x    | x    |
| Widget      | x     | x    | x    | x    |
| Integration | x     | x    | x    | x    |

List: failed tests (ID + reason + fix), coverage gaps, recommendations. State explicitly whether the
invariant suite passed — that line goes first, before the table.
