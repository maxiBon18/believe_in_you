# Examples

## 1. Intended behaviour — stop before scanning

**User Input:**

- Problem: "I missed Tuesday evening and now the chart line has a hole in it. It should connect."

**Output:**

Not a bug — this is specified behaviour.

A day with no recording produces no data point, and the line breaks rather than bridging the gap
(`data-integrity-rules.md` § 4, `business_analysis_complete.md` §4.8). Connecting across the gap
would draw a value you never reported, and the reader of the export cannot tell a drawn line from a
recorded one.

The gap is also information in its own right: evenings that go unrecorded are disproportionately bad
evenings, so a bridged line would smooth over exactly the days worth discussing.

If the *rendering* of the gap is what feels wrong — too subtle, ambiguous with a flat stretch — that
is a legitimate UI issue and worth changing. The underlying behaviour is not.

**Files Read:** 0

---

## 2. User knows the file — minimal scanning

**User Input:**

- Problem: "Crash opening the app first thing in the morning, before my usual wake time."
- Error: `Null check operator used on a null value`
- Suspect file: `lib/entry/presentation/ux/entry_page.dart`

**Output:**

**Root Cause:** `currentWindow!.closesAt` in `MoodDiaryEntryPage.build()` force-unwraps the current
window. Before the first slot opens, no window contains `now`, so `currentWindow` is `null` and the
page crashes rather than rendering the locked state.

**Data Impact:** None. The crash occurs on read, before any write path is reached.

**Fix:** Replaced the force-unwrap with an exhaustive `switch` on `SlotStatus` in
`entry_page.dart:34–48`. The `locked` branch now renders the opening time, matching the four states
in `presentation-layer-rules.md`. Added `entry_page_test.dart` covering a build at
`windowStart - 1ms`.

**Files Read:** 1

---

## 3. Known failure mode — Level 0 match

**User Input:**

- Problem: "Since the clocks changed my afternoon slot starts an hour early."

**Output (Step 4 Level 0 → matched failure mode 1, read `SlotWindowService` and its test):**

**Root Cause:** `SlotWindowService.windowsFor()` computes the waking span by subtracting epoch
milliseconds and adding thirds back as `Duration`. Across a DST transition the local day is 23 or 25
hours, so a duration-based offset lands an hour off the intended wall-clock time.

**Data Impact:** None to stored values — recordings carry their own denormalized window boundaries,
so past entries are unaffected. Only the live computation for the transition day was wrong.

**Fix:** Rewrote the span arithmetic in `slot_window_service.dart:28–41` to operate on local
wall-clock components and construct each boundary as a local `DateTime`, per
`coding-conventions.md` § Time. Added two tests advancing the fake clock across a spring-forward and
a fall-back transition.

**Files Read:** 2

---

## 4. Data impact is the important part of the report

**User Input:**

- Problem: "Some days in March show a 3 that I'm sure I didn't enter."

**Output (Step 4 Level 1 → Grep for `?? 3`, then read the mapper and its callers):**

**Root Cause:** `recording_dto_mapper.dart:31` maps a null `scale` column to `3`. Rows written by
the v2 migration have a null scale, so every one of them reads back as a neutral 3 —
`data-integrity-rules.md` § 1.

**Data Impact:** **Affected.** 14 rows between 2026-03-02 and 2026-03-19 have a null `scale` and are
currently displayed as 3. They are not corrupted in storage — the null is intact — but every export
generated since the migration shows a fabricated value for those slots. If any of those exports were
shared, they should be regenerated after the fix.

**Fix:** Removed the `?? 3` and changed the mapper to return `RecordingEntity?`, letting
`SlotStatusService` classify the absent value. Updated the two call sites to handle null.

No repair script is proposed: the underlying rows are correct, so the fix alone restores accurate
display. Had the null been written *as* a 3, the affected rows would need deleting rather than
correcting — a fabricated value cannot be recovered, only removed.

**Files Read:** 4

---

## 5. Insufficient information — abort and ask

**User Input:**

- Problem: "The reminders are unreliable."

**Output:**

Unable to diagnose with the information provided. Notification problems in this app split into at
least four unrelated causes: a missing or revoked exact-alarm permission on Android, an
uninitialized timezone database, a failure to reschedule after reboot, and the suppression check for
an already-recorded slot firing incorrectly.

Please provide:

- Which slot, and whether it is always the same one.
- Whether the reminder is late, early, missing, or duplicated.
- Whether it stopped after a reboot, an app update, or a schedule change.
- Device and platform, and the Android version if applicable.
- Whether the slot in question already had a recording when the reminder was due.

**Files Read:** 0
