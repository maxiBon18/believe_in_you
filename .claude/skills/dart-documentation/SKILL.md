---
name: dart-documentation
description: "Document Dart code with dartdoc comments. Use when asked to write, review, or improve doc comments in lib/**/*.dart files. Covers public APIs, private non-obvious code, and library-level docs."
disable-model-invocation: true
---

# Dart Documentation Skill

Add, review, and improve documentation in Dart source files.

- For documentation standards, style rules, and policies, see [reference.md](reference.md).
- For correct doc comment examples, see [examples.md](examples.md).

## Scope

- **Target files:** `lib/**/*.dart`
- **Exclude generated files:** skip any file matching `*.g.dart`, `*.freezed.dart`, `*.gen.dart`, `*.mocks.dart`, or containing a `// GENERATED CODE` header.

## Instructions

### Step 1 — Identify target files

- Determine which `.dart` files in `lib/` are in scope for the current task.
- Exclude generated files (see Scope above).
- If you are unsure which files to comment, ask the user for a list and comment those.
- Stop conditions:
  - If all files are generated, stop and report: "All target files are generated — no documentation needed."
  - If all files are already documented, stop and report: "All target files are documented"

### Step 2 — Audit existing documentation

- For each target file, check public APIs (classes, methods, top-level functions, properties, enums, extensions) for missing or low-quality doc comments.
- Flag private APIs only if they contain non-obvious logic.
- Check for violations of the rules in [reference.md](reference.md): restated-the-obvious comments, commented-out code, trailing comments, missing summary sentences.

### Step 3 — Write or improve doc comments

- Apply the documentation standards from [reference.md](reference.md).
- Use [examples.md](examples.md) to calibrate tone, length, and structure.
- For each doc comment:
  1. Write a single-sentence summary ending with a period.
  2. Add a blank line, then body text only if the summary is insufficient.
  3. Describe parameters, return values, and exceptions in prose — not with tags.
  4. Add a code sample only where it clarifies non-obvious usage.

### Step 4 — Clean up

- Remove any commented-out code.
- Remove any doc comments that merely restate the name or signature.
- Remove trailing comments.
- Verify consistent terminology across all modified files.

### Step 5 — Verify

- Confirm every public API in the modified files has a doc comment.
- Confirm no generated files were modified.
- Report a summary: number of files touched, doc comments added, doc comments improved, doc comments removed.