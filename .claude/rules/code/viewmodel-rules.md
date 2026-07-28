---
description: "ViewModel layer and Riverpod state management"
paths:
  - "lib/*/presentation/viewmodel/**/*.dart"
  - "lib/*/presentation/viewmodel/*.dart"
---

# ViewModel

A ViewModel turns domain results into the exact state one view needs, and exposes methods for that
view's interactions. It holds presentation logic; business rules stay in `domain/services/`.

## Boundaries

- One ViewModel per file, named `<name>_viewmodel.dart`. Its provider lives in the same file — a
  generated provider and its notifier are one unit, and splitting them adds an import for nothing.
- Call domain **services** only. Do not import repositories, DTOs, Drift, or anything else from
  `data/`.
- No `BuildContext` in a ViewModel, and no `AppRouter`. Navigation and dialogs are the view's job;
  the ViewModel exposes state the view reacts to (`routing-rules.md` § The AppRouter contract).
- **No domain logic.** A ViewModel does not compute slot status, window boundaries, or a daily
  average — it asks a service. If a computation would still be correct in a CLI version of this app,
  it is in the wrong place.
- **No clock.** Do not call `DateTime.now()` to decide whether a slot is open. Ask the domain
  service that derives status, which takes the injected clock. A ViewModel that reads the wall clock
  cannot be tested at a slot boundary.

## Riverpod

This project targets Riverpod 3. Verify specifics against the version in `pubspec.yaml` before
relying on them.

- Use `Notifier` / `AsyncNotifier` (or their `@riverpod` generated equivalents). `StateProvider`,
  `StateNotifierProvider`, and `ChangeNotifierProvider` moved to `package:riverpod/legacy.dart` in
  3.0 — do not introduce new ones.
- In Riverpod 3 the `AutoDispose*` interfaces are merged into the base ones and `Ref` is no longer
  generic: write `Ref`, not `MyThingRef`.
- Control lifetime deliberately. With codegen, providers auto-dispose by default; use
  `@Riverpod(keepAlive: true)` only for state that must outlive its last listener, and say why in a
  comment.
- `ref.watch` inside `build`; `ref.read` inside callbacks and event handlers only.
- Mutate through Notifier methods. Never assign to `state` from outside the notifier.
- **Guard async gaps:** after every `await`, `if (!ref.mounted) return;` before touching `state`.
- Model async state as `AsyncValue` so loading, error, and data are all representable. The one
  exception is `lib/core/presentation/viewmodel/loading_viewmodel.dart`, which drives the global
  overlay and would deadlock on itself.
- Provider logging is centralized in `lib/core/shared/utils/loggers.dart`. Add observers there
  rather than logging inside notifiers. Never log note text, emotions, or scale values.

## Entry ViewModel specifics

The entry screen is the one place where a state bug costs data, so it has extra rules:

- **Save is explicit.** No save-on-change, no autosave on dispose, no save on navigation away. A
  stray slider drag must not become a recording.
- **A failed save leaves the form intact** and surfaces an error the user can retry from. Never
  clear the form optimistically.
- **The window can close while the screen is open.** Recompute status on resume and on a timer, and
  transition the form to read-only when it does — do not let a save land after the window has shut.
- **Never construct a recording with a default scale.** The form's initial state is "nothing
  selected", and Save stays disabled until a scale and at least one emotion exist.

The shape, illustrative only — class, state, and provider names are chosen when the screen is built:

<example>

```dart
@riverpod
class ExampleViewModel extends _$ExampleViewModel {
  @override
  Future<ExampleState> build(DateTime date, int index) =>
      ref.read(exampleQueryServiceProvider).load(date: date, index: index);

  Future<void> save(ExampleDraft draft) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(exampleWriteServiceProvider).save(draft),
    );
    if (!ref.mounted) return;
    state = result;
  }
}
```
</example>

Two things in it are not illustrative: `AsyncValue.guard` around the write, so a failure lands in
`AsyncError` rather than escaping, and the `ref.mounted` check after the await.
