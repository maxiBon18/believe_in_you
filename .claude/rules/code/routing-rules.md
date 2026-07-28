---
description: "Navigation: the AppRouter contract, route configs, guards, and notification launch"
paths:
  - "lib/core/presentation/ux/routing/**/*.dart"
  - "lib/core/domain/routing/**/*.dart"
  - "lib/*/presentation/ux/pages/*_page.dart"
  - "lib/main.dart"
---

# Navigation

Navigation is a **custom router on Navigator 2.0**, reached only through the abstract `AppRouter`
contract. No `go_router`, no `auto_route`, no other navigation package.

## Why not named routes

A `Map<String, WidgetBuilder>` cannot express what this app needs: guards that run before a
destination is reachable, and route arguments that must be validated rather than cast from
`Object?`. Both are load-bearing here — a home screen reached without a schedule cannot compute a
window, and a notification payload carries a date and a slot that arrive from outside the app.

So destinations are a **sealed route-config type**, not strings. String parsing lives in the
`RouteInformationParser` and nowhere else.

## Destinations

The set of destinations is decided feature by feature, as each screen is built. What is fixed is
their form: every destination is a variant of the sealed `AppRoute` type, carrying its arguments as
typed fields rather than as a `Map` or an `Object?`.

Two carry rules regardless of what they end up called:

- The **support-resources** destination is reachable from Settings permanently and is never pushed
  reactively — see `data-integrity-rules.md` § 7.
- Any destination carrying a date and a slot must validate them, because one of them is reachable
  from a notification payload — see § Notification launch.

The shape, illustrative only:

<example>

```dart
sealed class AppRoute {
  const AppRoute();
}

final class ExampleDetailRoute extends AppRoute {
  const ExampleDetailRoute({required this.date});
  final DateTime date;
}
```

</example>

Exhaustive `switch` over `AppRoute` is what makes adding a destination break every site that has to
change — the parser, the delegate's page stack, and the guard chain. That is the point of the sealed
type; do not add a `default` branch to any of them.

## The AppRouter contract

`AppRouter` is an **interface in `core/domain/routing/`**, implemented in
`core/presentation/ux/routing/`. It is the only navigation surface the rest of the app sees.

- Registered in GetIt (`di-rules.md`). Never constructed at a call site.
- Exposes intent (`go`, `push`, `pop`, `replace`) over `AppRoute` values. No `BuildContext`
  parameter, no `Widget` literal, no `MaterialPageRoute`.
- **ViewModels do not navigate.** A ViewModel exposes state; the view decides what that state means
  for navigation. A ViewModel holding an `AppRouter` is a violation
  (`viewmodel-rules.md` § Boundaries).

Anything that reaches for `Navigator.of(context).push(MaterialPageRoute(...))` bypasses the guards
and the observer, and the router's stack stops matching the real one.

## Guards

Two guards run before the home destination resolves, in this order:

1. Onboarding is complete.
2. A schedule exists.

Home without a schedule cannot compute a window and is a crash waiting for a cold start. Guards
redirect; they do not throw, and they do not create the missing schedule. Inventing a schedule would
fabricate window boundaries for every slot derived afterwards.

Guards are pure functions of state read once per resolution. A guard that hits the database on every
`build` puts work on the path to first frame — see `presentation-layer-rules.md` § Performance and
the 20-second entry budget.

## Adding a destination

1. Add the variant to the sealed `AppRoute` type, with its typed arguments as fields.
2. Handle it in the parser (string ↔ config) and in the delegate's page stack.
3. Confirm the page class matches `BelieveInYou<Name>Page` and lives in
   `lib/<feature>/presentation/ux/pages/`.
4. Decide whether either guard applies to it, and say so explicitly rather than by omission.

Changing navigation or routes is **confirm-first** (`CLAUDE.md`). Ask before step 1.

## Observers

Route observation is registered once, where the router is built — not per page. Observers log
**route names only**. A route config carries a date and a slot; logging the config logs health data.
See `data-integrity-rules.md` § 6.

## Notification launch

A notification tap opens the home destination at the slot the notification was for. Two rules make
this safe:

- The payload is untrusted input. Parse it into an `AppRoute` through the same validation path as a
  deep link, and fall back to plain home if it does not validate. Never cast it.
- **The target slot's status is recomputed on arrival.** A notification can be tapped after its
  window has closed, and the screen must open read-only in that case rather than accepting a save.
  The payload's age is not evidence about the window — only the status-derivation service is
  (`data-integrity-rules.md` § 3).
