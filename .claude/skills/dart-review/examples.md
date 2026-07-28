# Examples

File paths and symbol names below are placeholders — the point of each example is the *shape* of the
finding, not the identifier. Use whatever the code under review is actually called.

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

- **File:** `lib/entry/data/repo/<mapper>.dart:31`
- **Rule:** `data-integrity-rules.md` § 1 — "Never synthesize a mood value."
- **Issue:** The row → entity mapping supplies a neutral `3` with `??` when the stored scale is
  null.
- **Why it matters:** This writes a value the user never reported, and it is indistinguishable
  downstream from a real one. The bias is directional — unlogged slots are disproportionately bad
  ones — so the chart flattens exactly where the signal is strongest, and the psychologist reads
  the fabricated 3 as an observation.
- **Fix:** Make the mapper return a nullable entity and let the status-derivation service decide
  what an absent row means. Delete the `??`.

**2. Time Correctness — `DateTime.now()` in a domain service**

- **File:** `lib/entry/domain/services/<name>_service.dart:22`
- **Rule:** `coding-conventions.md` § Time — "Never call `DateTime.now()` in `domain/` or `data/`."
- **Issue:** `final now = DateTime.now();` instead of reading the injected clock.
- **Why it matters:** Slot-boundary behaviour becomes untestable. The rule that a save one
  millisecond before the window closes succeeds and one exactly at the close does not cannot be
  covered without a fake clock, and that boundary is the one the no-editing invariant rests on.
- **Fix:** Inject `Clock` through the constructor and call it. Register it in
  `core/shared/controllers/di.dart` per `di-rules.md` § Core registrations.

**3. State Management — `ref.read` in build method**

- **File:** `lib/entry/presentation/ux/<name>_page.dart:32`
- **Rule:** `viewmodel-rules.md` § Riverpod — "`ref.watch` inside `build`; `ref.read` inside
  callbacks and event handlers only."
- **Issue:** `ref.read` on the entry ViewModel's provider inside `build()` prevents the widget
  rebuilding when the slot transitions from open to closed.
- **Why it matters:** The window can close while the screen is visible. Without a rebuild the form
  stays editable and a save can land after the window has shut.
- **Fix:** Replace with `ref.watch`.

**4. Privacy & Security — Note text written to log**

- **File:** `lib/entry/presentation/viewmodel/<name>_viewmodel.dart:58`
- **Rule:** Code Review § Privacy & Security — "Note text, emotion selections, and scale values must
  never be logged."
- **Issue:** `log('saving draft: $draft')` interpolates the full draft, including the note.
- **Fix:** Log the slot identifier and the status transition only.

### ⚠️ Warnings

**1. Code Quality — Inconsistent naming**

- **File:** `lib/history/domain/services/<name>_service.dart:15`
- **Rule:** `coding-conventions.md` § Naming — "Use lowerCamelCase for variables and methods."
- **Issue:** Method named `Compute_Average` instead of `computeAverage`.
- **Fix:** Rename to `computeAverage`.

**2. Error Handling — Missing feedback on failed save**

- **File:** `lib/entry/presentation/ux/<name>_page.dart:71`
- **Rule:** `viewmodel-rules.md` § Entry ViewModel specifics — "A failed save leaves the form intact
  and surfaces an error the user can retry from."
- **Issue:** The `AsyncError` state is handled by returning an empty `SizedBox`, so a failed save is
  silent and the user believes the recording was stored.
- **Fix:** Render an inline error with a retry action, keeping the current form values.

## 3. Intended behaviour reported as a finding — how to handle it

A reviewer flagged that summary computation produces no data point for a day with no recordings, and
proposed carrying the previous day's value forward so the chart line stays continuous.

**This is not a finding.** The broken line is the specified behaviour
(`data-integrity-rules.md` § 4, `business_analysis_en.md` §4). Record it as follows and do
not open a violation:

> Not a violation — a day with zero recordings intentionally yields no point. Carrying a value
> forward would fabricate an observation. See `data-integrity-rules.md` § 4.