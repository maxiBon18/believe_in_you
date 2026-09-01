import 'package:believe_in_you/core/shared/controllers/di.dart';
import 'package:believe_in_you/core/shared/utils/enums.dart';
import 'package:believe_in_you/core/shared/utils/logger/logger_app.dart';
import 'package:flutter/material.dart';

/// [NavigatorObserver] that maintains a live stack of active routes and logs every navigation event.
///
/// Registered with the root [MaterialApp] navigator so that the current back-stack
/// is inspectable at any time via [routesStack].
final class BelieveInYouNavigatorObserver extends NavigatorObserver {
  final AppLogger _logger = getDI<AppLogger>();

  final List<Route<dynamic>> _routesStack = <Route<dynamic>>[];

  BelieveInYouNavigatorObserver();

  /// Ordered list of routes currently on the navigation stack, with the most recently pushed route last.
  List<Route<dynamic>> get routesStack => List<Route<dynamic>>.unmodifiable(_routesStack);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logger.printDebug(
      'from ${previousRoute?.settings.name} to ${route.settings.name}',
      event: BelieveInYouLogEvent.navigatorDidPush,
    );
    _routesStack.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logger.printDebug(
      'from ${route.settings.name} to ${previousRoute?.settings.name}',
      event: BelieveInYouLogEvent.navigatorDidPop,
    );
    _routesStack.remove(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _logger.printDebug(
      'from ${previousRoute?.settings.name} to ${route.settings.name}',
      event: BelieveInYouLogEvent.navigatorDidRemove,
    );
    _routesStack.remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logger.printDebug(
      'from ${oldRoute?.settings.name} to ${newRoute?.settings.name}',
      event: BelieveInYouLogEvent.navigatorDidReplace,
    );
    if (oldRoute != null) _routesStack.remove(oldRoute);
    if (newRoute != null) _routesStack.add(newRoute);
  }

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    super.didChangeTop(topRoute, previousTopRoute);
    _logger.printDebug(
      'from ${previousTopRoute?.settings.name} to ${topRoute.settings.name}',
      event: BelieveInYouLogEvent.navigatorDidChangeTop,
    );
  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didStartUserGesture(route, previousRoute);
    _logger.printDebug(
      'from ${previousRoute?.settings.name} to ${route.settings.name}',
      event: BelieveInYouLogEvent.navigatorDidStartUserGesture,
    );
  }

  @override
  void didStopUserGesture() {
    super.didStopUserGesture();
    _logger.printDebug(BelieveInYouLogEvent.navigatorDidStopUserGesture.name);
  }
}
