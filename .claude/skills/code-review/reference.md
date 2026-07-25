# Code Review — Reference

## Privacy & Security

These rules are evaluated directly by the skill (not delegated to an external rule file). This app
holds health data and has no backend, which changes what "security" means here: the threat is not an
attacker on the wire, it is data leaving the device at all.

- No credentials, API keys, or secrets in the codebase.
- **No user data in logs or print statements** (`print()`, `debugPrint()`, `log()`). Note text,
  emotion selections, and scale values must never be logged. Identifiers, counts, and state
  transitions are fine.
- **No package with a transport dependency** — analytics, crash reporting, remote config, or an
  HTTP client. A crash reporter can carry note text off-device, which is why it is excluded even
  though it would be useful.
- The database is encrypted at rest. Preferences holding anything about recordings use secure
  storage, not `SharedPreferences`.
- Route observers and provider loggers record names only, never arguments — a route argument carries
  a date and slot index.
- Export writes to a temporary location and is shared through the OS share sheet; it is not left in
  a world-readable directory.

### Reviewed here, though it looks like styling

- **Red-to-green mood ramps.** A red bad day reads as a failure and a green good day as a success.
  This is a product-safety rule, not a palette preference — see `data-integrity-rules.md` § 5.
- **Evaluative copy.** Celebratory or admonishing strings, streak counters, progress rings.

## Dependencies & Imports

These rules are evaluated directly by the skill:

- No unused dependencies in `pubspec.yaml`.
- Import order: `dart:` → `package:flutter/` → `package:` (third-party) → project relative imports.
- Prefer relative imports within the same feature.
- No circular dependencies between features.
- New packages must be justified (maintenance status, pub.dev popularity, null safety support) —
  **and must not transmit data**. A new dependency with a network capability is a 🔴, not a
  discussion.

## External Rule Files

The following project rule files contain the authoritative standards for their respective review
areas. Read each file at the step that references it:

| Review Area        | Rule File                                        | Section                              |
| ------------------ | ------------------------------------------------ | ------------------------------------ |
| Data Integrity     | `.claude/rules/code/data-integrity-rules.md`     | Full file                            |
| Architecture       | `CLAUDE.md`                                      | §§ Architecture, Dependency rule     |
| Time Correctness   | `.claude/rules/code/coding-conventions.md`       | § Time                               |
| Time Correctness   | `.claude/rules/code/domain-layer-rules.md`       | § Services                           |
| Code Quality       | `.claude/rules/code/coding-conventions.md`       | Full file                            |
| Null Safety        | `.claude/rules/code/coding-conventions.md`       | § Null safety                        |
| Widget Quality     | `.claude/rules/code/presentation-layer-rules.md` | §§ Naming and placement, Composition |
| State Management   | `.claude/rules/code/viewmodel-rules.md`          | Full file                            |
| Error Handling     | `.claude/rules/code/coding-conventions.md`       | § Error handling                     |
| Performance        | `.claude/rules/code/presentation-layer-rules.md` | § Performance                        |
| Accessibility      | `.claude/rules/code/presentation-layer-rules.md` | § Responsive and accessible          |
| Data layer specifics | `.claude/rules/code/data-layer-rules.md`       | § Repository rules specific to this app |

## Output Format

### Integrity Banner

If any data-integrity violation was found, print this line **before** the table:

```
🛑 Data integrity violation found — do not merge. Detail below.
```

Omit the line entirely if there are none. Do not print a reassuring equivalent.

### Summary Table

| Area                | Result       | Issues               |
| ------------------- | ------------ | ---------------------|
| Data Integrity      | ✅ / 🔴      | Brief description    |
| Architecture        | ✅ / ⚠️ / 🔴 | Brief description    |
| Time Correctness    | ✅ / ⚠️ / 🔴 | Brief description    |
| Code Quality        | ✅ / ⚠️ / 🔴 | Brief description    |
| Null Safety         | ✅ / ⚠️ / 🔴 | Brief description    |
| Widget Quality      | ✅ / ⚠️ / 🔴 | Brief description    |
| State Management    | ✅ / ⚠️ / 🔴 | Brief description    |
| Error Handling      | ✅ / ⚠️ / 🔴 | Brief description    |
| Performance         | ✅ / ⚠️ / 🔴 | Brief description    |
| Privacy & Security  | ✅ / ⚠️ / 🔴 | Brief description    |
| Accessibility       | ✅ / ⚠️ / 🔴 | Brief description    |
| Dependencies        | ✅ / ⚠️ / 🔴 | Brief description    |

Data Integrity has no ⚠️ column value. It passes or it blocks.

### Violation Detail

After the summary table, list every 🔴 Violation:

- **File and line** (or range).
- **Rule violated** (reference the source rule file and section).
- **Issue** — what the code does.
- **Why it matters** — for integrity findings, state the clinical consequence, not just the rule
  number. "This writes a value the user never reported" lands; "violates § 1" does not.
- **Suggested fix** (concrete, actionable).

Then list every ⚠️ Warning with the same structure, minus "Why it matters".