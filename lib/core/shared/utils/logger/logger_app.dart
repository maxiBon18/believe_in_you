import 'package:believe_in_you/core/shared/utils/enums.dart';

abstract class AppLogger {
  void printDebug(String message, {BelieveInYouLogEvent? event});
  void printInformation(String message, {BelieveInYouLogEvent? event});
  void printWarning(String message, {BelieveInYouLogEvent? event});
  void printError(String message, {BelieveInYouLogEvent? event, Object? error, StackTrace? stackTrace});
}
