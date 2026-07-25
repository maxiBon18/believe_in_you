---
description: "Routes and navigation"
paths:
  - "lib/routes.dart"
  - "lib/core/presentation/ux/routing_service.dart"
  - "lib/*/presentation/ux/**/*_page.dart"
---

# Routes

Navigation is named-only and centralized, so every destination is discoverable from one file and
deep links have a single source of truth.

> **Decide this before Phase 0.** `CLAUDE.md` specifies a custom router on Navigator 2.0, while the
> mechanics below describe a `Map<String, WidgetBuilder>` — Navigator 1.0 named routes. Both are
> defensible for an app with this many destinations; what isn't defensible is having the two
> documents disagree. Pick one and rewrite the other section to match.

## Destinations

| Route | Screen |
| --- | --- |
| `/` | Splash |
| `/onboarding` | Onboarding flow |
| `/home` | Slot entry and trend chart |
| `/history` | Calendar heatmap |
| `/history/day` | Day detail, read-only |
| `/settings` | Settings list |
| `/settings/schedule` | Wake and sleep times |
| `/settings/notifications` | Reminder configuration |
| `/settings/support` | Support resources |
| `/settings/export` | Weekly export |

Two guards exist and both run before `/home` is reachable: onboarding must be complete, and a
schedule row must exist. A `/home` without a schedule cannot compute a window and is a crash waiting
for a cold start.

## Adding a route

Three edits, all in `lib/routes.dart`, in this order:

1. Declare the constant: `static const String <name>Route = '/<routeName>';`
2. Add the entry to the `routes` map, keyed by that constant, valued by the page widget.
3. Confirm the page's class name matches the `MoodDiary<Name>Page` convention.

A constant without a map entry compiles fine and fails at runtime — check both.

<example>

```dart
static const String historyDayRoute = '/history/day';

// ...
final Map<String, WidgetBuilder> routes = {
  historyDayRoute: (_) => const MoodDiaryHistoryDayPage(),
};
```
</example>

## Navigating

- Always navigate by name through the routing service in
  `lib/core/presentation/ux/routing_service.dart`. No inline `MaterialPageRoute`, no
  `Navigator.push` with a widget literal — those bypass the observer and the route stack stops
  matching.
- Route observation is wired in `lib/core/shared/controllers/custom_navigator_observer.dart`.
  Register new observers there rather than attaching them per-page. Observers log route names only;
  never route arguments, which can carry a date and slot index.
- Pass arguments as a single typed object, and validate on arrival. `Object?` route arguments are
  unchecked, so an unvalidated cast crashes only on the device.
- ViewModels do not navigate. A ViewModel exposes state; the view decides what that means for
  navigation.

## Notification launch

A notification tap opens the app directly on `/home` at the slot the notification was for. Two rules
make this safe:

- The payload carries the date and slot index, and both are validated on arrival like any other
  route argument.
- The target slot's status is recomputed on arrival. A notification can be tapped after its window
  has closed, and the screen must open read-only in that case rather than accepting a save.
