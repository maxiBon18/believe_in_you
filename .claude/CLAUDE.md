# Mood Diary

Flutter app (Android, iOS) for structured self-monitoring in therapy. Three times a day the user
records a 1–5 mood value, one or more emotions from a fixed vocabulary, and an optional one-line
note. The app charts the trend and produces a one-page weekly PDF for the user's psychologist.

The three daily moments are computed from the user's declared wake and sleep times, not fixed at
preset hours.

This is a study project: the goal is for the developer to learn Flutter architecture and, later,
backend development.

## Product decisions

`business_analysis_en.md` is the source of truth, and the only business document in this repo — a
citation to any other filename is stale. §4 records what was decided **and why**, including costs
knowingly accepted. Before proposing a behavioural change, check whether §4 already rejected it.

## Invariants

Not open to convenience-driven revision. An implementation that violates one is wrong regardless of
how clean it looks — raise it rather than weakening it. Full rationale and the concrete code shapes
that violate each one are in `.claude/rules/code/data-integrity-rules.md`, which loads whenever you
touch a Dart file.

1. **Never synthesise a mood value** — no defaults, no imputation, no interpolation.
2. **A row is written only when the user saves.** `skipped` is derived at read time, never stored.
3. **No editing once a slot window closes.** No backfill, no "recorded late" path.
4. **Missing data is excluded from averages**, never zeroed and never interpolated.
5. **No streaks, badges, scores, or evaluative copy** — celebratory or admonishing.
6. **Local only.** No network, no analytics, no third-party crash reporting.
7. **The support-resources screen stays reachable** from Settings, permanently.
8. **Migrations must not lose recordings.** This is the developer's own clinical record.

Entry cost is a hard budget on top of these: **under 20 seconds from cold launch to saved
recording.**

## Vocabulary

One word per concept, in code, copy, and commits. Two words for one concept is how a rule stops
being findable.

| Term | Means | Never |
| --- | --- | --- |
| **recording** | One saved observation for one slot | entry, log, record |
| **slot** | One of the three daily moments | period, session, timeslot |
| **window** | The time range a slot is open for | interval, range |
| **schedule** | A wake/sleep pair that applies from a given date onward | settings, times |
| **skipped** | A slot whose window closed with no recording | missed, empty |
| **not applicable** | A slot whose window closed before installation | skipped |
| **scale** | The 1–5 value | score, rating, mood level |
| **export** | The weekly PDF for the clinician | report, summary |

The vocabulary fixes **concepts, not identifiers**. Class, table, column, service, and route names
are chosen when the feature that needs them is built. No rule file in `.claude/` prescribes one, and
none should start to — a name written down before the code exists is a name the code will disagree
with. Where a rule needs to point at something unbuilt, it describes the role (*the service that
derives slot status*) rather than inventing a symbol.

## Stack and system boundaries

Do not assume versions — pinned numbers go stale silently. Read `pubspec.yaml` for packages,
`fvm flutter doctor` for Flutter/Dart/Android SDK/Xcode, `fvm --version` for FVM.

Persistence is Drift over SQLite, encrypted at rest, and the only store. Notifications are
`flutter_local_notifications`, one per slot, scheduled on-device. Charts are `fl_chart`. Export is
`pdf` + `printing`, generated on-device and shared through the OS share sheet. The Flutter app holds
all business logic.

**`pubspec.yaml` is still the Flutter starter template.** None of the above is installed yet. Do not
write code against a package before it is added, and do not add one without approval.

## Architecture

Clean Architecture, **MVVM**, **feature-first**. `/lib` holds `core/` and one self-contained
directory per feature, each split into `data/`, `domain/`, `presentation/`, `shared/`.

Features: `onboarding`, `entry`, `history`, `export`, `settings`.

Navigation is a **custom router built on Navigator 2.0**, reached only through the abstract
`AppRouter` contract. Do not add `go_router` or another navigation package. Details in
`.claude/rules/code/routing-rules.md`.

