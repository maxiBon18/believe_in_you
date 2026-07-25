---
description: "Naming, typing, null safety, time, and error handling for all Dart code"
paths:
  - "lib/**/*.dart"
  - "test/**/*.dart"
---

# Coding Conventions

`analysis_options.yaml` is the enforcement layer. These rules cover what the linter cannot check.

## Naming

| Element            | Convention                       | Example                               |
| ------------------ | -------------------------------- | ------------------------------------- |
| Files              | `snake_case` + type suffix       | `home_page.dart`, `entry_dto.dart`    |
| Classes            | `PascalCase`                     | `RecordingEntity`                     |
| Variables, methods | `camelCase`                      | `slotIndex`, `fetchRecordings()`      |
| Private members    | `_` prefix                       | `_controller`, `_computeWindow()`     |
| Booleans           | `is`/`has`/`should`/`can` prefix | `isOpen`, `hasRecording`, `canEdit`   |

File name by type — the suffix is how every other rule locates a file, so it is not optional:

| Type                        | Pattern                     |
| --------------------------- | --------------------------- |
| Page                        | `<feature>_page.dart`       |
| Widget                      | `<name>_widget.dart`        |
| DTO                         | `<name>_dto.dart`           |
| Entity                      | `<name>_entity.dart`        |
| Drift table                 | `<name>_table.dart`         |
| ViewModel                   | `<name>_viewmodel.dart`     |
| Service                     | `<name>_service.dart`       |
| Repository interface / impl | `<name>_repository.dart` / `<name>_repository_impl.dart` |
| Data source interface / impl| `<name>_source.dart` / `<name>_source_impl.dart` |
| Test                        | `<name_of_file_under_test>_test.dart` |

## Typing

- No `dynamic` unless an external API forces it; add a comment saying which one.
- No `as` cast without a preceding `is` check, or use `case Foo foo` pattern matching instead.
- `final` for anything never reassigned; `const` wherever the value is compile-time constant.
- `late` only when initialization before first access is guaranteed by construction order.
- `@immutable` on classes whose fields are all final.
- Prefer records over one-off classes when returning two or three values with no behavior.
- Prefer exhaustive `switch` expressions over `if`/`else` chains on sealed types — the compiler
  then catches every missed case when a new variant is added. `SlotStatus` is sealed for exactly
  this reason: adding a variant must break every site that handles statuses.
- Use `=>` for single-expression functions and getters.

## Constants and magic values

No literal numbers, durations, keys, or file-name fragments inline. Put them in the feature's
`shared/constants/`. This includes the domain's structural constants — slot count, scale bounds,
the notification offset, the entry-time budget — which appear in more than one place and must not
drift apart. User-visible strings are covered by the localization rule in
`presentation-layer-rules.md`.

## Null safety

- No `!` where a null check, `??`, or early return would do. `!` is acceptable only immediately
  after a check the compiler cannot see through — comment why.
- No `?.` chain deeper than two levels; bind an intermediate variable instead.
- A nullable return type needs a doc comment stating what `null` means. If `null` has no distinct
  meaning, return a non-nullable type with a default.
- **Never `??` a default onto a recorded value.** A missing mood value is missing; a missing
  emotion set is missing. `scale ?? 3` and `emotions ?? const []` are bugs, not defensive coding.
  See `data-integrity-rules.md`.

## Time

Time is this app's main source of bugs, and most of them are untestable if the clock is implicit.

- Never call `DateTime.now()`, `DateTime.timestamp()`, or `Timer` directly in `domain/` or `data/`.
  Inject a `Clock` through the constructor. Presentation may read the clock through its ViewModel,
  never directly.
- Slot windows are computed from **local wall-clock time**, so a DST change shifts them rather than
  breaking them. Store the IANA timezone identifier alongside every timestamp.
- Compare instants, not formatted strings, and never compare a `DateTime` in one zone against one
  in another without normalizing first.
- A test that depends on the real clock is a flaky test. Advance a fake clock instead.

## Async

- `async`/`await` for single results, `Stream` for sequences. No `.then()` chains, no `catchError`.
- After every `await`, re-check liveness before touching state or context:
  `if (!mounted) return;` in widgets, `if (!ref.mounted) return;` in Riverpod notifiers.
  Skipping this is the most common source of "used after dispose" crashes here.

## Error handling

- `try`/`catch` with the narrowest exception type you can name. Bare `catch (e)` is acceptable
  only at a boundary where the thrown type genuinely isn't known — always with `catch (e, st)`
  so the stack trace survives.
- Never swallow: log, rethrow, or convert into a typed failure. An empty `catch` block is a bug.
- Define domain-specific exceptions in `domain/` and translate infrastructure exceptions
  (`SqliteException`, `DriftWrappedException`, `PlatformException` from notifications or the share
  sheet) into them at the repository boundary, so nothing above `data/` has to know the storage
  engine.
- **A failed write is never silently downgraded to a no-op.** If a recording cannot be saved, the
  user is told, and the entry screen stays in a state they can retry from. Losing a recording
  silently is worse than crashing.

## Logging

Logging is local-only and must never carry note text, emotion selections, or scale values. Log
identifiers, counts, and state transitions. There is no remote sink and no crash reporter — see
`data-integrity-rules.md`.

## Size limits

Functions and methods stay under ~30 lines. Treat this as a smell threshold, not a hard gate:
if a function is long because it is one flat sequence of setup steps, leave it; if it is long
because it does three things, split it.

## Formatting

Line width is **120**. `dart format` defaults to 80, so the width is set in `analysis_options.yaml`:

```yaml
formatter:
  page_width: 120
```

If that key is missing, add it rather than passing `--line-length` by hand — otherwise CI and
local runs disagree.
