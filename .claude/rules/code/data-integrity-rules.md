---
description: "Clinical data invariants — read before changing anything that reads or writes a recording"
paths:
  - "lib/**/*.dart"
---

# Data Integrity

The output of this app is read by a clinician and informs treatment. A design that fabricates or
distorts a value is a real failure, not a cosmetic one. These invariants are not open to
convenience-driven revision. An implementation that violates one is wrong regardless of how clean
it looks — raise it rather than weakening it.

Rationale for each is in `business_analysis_en.md` §4.

## 1. Never synthesize a mood value

No defaults, no imputation, no neutral fill, no interpolation, no carrying the previous value
forward. A missing recording is missing.

This is the most serious defect found in review. Unlogged evenings are disproportionately bad
evenings, so imputing a neutral value systematically replaces the worst data with the blandest —
and the clinician reads the result as an observation.

Concretely, all of these are bugs, whatever the surrounding code is called:

- `??` supplying a scale when the stored value is absent
- an average that maps missing values to a neutral number before summing
- a lookup that returns a placeholder observation when no row matched
- a chart configured to interpolate across a gap

## 2. A row exists only because the user saved it

The recording store holds real observations and nothing else.

- No background job creates rows at the start of a day.
- No persisted status column. Status is derived at read time by a domain service.
- Reading a slot must never write one.

*Skipped* and *not applicable* are computed from the schedule in effect on that date plus the
absence of a row. If you find yourself wanting to persist them, the derivation is in the wrong
place.

## 3. No editing after the window closes

A recording is editable while its slot window is open and permanently read-only afterwards. There
is no backfill path and no "recorded late" flag, which is why a recording's timestamp always falls
inside its own slot window — half-open, so the closing instant belongs to no slot — and no
provenance flag is needed to interpret the data.

A skipped slot stays skipped. Do not add a UI affordance to fill it in.

## 4. Missing data is excluded, never zeroed

- The daily average is computed over completed slots only.
- A skipped slot is never counted as zero and never imputed.
- A day with zero recordings produces no point, and the chart line breaks rather than bridging it.
- A day with one or two recordings is marked as incomplete wherever its average is displayed.

## 5. No streaks, scores, or evaluative copy

No streak counters, badges, points, progress rings, or trophies. No celebratory language
(*"great job"*, *"don't break your streak"*) and no admonishing language (*"you missed 3 days"*).

In a depressed population a broken streak reads as evidence of failure — the exact cognitive
pattern the therapy is working against — and the risk lands by construction on the worst days.

Completion rate is stated factually (`18 of 21`), appears in History and the export, and never on
the entry screen.

## 6. Nothing leaves the device

No network calls, no analytics, no remote config, no third-party crash reporting. Crash reporters
in particular can carry note text off-device, so they are excluded even though they would be
useful.

Do not add a package with a transport dependency without raising it first. The only data that
leaves is what the user explicitly exports through the OS share sheet.

## 7. Support resources stay reachable

The support-resources screen is reachable from Settings, permanently, and never interrupts
anything. Do not add content scanning, keyword detection, or reactive prompts to the note field —
it must remain a place where the user can write honestly.

## 8. Migrations must not lose recordings

This is the developer's own clinical record and there is no backup anywhere else.

- Every schema change ships with a migration and a migration test.
- No destructive migration — no column drops that discard data, no table recreation without copy.
- The schema version is incremented explicitly, never inferred.
- Confirm before writing any migration (`CLAUDE.md` § Confirm first).

## When a requirement conflicts with an invariant

Say so and stop. The invariant wins, and the requirement needs rethinking. Do not resolve the
conflict by relaxing the invariant "just for this case" — every case looks like an exception from
inside it.
