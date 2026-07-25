# Examples

## 1. Class with public API — normal case

```dart
/// Manages user authentication state and token lifecycle.
///
/// Call [signIn] to authenticate and [signOut] to clear the session.
/// Automatically refreshes the access token before expiration.
class AuthManager {
  /// The currently authenticated user, or `null` if signed out.
  final User? currentUser;

  /// Signs in with the given [email] and [password].
  ///
  /// Returns the authenticated [User] on success. Throws
  /// [AuthException] if credentials are invalid or the account
  /// is locked.
  Future<User> signIn(String email, String password) async {
    // ...
  }

  /// Signs out and revokes the current refresh token.
  Future<void> signOut() async {
    // ...
  }
}
```

## 2. Private method — non-obvious logic

```dart
/// Debounces rapid token refresh attempts to prevent race conditions.
///
/// If a refresh is already in flight, returns the existing future
/// instead of issuing a duplicate network call.
Future<String> _refreshToken() async {
  // ...
}
```

## 3. Enum with values

```dart
/// The status of an order in the fulfillment pipeline.
enum OrderStatus {
  /// Order created but not yet paid.
  pending,

  /// Payment confirmed; awaiting shipment.
  confirmed,

  /// Handed to the carrier.
  shipped,

  /// Delivered to the customer.
  delivered,

  /// Cancelled by the customer or system.
  cancelled,
}
```

## 4. Removing a bad doc comment — edge case

Before (bad — restates the name):
```dart
/// The user repository.
class UserRepository {
  /// Gets a user by ID.
  Future<User> getUserById(String id) async { ... }
}
```

After (good — explains purpose and behavior):
```dart
/// Provides read and write access to user records in Firestore.
class UserRepository {
  /// Fetches the user with the given [id].
  ///
  /// Returns `null` if no matching document exists. Throws
  /// [FirebaseException] on network failure.
  Future<User?> getUserById(String id) async { ... }
}
```

## 5. Code sample for non-obvious usage

```dart
/// Converts a flat list of [MenuItem] into a nested tree structure
/// based on each item's [parentId].
///
/// ```dart
/// final flat = [
///   MenuItem(id: '1', parentId: null, label: 'Home'),
///   MenuItem(id: '2', parentId: '1', label: 'Dashboard'),
/// ];
/// final tree = buildMenuTree(flat);
/// // tree[0].children[0].label == 'Dashboard'
/// ```
List<MenuNode> buildMenuTree(List<MenuItem> items) {
  // ...
}
```