import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notification_controller.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationController = Get.find<NotificationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (notificationController.unreadCount > 0)
            TextButton(
              onPressed: () => notificationController.markAllAsRead(),
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white),
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'clear_all':
                  _showClearAllDialog(context, notificationController);
                  break;
                case 'copy_token':
                  notificationController.copyFCMToken();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: ListTile(
                  leading: Icon(Icons.clear_all),
                  title: Text('Clear all'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'copy_token',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Copy FCM Token'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        final notifications = notificationController.notifications;

        if (notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You\'ll see notifications here when they arrive',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            final isRead = notification['read'] as bool;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isRead ? Colors.grey[300] : Colors.blue[100],
                  child: Icon(
                    _getNotificationIcon(notification['data']),
                    color: isRead ? Colors.grey[600] : Colors.blue[600],
                  ),
                ),
                title: Text(
                  notification['title'],
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification['body']),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(notification['timestamp']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'mark_read':
                        if (!isRead) {
                          notificationController.markAsRead(notification['id']);
                        }
                        break;
                      case 'remove':
                        notificationController.removeNotification(notification['id']);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (!isRead)
                      const PopupMenuItem(
                        value: 'mark_read',
                        child: ListTile(
                          leading: Icon(Icons.mark_email_read),
                          title: Text('Mark as read'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Remove', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  if (!isRead) {
                    notificationController.markAsRead(notification['id']);
                  }
                  // Handle notification tap navigation
                  _handleNotificationTap(notification);
                },
              ),
            );
          },
        );
      }),
    );
  }

  IconData _getNotificationIcon(Map<String, dynamic> data) {
    final type = data['type'];
    switch (type) {
      case 'board':
        return Icons.dashboard;
      case 'card':
        return Icons.credit_card;
      case 'comment':
        return Icons.comment;
      case 'member':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    final data = notification['data'] as Map<String, dynamic>;
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
        Get.toNamed('/home');
    }
  }

  void _showClearAllDialog(BuildContext context, NotificationController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearAllNotifications();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}



