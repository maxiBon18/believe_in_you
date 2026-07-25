# Debug-code — Reference

## Diagnostic Strategy

1. **Rule out intended behaviour first.** This project deliberately does several things that look
   like bugs — permanent gaps, non-editable slots, a broken chart line. Check
   `data-integrity-rules.md` before reading any code.
2. **Minimize scanning.** Ask the user for suspect files. Never scan the full codebase unless all
   narrower strategies have failed.
3. **Match the symptom to a known failure mode** (below) before following a stack trace. Six
   categories cover most of what goes wrong here, and each maps to a handful of files.
4. **Stack trace second.** Where one exists, work outward from the first project frame.
5. **Reproduce the path.** Trace the flow: user action → widget → ViewModel → domain service →
   repository → data source.
6. **Expand progressively.** Read imports of suspect files before broadening. Each expansion level
   costs tokens — justify it.

## Common failure modes

Six categories, in rough order of how often they are the answer.

### 1. Slot windows and time

**Symptoms:** wrong slot open; a slot open twice or never; entry rejected as closed when it looks
open; slots shifted by an hour; a slot missing entirely on one date.

**Look at:** `SlotWindowService`, `SlotStatusService`, the schedule repository, anything calling
`DateTime.now()` outside a clock.

**Usual causes:** a real clock somewhere instead of the injected one; midnight crossing handled with
date arithmetic instead of span arithmetic; a DST transition inside a window; comparing a UTC
instant to a local one; a half-open interval treated as closed, so `windowEnd` belongs to two slots
or none.

### 2. Schedule changes rewriting history

**Symptoms:** yesterday's slots move; a past day suddenly shows a skip; the completion rate changes
for a week that is over.

**Look at:** the `schedules` table writes, and every read that resolves a schedule for a date.

**Usual causes:** a schedule row updated instead of appended; a read using the *current* schedule
rather than the one effective on that date; window boundaries not denormalized onto the entry at
write time.

### 3. Notifications

**Symptoms:** no reminder; a reminder at the wrong time; duplicate reminders; reminders stop after a
reboot or a force-quit; a reminder for a slot already recorded.

**Look at:** the notification scheduler, permission handling, and the reschedule triggers (app
resume, schedule change, reboot).

**Usual causes:** timezone database not initialized; Android exact-alarm permission not requested or
revoked; schedule not re-registered after reboot; the suppression check for an already-completed
slot missing or racing the save.

### 4. Drift, migrations, and persistence

**Symptoms:** crash on launch after an update; recordings missing after an update; a unique-
constraint failure on save; the same slot appearing twice.

**Look at:** `schemaVersion`, the migration strategy, and the unique constraint on
`(date(refersTo), slotIndex)`.

**Usual causes:** `schemaVersion` not incremented; a migration that recreates a table without
copying; two database instances because it was registered lazily in two places; a save path that
inserts instead of upserting.

**Handle with care.** These are the only bugs in this app that can destroy data with no backup
anywhere. Diagnose fully before touching anything, and get approval before running a repair.

### 5. Riverpod lifecycle and async gaps

**Symptoms:** stale values after returning from another screen; "used after dispose"; the entry form
not updating when the window closes; a save landing twice.

**Look at:** the entry ViewModel, provider lifetimes, `ref.watch` vs `ref.read`, missing
`if (!ref.mounted) return;` after awaits.

### 6. Chart and summary rendering

**Symptoms:** a gap drawn as zero; a line bridging a missing day; a one-recording day rendered as
complete; the export disagreeing with the on-screen chart.

**Look at:** `MoodSummaryService` and the chart adapter.

**Usual causes:** a missing value coerced to zero in the plotting layer rather than excluded; the
incomplete-day marker not wired; the export recomputing the summary with different rules instead of
reusing the service.

## Reproducing time-dependent bugs

Do not wait for a real boundary. Advance the fake `Clock` to one millisecond either side of
`windowStart` and `windowEnd`, and assert. Any bug reproduced this way should leave a permanent test
behind — see `.claude/rules/code/testing-rules.md` § Time.

## What never counts as a fix

- Adding a default, fallback, or imputed value so a null stops appearing.
- Making a closed window editable so the user can correct something.
- Bridging a chart gap so the line looks continuous.
- Deleting a "bad" recording so an average looks reasonable.

Each of these makes the symptom disappear and the record wrong. If one of them is the only fix
available, the design is wrong somewhere else — raise it.
