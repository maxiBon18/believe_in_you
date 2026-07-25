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
- `SlotStatus` is a **sealed** type (`Locked`, `Open`, `Completed`, `Skipped`, `NotApplicable`).
  Handle it with exhaustive `switch` so that adding a variant breaks every site that must change.

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

### Services this app owns

| Service | Responsibility |
| --- | --- |
| `SlotWindowService` | Computes the three windows for a date from the schedule in effect on that date. Owns midnight crossing, span validation, and DST. |
| `SlotStatusService` | Derives `SlotStatus` from window, clock, installation instant, and the presence of a row. Never writes. |
| `MoodSummaryService` | Daily average over completed slots, completeness flag, weekly statistics, completion rate. |
| `EmotionSummaryService` | Frequency counts over a period. |

These four carry the invariants in `data-integrity-rules.md`. Changes to them are the changes most
likely to break something a clinician relies on — take them slowly and cover them with tests first.

<example>

```dart
// domain/services/slot_status_service.dart
class SlotStatusService {
  const SlotStatusService(this._clock, this._windows);
  final Clock _clock;
  final SlotWindowService _windows;

  SlotStatus statusOf({
    required SlotWindow window,
    required DateTime installedAt,
    required RecordingEntity? recording,
  }) {
    if (recording != null) return const SlotStatus.completed();
    if (!window.end.isAfter(installedAt)) return const SlotStatus.notApplicable();

    final now = _clock.now();
    if (now.isBefore(window.start)) return SlotStatus.locked(opensAt: window.start);
    if (now.isBefore(window.end)) return SlotStatus.open(closesAt: window.end);
    return const SlotStatus.skipped();
  }
}
```
</example>

Note the order of the branches: `notApplicable` is checked before the clock comparisons, so a slot
that closed before the app existed never surfaces as a skip.
