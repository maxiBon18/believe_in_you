---
description: "Data invariants — read before changing anything that reads or writes user-recorded data"
paths:
  - "lib/**/*.dart"
---

# Data Integrity

What this app stores is the user's own record, and the app's output is read as an observation of
what actually happened. A design that fabricates or distorts a value is a real failure, not a
cosmetic one. These invariants are not open to convenience-driven revision. An implementation that
violates one is wrong regardless of how clean it looks — raise it rather than weakening it.

The project's own invariants — the ones that come from the product rather than from data handling —
are in `CLAUDE.md` § Invariants, and they bind exactly as hard as these. Where a rule below says
"the project decides", that is where to look.

## 1. Never synthesize a user-recorded value

No defaults, no imputation, no neutral fill, no interpolation, no carrying the previous value
forward. A missing record is missing.

This is the most serious defect found in review. Absent records are not randomly distributed — the
occasions a user skips differ systematically from the ones they log — so imputing a neutral value
replaces the most informative data with the blandest, and it is then read as an observation.

Concretely, all of these are bugs, whatever the surrounding code is called:

- `??` supplying a value when the stored one is absent
- an aggregate that maps missing values to a neutral number before summing
- a lookup that returns a placeholder record when no row matched
- a chart configured to interpolate across a gap

## 2. A row exists only because the user saved it

The store holds real observations and nothing else.

- No background job creates rows ahead of the user.
- Reading must never write. Fetching a range must not create rows for the parts of it that are
  empty.
- A write happens on an explicit user action, never on navigation away, dispose, or a timer.

## 3. Derived state is computed, never stored

Status that follows from stored facts plus the rules in effect is derived at read time by a domain
service — never persisted as a column, and never cached in a way that can disagree with the facts
it came from.

If you find yourself wanting to persist a derived status, the derivation is in the wrong place.
Absence is itself a fact the derivation reads; it is not a row to write.

## 4. Missing data is excluded, never zeroed

- An aggregate is computed over the records that exist.
- A missing record is never counted as zero and never imputed.
- A period with no records produces no point, and a chart line breaks rather than bridging it.
- A partial period is marked as partial wherever its aggregate is displayed.

## 5. Nothing leaves the device

No network calls, no analytics, no remote config, no third-party crash reporting. Crash reporters in
particular can carry user-entered text off-device, so they are excluded even though they would be
useful.

Do not add a package with a transport dependency without raising it first. The only data that leaves
is what the user explicitly hands to the OS — a share sheet, a file save — by their own action.

## 6. Migrations must not lose data

The store is the user's own record, and there may be no backup anywhere else.

- Every schema change ships with a migration and a migration test.
- No destructive migration — no column drops that discard data, no table recreation without copy.
- The schema version is incremented explicitly, never inferred.
- Confirm before writing any migration.

## When a requirement conflicts with an invariant

Say so and stop. The invariant wins, and the requirement needs rethinking. Do not resolve the
conflict by relaxing the invariant "just for this case" — every case looks like an exception from
inside it.
