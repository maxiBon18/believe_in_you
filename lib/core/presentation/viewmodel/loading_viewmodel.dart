import 'package:believe_in_you/core/domain/entities/loading.dart';
import 'package:believe_in_you/core/presentation/ux/pages/loading_page.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:material_ui/material_ui.dart' show BuildContext, OverlayState, OverlayEntry;

/// Manages the global full-screen loading overlay used during async operations.
///
/// Registered as a singleton via GetIt so any widget can call [showLoading] and
/// [hideLoading] without needing a [BuildContext] reference at the call site.
class LoadingViewmodel {
  Loading? loading;

  /// Inserts the loading overlay into the nearest [OverlayState], throttled to prevent double-shows.
  void showLoading({required BuildContext context}) {
    EasyThrottle.throttle('show-loading-throttler', const Duration(milliseconds: 500), () {
      loading = _setOverlayLoading(context: context);
    });
  }

  /// Removes the current loading overlay and clears the stored [Loading] reference.
  void hideLoading() {
    if (loading == null) return;
    loading?.onClose.call();
    EasyDebounce.cancel('show-loading-throttler');
    loading = null;
  }

  Loading? _setOverlayLoading({required BuildContext context}) {
    final OverlayState? state = context.findAncestorStateOfType<OverlayState>();
    if (state == null) return null;

    final OverlayEntry overlayEntry = OverlayEntry(
      builder: (BuildContext context) => const BelieveInYouOverlayLoadingWidget(),
    );

    state.insert(overlayEntry);

    return Loading(
      onClose: () {
        overlayEntry.remove();
        overlayEntry.dispose();
      },
    );
  }
}
