# Examples

File paths and symbol names are placeholders. These examples calibrate the *shape and depth* of a
report — root cause, data impact, fix, scanning cost — not the identifiers a finding names. They are
ordered by scanning cost, which is the axis the skill optimises: 0 files, 2, 4, and abort.

## 1. Intended behaviour — stop before scanning

**User Input:**

- Problem: "I missed a day and now the chart line has a hole in it. It should connect."

**Output:**

Not a bug — this is specified behaviour.

A period with no record produces no data point, and the line breaks rather than bridging the gap
(`data-integrity-rules.md` § 4). Connecting across the gap would draw a value you never entered, and
a reader of the output cannot tell a drawn value from a recorded one.

The gap is also information in its own right: the occasions that go unrecorded are not a random
sample, so a bridged line would smooth over exactly the ones worth discussing.

If the *rendering* of the gap is what feels wrong — too subtle, ambiguous with a flat stretch — that
is a legitimate UI issue and worth changing. The underlying behaviour is not.

**Files Read:** 0

---

## 2. Known failure mode — Level 0 match

**User Input:**

- Problem: "Since the clocks changed, the afternoon range starts an hour early."

**Output (Step 4 Level 0 → matched failure mode 1, read the boundary-computation service and its
test):**

**Root Cause:** Boundary computation derives the span by subtracting epoch milliseconds and adding
fractions back as `Duration`. Across a DST transition the local day is 23 or 25 hours, so a
duration-based offset lands an hour off the intended wall-clock time.

**Data Impact:** None to stored values — existing records can reconstruct their own boundaries, so
they are unaffected. Only the live computation for the transition day was wrong.

**Fix:** Rewrote the span arithmetic at `<name>_service.dart:28–41` to operate on local wall-clock
components and construct each boundary as a local `DateTime`.
Added two tests evaluating instants across a spring-forward and a fall-back transition.

**Files Read:** 2

---

## 3. Data impact is the important part of the report

**User Input:**

- Problem: "Some days in March show a value I'm sure I didn't enter."

**Output (Step 4 Level 1 → Grep for the default literal, then read the mapper and its callers):**

**Root Cause:** The row → entity mapping at `<mapper>.dart:31` maps a null column to a midpoint
default. Rows written by the v2 migration have a null there, so every one of them reads back as that
value — `data-integrity-rules.md` § 1.

**Data Impact:** **Affected.** 14 rows between 2026-03-02 and 2026-03-19 have a null column and are
currently displayed as the default. They are not corrupted in storage — the null is intact — but
every file generated since the migration shows a fabricated value for those records. If any of them
were shared, they should be regenerated after the fix.

**Fix:** Removed the default and changed the mapper to return a nullable entity, letting the
derivation service classify the absent value. Updated the two call sites to handle null.

No repair script is proposed: the underlying rows are correct, so the fix alone restores accurate
display. Had the null been written *as* the default, the affected rows would need deleting rather
than correcting — a fabricated value cannot be recovered, only removed.

**Files Read:** 4

---

## 4. Insufficient information — abort and ask

**User Input:**

- Problem: "The reminders are unreliable."

**Output:**

Unable to diagnose with the information provided. Scheduling problems in this app split into at
least four unrelated causes: a missing or revoked OS permission, an uninitialized timezone database,
a failure to re-register after reboot, and the suppression check for an already-handled item firing
incorrectly.

Please provide:

- Which item, and whether it is always the same one.
- Whether it is late, early, missing, or duplicated.
- Whether it stopped after a reboot, an app update, or a configuration change.
- Device and platform, and the OS version.
- Whether the item in question had already been handled when it was due.

Note that the ask is specific to the four causes named. "Please provide more detail" would put the
work back on the user without telling them which detail decides between the candidates.
