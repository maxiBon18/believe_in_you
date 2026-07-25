---
description: "ViewModel layer and Riverpod state management"
paths:
  - "lib/*/presentation/viewmodel/**/*.dart"
  - "lib/*/presentation/viewmodel/*.dart"
---

# ViewModel

A ViewModel turns domain results into the exact state one view needs, and exposes methods for
that view's interactions. It holds presentation logic; business rules stay in `domain/services/`.

## Boundaries

- One ViewModel per file, named `<name>_viewmodel.dart`. Its provider lives in the same file —
  a generated provider and its notifier are one unit, and splitting them adds an import for
  nothing.
- Call domain **services** only. Do not import repositories, DTOs, Firebase, or anything
  else from `data/`.
- No `BuildContext` in a ViewModel. Navigation and dialogs are the view's job; the ViewModel
  exposes state the view reacts to.

## Riverpod

This project targets Riverpod 3. Verify specifics against the version in `pubspec.yaml` before
relying on them.

- Use `Notifier` / `AsyncNotifier` (or their `@riverpod` generated equivalents).
  `StateProvider`, `StateNotifierProvider`, and `ChangeNotifierProvider` moved to
  `package:riverpod/legacy.dart` in 3.0 — do not introduce new ones.
- In Riverpod 3 the `AutoDispose*` interfaces are merged into the base ones and `Ref` is no
  longer generic: write `Ref`, not `MyThingRef`.
- Control lifetime deliberately. With codegen, providers auto-dispose by default; use
  `@Riverpod(keepAlive: true)` only for state that must outlive its last listener, and say why
  in a comment.
- `ref.watch` inside `build`; `ref.read` inside callbacks and event handlers only.
- Mutate through Notifier methods. Never assign to `state` from outside the notifier.
- **Guard async gaps:** after every `await`, `if (!ref.mounted) return;` before touching `state`.
- Model async state as `AsyncValue` so loading, error, and data are all representable. The one
  exception is `lib/core/presentation/viewmodel/loading_viewmodel.dart`, which drives the global
  overlay and would deadlock on itself.
- Provider logging is centralized in `lib/core/shared/utils/loggers.dart`. Add observers there
  rather than logging inside notifiers.

<example>

```dart
@riverpod
class SubscriptionListViewModel extends _$SubscriptionListViewModel {
  @override
  Future<List<SubscriptionEntity>> build() =>
      ref.read(subscriptionServiceProvider).activeSubscriptions();

  Future<void> refresh() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(subscriptionServiceProvider).activeSubscriptions(),
    );
    if (!ref.mounted) return;
    state = result;
  }
}
```
</example>
