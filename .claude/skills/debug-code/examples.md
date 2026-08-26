# Examples

File paths and symbol names are placeholders. These examples calibrate the *shape and depth* of a
report — root cause, data impact, fix, scanning cost — not the identifiers a finding names. They are
ordered by scanning cost, which is the axis the skill optimises: 0 files, 2, 4, and abort.

## 1. Intended behaviour — stop before scanning

**User Input:**

- Problem: "I missed Tuesday evening and now the chart line has a hole in it. It should connect."

**Output:**

Not a bug — this is specified behaviour.

A day with no recording produces no data point, and the line breaks rather than bridging the gap
(`data-integrity-rules.md` § 4, `business_analysis_en.md` §4). Connecting across the gap
would draw a value you never reported, and the reader of the export cannot tell a drawn line from a
recorded one.

The gap is also information in its own right: evenings that go unrecorded are disproportionately bad
evenings, so a bridged line would smooth over exactly the days worth discussing.

If the *rendering* of the gap is what feels wrong — too subtle, ambiguous with a flat stretch — that
is a legitimate UI issue and worth changing. The underlying behaviour is not.

**Files Read:** 0

---

## 2. Known failure mode — Level 0 match

**User Input:**

- Problem: "Since the clocks changed my afternoon slot starts an hour early."

**Output (Step 4 Level 0 → matched failure mode 1, read the window-computation service and its
test):**

**Root Cause:** Window computation derives the waking span by subtracting epoch milliseconds and
adding thirds back as `Duration`. Across a DST transition the local day is 23 or 25 hours, so a
duration-based offset lands an hour off the intended wall-clock time.

**Data Impact:** None to stored values — past recordings can reconstruct their own window
boundaries, so they are unaffected. Only the live computation for the transition day was wrong.

**Fix:** Rewrote the span arithmetic at `<name>_service.dart:28–41` to operate on local wall-clock
components and construct each boundary as a local `DateTime`.
Added two tests evaluating instants across a spring-forward and a fall-back transition.

**Files Read:** 2

---

## 3. Data impact is the important part of the report

**User Input:**

- Problem: "Some days in March show a 3 that I'm sure I didn't enter."

**Output (Step 4 Level 1 → Grep for `?? 3`, then read the mapper and its callers):**

**Root Cause:** The row → entity mapping at `<mapper>.dart:31` maps a null scale to `3`. Rows
written by the v2 migration have a null scale, so every one of them reads back as a neutral 3 —
`data-integrity-rules.md` § 1.

**Data Impact:** **Affected.** 14 rows between 2026-03-02 and 2026-03-19 have a null scale and are
currently displayed as 3. They are not corrupted in storage — the null is intact — but every export
generated since the migration shows a fabricated value for those slots. If any of those exports were
shared, they should be regenerated after the fix.

**Fix:** Removed the `?? 3` and changed the mapper to return a nullable entity, letting status
derivation classify the absent value. Updated the two call sites to handle null.

No repair script is proposed: the underlying rows are correct, so the fix alone restores accurate
display. Had the null been written *as* a 3, the affected rows would need deleting rather than
correcting — a fabricated value cannot be recovered, only removed.

**Files Read:** 4

---

## 4. Insufficient information — abort and ask

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

Note that the ask is specific to the four causes named. "Please provide more detail" would put the
work back on the user without telling them which detail decides between the candidates.
