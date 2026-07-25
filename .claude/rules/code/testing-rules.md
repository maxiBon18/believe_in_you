---
description: "Test structure, doubles, and what to test per layer"
paths:
  - "test/**/*.dart"
  - "integration_test/**/*.dart"
---

# Testing

<!-- NEW FILE — the original rule set had no testing rules, so an agent asked to "add tests"
     had no convention to follow. Adjust the package names below to match pubspec.yaml. -->

## Structure

- `test/` mirrors `lib/`: `lib/payments/domain/services/payment_service.dart` is tested by
  `test/payments/domain/services/payment_service_test.dart`.
- One top-level `group` per class under test, named after that class.
- Test names state behavior, not method names: `'returns only active subscriptions'`, not
  `'test activeSubscriptions'`.

## What to test at each layer

| Layer      | Test with                | Fake out                       |
| ---------- | ------------------------ | ------------------------------ |
| Services   | plain unit tests         | repository interfaces          |
| Repositories | unit tests             | data source interfaces         |
| ViewModels | `ProviderContainer.test()` | services, via provider overrides |
| Widgets    | `testWidgets`            | ViewModels, via provider overrides |

Because repository and data source interfaces live behind abstractions, nothing above `data/`
needs a network stub or an in-memory database. If a test needs one, a dependency is being
constructed instead of injected — fix the code, not the test.

## Doubles

- Use the mocking package already in `pubspec.yaml`; do not add a second one.
- Prefer hand-written fakes for interfaces with two or three methods — they read better than
  mock setup and don't break on signature changes.
- Riverpod: override providers on the container rather than mocking `ref`. Use
  `ProviderContainer.test()` so disposal is automatic.

## Rules of thumb

- A bug fix lands with a test that fails before the fix.
- No test asserts on generated output (`.g.dart`, `.freezed.dart`) — test the behavior that uses it.
- No `await Future.delayed(...)` to wait for state. Pump, or await the future you actually care about.
- Widget tests assert on user-visible outcomes (`find.text`, semantics), not on widget internals.

Run tests with the commands in `CLAUDE.md`.
