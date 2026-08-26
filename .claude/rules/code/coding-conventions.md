---
description: "Naming, typing, null safety, and error handling for all Dart code"
paths:
  - "lib/**/*.dart"
  - "test/**/*.dart"
---

# Coding Conventions

`analysis_options.yaml` is the enforcement layer. These rules cover what the linter cannot check,
plus the handful of lints strict enough to change how code is shaped.

Names come from the fixed vocabulary in `CLAUDE.md` § Vocabulary. `recording`, not entry or log;
`scale`, not score or rating. A symbol named off-vocabulary is a naming violation even when the
casing is right.

## Naming

| Element            | Convention                       | Shape                                 |
| ------------------ | -------------------------------- | ------------------------------------- |
| Files              | `snake_case` + type suffix       | `<name>_page.dart`, `<name>_dto.dart` |
| Classes            | `PascalCase`                     | `<Name>Entity`, `<Name>Service`       |
| Variables, methods | `camelCase`                      | `<name>`, `fetch<Name>()`             |
| Private members    | `_` prefix                       | `_controller`, `_compute()`           |
| Booleans           | `is`/`has`/`should`/`can` prefix | `isOpen`, `hasValue`, `canEdit`       |

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

## What the linter already enforces

`analysis_options.yaml` is stricter than `flutter_lints` alone, in ways that change how you write.
These are not preferences — code that ignores them fails `fvm dart analyze`:

| Rule | Consequence |
| --- | --- |
| `always_specify_types` | `final String name = …`, never `final name = …`. Type arguments too: `<String>[]`, `Map<String, Object?>{}` |
| `always_use_package_imports` | `package:believe_in_you/…` everywhere. **No relative imports, not even within a feature** |
| `always_declare_return_types` | Every function and method writes its return type, including `void` |
| `always_put_required_named_parameters_first` | Required named parameters precede optional ones in the signature |
| `prefer_single_quotes` | `'text'`, not `"text"` |
| `constant_identifier_names` | `lowerCamelCase` constants — not `SCREAMING_CASE` |
| `avoid_print` | `print()` is an error. See § Logging |

`always_specify_types` and the "prefer records" guidance below coexist: a record still needs its
type written out, `final (int, String) pair = …`.

## Typing

- No `dynamic` unless an external API forces it; add a comment saying which one.
- No `as` cast without a preceding `is` check, or use `case Foo foo` pattern matching instead.
- `final` for anything never reassigned; `const` wherever the value is compile-time constant.
- `late` only when initialization before first access is guaranteed by construction order.
- `@immutable` on classes whose fields are all final.
- Prefer records over one-off classes when returning two or three values with no behavior.
- Prefer exhaustive `switch` expressions over `if`/`else` chains on sealed types — the compiler
  then catches every missed case when a new variant is added. Slot status is the case where this
  matters most: adding a state must break every site that renders one, so model it as a sealed type
  and never add a `default` branch.
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
  emotion set is missing. A neutral scale or an empty emotion list supplied by `??` is a bug, not
  defensive coding. See `data-integrity-rules.md`.

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

Logging is local-only. There is no remote sink and no crash reporter — see
`data-integrity-rules.md`.

**Release builds must never carry note text, emotion selections, or scale values into a log line.**
Unconditional logging is therefore limited to identifiers, counts, and state transitions.

**Debug builds may log values and state in full**, note text included — it is the developer's own
device and the data never leaves it. Any such line is guarded so it cannot survive into release:

```dart
if (kDebugMode) {
  log('saving draft: $draft');
}
```

The guard is the rule, not the content: a value-carrying log line without `kDebugMode` around it is
the defect, and a guarded one is not. `avoid_print` still makes bare `print()` an analyzer error in
either mode — use `log()` or `debugPrint()`.

## Size limits

Functions and methods stay under ~30 lines. Treat this as a smell threshold, not a hard gate:
if a function is long because it is one flat sequence of setup steps, leave it; if it is long
because it does three things, split it.

## Formatting

Line width is **120**, set once in `analysis_options.yaml`:

```yaml
formatter:
  page_width: 120
```

`fvm dart format .` reads that key, so it needs no arguments. Never pass `--line-length`: a
hand-supplied width diverges from CI the moment someone forgets it. `.vscode/settings.json` sets
`editor.rulers: [120]` to match visually — that is a guide only, and changing it formats nothing.
