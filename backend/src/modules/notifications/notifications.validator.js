const validator = require('validator');
const { ResponseHandler, StatusCodes } = require('../../utils');

class NotificationsValidator {
  // Test notification validation
  testNotification(req, res, next) {
    const data = req.body;

    if (!data || typeof data !== 'object' || Object.keys(data).length === 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.BAD_REQUEST,
        'No data provided for test notification!'
      );
    }

    const errors = [];

    if (!data.token || typeof data.token !== 'string' || data.token.trim().length === 0) {
      errors.push('FCM token is required and must be a non-empty string!');
    }

    if (errors.length > 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.BAD_REQUEST,
        'Invalid input data!',
        { data: errors }
      );
    }

    return next();
  }

  // Save FCM token validation
  saveFCMToken(req, res, next) {
    const data = req.body;

    if (!data || typeof data !== 'object' || Object.keys(data).length === 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.BAD_REQUEST,
        'No data provided!'
      );
    }

    const errors = [];

    if (!data.fcmToken || typeof data.fcmToken !== 'string' || data.fcmToken.trim().length === 0) {
      errors.push('FCM token is required and must be a non-empty string!');
    }

    if (errors.length > 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.BAD_REQUEST,
        'Invalid input data!',
        { data: errors }
      );
    }

    return next();
  }

  // Get user notifications validation
  getUserNotifications(req, res, next) {
    const { page, limit } = req.query;
    const errors = [];

    if (page && (!validator.isInt(page) || parseInt(page) < 1)) {
      errors.push('Page must be a positive integer!');
    }

    if (limit && (!validator.isInt(limit) || parseInt(limit) < 1 || parseInt(limit) > 100)) {
      errors.push('Limit must be a positive integer between 1 and 100!');
    }

    if (errors.length > 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.BAD_REQUEST,
        'Invalid query parameters!',
        { data: errors }
      );
    }

    return next();
  }

  // Mark as read validation
  markAsRead(req, res, next) {
    const { notificationId } = req.params;
    const errors = [];

    if (!notificationId || !validator.isMongoId(notificationId)) {
      errors.push('Valid notification ID is required!');
    }

    if (errors.length > 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.BAD_REQUEST,
        'Invalid notification ID!',
        { data: errors }
      );
    }

    return next();
  }

  // Create notification validation (for internal use)
  createNotification(data) {
    const errors = [];

    if (!data.userId || !validator.isMongoId(data.userId)) {
      errors.push('Valid user ID is required!');
    }

    if (!data.title || typeof data.title !== 'string' || data.title.trim().length === 0) {
      errors.push('Title is required and must be a non-empty string!');
    }

    if (!data.body || typeof data.body !== 'string' || data.body.trim().length === 0) {
      errors.push('Body is required and must be a non-empty string!');
    }

    if (data.type && !['general', 'board', 'card', 'test'].includes(data.type)) {
      errors.push('Invalid notification type!');
    }

    return errors;
  }
}

module.exports = { NotificationsValidator: new NotificationsValidator() };
