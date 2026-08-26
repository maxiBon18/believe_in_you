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
| Window computation, status derivation, averaging    |   ✅   |   —    |      —      |
| Entities (equality, immutability)                   |   ✅   |   —    |      —      |
| Repository with a data source dependency            |   ✅   |   —    |      —      |
| Drift schema change                                 |   ✅   |   —    |      —      |
| ViewModel logic (Notifier/AsyncNotifier)            |   ✅   |   —    |      —      |
| Router guards and route-config parsing              |   ✅   |   —    |      —      |
| Scale selector, emotion chips, note field           |   ✅   |   ✅    |      —      |
| Conditional UI based on slot status                 |   —   |   ✅    |      —      |
| User interactions (tap, drag, text input)           |   —   |   ✅    |      —      |
| Loading / error / empty / skipped states            |   —   |   ✅    |      —      |
| Text scaling and semantics                          |   —   |   ✅    |      —      |
| Onboarding → first recording flow                   |   —   |   —    |      ✅      |
| Notification tap → entry screen                     |   —   |   —    |      ✅      |
| Export generation and share                         |   —   |   —    |      ✅      |
| Delete-all-data flow                                |   —   |   —    |      ✅      |

## Invariant suite — mandatory

These encode `data-integrity-rules.md`. Include every applicable one in any plan touching entry,
summary, or persistence. All are Critical priority.

The **Target** column names the logic under test, not a class — bind each to whatever the feature
actually built.

| ID     | Target                  | Assertion                                                        |
| ------ | ----------------------- | ---------------------------------------------------------------- |
| INV-01 | recording repository    | Reading a day with no recordings writes nothing — row count unchanged |
| INV-02 | row → entity mapping    | A null scale maps to a null entity, never to a default value      |
| INV-03 | summary computation     | Average over 1 completed + 2 skipped equals the single value, day flagged incomplete |
| INV-04 | summary computation     | A day with 0 recordings yields no point — not 0, not interpolated |
| INV-05 | the save path           | Saving into a closed window fails                                 |
| INV-06 | status derivation       | A window closed before installation is *not applicable*, not *skipped* |
| INV-07 | completion rate         | *Not applicable* slots are excluded from the denominator          |
| INV-08 | migration n → n+1       | Every pre-existing recording survives with identical values       |
| INV-09 | export                  | Export summary equals the on-screen summary for the same week     |
| INV-10 | logging                 | No note text, emotion, or scale value in log output outside `kDebugMode` |
| INV-11 | router guards           | Home with no schedule redirects and writes no schedule            |

## Edge Case Checklist

For each feature in scope, check these categories. Each applicable case becomes a `-E` test.

| Category           | What to test                                                                                  |
| ------------------ | --------------------------------------------------------------------------------------------- |
| **Slot boundary**  | The opening instant and one millisecond before it; the closing instant and one millisecond before it. Half-open interval respected |
| **Midnight**       | Sleep time after midnight; the "day" is the wake date                                          |
| **DST**            | Transition inside a window, both directions                                                    |
| **Schedule change**| Yesterday's slots keep their original windows; change applies from tomorrow                    |
| **Span validation**| Waking span < 8h and > 20h rejected                                                            |
| **Install**        | First launch mid-day; slots already closed are *not applicable*                                |
| **Null / Empty**   | No recordings at all; note absent; single emotion; all sixteen emotions                        |
| **Boundaries**     | Scale at 1 and 5; a week with 0 and with 21 recordings                                         |
| **Format**         | Long note, unicode, RTL text, whitespace-only note                                             |
| **State**          | Window closes while the entry screen is open; app resumed after days in background             |
| **Concurrency**    | Double-tap save; save racing the window close                                                  |
| **Permissions**    | Notification permission denied; Android exact-alarm revoked mid-use                            |
| **Navigation**     | Notification payload malformed or for a closed window; cold start with onboarding incomplete    |
| **Device**         | Reboot (reminders rescheduled); timezone changed while the app was closed                      |
| **Data**           | First launch with no data; migration from an older schema; delete-all then re-record           |

**Rule:** Every feature MUST have at least 2 edge case tests. If analysis reveals none applicable,
document why in the plan.

There is no Network or Auth category. The app has neither — a plan proposing tests for them has
misunderstood the architecture.

## Priority Levels

| Priority | Assign when                                                                                |
| -------- | ------------------------------------------------------------------------------------------ |
| Critical | Invariant suite, migrations, anything that can write or lose a recording, slot boundaries  |
| High     | Entry flow, status derivation, notification scheduling, summary computation                |
| Medium   | Non-blocking UI states, formatting, History navigation                                     |
| Low      | Cosmetic, animations, rare paths with graceful fallbacks                                   |

## Rationale Rules

Rationale answers: **"What breaks without this test?"**

- ✅ `"Prevents a null scale reading back as a neutral 3 in the clinician's export"`
- ✅ `"Ensures a save one millisecond after the window closes is rejected, not accepted late"`
- ❌ `"To make sure it works"`
- ❌ `"For code coverage"`

For invariant tests, the rationale states the clinical consequence, not the rule number.

## Mocking Strategy

| Dependency                    | Approach                                                          |
| ----------------------------- | ----------------------------------------------------------------- |
| Current time                  | Instants declared by the test and passed in. No time-source package |
| Drift database                | In-memory instance (`NativeDatabase.memory()`)                    |
| Migrations                    | Real schema versions via Drift's migration test harness           |
| Local notifications           | Fake implementing the scheduler interface; assert on scheduled set |
| PDF / share                   | Fake adapter; assert on the summary model passed in, not on bytes  |
| Repos / Services              | Hand-written fakes for 2–3 method interfaces; `mocktail` otherwise |
| Riverpod                      | `ProviderContainer.test()` with provider overrides                |
| Navigation                    | Fake `AppRouter` recording the `AppRoute` values it was given      |

`mocktail` is the project's mocking package (`testing-rules.md` § Doubles). Do not propose
`mockito` alongside it.

A fake `AppRouter` asserts on route *configs*, not on strings or widget types — that is the whole
reason the routes are a sealed type (`routing-rules.md`).

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
