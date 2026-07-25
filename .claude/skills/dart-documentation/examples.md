# Examples

## 1. Class with public API — normal case

```dart
/// Derives the display state of a slot from its window, the clock, and whether
/// a recording exists.
///
/// Status is never persisted: it is computed on every read from the schedule
/// that was in effect on that date. See `data-integrity-rules.md` § 2.
class SlotStatusService {
  /// Returns the status of the slot described by [window].
  ///
  /// Pass the [recording] for that slot, or `null` if none was saved.
  /// [installedAt] is the instant the first schedule was written, used to tell
  /// a genuine skip from a slot that closed before the app existed.
  SlotStatus statusOf({
    required SlotWindow window,
    required DateTime installedAt,
    required RecordingEntity? recording,
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
Future<RecordingEntity?> findBySlot({required DateTime date, required int slotIndex});
```

Without the second paragraph, the next reader adds `?? neutral` to remove the nullable and the
record quietly starts lying.

## 3. Documenting non-obvious branch ordering

```dart
/// Debounced so a slider drag does not emit one draft per pixel.
///
/// The not-applicable check runs before any clock comparison: a slot that
/// closed before installation must never surface as a skip, and comparing it
/// against `now` first would classify it as one.
SlotStatus _classify(SlotWindow window, DateTime installedAt) {
  // ...
}
```

## 4. Enum with values

```dart
/// The state of one daily slot, as shown on the entry screen.
enum SlotStatusKind {
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

`skipped` and `notApplicable` look interchangeable from the names and are not — which is exactly why
both need a line.

## 5. Removing a bad doc comment — edge case

Before (bad — restates the name):

```dart
/// The recording repository.
class RecordingRepository {
  /// Gets a recording by ID.
  Future<RecordingEntity> getById(String id) async { ... }
}
```

After (good — explains purpose and behavior):

```dart
/// Provides read and write access to recordings in the local database.
///
/// Reads never create rows: a missing recording is returned as `null`, and the
/// domain layer decides what its absence means.
class RecordingRepository {
  /// Fetches the recording with the given [id].
  ///
  /// Returns `null` if no matching row exists. Throws [StorageException] if the
  /// database cannot be read.
  Future<RecordingEntity?> getById(String id) async { ... }
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
/// final windows = service.windowsFor(
///   date: DateTime(2026, 3, 14),
///   schedule: Schedule(wake: TimeOfDay(hour: 7, minute: 0),
///                      sleep: TimeOfDay(hour: 23, minute: 0)),
/// );
/// // windows[0].start == 07:00, windows[2].end == 23:00
/// ```
List<SlotWindow> windowsFor({required DateTime date, required ScheduleEntity schedule}) {
  // ...
}
```

Note the sample uses round synthetic values, not something that reads like a real person's day.
