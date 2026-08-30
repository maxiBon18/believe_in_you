---
description: "Pages, widgets, theming, copy, and responsive UI"
paths:
  - "lib/*/presentation/ux/**/*.dart"
  - "lib/*/presentation/ux/*.dart"
---

# UI Layer

Views render state and forward interactions. They contain no business rules and no direct data
access — everything comes from a ViewModel (`viewmodel-rules.md`).

## Naming and placement

- Page file `<feature>_page.dart` in `presentation/ux/pages/`; the page class carries the app's
  widget prefix and the `Page` suffix — match the prefix the existing pages and widgets use.
- Widget classes carry the same prefix.
- Every page uses the shared app page shell in `core/` as its root widget — it supplies the app
  chrome, safe-area handling, and loading overlay wiring. A page that builds its own `Scaffold`
  bypasses all three.
- Feature widgets: `presentation/ux/widgets/`. Widgets used by two or more features:
  `lib/core/presentation/ux/widgets/`.

## Composition

- `StatelessWidget` unless local mutable state genuinely exists.
- Extract sub-widgets as **classes**, not as private methods returning a `Widget`. A method rebuilds
  with the whole parent; a `const` widget class does not.
- Keep `build()` around 30 lines. Past that, extract a sub-widget with one visual responsibility.
- No logic in `build()`, `initState()`, or `dispose()` beyond wiring.
- Pass `Key` to widgets rendered inside lists or behind conditionals, so element reuse doesn't carry
  the wrong state across.
- Dispose every controller, subscription, and animation you create.
- Navigation goes through the `AppRouter` contract — never `context.go` / `context.push` or another
  `GoRouter` context extension, and never `Navigator.push` with a widget literal
  (`routing-rules.md`). The view decides *when* to navigate; the ViewModel never does.

## Performance

Standard Flutter practice applies (`const` constructors, `ListView.builder` for long or unbounded
lists, no expensive work in `build()`). Project-specific additions:

- Cache `MediaQuery.of(context)` in a local variable when used more than once in a build.
- Watch the narrowest slice of state that a widget needs (`ref.watch(p.select(...))`) rather than
  the whole object, so an unrelated field change doesn't rebuild the subtree.
- Animate with `AnimatedBuilder`/`AnimatedWidget` driving a leaf, not `setState` on a parent.
- Aggregated or chart-ready data is computed by a domain service and passed in ready to render. No
  aggregation inside `build()`.
- Move CPU-bound work off the UI isolate with `Isolate.run` (or `compute`) — document rendering and
  large exports qualify.

**Cold start is a product requirement, not a nicety.** `CLAUDE.md` states the app's time-to-task
budget, and launch is the part the user cannot skip. Nothing blocking goes on the path to first
frame — no eager aggregation, no warm-up of a feature the user has not opened.

## Style and theme

- No hardcoded colors, text styles, or spacing in widget code.
- Theme components: `lib/core/presentation/ux/theme/app_theme.dart`.
- Colors: `lib/core/presentation/ux/theme/app_color.dart`.
- Typography: `lib/core/presentation/ux/theme/app_typography.dart`
- Dimensions: `lib/core/presentation/ux/theme/app_dimensions.dart`
- Express a new design decision as a `ThemeData` token first. Only when the token model can't carry
  it should you create a dedicated prefixed widget.
- No user-visible string literals in widgets — route them through the app's localization layer, in
  every locale the project ships.
- Anchors the user reads as a fixed scale (icons, faces, symbols standing for a value) are **bundled
  assets, not system emoji glyphs**. Platform emoji rendering differs sharply between iOS, Android
  vendors, and OS versions, and a glyph that reads one way on one device reads differently on
  another.

## Copy

Copy is where the project's tone rules are actually enforced — `CLAUDE.md` § Invariants states them,
and this is where they are broken. Two that hold regardless of product:

- Factual over evaluative. State what happened; do not praise or admonish the user for it.
- Empty states describe the absence, they do not motivate.

## Responsive and accessible

- No fixed pixel widths on layout containers; use `Expanded`, `Flexible`, `FractionallySizedBox`,
  or `LayoutBuilder`.
- Handle insets with `SafeArea` / `MediaQuery.padding`; handle keyboard overlap on text input with
  `SingleChildScrollView` or `resizeToAvoidBottomInset`.
- Text scales with the system setting. Use `MediaQuery.textScalerOf(context)` — `textScaleFactor` is
  removed. Compact multi-item controls (selectors, chip rows) must survive the largest system text
  size without clipping; they are the first thing to break.
- Interactive targets are at least 48x48 logical pixels. The app's most-used control is sized
  generously past that minimum.
- Every icon or image carrying meaning has a `Semantics` label with that meaning in words, so the
  control is usable without seeing it.
- Colour is never the only carrier of meaning. States that differ must differ in label or shape, not
  only in tint.
- Platform differences go through `Platform` checks or conditional imports, never through runtime
  feature guessing. Writing either is **confirm-first** — ask before adding the first one to a file.
