import 'package:believe_in_you/core/domain/services/routing/app_routes.dart';

abstract interface class RoutingService {
  void push(AppRoutes route);
  void pop();
  void replace(AppRoutes route);
  void pushReplacement(AppRoutes route);
}
