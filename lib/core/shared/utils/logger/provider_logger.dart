import 'package:believe_in_you/core/shared/controllers/di.dart';
import 'package:believe_in_you/core/shared/utils/enums.dart';
import 'package:believe_in_you/core/shared/utils/logger/logger_app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// Riverpod observer that forwards every provider lifecycle event to the app [Logger].
///
/// Registered as a [ProviderScope] observer in debug builds so that provider
/// additions, updates, failures, and disposals are visible in the console.
final class ProviderLogger extends ProviderObserver {
  final AppLogger _logger = getDI<AppLogger>();

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    _logger.printInformation(
      '${context.provider.runtimeType} \n Value: $value',
      event: BelieveInYouLogEvent.providerAdded,
    );
  }

  @override
  void providerDidFail(ProviderObserverContext context, Object error, StackTrace stackTrace) {
    _logger.printError(
      '${context.provider.runtimeType}',
      event: BelieveInYouLogEvent.providerFailed,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void didUpdateProvider(ProviderObserverContext context, Object? previousValue, Object? newValue) {
    _logger.printInformation(
      '${context.provider.runtimeType} \n PreviousValue: $previousValue \n NewValue: $newValue',
      event: BelieveInYouLogEvent.providerUpdated,
    );
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    _logger.printInformation('${context.provider.runtimeType}', event: BelieveInYouLogEvent.providerDisposed);
  }
}

/// Prints [message] to the debug console only when running in debug mode.
void customDebugPrint(String message) {
  if (kDebugMode) {
    return debugPrint(message);
  }
}
