import 'package:believe_in_you/core/shared/utils/logger/custom_navigator_observer.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';

/// Generates platform-aware routes and exposes navigation observers.
///
/// The route builder map is injected at construction time so that this class
/// remains independent of any specific feature. On iOS it produces
/// [CupertinoPageRoute]; on all other platforms it falls back to
/// [MaterialPageRoute].
///
/// ```dart
/// final service = RoutingService(observer, routes);
/// MaterialApp(
///   onGenerateRoute: service.onGenerateRoute,
///   onUnknownRoute: service.onUnknownRoute,
///   navigatorObservers: [service.navigatorObserver, service.routeObserver],
/// );
/// ```
class AppRouting {
  final BelieveInYouNavigatorObserver _navigatorObserver;
  final Map<String, WidgetBuilder> _routes;
  final RouteObserver<ModalRoute<dynamic>> _routeObserver = RouteObserver<ModalRoute<dynamic>>();

  AppRouting(this._navigatorObserver, this._routes);

  /// Observer that pages subscribe to for [RouteAware] lifecycle callbacks.
  RouteObserver<ModalRoute<dynamic>> get routeObserver => _routeObserver;

  /// Observer that tracks the full navigation stack and logs push/pop events.
  BelieveInYouNavigatorObserver get navigatorObserver => _navigatorObserver;

  /// Returns a platform-specific [Route] wrapping [builder].
  Route<dynamic> _buildPlatformRoute(RouteSettings settings, WidgetBuilder builder, {bool maintainState = true}) {
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => CupertinoPageRoute<dynamic>(settings: settings, builder: builder),
      _ => MaterialPageRoute<dynamic>(settings: settings, builder: builder, maintainState: maintainState),
    };
  }

  /// Fallback used by [MaterialApp.onUnknownRoute].
  ///
  /// Always renders [BelieveInYouNotFoundPage].
  Route<dynamic> onUnknownRoute(RouteSettings routeSettings, {bool maintainState = true}) {
    return _buildPlatformRoute(
      routeSettings,
      (BuildContext context) => const Placeholder(),
      maintainState: maintainState,
    );
  }

  /// Resolves [routeSettings] against the injected route map.
  ///
  /// Falls back to [BelieveInYouNotFoundPage] when no matching route is found.
  Route<dynamic> onGenerateRoute(RouteSettings routeSettings, {bool maintainState = true}) {
    final WidgetBuilder? pageBuilder = _routes[routeSettings.name];
    if (pageBuilder != null) {
      return _buildPlatformRoute(routeSettings, pageBuilder, maintainState: maintainState);
    }
    return onUnknownRoute(routeSettings);
  }

  /// Returns the named-route arguments for [routeName] if present.
  ///
  /// Searches the navigation stack for the most recent route matching
  /// [routeName] and returns its arguments when they are a
  /// `Map<String, dynamic>`. Returns `null` when the route is not active
  /// or carries no arguments.
  Map<String, dynamic>? getArgumentsForRoute(String routeName) {
    final Route<dynamic>? matchingRoute = _navigatorObserver.routesStack.lastWhereOrNull(
      (Route<dynamic> route) => route.settings.name == routeName,
    );

    if (matchingRoute != null && matchingRoute.settings.arguments is Map<String, dynamic>) {
      return matchingRoute.settings.arguments as Map<String, dynamic>;
    }

    return null;
  }
}
