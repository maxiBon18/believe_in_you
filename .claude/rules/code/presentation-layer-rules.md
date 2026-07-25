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

- Page file `<feature>_page.dart`; page class starts with `MoodDiary` (`MoodDiaryHomePage`).
- Every page uses `MoodDiaryPage` as its root widget — it supplies the app chrome, safe-area
  handling, and loading overlay wiring. A page that builds its own `Scaffold` bypasses all three.
- Widget classes start with `MoodDiary` (`MoodDiaryScaleSelector`).
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

## Performance

Standard Flutter practice applies (`const` constructors, `ListView.builder` for long or unbounded
lists, no expensive work in `build()`). Project-specific additions:

- Cache `MediaQuery.of(context)` in a local variable when used more than once in a build.
- Watch the narrowest slice of state that a widget needs (`ref.watch(p.select(...))`) rather than
  the whole object, so an unrelated field change doesn't rebuild the subtree.
- Animate with `AnimatedBuilder`/`AnimatedWidget` driving a leaf, not `setState` on a parent.
- Chart data is computed by a domain service and passed in ready to plot. No aggregation inside
  `build()`.
- Move CPU-bound work off the UI isolate with `Isolate.run` (or `compute`). PDF rendering qualifies.

**Cold start is a product requirement, not a nicety.** The entry budget is under 20 seconds from
cold launch to saved recording, and launch is the part the user cannot skip. Nothing blocking goes
on the path to first frame — no eager chart computation, no export warm-up, no schedule recompute
beyond the current day.

## Style and theme

- No hardcoded colors, text styles, or spacing in widget code.
- Colors: `lib/core/presentation/ux/theme/color.dart`. Theme components:
  `lib/core/presentation/ux/theme/theme.dart`.
- Express a new design decision as a `ThemeData` token first. Only when the token model can't carry
  it should you create a dedicated `MoodDiary*` widget.
- No user-visible string literals in widgets — route them through the app's localization layer.
  Strings are maintained in English and Italian.

### Mood colour rule

**Never use a red-to-green ramp for mood values.** A red bad day reads as a failure and a green good
day reads as a success; the data is neither. Use a single hue varying in lightness and saturation.

This applies to the trend chart, the History heatmap, the scale selector, and the export. Semantic
red stays available for genuinely destructive actions (delete all data) and nowhere else.

### Scale assets

The five scale faces are **bundled assets**, not system emoji glyphs. Platform emoji rendering
differs sharply between iOS, Android vendors, and OS versions, and a face that reads as *sad* on one
device reads as *distressed* on another. The face is a scale anchor, so its appearance is fixed.

## Copy

The tone rules in `data-integrity-rules.md` § 5 are enforced here, since this is where copy lives:

- No celebratory language, no encouragement, no praise for consistency.
- No admonishing language, no guilt framing, no counting of missed days as a deficit.
- Completion rate is stated neutrally (`18 of 21 recordings`) and never appears on the entry screen.
- Notifications prompt an action; they do not comment on past behaviour.
- Empty states are factual (`No recordings yet`), not motivational.

## Responsive and accessible

- No fixed pixel widths on layout containers; use `Expanded`, `Flexible`, `FractionallySizedBox`,
  or `LayoutBuilder`.
- Handle insets with `SafeArea` / `MediaQuery.padding`; handle keyboard overlap on the note field
  with `SingleChildScrollView` or `resizeToAvoidBottomInset`.
- Text scales with the system setting. Use `MediaQuery.textScalerOf(context)` — `textScaleFactor` is
  removed. The scale selector and emotion chips must survive the largest system text size without
  clipping; they are the two places most likely to break.
- Interactive targets are at least 48x48 logical pixels. The scale selector's five targets are the
  most-used control in the app — size them generously past that minimum.
- Every scale face carries a `Semantics` label with its word, so the scale is usable without seeing
  the image.
- Colour is never the only carrier of meaning. Completed, skipped, and locked slots differ in label
  and shape, not only in tint.
- Platform differences go through `Platform` checks or conditional imports, never through runtime
  feature guessing.
