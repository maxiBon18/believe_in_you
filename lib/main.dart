import 'package:believe_in_you/core/presentation/ux/pages/believe_in_you_app.dart';
import 'package:believe_in_you/core/shared/controllers/di.dart';
import 'package:believe_in_you/core/shared/utils/enums.dart';
import 'package:believe_in_you/core/shared/utils/logger/logger_app.dart';
import 'package:believe_in_you/core/shared/utils/logger/provider_logger.dart' show ProviderLogger;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart' show SystemChrome, DeviceOrientation;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupAllDependencies();
  await _lockOrientationToPortrait();
  _runApp();
}

void _runApp() {
  if (kDebugMode) {
    runApp(ProviderScope(observers: <ProviderObserver>[getDI<ProviderLogger>()], child: const BelieveInYouApp()));
  } else {
    runApp(const ProviderScope(child: BelieveInYouApp()));
  }
}

/// Locks the device orientation to portrait mode for the entire app.
Future<void> _lockOrientationToPortrait() async {
  try {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    getDI<AppLogger>().printInformation(
      'Screen orientation locked to portrait.',
      event: BelieveInYouLogEvent.screenOrientationLocked,
    );
  } on Exception catch (e, st) {
    getDI<AppLogger>().printError(
      'Failed to lock screen orientation.',
      event: BelieveInYouLogEvent.failedToLockScreenOrientation,
      error: e,
      stackTrace: st,
    );
  }
}
