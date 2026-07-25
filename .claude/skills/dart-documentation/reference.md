# Dart Documentation — Reference

## Language

- All documentation in English.

## Philosophy

- Comment **why**, not **what**. The code should be self-explanatory.
- Write for the reader. If you found an answer to a question, document it where you first looked.
- No useless documentation. If a doc comment restates the obvious from the name, remove it.
- Use consistent terminology throughout the codebase.

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

## What to Document

- Always document public APIs (classes, methods, top-level functions, properties, enums, extensions, typedefs).
- Document private APIs when non-obvious.
- Consider library-level doc comments (`/// {@category ...}`) for general overviews.
- Include code samples where they clarify usage.
- Describe parameters, return values, and exceptions in prose — do not use `@param` or `@return` tags.
- Place doc comments before annotations (e.g., `@override`, `@deprecated`).

## Excluded Files

Generated files must never be documented. Patterns:
- `*.g.dart` (json_serializable, built_value, etc.)
- `*.freezed.dart` (freezed)
- `*.gen.dart` (auto_route, etc.)
- `*.mocks.dart` (mockito)
- Any file with a `// GENERATED CODE` header.