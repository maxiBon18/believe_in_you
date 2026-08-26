# Code Review — Reference

## Privacy & Security

These rules are evaluated directly by the skill (not delegated to an external rule file). This app
holds health data and has no backend, which changes what "security" means here: the threat is not an
attacker on the wire, it is data leaving the device at all.

- No credentials, API keys, or secrets in the codebase.
- **No user data in a release-build log line** (`print()`, `debugPrint()`, `log()`). Note text,
  emotion selections, and scale values reach a log only behind a `kDebugMode` guard; unguarded,
  log identifiers, counts, and state transitions. A value-carrying line without the guard is the
  finding — a guarded one is not. `print()` is an analyzer error either way.
- **No package with a transport dependency** — analytics, crash reporting, remote config, or an
  HTTP client. A crash reporter can carry note text off-device, which is why it is excluded even
  though it would be useful.
- The database is encrypted at rest. Preferences holding anything about recordings use secure
  storage, not `SharedPreferences`.
- Route observers and provider loggers record names only, never arguments, unless the line is
  `kDebugMode`-guarded — a route argument carries a date and a slot.
- Export writes to a temporary location and is shared through the OS share sheet; it is not left in
  a world-readable directory.

### Reviewed here, though it looks like styling

- **Red-to-green mood ramps.** A red bad day reads as a failure and a green good day as a success.
  This is a product-safety rule, not a palette preference — see `data-integrity-rules.md` § 5.
- **Evaluative copy.** Celebratory or admonishing strings, streak counters, progress rings.

## Dependencies & Imports

These rules are evaluated directly by the skill:

- No unused dependencies in `pubspec.yaml`.
- Import order: `dart:` → `package:flutter/` → `package:` (third-party) →
  `package:believe_in_you/` (project).
- **All project imports are package imports.** `analysis_options.yaml` enables
  `always_use_package_imports`, so a relative import fails analysis — including within one feature.
- No circular dependencies between features.
- No import that crosses a feature boundary into another feature's `data/` or `presentation/`.
  Shared code is promoted to `core/`, not reached into.
- New packages must be justified (maintenance status, pub.dev popularity, null safety support) —
  **and must not transmit data**. A new dependency with a network capability is a 🔴, not a
  discussion.

Each SKILL.md step names the rule file it depends on. Read it at that step, not up front — the
review is layered so a blocking integrity finding stops the pass before the later files are needed.
Two files no step names explicitly: `data-layer-rules.md` when a repository or data source is in
scope, and `CLAUDE.md` § Vocabulary whenever a finding turns on what something is called.

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