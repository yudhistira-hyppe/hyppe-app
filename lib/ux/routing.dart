import 'package:flutter/material.dart';

class Routing {
  Routing._private();

  static final Routing _instance = Routing._private();

  factory Routing() {
    return _instance;
  }

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  /// Go to next route screen
  Future<dynamic> move(String routeName, {dynamic argument}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: argument);
  }

  /// Go to named route screen and delete all routes
  Future<dynamic> moveReplacement(String routeName, {dynamic argument}) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: argument);
  }

  /// Go to next route screen and remove previous (latest) route
  Future<dynamic> moveAndPop(String routeName, {dynamic argument}) {
    return navigatorKey.currentState!.popAndPushNamed(routeName, arguments: argument);
  }

  /// Go to named route screen and delete all route until "removeUntil"
  Future<dynamic> moveAndRemoveUntil(String routeName, String removeUntil, {dynamic argument}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(routeName, ModalRoute.withName(removeUntil), arguments: argument);
  }

  /// Go to previous route screen or close pop dialog or overlays widget / delete current route
  void moveBack() {
    return navigatorKey.currentState!.pop();
  }

  /// Show showSnackBar
  void showSnackBar({required SnackBar snackBar}) {
    scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
  }

  /// Remove showSnackBar
  void removeSnackBar() {
    scaffoldMessengerKey.currentState!.hideCurrentSnackBar();
  }
}
