---
description: "Pages, widgets, theming, and responsive UI"
paths:
  - "lib/*/presentation/ux/**/*.dart"
  - "lib/*/presentation/ux/*.dart"
---

# UI Layer

Views render state and forward interactions. They contain no business rules and no direct data
access — everything comes from a ViewModel (`viewmodel-rules.md`).

## Naming and placement

- Page file `<feature>_page.dart`; page class starts with `BelieveInYou` (`BelieveInYouHomePage`).
- Every page uses `BelieveInYouPage` as its root widget — it supplies the app chrome, safe-area
  handling, and loading overlay wiring. A page that builds its own `Scaffold` bypasses all three.
- Widget classes start with `BelieveInYou` (`BelieveInYouBalanceCard`).
- Feature widgets: `presentation/ux/widgets/`. Widgets used by two or more features:
  `lib/core/presentation/ux/widgets/`.

## Composition

- `StatelessWidget` unless local mutable state genuinely exists.
- Extract sub-widgets as **classes**, not as private methods returning a `Widget`. A method
  rebuilds with the whole parent; a `const` widget class does not.
- Keep `build()` around 30 lines. Past that, extract a sub-widget with one visual responsibility.
- No logic in `build()`, `initState()`, or `dispose()` beyond wiring.
- Pass `Key` to widgets rendered inside lists or behind conditionals, so element reuse doesn't
  carry the wrong state across.
- Dispose every controller, subscription, and animation you create.

## Performance

Standard Flutter practice applies (`const` constructors, `ListView.builder` for long or unbounded
lists, no expensive work in `build()`). Project-specific additions:

- Cache `MediaQuery.of(context)` in a local variable when used more than once in a build.
- Watch the narrowest slice of state that a widget needs (`ref.watch(p.select(...))`) rather than
  the whole object, so an unrelated field change doesn't rebuild the subtree.
- Animate with `AnimatedBuilder`/`AnimatedWidget` driving a leaf, not `setState` on a parent.
- Network images go through `CachedNetworkImage`.
- Move CPU-bound work off the UI isolate with `Isolate.run` (or `compute`).

## Style and theme

- No hardcoded colors, text styles, or spacing in widget code.
- Colors: `lib/core/presentation/ux/theme/color.dart`. Theme components:
  `lib/core/presentation/ux/theme/theme.dart`.
- Express a new design decision as a `ThemeData` token first. Only when the token model can't
  carry it should you create a dedicated `BelieveInYou*` widget.
- No user-visible string literals in widgets — route them through the app's localization layer.

## Responsive and accessible

- No fixed pixel widths on layout containers; use `Expanded`, `Flexible`, `FractionallySizedBox`,
  or `LayoutBuilder`.
- Handle insets with `SafeArea` / `MediaQuery.padding`; handle keyboard overlap on form pages with
  `SingleChildScrollView` or `resizeToAvoidBottomInset`.
- Text scales with the system setting. Use `MediaQuery.textScalerOf(context)` — `textScaleFactor`
  is removed.
- Interactive targets are at least 48x48 logical pixels, and images and icon-only buttons carry a
  `Semantics` label or `tooltip`.
- Platform differences go through `Platform` checks or conditional imports, never through
  runtime feature guessing.
