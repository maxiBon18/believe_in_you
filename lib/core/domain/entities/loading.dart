import 'package:flutter/foundation.dart' show immutable;

/// Carries the callback needed to dismiss the global loading overlay.
@immutable
class Loading {
  /// Callback invoked to close the loading overlay when the operation finishes.
  final void Function() onClose;

  const Loading({required this.onClose});
}
