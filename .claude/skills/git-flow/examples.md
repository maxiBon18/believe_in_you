# Examples

Scopes and symbol names below are placeholders — use the project's own feature names
(`CLAUDE.md` § Architecture) and the words the code already uses.

## 1. Feature, no body needed

```text
feat(<feature>): add multi-select chips to the capture form
```

## 2. Fix touching an invariant — body required

```text
fix(<feature>): stop mapping a null value to a neutral midpoint

The DTO mapper substituted a midpoint for a null column, so a record with no stored value
read back as a real observation in the chart and the summary. The mapper now returns a
nullable entity and the derivation service classifies the absence.

Invariant: data-integrity-rules.md §1 — never synthesize a user-recorded value.
```

## 3. Time boundary fix

```text
fix(core): compute boundaries from wall-clock components, not durations

Adding a Duration to the start instant shifted every boundary by an hour across a DST
transition, because the local day is 23 or 25 hours. Boundaries are now constructed from
local wall-clock components.

Covers spring-forward and fall-back with two new tests.
```

## 4. Migration — say what survives

```text
feat(core): carry the timezone with every record, schema v2

Records written before v2 keep their existing values; the new column is backfilled from
the device timezone only for rows that have none, and no row is recreated.

Migration test asserts every v1 row survives with its value and timestamp intact.
```

## 5. Tests only

```text
test(<feature>): cover a save one ms before the boundary closes, and at the close
```

## 6. Repo configuration

```text
chore(config): add commit-msg hook so commitlint actually runs
```

## 7. Revert

```text
revert(<feature>): remove the progress ring from the capture screen

Reverts 4a91c02. A progress ring at the moment of recording is evaluative feedback —
CLAUDE.md § Invariants.
```
