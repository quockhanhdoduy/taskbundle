const express = require('express');

const router = express.Router();
const { UsersController } = require('./users.controller');
const { AuthMiddleware } = require('../auth/auth.middleware');
const { UsersValidator } = require('./users.validator');

router.get(
    '/v1/users/my-profiles',
    AuthMiddleware.verifyToken,
    UsersController.viewMyProfile
);

router.put(
    '/v1/users/my-profiles',
    AuthMiddleware.verifyToken,
    UsersValidator.updateMyProfile,
    UsersController.updateMyProfile
);

router.put(
    '/v1/users/change-password',
    AuthMiddleware.verifyToken,
    UsersValidator.changePassword,
    UsersController.changePassword
);

router.post(
    '/v1/users/forgot-password',
    UsersController.forgotPassword
);

router.put(
    '/v1/users/verify-forgot-password',
    UsersController.verifyForgotPassword
);

router.post(
    '/v1/users/reset-password',
    UsersController.resetPassword
);

router.get(
    '/v1/users/:userId',
    UsersValidator.viewUserGeneralInfo,
    UsersController.viewUserGeneralInfo
);

router.post(
    '/v1/users/fcm-token',
    AuthMiddleware.verifyToken,
    UsersController.saveFCMToken
);

module.exports = { usersRoutes: router };
