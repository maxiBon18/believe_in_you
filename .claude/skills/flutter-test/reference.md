# Flutter Testing Reference

## Test Type Overview

| Type        | Tests                                   | Speed | Requires device | Runner                               |
| ----------- | --------------------------------------- | ----- | --------------- | ------------------------------------ |
| Unit        | Logic, entities, repos, services         | ms    | No              | `fvm flutter test test/`             |
| Widget      | Rendering, interactions, state display   | sec   | No              | `fvm flutter test test/`             |
| Migration   | Schema upgrades preserving data          | sec   | No              | `fvm flutter test test/`             |
| Integration | Multi-screen flows, navigation, e2e      | min   | Yes             | `fvm flutter test integration_test/` |

Unit, widget, and migration tests all live under `test/`, mirroring `lib/`. There is no
`test/unit/` split.

## Selection Matrix

Check each row per feature. ✅ = include that test type.

| Feature characteristic                              | Unit  | Widget | Integration |
| --------------------------------------------------- | :---: | :----: | :---------: |
| Boundary computation, status derivation, aggregation |   ✅   |   —    |      —      |
| Entities (equality, immutability)                   |   ✅   |   —    |      —      |
| Repository with a data source dependency            |   ✅   |   —    |      —      |
| Drift schema change                                 |   ✅   |   —    |      —      |
| ViewModel logic (Notifier/AsyncNotifier)            |   ✅   |   —    |      —      |
| Redirects and route-config parsing                  |   ✅   |   —    |      —      |
| Input controls (selectors, chips, text fields)      |   ✅   |   ✅    |      —      |
| Conditional UI driven by derived status             |   —   |   ✅    |      —      |
| User interactions (tap, drag, text input)           |   —   |   ✅    |      —      |
| Loading / error / empty / absent states             |   —   |   ✅    |      —      |
| Text scaling and semantics                          |   —   |   ✅    |      —      |
| First-run flow through to the first saved record    |   —   |   —    |      ✅      |
| An OS-delivered entry point into a screen           |   —   |   —    |      ✅      |
| Generating a file and handing it to the OS          |   —   |   —    |      ✅      |
| Destructive flows (delete all data)                 |   —   |   —    |      ✅      |

## Invariant suite — mandatory

These encode `data-integrity-rules.md` and the project's own rules in `CLAUDE.md` § Invariants.
Include every applicable one in any plan touching a write path, an aggregate, or persistence. All
are Critical priority.

The **Target** column names the logic under test, not a class — bind each to whatever the feature
actually built, and drop any row the project has no equivalent for rather than inventing one.

| ID     | Target                  | Assertion                                                        |
| ------ | ----------------------- | ---------------------------------------------------------------- |
| INV-01 | the repository          | Reading a range with no records writes nothing — row count unchanged |
| INV-02 | row → entity mapping    | A null column maps to a null entity, never to a default value     |
| INV-03 | aggregation             | An aggregate over 1 present + 2 missing equals the single value, period flagged partial |
| INV-04 | aggregation             | A period with 0 records yields no point — not 0, not interpolated |
| INV-05 | the save path           | A write the domain rules forbid fails rather than succeeding quietly |
| INV-06 | status derivation       | States that mean different things stay distinct — a period that was never available is not reported as one the user let pass |
| INV-07 | coverage metric         | Units that were never applicable are excluded from the denominator |
| INV-08 | migration n → n+1       | Every pre-existing row survives with identical values             |
| INV-09 | generated output        | A generated file's figures equal the on-screen figures for the same input |
| INV-10 | logging                 | No user-recorded value in log output outside `kDebugMode`         |
| INV-11 | redirects               | A failed precondition redirects and fabricates no state           |

## Edge Case Checklist

For each feature in scope, check these categories. Each applicable case becomes a `-E` test.

