# Dart Documentation — Reference

## Language

- All documentation in English, including in a codebase whose product docs are bilingual.

## Philosophy

- Comment **why**, not **what**. The code should be self-explanatory.
- Write for the reader. If you found an answer to a question, document it where you first looked.
- No useless documentation. If a doc comment restates the obvious from the name, remove it.
- Use consistent terminology throughout the codebase.
- **Document deliberate absences.** In this project the most valuable comments explain why something
  simpler was rejected — why there is no default, no backfill, no interpolation. Code that looks
  needlessly awkward gets "cleaned up" unless the comment stops it.

## Terminology

Fixed vocabulary. Using two words for one concept is how a rule stops being findable.

| Term | Means | Not |
| --- | --- | --- |
| **recording** | One saved observation for one slot | entry, log, record |
| **slot** | One of the three daily moments | period, session, timeslot |
| **window** | The time range a slot is open for | interval, range |
| **schedule** | A wake/sleep pair with an `effectiveFrom` date | settings, times |
| **skipped** | A slot whose window closed with no recording | missed, empty, blank |
| **not applicable** | A slot whose window closed before installation | skipped |
| **scale** | The 1–5 value | score, rating, mood level |
| **export** | The weekly PDF for the clinician | report, summary, share |

"Score" and "rating" are avoided throughout, in code and in copy — they carry an evaluative sense
this app deliberately does not have.

## Commenting Style

- Use `///` for doc comments (not `/** */`).
- Start with a single-sentence summary ending with a period.
- Add a blank line after the first sentence to separate summary from body.
- Do not repeat the class name or method signature in the doc comment.
- For properties with both getter and setter, document only one.
- No trailing comments (comments at the end of a code line).
- No commented-out code — Git preserves history.
- Write clear comments for complex or non-obvious code. Avoid over-commenting.

## Writing Style

- Be brief.
- Avoid jargon and acronyms unless widely understood.
- Use Markdown sparingly. Never use HTML for formatting.
- Use backtick fences for code blocks and specify the language.
- Cite a rule file and section when documenting an invariant, so the reader can find the full
  reasoning rather than only the summary.

## What to Document

- Always document public APIs (classes, methods, top-level functions, properties, enums, extensions,
  typedefs).
- Document private APIs when non-obvious.
- **Always document a nullable return type**, stating what `null` means. In this codebase `null`
  frequently means "the user did not record anything", which is a load-bearing distinction, not an
  edge case.
- **Always document sealed-type variants.** Each `SlotStatus` variant needs a line saying what
  produces it, because the difference between `skipped` and `notApplicable` is not inferable from
  the names.
- Consider library-level doc comments (`/// {@category ...}`) for general overviews.
- Include code samples where they clarify usage.
- Describe parameters, return values, and exceptions in prose — do not use `@param` or `@return`
  tags.
- Place doc comments before annotations (e.g., `@override`, `@deprecated`).

## What Not to Put in Documentation

- No realistic note text, emotion selections, or scale sequences presented as a person's data. Use
  obviously synthetic values in samples.
- No clinical claims. Document what the code does, not what a pattern in the data means.

## Excluded Files

Generated files must never be documented. Patterns:

- `*.g.dart` (json_serializable)
- `*.freezed.dart` (freezed)
- `*.drift.dart` (drift)
- `*.gen.dart`
- `*.mocks.dart` (mockito)
- Any file with a `// GENERATED CODE` header.
