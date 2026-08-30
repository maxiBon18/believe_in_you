# Examples

Class and method names below are placeholders — nothing here is a naming decision. What the examples
calibrate is the *content* of a comment: what it explains, in how many sentences, and when it cites a
rule. Use whatever the code you are documenting is actually called.

## 1. Class with public API — normal case

```dart
/// Derives the display state of a time range from its boundaries, the instant
/// it is evaluated at, and whether a record exists.
///
/// Status is never persisted: it is computed on every read from the
/// configuration that was in effect on that date. See
/// `data-integrity-rules.md` § 3.
class ExampleStatusService {
  /// Returns the status of the range described by [range].
  ///
  /// Pass the [record] for that range, or `null` if none was saved.
  /// [installedAt] is the instant the app first stored anything, used to tell a
  /// range the user let pass from one that closed before the app existed.
  ExampleStatus statusOf({
    required ExampleRange range,
    required DateTime installedAt,
    required ExampleRecord? record,
  }) {
    // ...
  }
}
```

## 2. Documenting a deliberate absence — the highest-value case here

```dart
/// Loads the record for a range, or `null` if the user did not save one.
///
/// Returns `null` rather than a neutral placeholder on purpose. A synthesized
/// value is indistinguishable from a real one downstream, and the occasions a
/// user skips are not a random sample — so a default would flatten the output
/// exactly where the signal is strongest. See `data-integrity-rules.md` § 1.
Future<ExampleRecord?> findByRange({required DateTime date, required int index});
```

Without the second paragraph, the next reader adds `?? neutral` to remove the nullable and the
record quietly starts lying.

## 3. Documenting non-obvious branch ordering

```dart
/// Classifies a range whose window has closed.
///
/// The never-applicable check runs before any time comparison: a range that
/// closed before installation must never surface as something the user skipped,
/// and comparing it against `now` first would classify it as one.
ExampleStatus _classify(ExampleRange range, DateTime installedAt) {
  // ...
}
```

The summary says what the method does; the body paragraph explains the one thing a reader would
otherwise "simplify". Both are needed — a body paragraph attached to a summary that describes some
other method is worse than no comment, because it reads as authoritative.

## 4. Enum with values

```dart
/// The state of one range, as shown on the capture screen.
enum ExampleStatusKind {
  /// The range has not opened yet. Visible, not editable.
  locked,

  /// The range is open. Editable until it closes.
  open,

  /// A record exists. Permanently read-only.
  completed,

  /// The range closed with no record. Terminal — there is no way back.
  missed,

  /// The range closed before the app was installed. Excluded from coverage
  /// metrics and never drawn as a gap.
  notApplicable,
}
```

The last two look interchangeable from their names and are not — which is exactly why both need a
line.

## 5. Removing a bad doc comment — edge case

Before (bad — restates the name):

```dart
/// The record repository.
class ExampleRepository {
  /// Gets a record by ID.
  Future<ExampleRecord> getById(String id) async { ... }
}
```

After (good — explains purpose and behavior):

```dart
/// Provides read and write access to records in the local database.
///
/// Reads never create rows: a missing record is returned as `null`, and the
/// domain layer decides what its absence means.
class ExampleRepository {
  /// Fetches the record with the given [id].
  ///
  /// Returns `null` if no matching row exists. Throws [StorageException] if the
  /// database cannot be read.
  Future<ExampleRecord?> getById(String id) async { ... }
}
```

## 6. Code sample for non-obvious usage

```dart
/// Splits the configured span into the ranges that apply on [date].
///
/// The span may cross midnight, in which case the "day" is the date the span
/// started. Ranges are half-open: `[start, end)`, so a save at `end` belongs to
/// no range.
///
/// ```dart
/// // span 07:00 → 23:00: ranges.first.start == 07:00, ranges.last.end == 23:00
/// final ranges = service.rangesFor(date: date, config: config);
/// ```
List<ExampleRange> rangesFor({required DateTime date, required ExampleConfig config}) {
  // ...
}
```

A sample earns its place only where prose cannot carry the point — here, that the last range's end
is the configured end rather than midnight. Round synthetic values, never something that reads like
a real person's data.
