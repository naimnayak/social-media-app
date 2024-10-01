import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final List<String> navigationStack = [];

  factory NavigationService() {
    return _instance;
  }

  NavigationService._internal();

  static NavigationService get instance => _instance;

  void navigateTo(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
    navigationStack.add(routeName);
  }

  void replaceWith(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushReplacementNamed(routeName, arguments: arguments);
    if (navigationStack.isNotEmpty) {
      navigationStack.removeLast();
    }
    navigationStack.add(routeName);
  }

  void pop() {
    if (navigationStack.isNotEmpty) {
      navigatorKey.currentState?.pop();
      navigationStack.removeLast();
    }
  }

  String? getCurrentPage() {
    return navigationStack.isNotEmpty ? navigationStack.last : null;
  }

  void goBack() {
    if (navigationStack.length > 1) {
      navigatorKey.currentState?.pop();
      navigationStack.removeLast();
    } else {
      // Close the app if there's no more page in the stack
      navigatorKey.currentState?.maybePop();
    }
  }
}
