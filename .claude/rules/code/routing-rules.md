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

## Adding a route

Three edits, all in `lib/routes.dart`, in this order:

1. Declare the constant: `static const String <name>Route = '/<routeName>';`
2. Add the entry to the `routes` map, keyed by that constant, valued by the page widget.
3. Confirm the page's class name matches the `BelieveInYou<Name>Page` convention.

A constant without a map entry compiles fine and fails at runtime — check both.

<example>

```dart
static const String subscriptionDetailRoute = '/subscriptionDetail';

// ...
final Map<String, WidgetBuilder> routes = {
  subscriptionDetailRoute: (_) => const BelieveInYouSubscriptionDetailPage(),
};
```
</example>

## Navigating

- Always navigate by name through the routing service in
  `lib/core/presentation/ux/routing_service.dart`. No inline `MaterialPageRoute`, no
  `Navigator.push` with a widget literal — those bypass the observer and the route stack stops
  matching analytics.
- Route observation is wired in `lib/core/shared/controllers/custom_navigator_observer.dart`.
  Register new observers there rather than attaching them per-page.
- Pass arguments as a single typed object, and validate on arrival. `Object?` route arguments
  are unchecked, so an unvalidated cast crashes only on the device.
- ViewModels do not navigate. A ViewModel exposes state; the view decides what that means for
  navigation.
