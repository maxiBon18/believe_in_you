# Examples

## 1. Clean review — all checks passed

| Area             | Result | Issues                                        |
| ---------------- | ------ | --------------------------------------------- |
| Architecture     | ✅     | Layer boundaries respected                    |
| Code Quality     | ✅     | Naming and formatting consistent              |
| Null Safety      | ✅     | No unnecessary nullable types                 |
| Widget Quality   | ✅     | Proper decomposition, const constructors used |
| State Management | ✅     | Providers correctly scoped                    |
| Error Handling   | ✅     | All error paths produce UI feedback           |
| Performance      | ✅     | No expensive operations in build methods      |
| Security         | ✅     | No secrets or sensitive data in logs          |
| Responsiveness   | ✅     | Adaptive layouts used throughout              |
| Dependencies     | ✅     | Import order correct, no unused packages      |

All checks passed. Verified 4 files, 0 violations, 0 warnings.

## 2. Review with violations and warnings

| Area             | Result | Issues                             |
| ---------------- | ------ | ---------------------------------- |
| Architecture     | ✅     | Layer boundaries respected         |
| Code Quality     | ⚠️     | Inconsistent naming in 1 file      |
| Null Safety      | 🔴     | Force-unwrap without justification |
| Widget Quality   | ✅     | Proper decomposition               |
| State Management | 🔴     | `ref.read` used in build method    |
| Error Handling   | ⚠️     | Missing snackbar on network error  |
| Performance      | ✅     | No issues                          |
| Security         | 🔴     | API key hardcoded                  |
| Responsiveness   | ✅     | Adaptive layouts used              |
| Dependencies     | ✅     | Import order correct               |

### 🔴 Violations

**1. Null Safety — Force-unwrap without justification**

- **File:** `lib/features/auth/data/auth_repository.dart:47`
- **Rule:** `coding-conventions.md` § Null Safety — "Never force-unwrap without a preceding null check or documented reason."
- **Issue:** `user!.token` used without null guard.
- **Fix:** Add a null check: `if (user == null) throw AuthException('No user');` before accessing `user.token`.

**2. State Management — `ref.read` in build method**

- **File:** `lib/features/home/presentation/home_page.dart:32`
- **Rule:** `viewmodel-rules.md` § Riverpod — "Use `ref.watch` inside build methods; reserve `ref.read` for callbacks."
- **Issue:** `ref.read(homeProvider)` inside `build()` prevents widget from rebuilding on state changes.
- **Fix:** Replace with `ref.watch(homeProvider)`.

**3. Security — Hardcoded API key**

- **File:** `lib/core/network/api_client.dart:8`
- **Rule:** Code Review § Security — "No credentials, API keys, or secrets in the codebase."
- **Issue:** `const apiKey = 'sk-abc123...'` hardcoded in source.
- **Fix:** Move to environment variable via `--dart-define` or `.env` loaded with `flutter_dotenv`.

### ⚠️ Warnings

**1. Code Quality — Inconsistent naming**

- **File:** `lib/features/auth/domain/auth_service.dart:15`
- **Rule:** `coding-conventions.md` § Naming — "Use lowerCamelCase for variables and methods."
- **Issue:** Method named `Validate_Token` instead of `validateToken`.
- **Fix:** Rename to `validateToken`.

**2. Error Handling — Missing UI feedback**

- **File:** `lib/features/home/presentation/home_page.dart:58`
- **Rule:** Code Review § Error Handling — "User-facing errors produce UI feedback."
- **Issue:** Network error caught and logged but no snackbar or dialog shown to user.
- **Fix:** Add `ScaffoldMessenger.of(context).showSnackBar(...)` in the catch block.
