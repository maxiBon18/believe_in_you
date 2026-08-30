---
description: "Domain layer: entities, services, repository interfaces"
paths:
  - "lib/*/domain/**/*.dart"
  - "lib/*/domain/*.dart"
---

# Domain Layer

The domain layer is the innermost layer: it defines what the app *means*, independent of how data
arrives or how it is displayed. Keeping it dependency-free is what makes services unit testable
without a widget tree, a database, or a hidden time source.

## Imports

Import nothing from `data/` or `presentation/`, and nothing SDK- or plugin-specific (Drift, a
platform plugin, `package:flutter/material.dart`). Pure Dart plus `package:flutter/foundation.dart`
if you need `@immutable`.

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
- A status whose states are distinguishable and non-interchangeable is a **sealed** type, not an
  enum with a `default` branch anywhere. Handle it with exhaustive `switch` so that adding a state
  breaks every site that must change. Two states that mean different things must not collapse into
  one just because they render the same today.

## Services

- A service depends on repository **interfaces** only. It never names a class from `data/`, never
  constructs a repository implementation, and never touches a data source directly. Dependencies
  arrive through the constructor (see `di-rules.md`).
- Business rules live here: validation, invariants, calculations, and workflows spanning more than
  one repository. If the rule would still hold in a CLI version of this app, it is a service's job —
  not a ViewModel's.
- Derivation from stored facts is a service, not a stored column
  (`data-integrity-rules.md` § 3). Written as pure functions over their inputs, these stay
  unit-testable without a database.
- Services return entities or typed failures, never row classes and never `Map<String, dynamic>`.
