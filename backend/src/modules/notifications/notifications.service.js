const { NotificationsModel } = require('./notifications.model');
const notificationService = require('../../services/notification.service');
const notificationHelper = require('../../services/notification-helper.service');

class NotificationsService {
  /**
   * Send test notification
   * @param {string} token FCM token
   * @returns {Object} result
   */
  async sendTestNotification(token) {
    try {
      const result = await notificationService.sendCustomNotification(
        'Test Notification',
        'This is a test notification from TaskBundle backend',
        { type: 'test', timestamp: new Date().toISOString() },
        [token]
      );
      return result;
    } catch (error) {
      throw new Error(error.message || 'Error sending test notification');
    }
  }

  /**
   * Save FCM token for user
   * @param {string} userId User ID
   * @param {string} fcmToken FCM token
   * @returns {Object} result
   */
  async saveUserToken(userId, fcmToken) {
    try {
      await notificationHelper.saveUserToken(userId, fcmToken);
      return { success: true };
    } catch (error) {
      throw new Error(error.message || 'Error saving FCM token');
    }
  }

  /**
   * Get user notifications with pagination
   * @param {string} userId User ID
   * @param {number} page Page number
   * @param {number} limit Items per page
   * @returns {Object} notifications with pagination
   */
  async getUserNotifications(userId, page = 1, limit = 10) {
    try {
      const skip = (page - 1) * limit;

      const [notifications, total] = await Promise.all([
        NotificationsModel.find({ userId })
          .sort({ createdAt: -1 })
          .skip(skip)
          .limit(limit),
        NotificationsModel.countDocuments({ userId })
      ]);

      return {
        notifications,
        pagination: {
          currentPage: page,
          totalPages: Math.ceil(total / limit),
          totalItems: total,
          itemsPerPage: limit
        }
      };
    } catch (error) {
      throw new Error(error.message || 'Error getting user notifications');
    }
  }

  /**
   * Mark notification as read
   * @param {string} notificationId Notification ID
   * @param {string} userId User ID
   * @returns {Object} result
   */
  async markAsRead(notificationId, userId) {
    try {
      const notification = await NotificationsModel.findOneAndUpdate(
        { _id: notificationId, userId },
        { isRead: true },
        { new: true }
      );

      if (!notification) {
        throw new Error('Notification not found or access denied');
      }

      return { success: true };
    } catch (error) {
      throw new Error(error.message || 'Error marking notification as read');
    }
  }

  /**
   * Mark all notifications as read for user
   * @param {string} userId User ID
   * @returns {Object} result
   */
  async markAllAsRead(userId) {
    try {
      await NotificationsModel.updateMany(
        { userId, isRead: false },
        { isRead: true }
      );

      return { success: true };
    } catch (error) {
      throw new Error(error.message || 'Error marking all notifications as read');
    }
  }

  /**
   * Create notification
   * @param {Object} data Notification data
   * @returns {Object} notification
   */
  async createNotification(data) {
    try {
      const notification = await NotificationsModel.create(data);
      return notification;
    } catch (error) {
      throw new Error(error.message || 'Error creating notification');
    }
  }

  /**
   * Send notification to user
   * @param {string} userId User ID
   * @param {string} title Notification title
   * @param {string} body Notification body
   * @param {string} type Notification type
   * @returns {Object} result
   */
  async sendNotificationToUser(userId, title, body, type = 'general') {
    try {
      // Create notification record
      const notification = await this.createNotification({
        userId,
        title,
        body,
        type
      });

      // Send FCM notification
      const fcmResult = await notificationService.sendCustomNotification(
        title,
        body,
        { notificationId: notification._id },
        [userId]
      );

      return {
        notification,
        fcmResult
      };
    } catch (error) {
      throw new Error(error.message || 'Error sending notification to user');
    }
  }
}

module.exports = { NotificationsService: new NotificationsService() };
