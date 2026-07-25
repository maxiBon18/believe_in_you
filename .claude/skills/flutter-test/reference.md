# Flutter Testing Reference

## Test Type Overview

| Type        | Tests                                   | Speed | Requires device | Runner                               |
| ----------- | --------------------------------------- | ----- | --------------- | ------------------------------------ |
| Unit        | Logic, models, repos, utils, state mgmt | ms    | No              | `fvm flutter test test/unit/`        |
| Widget      | Rendering, interactions, state display  | sec   | No              | `fvm flutter test test/widget/`      |
| Integration | Multi-screen flows, navigation, e2e     | min   | Yes             | `fvm flutter test integration_test/` |

## Selection Matrix

Check each row per feature. ✅ = include that test type.

| Feature characteristic                            | Unit  | Widget | Integration |
| ------------------------------------------------- | :---: | :----: | :---------: |
| Business logic, calculations, validation rules    |   ✅   |   —    |      —      |
| Data models (toJson/fromJson, equality)           |   ✅   |   —    |      —      |
| Repository/service with external deps             |   ✅   |   —    |      —      |
| State management logic (BLoC/Cubit/Notifier)      |   ✅   |   —    |      —      |
| Form inputs with validation                       |   ✅   |   ✅    |      —      |
| Conditional UI based on state                     |   —   |   ✅    |      —      |
| User interactions (tap, swipe, text input)        |   —   |   ✅    |      —      |
| Loading / error / empty states                    |   —   |   ✅    |      —      |
| Multi-screen navigation flow                      |   —   |   —    |      ✅      |
| Critical user journey (auth, payment, onboarding) |   —   |   —    |      ✅      |
| Platform channels / device features               |   —   |   —    |      ✅      |
| Deep linking / universal links                    |   —   |   —    |      ✅      |

## Edge Case Checklist

For each feature in scope, systematically check these categories. Each applicable edge case becomes a test case tagged with `-E` suffix.

| Category         | What to test                                                                                 |
| ---------------- | -------------------------------------------------------------------------------------------- |
| **Null / Empty** | Null inputs, empty strings, empty lists, missing optional fields                             |
| **Boundaries**   | Min/max values, 0, negative numbers, max length strings, list with 1 item vs. 1000           |
| **Format**       | Invalid email, malformed JSON, special characters, unicode, RTL text, extra whitespace       |
| **Network**      | Timeout, no connection, slow response, HTTP 4xx/5xx, malformed response body                 |
| **State**        | Rapid state changes, back-to-back identical events, stale state after background resume      |
| **Concurrency**  | Double-tap submit, multiple rapid navigations, simultaneous API calls                        |
| **Permissions**  | Denied permission, revoked permission mid-flow, "don't ask again" selected                   |
| **Device**       | Low memory, disk full, interrupted (phone call during flow), screen rotation during async op |
| **Auth**         | Expired token mid-flow, revoked session, concurrent login from another device                |
| **Data**         | First launch (no data), corrupted cache, schema migration from older version                 |

**Rule:** Every feature MUST have at least 2 edge case tests. If analysis reveals no applicable edge cases, document why in the plan.

## Priority Levels

| Priority | Assign when                                                                            |
| -------- | -------------------------------------------------------------------------------------- |
| Critical | Auth, payments, data persistence, security, edge cases that cause data loss or crashes |
| High     | Core CRUD, navigation, form submission, edge cases on critical paths                   |
| Medium   | Non-blocking UI edge cases, formatting, secondary flows                                |
| Low      | Cosmetic, animations, rare paths with graceful fallbacks                               |

## Rationale Rules

Rationale answers: **"What breaks without this test?"**

- ✅ `"Prevents double-charge if user taps pay twice during loading"`
- ✅ `"Validates expired tokens trigger refresh instead of 401 to user"`
- ❌ `"To make sure it works"`
- ❌ `"For code coverage"`

## Mocking Strategy

| Dependency                    | Approach                                                       |
| ----------------------------- | -------------------------------------------------------------- |
| HTTP (dio/http)               | `MockClient` or `HttpClientAdapter` with canned responses      |
| Firebase                      | `fake_cloud_firestore`, `firebase_auth_mocks`, or custom fakes |
| SharedPreferences             | `SharedPreferences.setMockInitialValues({})`                   |
| Local DB (sqflite/drift/isar) | In-memory instance                                             |
| Platform channels             | `TestDefaultBinaryMessenger`                                   |
| Repos / Services              | `mocktail` or `mockito` mocks                                  |
| Navigation                    | `MockNavigatorObserver`                                        |

## Test Structure Rules

- Pattern: **Arrange-Act-Assert** in every test.
- Naming: `'should [behavior] when [condition]'`.
- Grouping: `group()` by logical category.
- ID comment above each test: `// UT-001: [description]`.

## File Organization

```text
test/
├── unit/<feature>/<class>_test.dart
├── widget/<feature>/<widget>_test.dart
└── helpers/
    ├── mocks.dart
    └── fixtures/
integration_test/<flow>_test.dart
```
