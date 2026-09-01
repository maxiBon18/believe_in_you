import 'package:believe_in_you/core/shared/utils/logger/custom_navigator_observer.dart';
import 'package:believe_in_you/core/shared/utils/logger/logger_app.dart';
import 'package:believe_in_you/core/shared/utils/logger/logger_app_impl.dart';
import 'package:believe_in_you/core/shared/utils/logger/provider_logger.dart';
import 'package:get_it/get_it.dart';

/// Shorthand for retrieving a registered instance from GetIt.
R getDI<R extends Object>() => GetIt.instance<R>();

/// Initialises all singletons and waits for async registrations to complete.
Future<void> setupAllDependencies() async {
  final GetIt getIt = GetIt.instance;
  await setupDependencies(getIt);
  await getIt.allReady();
}

Future<void> setupDependencies(GetIt getIt) async {
  getIt.registerSingletonIfAbsent<AppLogger>(() => AppLoggerImpl());
  getIt.registerSingletonIfAbsent<ProviderLogger>(() => ProviderLogger());
  getIt.registerSingletonIfAbsent<BelieveInYouNavigatorObserver>(() => BelieveInYouNavigatorObserver());
}
