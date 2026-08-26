import 'package:believe_in_you/core/shared/utils/enums.dart';
import 'package:believe_in_you/core/shared/utils/logger/logger_app.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLoggerImpl implements AppLogger {
  AppLoggerImpl()
    : _logger = Logger(
        filter: DevelopmentFilter(),
        level: kDebugMode ? Level.debug : Level.error,
        printer: PrettyPrinter(
          colors: true,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // ← non `printTime`
        ),
      );

  final Logger _logger;

  @override
  void printDebug(String message, {BelieveInYouLogEvent? event}) =>
      _logger.d(event != null ? '${event.name}: $message' : message);

  @override
  void printInformation(String message, {BelieveInYouLogEvent? event}) =>
      _logger.i(event != null ? '${event.name}: $message' : message);

  @override
  void printWarning(String message, {BelieveInYouLogEvent? event}) =>
      _logger.w(event != null ? '${event.name}: $message' : message);

  @override
  void printError(String message, {BelieveInYouLogEvent? event, Object? error, StackTrace? stackTrace}) =>
      _logger.e(event != null ? '${event.name}: $message' : message, error: error, stackTrace: stackTrace);
}
