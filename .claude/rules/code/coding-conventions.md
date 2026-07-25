---
description: "Naming, typing, null safety, and error handling for all Dart code"
paths:
  - "lib/**/*.dart"
  - "test/**/*.dart"
---

# Coding Conventions

`analysis_options.yaml` is the enforcement layer. These rules cover what the linter cannot check.

## Naming

| Element            | Convention                       | Example                               |
| ------------------ | -------------------------------- | ------------------------------------- |
| Files              | `snake_case` + type suffix       | `home_page.dart`, `payment_dto.dart`  |
| Classes            | `PascalCase`                     | `SubscriptionEntity`                  |
| Variables, methods | `camelCase`                      | `totalAmount`, `fetchSubscriptions()` |
| Private members    | `_` prefix                       | `_controller`, `_calculateTotal()`    |
| Booleans           | `is`/`has`/`should`/`can` prefix | `isActive`, `hasExpired`, `canDelete` |

File name by type — the suffix is how every other rule locates a file, so it is not optional:

| Type                        | Pattern                     |
| --------------------------- | --------------------------- |
| Page                        | `<feature>_page.dart`       |
| Widget                      | `<name>_widget.dart`        |
| DTO                         | `<name>_dto.dart`           |
| Entity                      | `<name>_entity.dart`        |
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
  then catches every missed case when a new variant is added.
- Use `=>` for single-expression functions and getters.

## Constants and magic values

No literal numbers, durations, keys, or endpoint fragments inline. Put them in the feature's
`shared/constants/`. User-visible strings are covered by the localization rule in
`presentation-layer-rules.md`.

## Null safety

- No `!` where a null check, `??`, or early return would do. `!` is acceptable only immediately
  after a check the compiler cannot see through — comment why.
- No `?.` chain deeper than two levels; bind an intermediate variable instead.
- A nullable return type needs a doc comment stating what `null` means. If `null` has no distinct
  meaning, return a non-nullable type with a default.

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
  (`DioException`, `FirebaseException`) into them at the repository
  boundary, so nothing above `data/` has to know the transport.

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
