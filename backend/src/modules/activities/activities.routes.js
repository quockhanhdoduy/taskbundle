const express = require('express');

const { ActivitiesValidator } = require('./activities.validator');
const { ActivitiesController } = require('./activities.controller');
const { BoardAuthz } = require('../boards/boards.authz');
const { AuthMiddleware } = require('../auth/auth.middleware');

const router = express.Router();

router.get(
    '/v1/boards/:boardId/activities',
    AuthMiddleware.verifyToken,
    BoardAuthz.verifyBoardGeneralUser,
    ActivitiesValidator.getBoardActivities,
    ActivitiesController.getBoardActivities
);

module.exports = { activitiesRoutes: router };
