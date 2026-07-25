# Examples

## Test Plan Summary Format

| Type        | Cases  | Features                                    | Est. Time |
| ----------- | ------ | ------------------------------------------- | --------- |
| Unit        | 18     | SlotWindow, SlotStatus, MoodSummary, Repo   | ~20s      |
| Widget      | 7      | ScaleSelector, EmotionChips, EntryPage      | ~25s      |
| Migration   | 2      | Schema v1→v2, v2→v3                         | ~5s       |
| Integration | 3      | Onboarding→first recording, Notification tap, Export | ~90s |
| **Total**   | **30** |                                             | **~140s** |

Invariant suite: 10 of 10 included.

## Test Case Format

| ID     | Type   | Target                          | Description                                       | Rationale                                                                     | Deps       | Priority |
| ------ | ------ | ------------------------------- | ------------------------------------------------- | ----------------------------------------------------------------------------- | ---------- | -------- |
| UT-001 | Unit   | `SlotWindowService.windowsFor()`| Splits a 16h waking span into three equal windows  | Every other slot behaviour depends on these boundaries being right             | None       | Critical |
| UT-002 | Unit   | `SlotStatusService.statusOf()`  | Returns `open` inside the window                   | The entry form is editable only in this state                                  | FakeClock  | Critical |
| UT-003 | Unit   | `SlotStatusService.statusOf()`  | Returns `completed` when a recording exists        | A saved slot must never reopen for editing                                     | FakeClock  | Critical |
| UT-004 | Unit   | `MoodSummaryService.daily()`    | Averages three completed slots                     | The chart and the export both read this value                                  | None       | High     |
| WT-001 | Widget | `MoodDiaryScaleSelector`        | Shows the word and face for the selected value     | An unanchored scale drifts; the label is what prevents it                      | None       | High     |
| WT-002 | Widget | `MoodDiaryEntryPage`            | Save disabled until a scale and one emotion exist  | Prevents an empty or partial recording being written                           | Fake VM    | Critical |
| IT-001 | Integration | Onboarding → first recording | Completes onboarding and saves one recording       | Validates the full chain: schedule write → window computation → save → chart   | FakeClock  | Critical |

### Invariant Tests (prefix `INV-`)

| ID     | Type   | Target                 | Description                                              | Rationale                                                                                              | Deps       | Priority |
| ------ | ------ | ---------------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ | ---------- | -------- |
| INV-01 | Unit   | `RecordingRepository`  | Reading an empty day writes no rows                      | A read that writes turns every chart render into fabricated data                                        | In-mem DB  | Critical |
| INV-02 | Unit   | `recordingDtoMapper`   | Null scale maps to null entity, not a default            | A default reads back as a real observation in the clinician's export                                    | None       | Critical |
| INV-04 | Unit   | `MoodSummaryService`   | Zero recordings yields no point, not 0                   | A zero would plot as the worst possible day on a day with no data at all                                | None       | Critical |
| INV-05 | Unit   | `RecordingService`     | Save at `windowEnd` is rejected                          | The no-backfill rule rests entirely on this boundary; one millisecond of slack removes it               | FakeClock  | Critical |
| INV-08 | Migration | Schema v2 → v3      | All pre-existing recordings survive with identical values | This is the developer's own clinical record with no backup — a lossy migration is unrecoverable         | Real schemas | Critical |

### Edge Case Tests (suffix `-E`)

| ID       | Type   | Target                          | Description                                                | Rationale                                                                                   | Deps          | Priority |
| -------- | ------ | ------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------- | ------------- | -------- |
| UT-001-E | Unit   | `SlotWindowService.windowsFor()`| Sleep time after midnight resolves to the wake date         | Late bedtimes are the normal case for this user; getting the date wrong misfiles a whole day | None          | Critical |
| UT-002-E | Unit   | `SlotStatusService.statusOf()`  | Open at `windowEnd - 1ms`, skipped at `windowEnd`           | Half-open interval — a closed interval would let one instant belong to two slots             | FakeClock     | Critical |
| UT-003-E | Unit   | `SlotWindowService.windowsFor()`| Spring-forward transition inside window 2                   | A duration-based offset silently shifts boundaries by an hour twice a year                   | FakeClock     | High     |
| UT-005-E | Unit   | `SlotStatusService.statusOf()`  | Window closed before `installedAt` returns `notApplicable`  | Otherwise the first day shows phantom skips and depresses the completion rate on day one     | FakeClock     | High     |
| UT-006-E | Unit   | schedule resolution             | Changing the schedule leaves yesterday's windows unchanged  | A rewritten schedule silently relabels history and changes a week that is already over       | In-mem DB     | Critical |
| WT-003-E | Widget | `MoodDiaryEntryPage`            | Window closes while the screen is open → becomes read-only  | Without it a save lands after the window shut, violating the no-backfill rule from the UI    | FakeClock     | Critical |
| WT-004-E | Widget | `MoodDiaryScaleSelector`        | Renders at the largest system text scale without clipping   | The scale selector is the most-used control; clipping makes the app unusable at large sizes  | None          | Medium   |
| IT-002-E | Integration | Notification tap            | Tapping a reminder after its window closed opens read-only  | A notification can be tapped hours later; the screen must not accept a late save             | FakeClock     | High     |

## Missing Packages STOP Format

```
🛑 The following packages are required but missing from dev_dependencies:

| Package        | Version | Required by                              |
| -------------- | ------- | ---------------------------------------- |
| mocktail       | ^1.0.4  | UT-002, WT-002 (service and VM fakes)    |
| drift_dev      | ^2.x    | INV-08 (migration test harness)          |
| clock          | ^1.1.1  | FakeClock helper, all time-dependent cases |

Add these to pubspec.yaml? (y/n)
```

## Excluded Test Type Format

| Type        | Include? | Reason                                                                                                    |
| ----------- | -------- | --------------------------------------------------------------------------------------------------------- |
| Unit        | ✅        | History has date-range and aggregation logic                                                              |
| Widget      | ✅        | Heatmap cells have four distinct states that must be visually distinguishable                             |
| Integration | ❌        | Onboarding→first recording already exercises navigation into History; a separate flow duplicates coverage |

## Report Format — invariant line first

```text
Invariant suite: 10/10 passed.

| Type        | Total | Pass | Fail | Skip |
| ----------- | ----- | ---- | ---- | ---- |
| Unit        | 18    | 18   | 0    | 0    |
| Widget      | 7     | 6    | 1    | 0    |
| Migration   | 2     | 2    | 0    | 0    |
| Integration | 3     | 3    | 0    | 0    |
```

If an invariant test fails, the line reads `Invariant suite: 9/10 — INV-05 FAILED` and the run stops
there. An invariant failure is not a test to be fixed; it means the code violates a rule in
`data-integrity-rules.md`.
