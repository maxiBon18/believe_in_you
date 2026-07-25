# Examples

## 1. User knows the file — minimal scanning

**User Input:**
- Problem: "App crashes when I open the profile page after signing in."
- Error: `Null check operator used on a null value`
- Suspect file: `lib/features/profile/presentation/profile_page.dart`

**Output:**

**Root Cause:** `currentUser!.displayName` in `ProfilePage.build()` force-unwraps `currentUser` before the `userProvider` has emitted a value. On first build, the `AsyncValue` is still in `loading` state, so `currentUser` is `null`.

**Fix:** Replaced the direct force-unwrap with proper `AsyncValue` handling via `provider.when(data: ..., loading: ..., error: ...)` in `profile_page.dart:30–42`. The loading state now shows a `CircularProgressIndicator` and the error state shows a retry button.

**Files Read:** 1

---

## 2. No stack trace — Grep-based discovery

**User Input:**
- Problem: "The cart badge count doesn't update when I add items."

**Output (Step 2 → user says "no", Step 3 Level 1 → Grep for cart-related widgets):**

**Root Cause:** `CartPage.build()` uses `ref.read(cartProvider)` instead of `ref.watch(cartProvider)` at line 22. `ref.read` fetches the value once and does not subscribe to changes, so the widget never rebuilds when the cart state updates.

**Fix:** Changed `ref.read(cartProvider)` to `ref.watch(cartProvider)` in `cart_page.dart:22`.

**Files Read:** 2

---

## 3. Progressive expansion needed

**User Input:**
- Problem: "After checkout, the order confirmation screen shows the wrong total."

**Output (Step 3 Level 1 → checkout_page.dart, Level 2 → imported order_provider.dart and pricing_service.dart):**

**Root Cause:** `PricingService.calculateTotal()` in `pricing_service.dart:45` applies the discount percentage after tax instead of before tax. The order total passed to the confirmation screen is already incorrect at the provider level.

**Fix:** Reordered the calculation in `pricing_service.dart:45–52` to apply discount before tax: `subtotal → discount → taxed total`. Updated the unit test in `pricing_service_test.dart` to match.

**Files Read:** 4

---

## 4. Insufficient information — abort and ask

**User Input:**
- Problem: "The app is slow."

**Output:**

Unable to diagnose with the information provided. "The app is slow" could originate from network latency, expensive widget rebuilds, blocking computation on the main isolate, or large asset loading.

Please provide:
- Which screen or action is slow.
- Whether the slowness is on first load, every interaction, or after a specific action.
- Device and platform (iOS/Android, physical/emulator).
- Any console warnings or logs during the slow behavior.

**Files Read:** 0