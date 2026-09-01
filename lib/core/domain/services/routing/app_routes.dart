abstract final class AppRouteNames {
  const AppRouteNames();

  static const String splash = 'splash';
  static const String home = 'home';
}

abstract final class AppRoutePaths {
  const AppRoutePaths();

  static const String splash = '/splash';
  static const String home = '/';
}

sealed class AppRoutes {
  const AppRoutes();

  String get routeName;
  String get routePath;
}

final class HomeRoute extends AppRoutes {
  const HomeRoute();

  @override
  String get routeName => AppRouteNames.home;

  @override
  String get routePath => AppRoutePaths.home;
}

final class SplashRoute extends AppRoutes {
  const SplashRoute();

  @override
  String get routeName => AppRouteNames.splash;

  @override
  String get routePath => AppRoutePaths.splash;
}
