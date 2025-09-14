const express = require('express');

const { NotificationsValidator } = require('./notifications.validator');
const { NotificationsController } = require('./notifications.controller');
const { AuthMiddleware } = require('../auth/auth.middleware');

const router = express.Router();

router.post(
    '/v1/notifications/test',
    NotificationsValidator.testNotification,
    NotificationsController.testNotification
);

router.post(
    '/v1/notifications/save-token',
    AuthMiddleware.verifyToken,
    NotificationsValidator.saveFCMToken,
    NotificationsController.saveFCMToken
);

router.get(
    '/v1/notifications',
    AuthMiddleware.verifyToken,
    NotificationsValidator.getUserNotifications,
    NotificationsController.getUserNotifications
);

router.put(
    '/v1/notifications/:notificationId/read',
    AuthMiddleware.verifyToken,
    NotificationsValidator.markAsRead,
    NotificationsController.markAsRead
);

router.put(
    '/v1/notifications/mark-all-read',
    AuthMiddleware.verifyToken,
    NotificationsController.markAllAsRead
);

module.exports = { notificationsRoutes: router };
