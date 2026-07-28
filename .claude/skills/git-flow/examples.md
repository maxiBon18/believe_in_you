# Examples

## 1. Feature, no body needed

```text
feat(entry): add emotion chip multi-select to the slot form
```

## 2. Fix touching an invariant — body required

```text
fix(entry): stop mapping a null scale to a neutral 3

The DTO mapper substituted 3 for a null scale column, so a slot with no recorded value
read back as a real observation in the chart and the export. The mapper now returns a
nullable entity and status derivation classifies the absence.

Invariant: data-integrity-rules.md §1 — never synthesise a mood value.
```

## 3. Time boundary fix

```text
fix(core): compute slot windows from wall-clock components, not durations

Adding a Duration to the wake instant shifted every boundary by an hour across a DST
transition, because the local day is 23 or 25 hours. Boundaries are now constructed from
local wall-clock components.

Covers spring-forward and fall-back with two new tests.
```

## 4. Migration — say what survives

```text
feat(core): carry the timezone with every recording, schema v2

Recordings written before v2 keep their existing values; the new column is backfilled
from the device timezone only for rows that have none, and no row is recreated.

Migration test asserts every v1 recording survives with its scale and timestamp intact.
```

## 5. Tests only

```text
test(entry): cover save one ms before the window closes, and at the close
```

## 6. Repo configuration

```text
chore(config): add commit-msg hook so commitlint actually runs
```

## 7. Revert

```text
revert(history): remove completion-rate ring from the entry screen

Reverts 4a91c02. A progress ring on the entry screen is evaluative feedback at the moment
of recording — data-integrity-rules.md §5.
```
