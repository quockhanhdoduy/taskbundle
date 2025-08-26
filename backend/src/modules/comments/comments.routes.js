const express = require('express');

const { CommentsValidator } = require('./comments.validator');
const { CommentsController } = require('./comments.controller');
const { CommentsAuthz } = require('./comments.authz');
const { CardsAuthz } = require('../cards/cards.authz');
const { AuthMiddleware } = require('../auth/auth.middleware');
const { ActivityLoggerMiddleware, ActivityTypes } = require('../activities');

const router = express.Router();

router.post(
    '/v1/cards/:cardId/comments',
    AuthMiddleware.verifyToken,
    CardsAuthz.verifyCardMemberAccess,
    CommentsValidator.createComment,
    ActivityLoggerMiddleware.logActivity(ActivityTypes.COMMENT_ADDED),
    CommentsController.createComment
);

router.get(
    '/v1/cards/:cardId/comments',
    AuthMiddleware.verifyToken,
    CardsAuthz.verifyCardAccess,
    CommentsValidator.getCommentsByCard,
    CommentsController.getCommentsByCard
);



router.get(
    '/v1/comments/:commentId',
    AuthMiddleware.verifyToken,
    CommentsAuthz.verifyCommentAccess,
    CommentsValidator.getComment,
    CommentsController.getComment
);

router.put(
    '/v1/comments/:commentId',
    AuthMiddleware.verifyToken,
    CommentsAuthz.verifyCommentOwnership,
    CommentsValidator.updateComment,
    CommentsController.updateComment
);

router.delete(
    '/v1/comments/:commentId',
    AuthMiddleware.verifyToken,
    CommentsAuthz.verifyCommentDeleteAccess,
    CommentsValidator.deleteComment,
    CommentsController.deleteComment
);

module.exports = { commentsRoutes: router };