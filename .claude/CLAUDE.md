# Believe in you

Chat-first Flutter app (Android, iOS): an AI fashion stylist. The user chats, sends outfit photos,
and gets back a structured response — rating with breakdown, color palette, detected garments,
prioritized suggestions.

## Learning boundaries — read before implementing anything

This is a study project: the goal is for the developer to learn Flutter architecture and backend
development, not to ship fast. Generated code that skips the reasoning defeats the point.

- **Do not write the implementation** for the custom router (Navigator 1.0/2.0, `RouterDelegate`,
  guards, deep links) or the first stratification of the AI Gateway backend. Explain the mechanism
  or produce a plan, then stop and let the developer write it.
- **Delegate freely:** DTO mapping, boilerplate widgets, test scaffolding, codegen wiring,
  repetitive refactors inside an established pattern.
- When a task sits between the two, ask which side it falls on.

## Stack

Do not assume versions — pinned numbers here go stale silently. Read `pubspec.yaml` for packages,
`fvm flutter doctor` for Flutter/Dart/Android SDK/Xcode, `fvm --version` for FVM.

## System boundaries

- **Flutter app** — UI, state, user interaction.
- **Firebase** — Apple/Google sign-in, conversation and profile storage, photo storage, crashes.
- **AI Gateway** (separate service and repo) — model routing, prompts, caching, rate limiting.

The seam exists so the AI provider can change without touching auth or storage. The app calls the
Gateway, never a model provider API directly. Responses arrive as typed structured objects
(`rating`, `palette`, `detectedItems`, `suggestions`, `styleTags`) and are parsed into DTOs in the
data layer. A parse failure is an error state — never fall back to rendering raw text.

## Architecture

Clean Architecture, **MVVM**, **feature-first**. `/lib` holds `core/` and one self-contained
directory per feature, each split into `data/`, `domain/`, `presentation/`, `shared/`.

Navigation is a **custom router built on Navigator 2.0**, reached only through the abstract
`AppRouter` contract. Do not add `go_router` or another navigation package.

### Dependency rule

Dependencies point inward: presentation → domain ← data.

- `domain/` imports nothing from `presentation/` or `data/`.
- `data/` imports nothing from `presentation/`, but may import domain entities and interfaces.
- Code used by more than one layer goes in the feature's `shared/`; code used by more than one
  feature goes in `core/`. Promote only when a second consumer exists, not in anticipation of one.

#### Example

Correct — `data/repo/outfit_repository_impl.dart` imports `domain/repo/outfit_repository.dart`
and `domain/entities/outfit.dart`.

Incorrect — `domain/services/rate_outfit.dart` imports `data/source/dto/outfit_dto.dart`. The
domain layer would then depend on a data-layer type. Map the DTO to an entity inside `data/repo/`
instead.

### Where things live

| Artifact | Interface | Implementation |
| --- | --- | --- |
| Repository | `domain/repo/` | `data/repo/` |
| Data source | `data/repo/source/` | `data/source/` |
| DTO | `data/repo/dto/` | `data/source/dto/` |

`domain/repo/` holds repository interfaces and nothing else — data sources and DTOs are data-layer
concerns end to end. ViewModels talk only to domain services, never to a repository implementation
or a data source. Extra sub-folders for grouping inside a layer are fine. For the full feature
scaffold, run `/new-feature`.

### GetIt and Riverpod — one job each

- **GetIt** resolves dependencies: repositories, data sources, domain services, the Gateway client.
  Registration lives in the feature's `shared/controllers/`; see `.claude/rules/code/di-rules.md`.
- **Riverpod** manages state only — ViewModels, `Notifier` / `AsyncNotifier`, what the UI watches.

A provider whose only purpose is to construct and expose a dependency belongs in GetIt instead.
Nothing mutable goes in GetIt: Riverpod cannot observe it, so it changes without notifying any
listener.

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
  with default options, because the defaults ignore those settings and can reflow files the whole
  team formats differently.
- `fvm dart run build_runner build --delete-conflicting-outputs` — only after touching annotated
  classes.

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
radius spans every feature; changing navigation, routes, or DI scope; introducing a pattern not
already in the codebase; or writing platform-specific code (`Platform` checks, conditional imports).

## Do not

- Delete files unless explicitly instructed.
- Refactor or rename outside the current task's scope — it hides the intended change in the diff.
- Change `pubspec.yaml` dependencies without approval.
- Commit credentials, API keys, or secrets.
