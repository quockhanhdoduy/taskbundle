const { ResponseHandler, StatusCodes } = require('../../utils');
const { NotificationsService } = require('./notifications.service');

class NotificationsController {
  // Test notification endpoint
  async testNotification(req, res) {
    try {
      const { token } = req.body;

      const result = await NotificationsService.sendTestNotification(token);

      return ResponseHandler.success(
        res,
        StatusCodes.OK,
        'Test notification sent successfully',
        { result }
      );
    } catch (error) {
      console.error('Error in testNotification:', error);
      return ResponseHandler.error(
        res,
        StatusCodes.INTERNAL_SERVER_ERROR,
        'Failed to send test notification'
      );
    }
  }

  // Save FCM token for user
  async saveFCMToken(req, res) {
    try {
      const user = req.user;
      const { fcmToken } = req.body;

      await NotificationsService.saveUserToken(user._id, fcmToken);

      return ResponseHandler.success(
        res,
        StatusCodes.OK,
        'FCM token saved successfully'
      );
    } catch (error) {
      console.error('Error in saveFCMToken:', error);
      return ResponseHandler.error(
        res,
        StatusCodes.INTERNAL_SERVER_ERROR,
        'Failed to save FCM token'
      );
    }
  }

  // Get user notifications
  async getUserNotifications(req, res) {
    try {
      const user = req.user;
      const { page = 1, limit = 10 } = req.query;

      const notifications = await NotificationsService.getUserNotifications(
        user._id,
        parseInt(page),
        parseInt(limit)
      );

      return ResponseHandler.success(
        res,
        StatusCodes.OK,
        'Notifications retrieved successfully',
        notifications
      );
    } catch (error) {
      console.error('Error in getUserNotifications:', error);
      return ResponseHandler.error(
        res,
        StatusCodes.INTERNAL_SERVER_ERROR,
        'Failed to get notifications'
      );
    }
  }

  // Mark notification as read
  async markAsRead(req, res) {
    try {
      const { notificationId } = req.params;
      const user = req.user;

      await NotificationsService.markAsRead(notificationId, user._id);

      return ResponseHandler.success(
        res,
        StatusCodes.OK,
        'Notification marked as read'
      );
    } catch (error) {
      console.error('Error in markAsRead:', error);
      return ResponseHandler.error(
        res,
        StatusCodes.INTERNAL_SERVER_ERROR,
        'Failed to mark notification as read'
      );
    }
  }

  // Mark all notifications as read
  async markAllAsRead(req, res) {
    try {
      const user = req.user;

      await NotificationsService.markAllAsRead(user._id);

      return ResponseHandler.success(
        res,
        StatusCodes.OK,
        'All notifications marked as read'
      );
    } catch (error) {
      console.error('Error in markAllAsRead:', error);
      return ResponseHandler.error(
        res,
        StatusCodes.INTERNAL_SERVER_ERROR,
        'Failed to mark all notifications as read'
      );
    }
  }
}

module.exports = { NotificationsController: new NotificationsController() };
