---
description: "Data layer: DTOs, data sources, repository implementations"
paths:
  - "lib/*/data/**/*.dart"
  - "lib/*/data/*.dart"
---

# Data Layer

The data layer owns everything transport- and storage-specific. Nothing above it should be able
to tell whether data came from HTTP, or a cache.

## Imports

Import from `domain/` (to implement its interfaces and return its entities) and from
infrastructure packages. Never import `presentation/`.

## Layout

| Contents                     | Location            |
| ---------------------------  | ------------------- |
| DTO interfaces | `data/repo/dto/`   |
| DTO (generated) | `data/source/dto/` |
| Data source interfaces       | `data/repo/source/` |
| Data source implementations  | `data/source/`      |
| Repository implementations   | `data/repo/`        |

This mirrors `CLAUDE.md` § Where things live exactly: the `data/repo/` side holds the contracts a
repository is written against (data source and DTO interfaces), and the `data/source/` side holds
the concrete, transport-specific implementations. Most DTOs are concrete generated classes, so they
live in `data/source/dto/`; add a `data/repo/dto/` interface only when a DTO genuinely needs one.

- Each data source implementation (`data/source/`) implements its interface in `data/repo/source/`.
- Each repository implementation (`data/repo/`) implements its interface in `domain/repo/`.

## DTOs

Every DTO is generated — hand-written `fromJson`/`toJson` from the API silently. Use
`freezed` + `json_serializable` for network/JSON models.

Freezed 3 requires the class to be `abstract` (single class) or `sealed` (union), and it no
longer generates `when`/`map` — use Dart pattern matching instead:

<example>

```dart
@freezed
abstract class PaymentDto with _$PaymentDto {
  const factory PaymentDto({
    required String id,
    @JsonKey(name: 'amount_cents') required int amountCents,
  }) = _PaymentDto;

  factory PaymentDto.fromJson(Map<String, Object?> json) => _$PaymentDtoFromJson(json);
}
```
</example>

Re-run codegen after any change to an annotated file (command in `CLAUDE.md`).

## Repositories

- Repository implementations take data sources through the constructor and talk only to them —
  no direct `http`/`Dio` access inside the repository body.
- **Mapping happens here.** A repository accepts and returns entities on its public surface,
  and converts DTO → entity internally. A DTO must never escape `data/`. Keep the conversion in
  an extension (`payment_dto_mapper.dart`) rather than inline, so it is testable on its own.
- Translate infrastructure exceptions into domain exceptions at this boundary
  (see § Error handling in `coding-conventions.md`). A `DioException` reaching a ViewModel is a bug.
- Caching, retry, and offline fallback policy live in the repository, not in the data source and
  not in a service.
