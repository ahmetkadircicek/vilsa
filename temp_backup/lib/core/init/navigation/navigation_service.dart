import 'package:flutter/material.dart';

class NavigationService {
  static NavigationService? _instance;
  static NavigationService get instance {
    _instance ??= NavigationService._init();
    return _instance!;
  }

  NavigationService._init();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  dynamic goBack([dynamic popValue]) {
    return navigatorKey.currentState!.pop(popValue);
  }

  Future<dynamic> navigateTo(Widget page, {dynamic arguments}) async =>
      navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => page));

  Future<dynamic> replace(Widget page, {dynamic arguments}) async =>
      navigatorKey.currentState!.pushReplacement(MaterialPageRoute(builder: (_) => page));

  Future<dynamic> popToFirst() async => navigatorKey.currentState!.popUntil((route) => route.isFirst);
}
