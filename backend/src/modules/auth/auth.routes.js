const express = require('express');
const { AuthController } = require('./auth.controller');
const { AuthMiddleware } = require('./auth.middleware');

const router = express.Router();

router.post(
    '/v1/auth/register',
    AuthMiddleware.registerValidate,
    AuthController.register
);

router.put(
    '/v1/auth/verifications',
    AuthMiddleware.verifyUserValidate,
    AuthController.verifyUser
);

router.post(
    '/v1/auth/login',
    AuthMiddleware.loginValidate,
    AuthController.login
);

router.post(
    '/v1/auth/refresh-login',
    AuthController.refreshLogin
);

module.exports = {
    authRoutes: router,
}