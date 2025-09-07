import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1; // high priority

  @override
  RouteSettings? redirect(String? route) {

    return _checkAuthSync(route);
  }

  RouteSettings? _checkAuthSync(String? route) {
    try {
      final authController = Get.find<AuthController>();

      if (!authController.isAuthenticated.value) {
        return const RouteSettings(name: '/login');
      }
    } catch (e) {
      return const RouteSettings(name: '/login');
    }

    return null; // allow access
  }

}
