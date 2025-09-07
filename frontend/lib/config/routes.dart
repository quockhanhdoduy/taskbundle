import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/forgot_password_view.dart';
import '../views/auth/verify_otp_view.dart';
import '../views/auth/change_password_view.dart';
import '../views/home_view.dart';
import '../views/boards/create_board_view.dart';
import '../views/boards/board_detail_view.dart';
import '../views/cards/card_detail_view.dart';
import '../middlewares/auth_middleware.dart';

class AppRoutes {
  // Route names
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyOTP = '/verify-otp';
  static const String changePassword = '/change-password';
  static const String home = '/home';
  static const String createBoard = '/create-board';
  static const String boardDetail = '/board/:boardId';
  static const String cardDetail = '/card/:cardId';

  // Initial route
  static const String initial = login;

  // Route pages
  static final List<GetPage> routes = [
    // Auth routes
    GetPage(
      name: login,
      page: () => const LoginView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: register,
      page: () => const RegisterView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: verifyOTP,
      page: () => VerifyOTPView(
        email: Get.arguments?['email'] ?? '',
        source: Get.arguments?['source'] ?? 'register',
      ),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: changePassword,
      page: () => const ChangePasswordView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Home route
    GetPage(
      name: home,
      page: () => const HomeView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),

    // Create board route
    GetPage(
      name: createBoard,
      page: () => const CreateBoardView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),

      // Board detail
  GetPage(
    name: boardDetail,
    page: () => BoardDetailView(
      boardId: Get.parameters['boardId'] ?? '',
      boardName: Get.arguments?['boardName'],
    ),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
    middlewares: [AuthMiddleware()],
  ),

    // Card detail - Modal/popup
    GetPage(
      name: cardDetail,
      page: () {
        // Extract cardId from route path
        final String route = Get.currentRoute;
        final String cardId = route.replaceAll('/card/', '');

        return CardDetailView(
          cardId: cardId.isNotEmpty ? cardId : (Get.parameters['cardId'] ?? ''),
        );
      },
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
  ];

  // Helper methods for navigation

  // Auth navigation
  static void toLogin() => Get.offAllNamed(login);
  static void toRegister() => Get.toNamed(register);
  static void toForgotPassword() => Get.toNamed(forgotPassword);
  static void toVerifyOTP(String email, {String source = 'register'}) => Get.toNamed(verifyOTP, arguments: {'email': email, 'source': source});

  // Main app navigation
  static void toHome() => Get.offAllNamed(home);

  // Board navigation
  static void toCreateBoard() => Get.toNamed(createBoard);
  static void toBoardDetail(String boardId, {String? boardName}) => Get.toNamed('/board/$boardId', arguments: {'boardName': boardName});

  // Card navigation
  static void toCardDetail(String cardId) => Get.toNamed('/card/$cardId');

  // Card as bottom sheet
  static void showCardDetailBottomSheet(String cardId) {
    Get.bottomSheet(
      CardDetailView(cardId: cardId),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  // Back navigation helpers
  static void back() => Get.back();
  static bool canPop() => Get.currentRoute != initial;

  // Clear navigation stack
  static void clearAndGoTo(String route) => Get.offAllNamed(route);

  // Check current route
  static bool isCurrentRoute(String route) => Get.currentRoute == route;

  // Get current parameters
  static String getCurrentBoardId() => Get.parameters['boardId'] ?? '';
  static String getCurrentCardId() => Get.parameters['cardId'] ?? '';

  // Logout and clear everything
  static void logout() {
    // Clear any stored data here
    toLogin();
  }
}