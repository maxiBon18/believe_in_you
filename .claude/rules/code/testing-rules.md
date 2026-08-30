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
- Test names state behavior, not method names: `'returns unavailable once the window has closed'`,
  not `'test statusOf'`.

## What to test at each layer

| Layer        | Test with                  | Fake out                         |
| ------------ | -------------------------- | -------------------------------- |
| Services     | plain unit tests           | repository interfaces            |
| Repositories | unit tests                 | data source interfaces           |
| Migrations   | Drift migration harness    | nothing — run against real schemas |
| ViewModels   | `ProviderContainer.test()` | services, via provider overrides |
| Widgets      | `testWidgets`              | ViewModels, via provider overrides |
| Redirects    | plain unit tests           | the state the redirect reads     |

Because repository and data source interfaces live behind abstractions, nothing above `data/` needs
an in-memory database. If a test needs one, a dependency is being constructed instead of injected —
fix the code, not the test.

Migrations are the exception: they are tested against real schema versions, because the thing being
verified is that data survives, and a fake proves nothing about that.

## Time

Every time-dependent test fixes the instants it exercises and passes them in. No `DateTime.now()`,
no `Future.delayed` to cross a boundary. How the app sources the current time is decided in
`CLAUDE.md` § Time handling — do not introduce a mechanism for it from a test.

Boundary cases are the ones that actually break. Wherever the domain has a time boundary, each of
these deserves a named test:

- The instant a boundary opens, and the instant before it
- The instant a boundary closes, and the instant before it — half-open, so an action one
  millisecond before the close succeeds and an action exactly at the close does not
- A boundary that spans midnight, so the range crosses a date change
- A DST transition inside the range, in both directions
- A configuration change, asserting that already-recorded data keeps the boundaries it was written
  under
- A range that closed before installation, asserting it is distinguished from one the user actually
  let pass

## Invariants

The rules in `data-integrity-rules.md`, plus the project's own in `CLAUDE.md` § Invariants, are the
ones worth locking down with tests, because they are the ones a future refactor will quietly
violate. The shape of that suite:

- A read of an empty range writes nothing — assert the row count is unchanged.
- An aggregate over one recorded value and two missing ones equals that one value, and the period is
  flagged partial.
- A period with no records yields no data point, not a zero and not an interpolated value.
- A write that the domain rules forbid fails rather than succeeding quietly.
- A migration from schema version *n* to *n+1* preserves every existing row.
- A precondition that fails redirects rather than fabricating the missing state.
- No *unguarded* log line emitted during a save contains a user-recorded value — value-carrying
  lines sit behind `kDebugMode`, so a release build emits none.

A bug fix lands with a test that fails before the fix.

## Doubles

- `mocktail` is the project's mocking package. Check `pubspec.yaml` before assuming it is installed;
  adding it is the approval gate in the `/flutter-test` skill, not something to do silently. Never
  add a second mocking package alongside it.
- Prefer hand-written fakes for interfaces with two or three methods — they read better than mock
  setup and don't break on signature changes.
- Riverpod: override providers on the container rather than mocking `ref`. Use
  `ProviderContainer.test()` so disposal is automatic.

## Rules of thumb

- No test asserts on generated output (`.g.dart`, `.freezed.dart`, `.drift.dart`) — test the
  behavior that uses it.
- No `await Future.delayed(...)` to wait for state. Pump, or await the future you actually care
  about.
- Widget tests assert on user-visible outcomes (`find.text`, semantics), not on widget internals.
- Rendered output (documents, images, files) is tested at the data level — assert on the model that
  feeds the renderer, not on the bytes it produces. Rendering is verified by looking at it.

Run tests with the commands in `CLAUDE.md`.
