import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/app_theme.dart';
import 'config/routes.dart';
import 'controllers/auth_controller.dart';
import 'controllers/board_controller.dart';
import 'services/sync_service.dart';

void main() {
  // Tắt debug mode trong production
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    _initializeControllers();

    return GetMaterialApp(
      title: 'TaskBundle',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,

      // Routes configuration
      initialRoute: AppRoutes.initial,
      getPages: AppRoutes.routes,

      // Default transitions
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),

      // Disable navigation logging
      enableLog: false,
    );
  }

  void _initializeControllers() {
    // Initialize sync service first
    Get.put(SyncService(), permanent: true);

    // Initialize core controllers
    Get.put(AuthController());
    Get.put(BoardController());

    // Add other controllers here when needed
    // Get.put(CardController());
    // Get.put(UserController());
  }
}