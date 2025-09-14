import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';
import 'api_service.dart';

class NotificationService extends GetxService {
  static NotificationService get instance => Get.find<NotificationService>();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final RxString _fcmToken = ''.obs;
  final RxList<Map<String, dynamic>> _notifications = <Map<String, dynamic>>[].obs;

  String get fcmToken => _fcmToken.value;
  List<Map<String, dynamic>> get notifications => _notifications.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      await _initializeFirebase();
      await _initializeLocalNotifications();
      await _requestPermissions();
      await _getFCMToken();
      _setupMessageHandlers();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing NotificationService: $e');
      }
    }
  }

  // Initialize Firebase
  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (kDebugMode) {
        print('Firebase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization error: $e');
      }
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (status != PermissionStatus.granted) {
        if (kDebugMode) {
          print('Notification permission denied');
        }
      }
    }

    // Request FCM permissions
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('FCM Permission status: ${settings.authorizationStatus}');
    }
  }

  // Get FCM token
  Future<void> _getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        _fcmToken.value = token;
        await _saveFCMToken(token);
        if (kDebugMode) {
          print('FCM Token: $token');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
    }
  }

  // Save FCM token to SharedPreferences and send to backend
  Future<void> _saveFCMToken(String token) async {
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);

    // Send to backend if user is logged in
    try {
      await ApiService.post('/v1/users/fcm-token', {
        'fcmToken': token,
      });
      if (kDebugMode) {
        print('FCM token sent to backend successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending FCM token to backend: $e');
        // Don't throw error to avoid affecting token saving
      }
    }
  }

  // Get saved FCM token
  Future<String?> getSavedFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  // Setup message handlers
  void _setupMessageHandlers() {
    // Handle message when app is open
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle message when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle message when app is opened from terminated state
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessageOpenedApp(message);
      }
    });
  }

  // Handle message when app is open (foreground)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('Received foreground message: ${message.messageId}');
    }

    // Show local notification
    await _showLocalNotification(message);

    // Add to notifications list
    _addNotification(message);
  }

  // Handle message when app is opened from notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('App opened from notification: ${message.messageId}');
    }

    // Add to notifications list
    _addNotification(message);

    // Handle navigation based on data
    _handleNotificationNavigation(message.data);
  }

  // Handle when tapping notification
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }

    // Handle navigation based on payload
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      _handleNotificationNavigation(data);
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'taskbundle_channel',
      'TaskBundle Notifications',
      channelDescription: 'Notifications for TaskBundle app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'TaskBundle',
      message.notification?.body ?? 'You have a new notification',
      details,
      payload: jsonEncode(message.data),
    );
  }

  // Add notification to list
  void _addNotification(RemoteMessage message) {
    final notification = {
      'id': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': message.notification?.title ?? 'TaskBundle',
      'body': message.notification?.body ?? 'New notification',
      'data': message.data,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    };

    _notifications.insert(0, notification);

    // Limit number of notifications (keep 50 most recent)
    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }
  }

  // Handle navigation based on notification data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'];
    final boardId = data['boardId'];
    final cardId = data['cardId'];

    switch (type) {
      case 'board':
        if (boardId != null) {
          Get.toNamed('/board/$boardId');
        }
        break;
      case 'card':
        if (boardId != null && cardId != null) {
          Get.toNamed('/board/$boardId/card/$cardId');
        }
        break;
      case 'comment':
        if (boardId != null && cardId != null) {
          Get.toNamed('/board/$boardId/card/$cardId');
        }
        break;
      default:
        // Open home view if no specific type
        Get.toNamed('/home');
    }
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['read'] = true;
    }
  }

  // Mark all notifications as read
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['read'] = true;
    }
  }

  // Delete notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n['id'] == notificationId);
  }

  // Delete all notifications
  void clearAllNotifications() {
    _notifications.clear();
  }

  // Get number of unread notifications
  int get unreadCount => _notifications.where((n) => !n['read']).length;

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topic $topic: $e');
      }
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from topic $topic: $e');
      }
    }
  }

  // Send FCM token to backend (used when user logs in)
  Future<void> sendFCMTokenToBackend() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await ApiService.post('/v1/users/fcm-token', {
          'fcmToken': token,
        });
        if (kDebugMode) {
          print('FCM token sent to backend after login');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending FCM token to backend after login: $e');
      }
    }
  }
}