| Category              | What to test                                                                               |
| --------------------- | ------------------------------------------------------------------------------------------ |
| **Time boundary**     | The opening instant and one millisecond before it; the closing instant and one millisecond before it. Half-open interval respected |
| **Midnight**          | A range that crosses midnight; which calendar date the range is attributed to               |
| **DST**               | Transition inside a range, both directions                                                  |
| **Config change**     | Existing data keeps the configuration it was written under; the change applies going forward |
| **Input validation**  | Values outside the domain's accepted range are rejected                                     |
| **Install**           | First launch mid-period; periods already closed are distinguished from ones the user skipped |
| **Null / Empty**      | No records at all; optional fields absent; minimum and maximum collection sizes             |
| **Boundaries**        | Each bounded value at its minimum and maximum; a period with none and with all units filled |
| **Format**            | Long text, unicode, RTL text, whitespace-only input                                          |
| **State**             | A precondition expiring while the screen is open; app resumed after days in background       |
| **Concurrency**       | Double-tap save; a save racing a boundary                                                    |
| **Permissions**       | A required OS permission denied, or revoked mid-use                                          |
| **Navigation**        | An external payload malformed or pointing at a now-invalid destination; cold start with a precondition unmet |
| **Device**            | Reboot (scheduled OS work re-registered); timezone changed while the app was closed          |
| **Data**              | First launch with no data; migration from an older schema; delete-all then re-record         |

**Rule:** Every feature MUST have at least 2 edge case tests. If analysis reveals none applicable,
document why in the plan.

There is no Network or Auth category. The app has neither — a plan proposing tests for them has
misunderstood the architecture.

## Priority Levels

| Priority | Assign when                                                                                |
| -------- | ------------------------------------------------------------------------------------------ |
| Critical | Invariant suite, migrations, anything that can write or lose user data, time boundaries    |
| High     | The primary write flow, status derivation, scheduled OS work, aggregation                  |
| Medium   | Non-blocking UI states, formatting, secondary navigation                                   |
| Low      | Cosmetic, animations, rare paths with graceful fallbacks                                   |

## Rationale Rules

Rationale answers: **"What breaks without this test?"**

- ✅ `"Prevents a null value reading back as a neutral midpoint in generated output"`
- ✅ `"Ensures a save one millisecond after the boundary closes is rejected, not accepted late"`
- ❌ `"To make sure it works"`
- ❌ `"For code coverage"`

For invariant tests, the rationale states the real-world consequence, not the rule number.

## Mocking Strategy

| Dependency                    | Approach                                                          |
| ----------------------------- | ----------------------------------------------------------------- |
| Current time                  | Instants declared by the test and passed in (`CLAUDE.md` § Time handling) |
| Drift database                | In-memory instance (`NativeDatabase.memory()`)                    |
| Migrations                    | Real schema versions via Drift's migration test harness           |
| Platform plugins              | Fake implementing the adapter interface; assert on what it was asked to do |
| File generation / share       | Fake adapter; assert on the model passed in, not on bytes          |
| Repos / Services              | Hand-written fakes for 2–3 method interfaces; `mocktail` otherwise |
| Riverpod                      | `ProviderContainer.test()` with provider overrides                |
| Navigation                    | Fake `AppRouter` recording the `AppRoute` values it was given      |

`mocktail` is the project's mocking package (`testing-rules.md` § Doubles). Do not propose
`mockito` alongside it.

A fake `AppRouter` asserts on route *configs*, not on paths or widget types — that is the whole
reason the routes are a sealed type rather than `go_router` strings (`routing-rules.md`).
Route-config parsing is tested directly against a `GoRouterState`, including the invalid inputs that
must return `null`.

No HTTP, Firebase, or auth mocking — none of it exists in this app.

## Test Structure Rules

- Pattern: **Arrange-Act-Assert** in every test.
- Naming: `'[behavior] when [condition]'`.
- Grouping: one top-level `group()` per class under test, named after that class.
- ID comment above each test: `// UT-001: [description]`.
- Time is always fixed by instants the test supplies, never read from the wall clock.

## File Organization

`test/` mirrors `lib/`, per `.claude/rules/code/testing-rules.md`:

```text
test/
├── <feature>/domain/services/<name>_service_test.dart
├── <feature>/data/repo/<name>_repository_impl_test.dart
├── <feature>/presentation/viewmodel/<name>_viewmodel_test.dart
├── <feature>/presentation/ux/<name>_page_test.dart
├── core/data/source/db/migration_test.dart
└── helpers/
    ├── fake_clock.dart
    ├── fakes.dart
    └── fixtures/
integration_test/<flow>_test.dart
```
