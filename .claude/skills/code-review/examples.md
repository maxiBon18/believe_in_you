# Examples

## 1. Clean review — all checks passed

| Area                | Result | Issues                                        |
| ------------------- | ------ | --------------------------------------------- |
| Data Integrity      | ✅     | No synthesized values, no writes on read      |
| Architecture        | ✅     | Layer boundaries respected                    |
| Time Correctness    | ✅     | Clock injected, no direct `DateTime.now()`    |
| Code Quality        | ✅     | Naming and formatting consistent              |
| Null Safety         | ✅     | No unnecessary nullable types                 |
| Widget Quality      | ✅     | Proper decomposition, const constructors used |
| State Management    | ✅     | Providers correctly scoped                    |
| Error Handling      | ✅     | Failed save leaves form retryable             |
| Performance         | ✅     | No aggregation in build methods               |
| Privacy & Security  | ✅     | No user data in logs, no transport deps       |
| Accessibility       | ✅     | Semantics on scale faces, targets ≥ 48dp      |
| Dependencies        | ✅     | Import order correct, no unused packages      |

All checks passed. Verified 4 files, 0 violations, 0 warnings.

## 2. Review with an integrity violation

```
🛑 Data integrity violation found — do not merge. Detail below.
```

| Area                | Result | Issues                                    |
| ------------------- | ------ | ----------------------------------------- |
| Data Integrity      | 🔴     | Default scale substituted for missing row |
| Architecture        | ✅     | Layer boundaries respected                |
| Time Correctness    | 🔴     | `DateTime.now()` in a domain service      |
| Code Quality        | ⚠️     | Inconsistent naming in 1 file             |
| Null Safety         | ✅     | No unjustified force-unwraps              |
| Widget Quality      | ✅     | Proper decomposition                      |
| State Management    | 🔴     | `ref.read` used in build method           |
| Error Handling      | ⚠️     | Missing feedback on failed save           |
| Performance         | ✅     | No issues                                 |
| Privacy & Security  | 🔴     | Note text written to log                  |
| Accessibility       | ✅     | Targets and semantics correct             |
| Dependencies        | ✅     | Import order correct                      |

### 🔴 Violations

**1. Data Integrity — Default scale substituted for a missing recording**

- **File:** `lib/entry/data/repo/recording_dto_mapper.dart:31`
- **Rule:** `data-integrity-rules.md` § 1 — "Never synthesize a mood value."
- **Issue:** `scale: row.scale ?? 3` supplies a neutral value when the column is null.
- **Why it matters:** This writes a value the user never reported, and it is indistinguishable
  downstream from a real one. The bias is directional — unlogged slots are disproportionately bad
  ones — so the chart flattens exactly where the signal is strongest, and the psychologist reads
  the fabricated 3 as an observation.
- **Fix:** Make the mapper return `RecordingEntity?` and let `SlotStatusService` decide what an
  absent row means. Delete the `??`.

**2. Time Correctness — `DateTime.now()` in a domain service**

- **File:** `lib/entry/domain/services/slot_status_service.dart:22`
- **Rule:** `coding-conventions.md` § Time — "Never call `DateTime.now()` in `domain/` or `data/`."
- **Issue:** `final now = DateTime.now();` instead of `_clock.now()`.
- **Why it matters:** Slot-boundary behaviour becomes untestable. The rule that a save at
  `windowEnd - 1ms` succeeds and one at `windowEnd` does not cannot be covered without a fake clock,
  and that boundary is the one the no-editing invariant rests on.
- **Fix:** Inject `Clock` through the constructor and call `_clock.now()`. Register it in
  `core/shared/controllers/di.dart` per `di-rules.md` § Core registrations.

**3. State Management — `ref.read` in build method**

- **File:** `lib/entry/presentation/ux/entry_page.dart:32`
- **Rule:** `viewmodel-rules.md` § Riverpod — "`ref.watch` inside `build`; `ref.read` inside
  callbacks and event handlers only."
- **Issue:** `ref.read(slotEntryViewModelProvider)` inside `build()` prevents the widget rebuilding
  when the slot transitions from open to closed.
- **Why it matters:** The window can close while the screen is visible. Without a rebuild the form
  stays editable and a save can land after the window has shut.
- **Fix:** Replace with `ref.watch(slotEntryViewModelProvider)`.

**4. Privacy & Security — Note text written to log**

- **File:** `lib/entry/presentation/viewmodel/slot_entry_viewmodel.dart:58`
- **Rule:** Code Review § Privacy & Security — "Note text, emotion selections, and scale values must
  never be logged."
- **Issue:** `log('saving draft: $draft')` interpolates the full draft, including the note.
- **Fix:** Log the slot index and status transition only: `log('saving slot $slotIndex')`.

### ⚠️ Warnings

**1. Code Quality — Inconsistent naming**

- **File:** `lib/entry/domain/services/mood_summary_service.dart:15`
- **Rule:** `coding-conventions.md` § Naming — "Use lowerCamelCase for variables and methods."
- **Issue:** Method named `Compute_Average` instead of `computeAverage`.
- **Fix:** Rename to `computeAverage`.

**2. Error Handling — Missing feedback on failed save**

- **File:** `lib/entry/presentation/ux/entry_page.dart:71`
- **Rule:** `viewmodel-rules.md` § Entry ViewModel specifics — "A failed save leaves the form intact
  and surfaces an error the user can retry from."
- **Issue:** The `AsyncError` state is handled by returning an empty `SizedBox`, so a failed save is
  silent and the user believes the recording was stored.
- **Fix:** Render an inline error with a retry action, keeping the current form values.

## 3. Intended behaviour reported as a finding — how to handle it

A reviewer flagged that `MoodSummaryService` produces no data point for a day with no recordings,
and proposed carrying the previous day's value forward so the chart line stays continuous.

**This is not a finding.** The broken line is the specified behaviour
(`data-integrity-rules.md` § 4, `business_analysis_complete.md` §4.8). Record it as follows and do
not open a violation:

> Not a violation — a day with zero recordings intentionally yields no point. Carrying a value
> forward would fabricate an observation. See `data-integrity-rules.md` § 4.