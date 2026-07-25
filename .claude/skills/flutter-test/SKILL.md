---
name: flutter-test
description: "Analyze a Flutter app, build a test plan with rationale, get approval, then execute unit/widget/integration tests selectively. Use when asked to write tests, add test coverage, or build a test plan for Dart/Flutter code."
disable-model-invocation: true
---

# Flutter Test Skill

Test plan → approval → execution. Only approved tests run.

Every `dart`/`flutter` command in this skill takes the `fvm` prefix (see `CLAUDE.md`). Structure
conventions are authoritative in `.claude/rules/code/testing-rules.md` — follow it where it and
this skill overlap.

- Testing rules & selection logic: [reference.md](reference.md)
- Plan & test case format: [examples.md](examples.md)

## Step 1 — Scan project

1. `find lib -type f -name "*.dart" | head -80`
2. `find test -type f -name "*.dart" 2>/dev/null | head -40`
3. `find integration_test -type f -name "*.dart" 2>/dev/null | head -20`
4. Read `pubspec.yaml` → identify state management (Riverpod), test deps, key packages.
   Riverpod ViewModels are tested with `ProviderContainer.test()` and provider overrides, not by
   mocking `ref` (see `.claude/rules/code/testing-rules.md`).

## Step 2 — Determine scope

- User specified features → scope to those.
- User said "test everything" → scan `lib/`, identify all testable units.
- Read source code of in-scope items: public API, dependencies, UI components, user flows.

## Step 3 — Clarify (if needed)

Stop and ask if ANY is unclear:
- Which features/modules to test (and priority order)?
- External services to mock?
- Critical user flows requiring integration tests?
- Existing test conventions to follow?
- Features to exclude?

## Step 4 — Select test types

Apply the **Selection Matrix** from [reference.md](reference.md) per feature. Include only justified types. Document excluded types with reason.

## Step 5 — Generate test plan

Build plan following format in [examples.md](examples.md). Every test case needs: ID, Type, Target, Description, **Rationale** (mandatory — what breaks without this test), Dependencies, Priority.

For each feature, explicitly analyze **edge cases** using the Edge Case Checklist in [reference.md](reference.md). Edge case tests MUST be included in the plan with rationale explaining the boundary or failure condition they cover. Tag edge case IDs with suffix `-E` (e.g., `UT-003-E`).

### 🛑 STOP 1 — Approve Plan

Present the plan. Ask:
- **approve** → proceed to Step 6.
- **edit** → modify, re-present for approval.
- **reject** → abort.

Do NOT write test code before approval.

## Step 6 — Verify infrastructure

1. Check `dev_dependencies` for ALL packages required by the test plan (test runners, mocking libs, fakes, platform helpers).
2. Compare required vs. present. If ANY package is missing:

### 🛑 STOP 2 — Missing Packages

List every missing package with:
- Package name and version.
- Why it is needed (which test cases require it).

Ask: **"These packages are required. Add them to pubspec.yaml? (y/n)"**
- **y** → add via `fvm flutter pub add dev:<package>` (which runs pub get), then proceed.
- **n** → remove dependent test cases from the plan, re-present the reduced plan for approval (go back to STOP 1).

Do NOT install packages without user approval.

3. Verify `test/` and `integration_test/` dirs exist. Create with confirmation if needed.

## Step 7 — Write tests

Order: **Unit → Widget → Integration.**

- Mirror `lib/` structure: `test/unit/<feature>/`, `test/widget/<feature>/`, `integration_test/`.
- Use `group()`, Arrange-Act-Assert, descriptive names (`'should [behavior] when [condition]'`).
- Comment test plan ID above each test: `// UT-001`.
- Mocking strategy per [reference.md](reference.md).

## Step 8 — Execute

Run each type separately, in order:

```bash
fvm flutter test test/unit/ --reporter expanded
fvm flutter test test/widget/ --reporter expanded
fvm flutter test integration_test/ --reporter expanded
```

On failure → stop, report details, ask: fix / skip / abort.

## Step 9 — Report

### 🛑 STOP 3 — Final Report

Present compact summary:

| Type        | Total | Pass | Fail | Skip |
| ----------- | ----- | ---- | ---- | ---- |
| Unit        | x     | x    | x    | x    |
| Widget      | x     | x    | x    | x    |
| Integration | x     | x    | x    | x    |

List: failed tests (ID + reason + fix), coverage gaps, recommendations.
