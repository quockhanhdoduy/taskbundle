const express = require('express');

const { BoardsValidator } = require('./boards.validator');
const { BoardsController } = require('./boards.controller');
const { AuthMiddleware } = require('../auth/auth.middleware');
const { BoardAuthz } = require('./boards.authz');

const router = express.Router();

router.post(
    '/v1/boards',
    AuthMiddleware.verifyToken,
    BoardsValidator.createBoard,
    BoardsController.createBoard
);

router.get(
    '/v1/boards/home-views',
    AuthMiddleware.verifyToken,
    BoardsController.homeView
);

router.put(
    '/v1/boards/:boardId',
    AuthMiddleware.verifyToken,
    BoardsValidator.updateInfo,
    BoardsController.updateInfo
);

router.put(
    '/v1/boards/:boardId/close',
    AuthMiddleware.verifyToken,
    BoardAuthz.verifyBoardAdmin,
    BoardsValidator.closeBoard,
    BoardsController.closeBoard
);

router.put(
    '/v1/boards/:boardId/invite-members',
    AuthMiddleware.verifyToken,
    BoardsValidator.inviteMember,
    BoardsController.inviteMember
);

router.get(
    '/v1/boards/:boardId/accept-invites/:email',
    BoardsValidator.acceptInvitation,
    BoardsController.acceptInvitation
);

router.get(
    '/v1/boards/:boardId/members',
    AuthMiddleware.verifyToken,
    BoardAuthz.verifyBoardGeneralUser,
    BoardsValidator.getListBoardUsers,
    BoardsController.getListBoardUsers
  );

router.put(
    '/v1/boards/:boardId/member-roles',
    AuthMiddleware.verifyToken,
    BoardAuthz.verifyBoardGeneralUser,
    BoardsValidator.updateMemberRole,
    BoardsController.updateMemberRole
);

router.delete(
    '/v1/boards/:boardId/members/:email',
    AuthMiddleware.verifyToken,
    BoardAuthz.verifyBoardAdmin,
    BoardsValidator.removeMember,
    BoardsController.removeMember
);

router.put(
    '/v1/boards/:boardId/leavings',
    AuthMiddleware.verifyToken,
    BoardAuthz.verifyBoardGeneralUser,
    BoardsValidator.leaveBoard,
    BoardsController.leaveBoard
  );


module.exports = { boardsRoutes: router };
