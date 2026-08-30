---
description: "Navigation: go_router behind the AppRouter contract, route configs, redirects, and external launch"
paths:
  - "lib/core/presentation/ux/routing/**/*.dart"
  - "lib/core/domain/routing/**/*.dart"
  - "lib/*/presentation/ux/pages/*_page.dart"
  - "lib/main.dart"
---

# Navigation

Navigation is **`go_router`**, reached only through the abstract `AppRouter` contract. The
`GoRouter` instance itself is a detail of `core/presentation/ux/routing/`; nothing outside that
directory imports `package:go_router/go_router.dart`.

## Why the contract stays

`go_router` gives path parsing, deep links, and redirects. It does not give the two things this app
needs on top:

- **Typed, validated arguments.** `GoRouterState` hands every argument over as `String?` from
  `pathParameters` and `uri.queryParameters`, or as an `Object?` `extra`. Casting them is how a
  malformed external payload becomes a crash or, worse, a write against the wrong record.
- **Navigation without `BuildContext`.** `context.go(...)` puts navigation in the widget tree and
  makes it awkward to fake in tests. Intent goes through `AppRouter`, which holds the `GoRouter` and
  needs no context.

So destinations stay a **sealed route-config type**. Strings live in the `GoRoute` paths and in the
config's own `location` getter, nowhere else.

## Destinations

The set of destinations is decided feature by feature, as each screen is built. What is fixed is
their form: every destination is a variant of the sealed `AppRoute` type, carrying its arguments as
typed fields, plus two members — the `location` it serialises to, and a parse that validates a
`GoRouterState` back into it.

Any destination reachable from outside the app — a deep link, a notification, a share intent —
validates every argument it carries, because the input is not the app's own (§ External launch).

The shape, illustrative only:

<example>

```dart
sealed class AppRoute {
  const AppRoute();

  /// The path this config serialises to. The only place a destination string is built.
  String get location;
}

final class ExampleDetailRoute extends AppRoute {
  const ExampleDetailRoute({required this.date});

  final DateTime date;

  @override
  String get location => '/example/${_yyyymmdd(date)}';

  /// Returns `null` when the state does not describe a valid destination.
  static ExampleDetailRoute? tryParse(GoRouterState state) {
    final DateTime? date = _tryParseYyyymmdd(state.pathParameters['date']);
    return date == null ? null : ExampleDetailRoute(date: date);
  }
}
```

</example>

`tryParse` returns `null`; it does not throw, and it does not substitute a plausible value for an
unparsable one. A route that invents an argument fabricates the state every screen behind it is
derived from (`data-integrity-rules.md` § 1).

Exhaustive `switch` over `AppRoute` is what makes adding a destination break every site that has to
change. Do not add a `default` branch to any of them.

## The AppRouter contract

`AppRouter` is an **interface in `core/domain/routing/`**, implemented in
`core/presentation/ux/routing/` over a `GoRouter`. It is the only navigation surface the rest of the
app sees.

- Registered in GetIt (`di-rules.md`). Never constructed at a call site.
- Exposes intent (`go`, `push`, `pop`, `replace`) over `AppRoute` values. No `BuildContext`
  parameter, no `Widget` literal, no path string.
- **ViewModels do not navigate.** A ViewModel exposes state; the view decides what that state means
  for navigation. A ViewModel holding an `AppRouter` is a violation
  (`viewmodel-rules.md` § Boundaries).

<example>

```dart
// core/domain/routing/
abstract interface class AppRouter {
  void go(AppRoute route);
  void push(AppRoute route);
  void replace(AppRoute route);
  void pop();
}
```

</example>

These bypass the contract and are violations wherever they appear outside
`core/presentation/ux/routing/`: `context.go` / `context.push` / `context.goNamed` and the rest of
the `GoRouter` `BuildContext` extensions, `GoRouter.of(context)`, and
`Navigator.of(context).push(MaterialPageRoute(...))`.

## Redirects

Preconditions that must hold before a destination resolves are stated in `CLAUDE.md` — a screen that
cannot function without some state must not be reachable without it, or it is a crash waiting for a
cold start.

They are implemented as `go_router`'s top-level `redirect` — one place, not a `redirect` per
`GoRoute`. A redirect **redirects only**: it never throws, and it never creates the state it found
missing. Fabricating it there would put invented values underneath everything derived afterwards
(`data-integrity-rules.md` § 1).

The `redirect` callback runs on **state read once per resolution**, never on a database round-trip.
`redirect` is on the path to first frame, and an `await` there is time charged against the app's
time-to-task budget (`presentation-layer-rules.md` § Performance). Keep the decision a pure function
of already-loaded state and hand it a `refreshListenable` so it re-runs when that state changes.

Returning `null` from `redirect` means "no redirect" — write that branch explicitly rather than
falling off the end of a chain of `if`s.

## Adding a destination

1. Add the variant to the sealed `AppRoute` type, with its typed arguments as fields, its
   `location`, and its validating parse.
2. Add the matching `GoRoute` to the router configuration, with a `builder` that calls the parse and
   sends an invalid state to the fallback destination.
3. Confirm the page class carries the app's widget prefix and lives in
   `lib/<feature>/presentation/ux/pages/`.
4. Decide whether any redirect precondition applies to it, and say so explicitly rather than by
   omission.

Changing navigation or routes is **confirm-first**. Ask before step 1.

## Unknown routes

`errorBuilder` (or `onException`) is configured once on the router and renders a plain
not-found destination. It never silently rewrites an unknown path to a real screen — a deep link
that lands nowhere is a bug worth seeing, not a redirect to hide.

## Observers

`navigatorObservers` are registered once on the `GoRouter`, not per page. Observers log
**route names or paths only** unless the line is guarded by `kDebugMode`. A path or an `extra` can
carry user data; logging either in a release build leaks it. Under `kDebugMode` the full config may
be logged. See `data-integrity-rules.md` § 5 and `coding-conventions.md` § Logging.

## External launch

A notification tap, a deep link, or any other OS-delivered entry point opens a destination the app
did not construct itself. Two rules make that safe:

- The payload is untrusted input. Turn it into an `AppRoute` through the same validating parse as a
  typed-in path, and fall back to the app's default destination if it does not validate. Never cast
  it, and never pass it through `extra` unparsed.
- **Domain state is recomputed on arrival.** An external entry point can be triggered long after it
  was created, so the screen derives what it may do now rather than trusting what the payload
  implied. The payload's age is not evidence about current state — only the domain service is
  (`data-integrity-rules.md` § 3).
