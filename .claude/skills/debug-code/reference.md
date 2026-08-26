# Debug-code — Reference

## Diagnostic Strategy

1. **Rule out intended behaviour first.** This project deliberately does several things that look
   like bugs — permanent gaps, non-editable slots, a broken chart line. Check
   `data-integrity-rules.md` before reading any code.
2. **Minimize scanning.** Ask the user for suspect files. Never scan the full codebase unless all
   narrower strategies have failed.
3. **Match the symptom to a known failure mode** (below) before following a stack trace. Seven
   categories cover most of what goes wrong here, and each maps to a handful of files.
4. **Stack trace second.** Where one exists, work outward from the first project frame.
5. **Reproduce the path.** Trace the flow: user action → widget → ViewModel → domain service →
   repository → data source.
6. **Expand progressively.** Read imports of suspect files before broadening. Each expansion level
   costs tokens — justify it.

## Common failure modes

Seven categories, in rough order of how often they are the answer. Each names the *logic* to open,
not a class — find whatever the feature actually called it.

### 1. Slot windows and time

**Symptoms:** wrong slot open; a slot open twice or never; entry rejected as closed when it looks
open; slots shifted by an hour; a slot missing entirely on one date.

**Look at:** window computation, status derivation, schedule persistence, anything calling
`DateTime.now()` inside `domain/` or `data/`.

**Usual causes:** a wall-clock read inside the logic instead of an instant passed in; midnight
crossing handled with date arithmetic instead of span arithmetic; a DST transition inside a window;
comparing a UTC instant to a local one; a half-open interval treated as closed, so the closing
instant belongs to two slots or none.

### 2. Schedule changes rewriting history

**Symptoms:** yesterday's slots move; a past day suddenly shows a skip; the completion rate changes
for a week that is over.

**Look at:** every schedule write, and every read that resolves a schedule for a date.

**Usual causes:** a schedule updated in place instead of superseded; a read using the *current*
schedule rather than the one in effect on that date; a recording that cannot reconstruct its own
window without the schedule history.

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

**Look at:** the schema version, the migration strategy, and the constraint enforcing one recording
per slot.

**Usual causes:** the schema version not incremented; a migration that recreates a table without
copying; two database instances because it was registered lazily in two places; a save path that
inserts instead of upserting; a uniqueness key built on the recording's timestamp rather than the
slot's own identity, so a post-midnight slot duplicates.

**Handle with care.** These are the only bugs in this app that can destroy data with no backup
anywhere. Diagnose fully before touching anything, and get approval before running a repair.

### 5. Riverpod lifecycle and async gaps

**Symptoms:** stale values after returning from another screen; "used after dispose"; the entry form
not updating when the window closes; a save landing twice.

**Look at:** the entry screen's ViewModel, provider lifetimes, `ref.watch` vs `ref.read`, missing
`if (!ref.mounted) return;` after awaits.

### 6. Navigation and guards

**Symptoms:** the app opens on the wrong screen after a cold start; back exits the app from a
mid-flow screen; a notification tap lands on the wrong slot; onboarding shows again after it was
completed; a crash on launch reading a schedule that isn't there.

**Look at:** the `AppRouter` implementation, the `RouteInformationParser`, and the two guards
(`routing-rules.md` § Guards).

**Usual causes:** a guard reading state asynchronously and resolving before it arrives; a
notification payload cast instead of validated; navigation performed with `Navigator.push` so the
router's stack and the real stack diverge; a `switch` over `AppRoute` with a `default` branch that
swallowed a new variant.

### 7. Chart and summary rendering

**Symptoms:** a gap drawn as zero; a line bridging a missing day; a one-recording day rendered as
complete; the export disagreeing with the on-screen chart.

**Look at:** summary computation and the chart adapter.

**Usual causes:** a missing value coerced to zero in the plotting layer rather than excluded; the
incomplete-day marker not wired; the export recomputing the summary with different rules instead of
reusing the service.

## Reproducing time-dependent bugs

Do not wait for a real boundary. Evaluate at instants one millisecond either side of the window's
opening and closing instants, and assert. Any bug reproduced this way should leave a
permanent test behind — see `.claude/rules/code/testing-rules.md` § Time.

## What never counts as a fix

- Adding a default, fallback, or imputed value so a null stops appearing.
- Making a closed window editable so the user can correct something.
- Bridging a chart gap so the line looks continuous.
- Deleting a "bad" recording so an average looks reasonable.

Each of these makes the symptom disappear and the record wrong. If one of them is the only fix
available, the design is wrong somewhere else — raise it.
