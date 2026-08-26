# Examples

Class and method names below are placeholders — nothing here is a naming decision. What the examples
calibrate is the *content* of a comment: what it explains, in how many sentences, and when it cites a
rule. Use whatever the code you are documenting is actually called.

## 1. Class with public API — normal case

```dart
/// Derives the display state of a slot from its window, the instant it is
/// evaluated at, and whether a recording exists.
///
/// Status is never persisted: it is computed on every read from the schedule
/// that was in effect on that date. See `data-integrity-rules.md` § 2.
class ExampleStatusService {
  /// Returns the status of the slot described by [window].
  ///
  /// Pass the [recording] for that slot, or `null` if none was saved.
  /// [installedAt] is the instant the first schedule was written, used to tell
  /// a genuine skip from a slot that closed before the app existed.
  ExampleStatus statusOf({
    required ExampleWindow window,
    required DateTime installedAt,
    required ExampleRecording? recording,
  }) {
    // ...
  }
}
```

## 2. Documenting a deliberate absence — the highest-value case here

```dart
/// Loads the recording for a slot, or `null` if the user did not save one.
///
/// Returns `null` rather than a neutral placeholder on purpose. A synthesized
/// reading is indistinguishable from a real one downstream, and unlogged slots
/// are disproportionately bad ones — so a default would flatten the trend
/// exactly where the signal is strongest. See `data-integrity-rules.md` § 1.
Future<ExampleRecording?> findBySlot({required DateTime date, required int index});
```

Without the second paragraph, the next reader adds `?? neutral` to remove the nullable and the
record quietly starts lying.

## 3. Documenting non-obvious branch ordering

```dart
/// Classifies a slot whose window has closed.
///
/// The not-applicable check runs before any time comparison: a slot that
/// closed before installation must never surface as a skip, and comparing it
/// against `now` first would classify it as one.
ExampleStatus _classify(ExampleWindow window, DateTime installedAt) {
  // ...
}
```

The summary says what the method does; the body paragraph explains the one thing a reader would
otherwise "simplify". Both are needed — a body paragraph attached to a summary that describes some
other method is worse than no comment, because it reads as authoritative.

## 4. Enum with values

```dart
/// The state of one daily slot, as shown on the entry screen.
enum ExampleStatusKind {
  /// The window has not opened yet. Visible, not editable.
  locked,

  /// The window is open. Editable until it closes.
  open,

  /// A recording exists. Permanently read-only.
  completed,

  /// The window closed with no recording. Terminal — there is no backfill.
  skipped,

  /// The window closed before the app was installed. Excluded from the
  /// completion rate and never drawn as a gap.
  notApplicable,
}
```

The last two look interchangeable from their names and are not — which is exactly why both need a
line.

## 5. Removing a bad doc comment — edge case

Before (bad — restates the name):

```dart
/// The recording repository.
class ExampleRepository {
  /// Gets a recording by ID.
  Future<ExampleRecording> getById(String id) async { ... }
}
```

After (good — explains purpose and behavior):

```dart
/// Provides read and write access to recordings in the local database.
///
/// Reads never create rows: a missing recording is returned as `null`, and the
/// domain layer decides what its absence means.
class ExampleRepository {
  /// Fetches the recording with the given [id].
  ///
  /// Returns `null` if no matching row exists. Throws [StorageException] if the
  /// database cannot be read.
  Future<ExampleRecording?> getById(String id) async { ... }
}
```

## 6. Code sample for non-obvious usage

```dart
/// Splits the waking span into the three slot windows for [date].
///
/// The span runs from the schedule's wake time to its sleep time and may cross
/// midnight, in which case the "day" is the wake date. Windows are half-open:
/// `[start, end)`, so a save at `end` belongs to no slot.
///
/// ```dart
/// // wake 07:00, sleep 23:00 → windows[0].start == 07:00, windows[2].end == 23:00
/// final windows = service.windowsFor(date: date, schedule: schedule);
/// ```
List<ExampleWindow> windowsFor({required DateTime date, required ExampleSchedule schedule}) {
  // ...
}
```

A sample earns its place only where prose cannot carry the point — here, that the third window's end
is the sleep time rather than midnight. Round synthetic values, never something that reads like a
real person's day.
