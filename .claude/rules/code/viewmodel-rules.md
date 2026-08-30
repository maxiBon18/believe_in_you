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
  provider and its notifier are one unit, and splitting them adds an import for nothing.
- Call domain **services** only. Do not import repositories, DTOs, Drift, or anything else from
  `data/`.
- No `BuildContext` in a ViewModel, and no `AppRouter`. Navigation and dialogs are the view's job;
  the ViewModel exposes state the view reacts to (`routing-rules.md` § The AppRouter contract).
- **No domain logic.** A ViewModel does not derive status, compute boundaries, or aggregate — it
  asks a service. If a computation would still be correct in a CLI version of this app, it is in the
  wrong place.

## Riverpod

This project targets Riverpod 3. Verify specifics against the version in `pubspec.yaml` before
relying on them.

- **No code generation.** Providers are written by hand. Do not use `@riverpod` / `@Riverpod`, do not
  add `riverpod_annotation` or `riverpod_generator` to `pubspec.yaml`, and never emit a
  `part '<name>_viewmodel.g.dart';` directive. A generated provider hides the declaration that
  decides lifetime and argument identity — the two things that go wrong here — and puts
  `build_runner` on the path of every UI change.
- Use `Notifier` / `AsyncNotifier`, and declare the matching `NotifierProvider` /
  `AsyncNotifierProvider` next to the class, passing `TheNotifier.new`. `StateProvider`,
  `StateNotifierProvider`, and `ChangeNotifierProvider` moved to `package:riverpod/legacy.dart` in
  3.0 — do not introduce new ones.
- In Riverpod 3 the `AutoDispose*` interfaces are merged into the base ones and `Ref` is no longer
  generic: write `Ref`, not `MyThingRef`.
- Control lifetime deliberately. Hand-written providers do **not** auto-dispose by default, unlike
  the generated ones the Riverpod docs assume. Write `.autoDispose` on every per-screen ViewModel
  provider; leave it off only for state that must outlive its last listener, and say why in a
  comment.
- A ViewModel parameterised by an argument (an id, a date, an index) is a `.family`. Without codegen
  the argument reaches the notifier through its constructor, not through `build()`.
- `ref.watch` inside `build`; `ref.read` inside callbacks and event handlers only.
- Mutate through Notifier methods. Never assign to `state` from outside the notifier.
- **Guard async gaps:** after every `await`, `if (!ref.mounted) return;` before touching `state`.
- Model async state as `AsyncValue` so loading, error, and data are all representable. The one
  exception is `lib/core/presentation/viewmodel/loading_viewmodel.dart`, which drives the global
  overlay and would deadlock on itself.
- Provider logging is centralized in `lib/core/shared/utils/loggers.dart`. Add observers there
  rather than logging inside notifiers. User-recorded values reach a log line only behind
  `kDebugMode` — see `coding-conventions.md` § Logging. Unguarded, an observer records provider
  names and state transitions, never state values.

## ViewModels on a write path

A screen that writes user data is the one place where a state bug costs data, so it carries extra
rules:

- **Save is explicit.** No save-on-change, no autosave on dispose, no save on navigation away. A
  stray drag or a keystroke must not become a stored record (`data-integrity-rules.md` § 2).
- **A failed save leaves the form intact** and surfaces an error the user can retry from. Never
  clear the form optimistically.
- **Preconditions can expire while the screen is open.** Whatever the domain requires for the write
  to be legal, recompute it on resume and on a timer, and move the form to read-only when it stops
  holding — do not let a save land after the fact.
- **Never construct a record with a default value.** The form's initial state is "nothing selected",
  and Save stays disabled until the user has actually supplied what the record requires
  (`data-integrity-rules.md` § 1).

The shape, illustrative only — class, state, and provider names are chosen when the screen is built:

<example>

```dart
final exampleViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<ExampleViewModel, ExampleState, ({DateTime date, int index})>(ExampleViewModel.new);

class ExampleViewModel extends AsyncNotifier<ExampleState> {
  ExampleViewModel(this.args);

  final ({DateTime date, int index}) args;

  @override
  Future<ExampleState> build() =>
      ref.read(exampleQueryServiceProvider).load(date: args.date, index: args.index);

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
