---
description: "Dependency injection with GetIt, and its boundary with Riverpod"
paths:
  - "lib/*/shared/controllers/*.dart"
  - "lib/main.dart"
---

# Dependency Injection

## Where registrations live

- Feature dependencies: `lib/<feature>/shared/controllers/di.dart`.
- Dependencies used by two or more features: `lib/core/shared/controllers/di.dart`.
- Register in construction order — database → data source → repository → service → router —
  so a dependency is always available before the thing that needs it.

## GetIt and Riverpod split

| Object                                                        | Container |
| ------------------------------------------------------------- | --------- |
| Drift database, data sources, repositories, services          | GetIt     |
| Notification scheduler, PDF generator, file share adapter     | GetIt     |
| `AppRouter`                                                   | GetIt     |
| ViewModels / notifiers and all UI-facing state                | Riverpod  |

Two containers holding the same object is how you end up with two instances and a bug that only
reproduces after a hot restart. ViewModels reach GetIt-held services through a Riverpod provider
that reads from `GetIt.I`, so there is exactly one lookup path.

## Core registrations

Some things are registered in `core/` because more than one feature needs them, and because
registering them twice would be a correctness bug rather than a style problem:

- **The Drift database** — eager singleton, one instance for the process. A second instance means
  two connections to the same file and a migration race.
- **Window computation** — read by entry, history, export, and the notification scheduler. Its
  output must be identical across all four, so it is registered once and never reconstructed.
- **`AppRouter`** — eager singleton. The router owns the navigation stack; a second instance means
  two stacks and guards that run against the wrong one (`routing-rules.md`).

Promote anything else to `core/` only once a second feature actually consumes it.

## Registration style

- Register against the **interface**, supply the implementation:
  `getIt.registerLazySingleton<SomeRepository>(() => SomeRepositoryImpl(getIt()))`.
  Registering a concrete type makes it impossible to swap in a fake for tests.
- `registerLazySingleton` for anything stateless and reusable; `registerFactory` when each caller
  needs a fresh instance. Reach for `registerSingleton` only when construction must happen eagerly
  at startup — the database qualifies; almost nothing else does.
- Never call `GetIt.I` from inside `domain/` or `data/` classes. Dependencies arrive through
  constructors; the service locator is only touched at composition roots (`di.dart` and providers).
- Tests reset the container between cases (`getIt.reset()`) and override with fakes at registration
  time.