### Dependency rule

Dependencies point inward: presentation → domain ← data.

- `domain/` imports nothing from `presentation/` or `data/`.
- `data/` imports nothing from `presentation/`, but may import domain entities and interfaces.
- Code used by more than one layer goes in the feature's `shared/`; code used by more than one
  feature goes in `core/`. Promote only when a second consumer exists, not in anticipation of one.

A `domain/services/` file importing a Drift row class is the violation to watch for: the domain
layer would then depend on a data-layer type. Map the row to an entity inside `data/repo/` instead.

### Where things live

| Artifact | Interface | Implementation |
| --- | --- | --- |
| Repository | `domain/repo/` | `data/repo/` |
| Data source | `data/repo/source/` | `data/source/` |
| DTO | `data/repo/dto/` | `data/source/dto/` |

`domain/repo/` holds repository interfaces and nothing else. ViewModels talk only to domain
services, never to a repository implementation or a data source.

Slot status derivation, window computation, and the daily-average rules are **domain services** —
pure functions over a schedule and a set of recordings, unit-testable without a database.

### GetIt and Riverpod — one job each

**GetIt** resolves dependencies: repositories, data sources, domain services. Registration lives in `shared/controllers/`.
**Riverpod** manages state only — ViewModels.

A provider whose only purpose is to construct and expose a dependency belongs in GetIt instead.
Nothing mutable goes in GetIt: Riverpod cannot observe it, so it changes without notifying any
listener.

**Riverpod providers are hand-written.** No `@riverpod` / `@Riverpod` annotations, no
`riverpod_annotation` or `riverpod_generator` in `pubspec.yaml`, no `.g.dart` part file in a
ViewModel. Details in `.claude/rules/code/viewmodel-rules.md` § Riverpod.

## Time handling

Time is the main source of bugs in this app. **How the app reads the current time is not decided
yet** — there is no time-source abstraction, and introducing one is confirm-first. Until it is
chosen, code that needs an instant takes it as a parameter rather than reading the wall clock, so
slot-boundary behaviour stays testable.

## Working in this repo

1. Read existing code in the target feature and match its naming and structure — do not introduce a
   parallel pattern for the same problem.
2. Path-scoped rules in `.claude/rules/` load automatically for matching files. Follow the ones that
   load; you do not need to hunt for them.
3. If a requirement has more than one valid reading, say so and ask. A wrong assumption costs more
   here than a question.

After changing code:

- `fvm dart analyze` — zero errors before you consider the task done. `analysis_options.yaml` is
  strict in ways that shape how you write.
- `fvm dart format .` — `analysis_options.yaml` sets `page_width: 120`, so the default 80-column
  reflow does not happen. Never pass `--line-length`; it would disagree with CI.
- `fvm dart run build_runner build --delete-conflicting-outputs` — only after touching annotated
  classes, Drift tables above all. Never for a provider: Riverpod is used without code generation.

Every `dart` and `flutter` command takes the `fvm` prefix, because the repo pins its SDK through FVM
and a bare command silently runs a different Flutter version.

### Project skills and agents

Run with `/name`; none of them load on their own.

| Skill | Does |
| --- | --- |
| `/dart-review` | 12-area review of `lib/**/*.dart`, integrity first |
| `/debug-code` | Diagnose a bug with minimal scanning; rules out intended behaviour first |
| `/flutter-test` | Test plan → approval → execution, with the mandatory invariant suite |
| `/dart-documentation` | Dartdoc standards, terminology, invariant comments |
| `/git-flow` | Stage, Conventional Commit, push, with approval gates |
| `/new-feature` | Scaffold a feature's Clean Architecture directories |

Agents `code-reviewer`, `debugger`, and `doc-generator` wrap the first three plus documentation, and
add their own approval gates. Do not run them on speculation — they edit files.

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
