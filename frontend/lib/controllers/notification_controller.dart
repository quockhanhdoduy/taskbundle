import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService.instance;

  // Getters
  List<Map<String, dynamic>> get notifications => _notificationService.notifications;
  int get unreadCount => _notificationService.unreadCount;
  String get fcmToken => _notificationService.fcmToken;

  @override
  void onInit() {
    super.onInit();
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    _notificationService.markAsRead(notificationId);
  }

  // Mark all notifications as read
  void markAllAsRead() {
    _notificationService.markAllAsRead();
  }

  // Delete notification
  void removeNotification(String notificationId) {
    _notificationService.removeNotification(notificationId);
  }

  // Delete all notifications
  void clearAllNotifications() {
    _notificationService.clearAllNotifications();
  }

  // Subscribe to board notifications
  Future<void> subscribeToBoard(String boardId) async {
    await _notificationService.subscribeToTopic('board_$boardId');
  }

  // Unsubscribe from board notifications
  Future<void> unsubscribeFromBoard(String boardId) async {
    await _notificationService.unsubscribeFromTopic('board_$boardId');
  }

  // Subscribe to user notifications
  Future<void> subscribeToUser(String userId) async {
    await _notificationService.subscribeToTopic('user_$userId');
  }

  // Unsubscribe from user notifications
  Future<void> unsubscribeFromUser(String userId) async {
    await _notificationService.unsubscribeFromTopic('user_$userId');
  }

  // Copy FCM token to clipboard
  void copyFCMToken() {
    if (fcmToken.isNotEmpty) {
      // Note: You'll need to add clipboard package to pubspec.yaml
      // Clipboard.setData(ClipboardData(text: fcmToken));
      Get.snackbar(
        'FCM Token',
        'Token copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );
    }
  }
}
