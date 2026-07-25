---
description: "Data layer: Drift tables, DTOs, data sources, repository implementations"
paths:
  - "lib/*/data/**/*.dart"
  - "lib/*/data/*.dart"
---

# Data Layer

The data layer owns everything storage-specific. Nothing above it should be able to tell whether
data came from Drift, a file, or platform storage.

There is no network in v1. If you find yourself reaching for an HTTP client, stop — see
`data-integrity-rules.md` § 6.

## Imports

Import from `domain/` (to implement its interfaces and return its entities) and from infrastructure
packages. Never import `presentation/`.

## Layout

| Contents                     | Location            |
| ---------------------------  | ------------------- |
| DTO interfaces               | `data/repo/dto/`    |
| DTO (generated)              | `data/source/dto/`  |
| Drift tables and database    | `data/source/db/`   |
| Data source interfaces       | `data/repo/source/` |
| Data source implementations  | `data/source/`      |
| Repository implementations   | `data/repo/`        |

This mirrors `CLAUDE.md` § Where things live exactly: the `data/repo/` side holds the contracts a
repository is written against (data source and DTO interfaces), and the `data/source/` side holds
the concrete, storage-specific implementations.

- Each data source implementation (`data/source/`) implements its interface in `data/repo/source/`.
- Each repository implementation (`data/repo/`) implements its interface in `domain/repo/`.

## Drift

- Table definitions live in `data/source/db/`, one table per file, `<name>_table.dart`.
- The generated row class **is** the DTO for that table. Do not hand-write a parallel DTO to sit
  beside it; map the row class straight to an entity.
- Every table carries `id` (UUID text), `updatedAt`, and `deletedAt`. Soft delete everywhere —
  a hard delete only happens through the delete-all-data action.
- Queries live in the data source, never in the repository body and never in a service.
- Re-run codegen after any change to a table (command in `CLAUDE.md`).

### Migrations

Schema changes are a **confirm-first** action. Every migration ships with a test that starts from
the previous schema version, applies the migration, and asserts that existing rows survive intact.
See `data-integrity-rules.md` § 8 — losing recordings here is unrecoverable.

## DTOs

`freezed` + `json_serializable` is used for the **export payload only** — the JSON dump offered
from Settings. Everything else is a Drift row class.

Freezed 3 requires the class to be `abstract` (single class) or `sealed` (union), and it no longer
generates `when`/`map` — use Dart pattern matching instead:

<example>

```dart
@freezed
abstract class ExportBundleDto with _$ExportBundleDto {
  const factory ExportBundleDto({
    required int schemaVersion,
    @JsonKey(name: 'exported_at') required DateTime exportedAt,
    required List<RecordingDto> recordings,
  }) = _ExportBundleDto;

  factory ExportBundleDto.fromJson(Map<String, Object?> json) => _$ExportBundleDtoFromJson(json);
}
```

</example>

## Repositories

- Repository implementations take data sources through the constructor and talk only to them — no
  direct database access inside the repository body.
- **Mapping happens here.** A repository accepts and returns entities on its public surface and
  converts row → entity internally. A DTO or Drift row class must never escape `data/`. Keep the
  conversion in an extension (`recording_dto_mapper.dart`) rather than inline, so it is testable on
  its own.
- Translate infrastructure exceptions into domain exceptions at this boundary (see § Error handling
  in `coding-conventions.md`). A `SqliteException` reaching a ViewModel is a bug.
- Caching and retry policy live in the repository, not in the data source and not in a service.

### Repository rules specific to this app

- **A read never writes.** Fetching a day's slots must not create rows for the missing ones. The
  repository returns the recordings that exist; a domain service decides what the gaps mean.
- **No default row.** There is no `Recording.empty()` and no neutral placeholder returned when a
  row is absent. Return `null` or an empty collection and let the domain service handle it.
- **Denormalize the window at write time.** `windowStart`, `windowEnd`, and the IANA timezone are
  written onto the row when the recording is saved, so entries stay self-describing even if the
  schedule history is lost.
- **`schedules` is append-only.** A change writes a new row with a new `effectiveFrom`; it never
  updates an existing one. Rewriting a schedule row silently relabels historical slots.
- **Enforce one row per slot in the database**, not only in code: a unique constraint on
  `(date(refersTo), slotIndex)`.
