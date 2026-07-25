# Examples

## Test Plan Summary Format

| Type        | Cases  | Features                          | Est. Time |
| ----------- | ------ | --------------------------------- | --------- |
| Unit        | 12     | Auth, Product, Cart               | ~15s      |
| Widget      | 8      | LoginForm, ProductCard, CartBadge | ~25s      |
| Integration | 3      | Login flow, Add to cart, Checkout | ~90s      |
| **Total**   | **23** |                                   | **~130s** |

## Test Case Format

| ID     | Type        | Target                      | Description                                  | Rationale                                                       | Deps          | Priority |
| ------ | ----------- | --------------------------- | -------------------------------------------- | --------------------------------------------------------------- | ------------- | -------- |
| UT-001 | Unit        | `EmailValidator.validate()` | Returns true for valid emails                | Prevents malformed emails reaching API, causing server-side 422 | None          | High     |
| UT-002 | Unit        | `AuthRepository.login()`    | Returns AuthToken on valid creds             | Validates happy-path auth contract with API                     | MockApiClient | Critical |
| UT-003 | Unit        | `AuthRepository.login()`    | Throws InvalidCredentialsException on 401    | Ensures typed exceptions instead of raw HTTP errors to user     | MockApiClient | Critical |
| WT-001 | Widget      | `LoginForm`                 | Shows validation error on empty email submit | Users must see feedback on empty submit, not silent failure     | MockAuthCubit | High     |
| WT-002 | Widget      | `LoginForm`                 | Disables button while loading                | Prevents double-submit causing duplicate sessions               | MockAuthCubit | Medium   |
| IT-001 | Integration | Login → Home                | Navigates to Home after valid login          | Validates full chain: input → API → token storage → navigation  | MockAuthApi   | Critical |

### Edge Case Tests (suffix `-E`)

| ID       | Type        | Target                   | Description                                                     | Rationale                                                                               | Deps                     | Priority |
| -------- | ----------- | ------------------------ | --------------------------------------------------------------- | --------------------------------------------------------------------------------------- | ------------------------ | -------- |
| UT-002-E | Unit        | `AuthRepository.login()` | Throws NetworkException on timeout                              | User sees "no connection" message instead of unhandled exception crash                  | MockApiClient (timeout)  | Critical |
| UT-003-E | Unit        | `AuthRepository.login()` | Handles malformed JSON response body                            | Corrupted API response must not crash the app — must fail gracefully with typed error   | MockApiClient (bad body) | High     |
| WT-001-E | Widget      | `LoginForm`              | Handles rapid double-tap on submit button                       | Prevents duplicate auth requests that could create parallel sessions                    | MockAuthCubit            | High     |
| WT-002-E | Widget      | `LoginForm`              | Shows error when pasting email with leading/trailing whitespace | Whitespace in emails causes silent auth failures — must be trimmed or rejected visually | MockAuthCubit            | Medium   |
| IT-001-E | Integration | Login → Token expiry     | Triggers token refresh when token expires mid-session           | Expired token during active use must not log out user — must silently refresh           | MockAuthApi (expired)    | Critical |

## Missing Packages STOP Format

```
🛑 The following packages are required but missing from dev_dependencies:

| Package            | Version | Required by                         |
| ------------------ | ------- | ----------------------------------- |
| mocktail           | ^1.0.4  | UT-002, UT-003, WT-001 (mock repos) |
| network_image_mock | ^2.1.1  | WT-005 (product card with images)   |
| patrol             | ^3.13.0 | IT-001, IT-002 (integration runner) |

Add these to pubspec.yaml? (y/n)
```

## Excluded Test Type Format

| Type        | Include? | Reason                                                                                                             |
| ----------- | -------- | ------------------------------------------------------------------------------------------------------------------ |
| Unit        | ✅        | Cart has calculation logic (subtotal, tax, discounts)                                                              |
| Widget      | ✅        | Cart badge and remove button have interactive behavior                                                             |
| Integration | ❌        | Checkout integration test already covers cart-to-payment flow — separate cart integration test duplicates coverage |
