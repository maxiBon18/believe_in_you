---
description: "Test structure, doubles, and what to test per layer"
paths:
  - "test/**/*.dart"
  - "integration_test/**/*.dart"
---

# Testing

## Structure

- `test/` mirrors `lib/`: `lib/<feature>/domain/services/<name>_service.dart` is tested by
  `test/<feature>/domain/services/<name>_service_test.dart`.
- One top-level `group` per class under test, named after that class.
- Test names state behavior, not method names: `'returns skipped once the window has closed'`, not
  `'test statusOf'`.

## What to test at each layer

| Layer        | Test with                  | Fake out                         |
| ------------ | -------------------------- | -------------------------------- |
| Services     | plain unit tests           | repository interfaces, the clock |
| Repositories | unit tests                 | data source interfaces           |
| Migrations   | Drift migration harness    | nothing — run against real schemas |
| ViewModels   | `ProviderContainer.test()` | services, via provider overrides |
| Widgets      | `testWidgets`              | ViewModels, via provider overrides |
| Router guards| plain unit tests           | the repositories the guard reads |

Because repository and data source interfaces live behind abstractions, nothing above `data/` needs
an in-memory database. If a test needs one, a dependency is being constructed instead of injected —
fix the code, not the test.

Migrations are the exception: they are tested against real schema versions, because the thing being
verified is that data survives, and a fake proves nothing about that.

## Time

Every time-dependent test uses the injected `Clock`. No `DateTime.now()`, no `Future.delayed` to
cross a boundary.

The slot boundary cases below are the ones that actually break. Each deserves a named test:

- The instant a window opens, and the instant before it
- The instant a window closes, and the instant before it — a save one millisecond before the close
  succeeds, a save exactly at the close does not
- A sleep time after midnight, so the window spans a date boundary
- A DST transition inside a window, in both directions
- A schedule change, asserting that yesterday's slots keep their original windows
- A slot whose window closed before installation, asserting *not applicable* rather than *skipped*

## Invariants

The rules in `data-integrity-rules.md` are the ones worth locking down with tests, because they are
the ones a future refactor will quietly violate:

- A read of a day with no recordings writes nothing — assert the row count is unchanged.
- A daily average over one completed slot and two skipped ones equals that one value, and the day is
  flagged incomplete.
- A day with zero recordings yields no data point, not a zero and not an interpolated value.
- Saving into a closed window fails rather than succeeding late.
- A migration from schema version *n* to *n+1* preserves every existing recording.
- Home resolved with no schedule redirects rather than creating one.
- No log line emitted during a save contains note text, an emotion, or a scale value.

A bug fix lands with a test that fails before the fix.

## Doubles

- `mocktail` is the project's mocking package. It is not in `pubspec.yaml` yet; adding it is the
  approval gate in the `/flutter-test` skill, not something to do silently. Never add a second
  mocking package alongside it.
- Prefer hand-written fakes for interfaces with two or three methods — they read better than mock
  setup and don't break on signature changes. `Clock` in particular should be a hand-written fake
  with an `advance(Duration)` method, not a mock.
- Riverpod: override providers on the container rather than mocking `ref`. Use
  `ProviderContainer.test()` so disposal is automatic.

## Rules of thumb

- No test asserts on generated output (`.g.dart`, `.freezed.dart`, `.drift.dart`) — test the
  behavior that uses it.
- No `await Future.delayed(...)` to wait for state. Pump, or await the future you actually care
  about.
- Widget tests assert on user-visible outcomes (`find.text`, semantics), not on widget internals.
- The export is tested at the data level — assert on the summary model that feeds the PDF, not on
  rendered bytes. Rendering is verified by looking at it.

Run tests with the commands in `CLAUDE.md`.
