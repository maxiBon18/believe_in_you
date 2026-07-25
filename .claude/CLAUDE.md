# Mood Diary

Flutter app (Android, iOS) for structured self-monitoring in therapy. Three times a day the user
records a 1–5 mood value, one or more emotions from a fixed vocabulary, and an optional one-line
note. The app charts the trend and produces a one-page weekly PDF for the user's psychologist.

The three daily moments are computed from the user's declared wake and sleep times, not fixed at
preset hours.

## Learning boundaries — read before implementing anything

This is a study project: the goal is for the developer to learn Flutter architecture and, later,
backend development. Generated code that skips the reasoning defeats the point.

- **Do not write the implementation** for the custom router (Navigator 1.0/2.0, `RouterDelegate`,
  guards), the slot-window computation and its edge cases, or the Drift schema and its migrations.
  Explain the mechanism or produce a plan, then stop and let the developer write it.
- **Delegate freely:** DTO and entity mapping, boilerplate widgets, test scaffolding, codegen
  wiring, repetitive refactors inside an established pattern, chart and PDF layout code.
- When a task sits between the two, ask which side it falls on.

## Product decisions

`business_analysis_en.md` is the source of truth. §4 records what was decided **and why**,
including costs that were knowingly accepted. Before proposing a behavioural change, check whether
§4 already rejected it and on what grounds.

## Invariants

Not open to convenience-driven revision. An implementation that violates one is wrong, regardless of
how clean it looks.

1. **Never synthesise a mood value.** No defaults, no imputation, no neutral fill for a missing
   entry. Missing data is recorded as missing. Unlogged evenings are disproportionately bad
   evenings, so imputing a neutral value systematically replaces the worst data with the blandest —
   and a clinician reads the result as an observation.
2. **A row is written only when the user saves.** `skipped` is derived at read time, never stored.
   There is no `status` column and no background job that creates pending rows.
3. **No editing once a slot window closes.** No backfill, no "recorded late" path. `recorded_at`
   therefore always falls inside `[window_start, window_end)`.
4. **Excluded from the daily average:** skipped slots. Never counted as zero, never interpolated.
   Days with fewer than three recordings are marked, not silently averaged.
5. **No streaks, badges, scores, or celebratory copy.** No admonishing copy either. Completion rate
   is stated factually (`18 of 21`) and never appears on the entry screen.
6. **Local only.** No network calls, no analytics, no third-party crash reporting that could carry
   note text. Health data does not leave the device in v1.
7. **The support-resources screen stays reachable** from Settings, permanently, without
   interrupting anything. Do not add content scanning or reactive prompts to the note field.
8. **Entry cost is a hard budget:** under 20 seconds from cold launch to saved recording.

## Stack

Do not assume versions — pinned numbers here go stale silently. Read `pubspec.yaml` for packages,
`fvm flutter doctor` for Flutter/Dart/Android SDK/Xcode, `fvm --version` for FVM.

Persistence is Drift over SQLite. Notifications are `flutter_local_notifications`. Charts are
`fl_chart`. Export is `pdf` + `printing`.

## System boundaries

- **Flutter app** — UI, state, user interaction, all business logic.
- **Local database** — Drift/SQLite, encrypted at rest. The only store in v1.
- **Local notifications** — one per slot, scheduled on-device.
- **PDF export** — generated on-device, shared through the OS share sheet.

There is no backend in v1 and no account. The app is fully functional offline because there is
nothing to be online for. A backend (Node.js, then Python) arrives in Phase 3 as a learning
objective and is not shipped.

The schema is nevertheless built as though sync were coming: UUID primary keys, `updated_at` and
soft deletes on every table, explicit schema versioning, and a repository interface between UI and
data layer from the first commit. This is what makes Phase 3 an implementation rather than a
rewrite.

## Architecture

Clean Architecture, **MVVM**, **feature-first**. `/lib` holds `core/` and one self-contained
directory per feature, each split into `data/`, `domain/`, `presentation/`, `shared/`.

Features: `onboarding`, `entry`, `history`, `export`, `settings`.

Navigation is a **custom router built on Navigator 2.0**, reached only through the abstract
`AppRouter` contract. Do not add `go_router` or another navigation package.

### Dependency rule

Dependencies point inward: presentation → domain ← data.

- `domain/` imports nothing from `presentation/` or `data/`.
- `data/` imports nothing from `presentation/`, but may import domain entities and interfaces.
- Code used by more than one layer goes in the feature's `shared/`; code used by more than one
  feature goes in `core/`. Promote only when a second consumer exists, not in anticipation of one.

