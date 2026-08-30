# Examples

**Targets below are placeholders.** Name the logic under test — *boundary computation*, *status
derivation*, *the value selector* — until the code exists, then use its real symbol. A plan that
invents a class name commits the implementation to it before anyone chose it.

The invariant IDs and edge-case categories are enumerated in [reference.md](reference.md); the rows
below are excerpts showing the *column shape and the depth of a Rationale*, not the full lists.

## Test Plan Summary Format

| Type        | Cases  | Features                                             | Est. Time |
| ----------- | ------ | ---------------------------------------------------- | --------- |
| Unit        | 18     | Boundaries, status, aggregation, repository          | ~20s      |
| Widget      | 7      | Value selector, chip row, capture page               | ~25s      |
| Migration   | 2      | Schema v1→v2, v2→v3                                  | ~5s       |
| Integration | 3      | First run → first record, external launch, file export | ~90s    |
| **Total**   | **30** |                                                      | **~140s** |

Invariant suite: 11 of 11 included.

## Test Case Format

| ID     | Type   | Target                | Description                                       | Rationale                                                                     | Deps       | Priority |
| ------ | ------ | --------------------- | ------------------------------------------------- | ----------------------------------------------------------------------------- | ---------- | -------- |
| UT-001 | Unit   | boundary computation  | Splits the configured span into equal ranges       | Every other time-dependent behaviour depends on these boundaries being right   | None       | Critical |
| UT-002 | Unit   | status derivation     | Returns *open* inside the range                    | The form is editable only in this state                                        | Fixed instant | Critical |
| WT-002 | Widget | capture page          | Save disabled until the required fields exist      | Prevents an empty or partial record being written                              | Fake VM    | Critical |
| IT-001 | Integration | First run → first record | Completes setup and saves one record       | Validates the full chain: config write → boundary computation → save → display | Fixed instant | Critical |

### Invariant Tests (prefix `INV-`)

| ID     | Type   | Target                | Description                                              | Rationale                                                                                              | Deps       | Priority |
| ------ | ------ | --------------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ | ---------- | -------- |
| INV-02 | Unit   | row → entity mapping  | Null column maps to null entity, not a default            | A default reads back as a real observation in generated output                                          | None       | Critical |
| INV-08 | Migration | Schema v2 → v3     | All pre-existing rows survive with identical values       | The store is the user's own record with no backup — a lossy migration is unrecoverable                  | Real schemas | Critical |

Note the Rationale column on both: it states the real consequence, never the rule number. "Covers
`data-integrity-rules.md` § 1" does not tell a reviewer what breaks.

### Edge Case Tests (suffix `-E`)

| ID       | Type   | Target              | Description                                                    | Rationale                                                                                   | Deps          | Priority |
| -------- | ------ | ------------------- | -------------------------------------------------------------- | ------------------------------------------------------------------------------------------- | ------------- | -------- |
| UT-002-E | Unit   | status derivation   | Open one millisecond before the close, closed at the close      | Half-open interval — a closed interval would let one instant belong to two ranges             | Fixed instants | Critical |
| UT-003-E | Unit   | boundary computation | Spring-forward transition inside the second range              | A duration-based offset silently shifts boundaries by an hour twice a year                   | Fixed instants | High     |
| WT-003-E | Widget | capture page        | Boundary closes while the screen is open → becomes read-only    | Without it a save lands after the boundary shut, breaking the rule from the UI side          | Fixed instants | Critical |

## Missing Packages STOP Format

```
🛑 The following packages are required but missing from dev_dependencies:

| Package        | Version | Required by                              |
| -------------- | ------- | ---------------------------------------- |
| mocktail       | ^1.0.4  | UT-002, WT-002 (service and VM fakes)    |
| drift_dev      | ^2.x    | INV-08 (migration test harness)          |

Add these to pubspec.yaml? (y/n)
```

## Excluded Test Type Format

| Type        | Include? | Reason                                                                                                    |
| ----------- | -------- | --------------------------------------------------------------------------------------------------------- |
| Unit        | ✅        | The feature has date-range and aggregation logic                                                          |
| Integration | ❌        | The first-run flow already exercises navigation into this screen; a separate flow duplicates coverage      |

## Report Format — invariant line first

```text
Invariant suite: 11/11 passed.

| Type        | Total | Pass | Fail | Skip |
| ----------- | ----- | ---- | ---- | ---- |
| Unit        | 18    | 18   | 0    | 0    |
| Widget      | 7     | 6    | 1    | 0    |
| Migration   | 2     | 2    | 0    | 0    |
| Integration | 3     | 3    | 0    | 0    |
```

If an invariant test fails, the line reads `Invariant suite: 10/11 — INV-05 FAILED` and the run stops
there. An invariant failure is not a test to be fixed; it means the code violates a rule in
`data-integrity-rules.md`.
