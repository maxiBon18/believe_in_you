# Debug-code — Reference

## Diagnostic Strategy

1. **Rule out intended behaviour first.** This project deliberately does several things that look
   like bugs — permanent gaps, records that stop being editable, a chart line that breaks. Check
   `data-integrity-rules.md` and `CLAUDE.md` § Invariants before reading any code.
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

### 1. Time boundaries

**Symptoms:** the wrong range is open; a range open twice or never; input rejected as closed when it
looks open; boundaries shifted by an hour; a range missing entirely on one date.

**Look at:** boundary computation, status derivation, configuration persistence, anything calling
`DateTime.now()` inside `domain/` or `data/`.

**Usual causes:** a wall-clock read inside the logic instead of an instant passed in; midnight
crossing handled with date arithmetic instead of span arithmetic; a DST transition inside a range;
comparing a UTC instant to a local one; a half-open interval treated as closed, so the closing
instant belongs to two ranges or none.

### 2. Configuration changes rewriting history

**Symptoms:** past data moves; a completed period suddenly shows a gap; a metric changes for a
period that is over.

**Look at:** every write of the configuration, and every read that resolves it for a past date.

**Usual causes:** configuration updated in place instead of superseded; a read using the *current*
configuration rather than the one in effect at the time; a record that cannot reconstruct its own
context without the configuration history.

### 3. Platform plugins and scheduled OS work

**Symptoms:** something scheduled never fires; fires at the wrong time; fires twice; stops after a
reboot or a force-quit; fires for something already handled.

**Look at:** the adapter wrapping the plugin, permission handling, and the re-registration triggers
(app resume, configuration change, reboot).

**Usual causes:** a platform database or plugin not initialized; a permission not requested or
revoked since; nothing re-registered after reboot; a suppression check missing or racing the write
it depends on.

### 4. Drift, migrations, and persistence

**Symptoms:** crash on launch after an update; records missing after an update; a unique-constraint
failure on save; the same record appearing twice.

**Look at:** the schema version, the migration strategy, and the constraints enforcing uniqueness.

**Usual causes:** the schema version not incremented; a migration that recreates a table without
copying; two database instances because it was registered lazily in two places; a save path that
inserts instead of upserting; a uniqueness key built on a raw timestamp rather than the record's own
logical identity, so records at the edges duplicate.

**Handle with care.** These are the only bugs in this app that can destroy data with no backup
anywhere. Diagnose fully before touching anything, and get approval before running a repair.

### 5. Riverpod lifecycle and async gaps

**Symptoms:** stale values after returning from another screen; "used after dispose"; a form not
updating when its preconditions change; a save landing twice.

**Look at:** the screen's ViewModel, provider lifetimes, `ref.watch` vs `ref.read`, missing
`if (!ref.mounted) return;` after awaits.

### 6. Navigation and redirects

**Symptoms:** the app opens on the wrong screen after a cold start; back exits the app from a
mid-flow screen; an external launch lands on the wrong destination; a one-time flow shows again
after it was completed; a crash on launch reading state that isn't there.

**Look at:** the `AppRouter` implementation, the `GoRoute` list and each config's parse, and the
top-level `redirect` (`routing-rules.md` § Redirects).

**Usual causes:** a `redirect` reading state asynchronously and resolving before it arrives, or with
no `refreshListenable` so it never re-runs; an external payload or a `GoRouterState` value cast
instead of validated; navigation performed with `context.go` or `Navigator.push` so the contract is
bypassed; a `switch` over `AppRoute` with a `default` branch that swallowed a new variant.

### 7. Aggregation and rendering

**Symptoms:** a gap drawn as zero; a line bridging a missing period; a partial period rendered as
complete; generated output disagreeing with what is on screen.

**Look at:** the aggregation service and the adapter feeding the renderer.

**Usual causes:** a missing value coerced to zero in the rendering layer rather than excluded; the
partial-period marker not wired; generated output recomputing the aggregate with different rules
instead of reusing the service.

## Reproducing time-dependent bugs

Do not wait for a real boundary. Evaluate at instants one millisecond either side of the opening and
closing instants, and assert. Any bug reproduced this way should leave a permanent test behind — see
`.claude/rules/code/testing-rules.md` § Time.

## What never counts as a fix

- Adding a default, fallback, or imputed value so a null stops appearing.
- Reopening a closed write path so the user can correct something.
- Bridging a gap so a line looks continuous.
- Deleting an inconvenient record so an aggregate looks reasonable.

Each of these makes the symptom disappear and the record wrong. If one of them is the only fix
available, the design is wrong somewhere else — raise it.