#### Example

Correct — `data/repo/entry_repository_impl.dart` imports `domain/repo/entry_repository.dart` and
`domain/entities/entry.dart`.

Incorrect — `domain/services/compute_slot_status.dart` imports `data/source/dto/entry_dto.dart`.
The domain layer would then depend on a data-layer type. Map the DTO to an entity inside
`data/repo/` instead.

### Where things live

| Artifact | Interface | Implementation |
| --- | --- | --- |
| Repository | `domain/repo/` | `data/repo/` |
| Data source | `data/repo/source/` | `data/source/` |
| DTO | `data/repo/dto/` | `data/source/dto/` |

`domain/repo/` holds repository interfaces and nothing else — data sources and DTOs are data-layer
concerns end to end. ViewModels talk only to domain services, never to a repository implementation
or a data source. Extra sub-folders for grouping inside a layer are fine.

Slot status derivation, window computation, and the daily-average rules are **domain services**.
They are pure functions over a schedule and a set of entries, and they must be unit-testable without
a database.

### GetIt and Riverpod — one job each

- **GetIt** resolves dependencies: repositories, data sources, domain services, the notification
  scheduler, the PDF generator. Registration lives in the feature's `shared/controllers/`.
- **Riverpod** manages state only — ViewModels, `Notifier` / `AsyncNotifier`, what the UI watches.

A provider whose only purpose is to construct and expose a dependency belongs in GetIt instead.
Nothing mutable goes in GetIt: Riverpod cannot observe it, so it changes without notifying any
listener.

## Time handling

Time is the main source of bugs in this app. Rules:

- Every entry stores its `window_start`, `window_end`, and IANA `timezone`, denormalised at
  creation. Entries stay self-describing even if the schedule history is lost.
- `schedules` is append-only, each row carrying `effective_from`. Deriving the status of a past slot
  uses the schedule in effect on that date — never the current one.
- Windows are computed from local wall-clock time, so DST shifts them rather than breaking them.
- Never use `DateTime.now()` directly in domain code. Inject a clock so slot-boundary behaviour can
  be tested.

## Working in this repo

1. Read existing code in the target feature and match its naming and structure — do not introduce a
   parallel pattern for the same problem.
2. Path-scoped rules in `.claude/rules/` load automatically for matching files. Follow the ones that
   load; you do not need to hunt for them.
3. If a requirement has more than one valid reading, say so and ask. A wrong assumption costs more
   here than a question.

After changing code:

- `fvm dart analyze` — zero errors before you consider the task done.
- Formatting follows `.vscode/settings.json`. Read it and match it; do not run `fvm dart format`
  with default options, because the defaults ignore those settings and can reflow files.
- `fvm dart run build_runner build --delete-conflicting-outputs` — only after touching annotated
  classes, including Drift tables.

Every `dart` and `flutter` command takes the `fvm` prefix, because the repo pins its SDK through FVM
and a bare command silently runs a different Flutter version.

### Commands

- Run the app: `fvm flutter run`
- Run all tests: `fvm flutter test`
- Run a single test file: `fvm flutter test test/widget_test.dart`
- Run a single test by name: `fvm flutter test --plain-name "<test description>"`
- Add a dependency: `fvm flutter pub add <package>`
- Remove a dependency: `fvm flutter pub remove <package>`
- Build an Android artifact: `fvm flutter build apk`
- Build an iOS artifact: `fvm flutter build ipa`

## Confirm first

Stop and ask before creating a feature module or top-level directory; choosing between architectural
options (`Notifier` vs `AsyncNotifier`, one provider vs several); modifying `core/`, where the blast
radius spans every feature; changing navigation, routes, or DI scope; **changing the database schema
or writing a migration**; introducing a pattern not already in the codebase; or writing
platform-specific code (`Platform` checks, conditional imports).

## Do not

- Delete files unless explicitly instructed.
- Refactor or rename outside the current task's scope — it hides the intended change in the diff.
- Change `pubspec.yaml` dependencies without approval.
- Commit credentials, API keys, or secrets.
- Add any package that transmits data off-device — analytics, crash reporting, remote config.
- Write a migration that can lose recordings. This is the developer's own clinical record and there
  is no backup elsewhere.
- Weaken an invariant to make a test pass or a feature simpler. Raise it instead.
