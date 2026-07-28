---
description: "Domain layer: entities, services, repository interfaces"
paths:
  - "lib/*/domain/**/*.dart"
  - "lib/*/domain/*.dart"
---

# Domain Layer

The domain layer is the innermost layer: it defines what the app *means*, independent of how data
arrives or how it is displayed. Keeping it dependency-free is what makes services unit testable
without a widget tree, a database, or a fake clock hidden inside a mock.

In this app the domain layer is where the interesting logic actually lives — slot windows, status
derivation, and the daily-average rules are all pure functions over a schedule and a set of
recordings.

## Imports

Import nothing from `data/` or `presentation/`, and nothing SDK-specific (Drift,
`flutter_local_notifications`, `package:flutter/material.dart`). Pure Dart plus
`package:flutter/foundation.dart` if you need `@immutable`.

If you find yourself needing a type from `data/`, the type is misplaced: move it to
`domain/entities/` and have the row class map onto it.

## Layout

| Contents              | Location           |
| --------------------- | ------------------ |
| Entities              | `domain/entities/` |
| Services              | `domain/services/` |
| Repository interfaces | `domain/repo/`     |

Repository interfaces live in `domain/repo/` — not `data/` — because the domain declares what it
needs and `data/` supplies it. That inversion is what keeps the dependency arrow pointing inward.
`domain/repo/` holds repository interfaces and nothing else (see `CLAUDE.md` § Where things live).

## Entities

- Entities are the only domain type allowed to cross into `presentation/`.
- Entities model the app's concepts, not the storage format. If a field only exists because Drift
  needs it, it belongs on the row class instead.
- Prefer immutable entities with value equality.
- Slot status is a **sealed** type, not an enum with a `default` branch anywhere. Its states are
  distinguishable and non-interchangeable — in particular *skipped* and *not applicable* are
  different facts about a closed window. Handle it with exhaustive `switch` so that adding a state
  breaks every site that must change.

## Services

- A service depends on repository **interfaces** only. It never names a class from `data/`, never
  constructs a repository implementation, and never touches a data source directly. Dependencies
  arrive through the constructor (see `di-rules.md`).
- Business rules live here: validation, invariants, calculations, and workflows spanning more than
  one repository. If the rule would still hold in a CLI version of this app, it is a service's job —
  not a ViewModel's.
- Services return entities or typed failures, never row classes and never `Map<String, dynamic>`.
- **Inject the clock.** No `DateTime.now()` anywhere in `domain/`. Every time-dependent service
  takes a `Clock` so slot-boundary behaviour is testable by advancing a fake.

### The logic that belongs here

Four bodies of logic are domain services in this app. How they are split into classes, and what
those classes are called, is decided when the feature that needs them is built — but none of them
may end up in a ViewModel, a widget, or a repository:

- **Window computation** — deriving a date's three windows from the schedule in effect on that
  date. Owns midnight crossing, waking-span validation, and DST.
- **Status derivation** — turning a window, the clock, the installation instant, and the presence
  or absence of a recording into a slot status. Reads only; never writes.
- **Mood summarisation** — daily average over completed slots, the incomplete-day flag, weekly
  statistics, completion rate.
- **Emotion summarisation** — frequency counts over a period.

Each is a pure function over a schedule and a set of recordings, so each is unit-testable with a
fake clock and no database.

These four carry the invariants in `data-integrity-rules.md`, which means they are where a
regression stops being a bug and starts being a wrong clinical record. Take them slowly and cover
them with tests first.

One ordering constraint is not free to change: a slot whose window closed **before the app was
installed** is *not applicable*, and that has to be established before any comparison against the
current time, or the app's first day fills with skips that never happened.
