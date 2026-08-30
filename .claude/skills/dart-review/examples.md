# Examples

File paths and symbol names below are placeholders — the point of each example is the *shape* of the
finding, not the identifier. Use whatever the code under review is actually called.

The full summary table is defined in [reference.md](reference.md) § Output Format; the tables below
are excerpted to three rows to show how the **Issues** column reads, not to restate the row list.

## 1. Clean review — all checks passed

| Area                | Result | Issues                                     |
| ------------------- | ------ | ------------------------------------------ |
| Data Integrity      | ✅     | No synthesized values, no writes on read   |
| Time Correctness    | ✅     | Instants passed in, no `DateTime.now()`   |
| Error Handling      | ✅     | Failed save leaves form retryable          |

All checks passed. Verified 4 files, 0 violations, 0 warnings.

Note what the Issues column does even on a pass: it names *what was verified*, not "OK". A table of
twelve ✅ with no detail tells the reader nothing about whether the check was real.

## 2. Review with an integrity violation

```
🛑 Data integrity violation found — do not merge. Detail below.
```

| Area                | Result | Issues                                    |
| ------------------- | ------ | ----------------------------------------- |
| Data Integrity      | 🔴     | Default value substituted for missing row |
| Time Correctness    | 🔴     | `DateTime.now()` in a domain service      |
| Error Handling      | ⚠️     | Missing feedback on failed save           |

### 🔴 Violations

**1. Data Integrity — Default value substituted for a missing record**

- **File:** `lib/<feature>/data/repo/<mapper>.dart:31`
- **Rule:** `data-integrity-rules.md` § 1 — "Never synthesize a user-recorded value."
- **Issue:** The row → entity mapping supplies a neutral midpoint with `??` when the stored value is
  null.
- **Why it matters:** This stores a value the user never entered, and it is indistinguishable
  downstream from a real one. The bias is directional — the occasions a user skips are not a random
  sample — so the output flattens exactly where the signal is strongest, and a reader takes the
  fabricated value for an observation.
- **Fix:** Make the mapper return a nullable entity and let the derivation service decide what an
  absent row means. Delete the `??`.

**2. Time Correctness — `DateTime.now()` in a domain service**

- **File:** `lib/<feature>/domain/services/<name>_service.dart:22`
- **Rule:** `CLAUDE.md` § Time handling.
- **Issue:** `final now = DateTime.now();` instead of taking the instant as a parameter.
- **Why it matters:** Boundary behaviour becomes untestable. The rule that an action one millisecond
  before a boundary closes succeeds and one exactly at the close does not cannot be covered when the
  service reads the wall clock itself, and that boundary is what the surrounding invariant rests on.
- **Fix:** Take the instant as a parameter and let the caller supply it. Check `CLAUDE.md`
  § Time handling before introducing any other mechanism.

**3. Privacy & Security — User-entered text written to a release log**

- **File:** `lib/<feature>/presentation/viewmodel/<name>_viewmodel.dart:58`
- **Rule:** Code Review § Privacy & Security — "User-recorded values reach a log only behind a
  `kDebugMode` guard."
- **Issue:** `log('saving draft: $draft')` interpolates the full draft, including free text, with no
  guard, so it ships in release.
- **Fix:** Wrap it in `if (kDebugMode) { … }`, or log the record identifier and the status
  transition only.

Note the difference in weight: the two integrity-adjacent findings earn a *Why it matters* that
names the real consequence; the log leak is self-evident once stated and gets none.

### ⚠️ Warnings

**1. Error Handling — Missing feedback on failed save**

- **File:** `lib/<feature>/presentation/ux/<name>_page.dart:71`
- **Rule:** `viewmodel-rules.md` § ViewModels on a write path — "A failed save leaves the form
  intact and surfaces an error the user can retry from."
- **Issue:** The `AsyncError` state is handled by returning an empty `SizedBox`, so a failed save is
  silent and the user believes the data was stored.
- **Fix:** Render an inline error with a retry action, keeping the current form values.

## 3. Intended behaviour reported as a finding — how to handle it

A reviewer flagged that a summary produces no data point for a period with no records, and proposed
carrying the previous value forward so the chart line stays continuous.

**This is not a finding.** The broken line is the specified behaviour
(`data-integrity-rules.md` § 4). Record it as follows and do not open a violation:

> Not a violation — a period with zero records intentionally yields no point. Carrying a value
> forward would fabricate an observation. See `data-integrity-rules.md` § 4.
