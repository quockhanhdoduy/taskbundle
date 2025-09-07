const express = require('express');

const { ListsValidator } = require('./lists.validator');
const { ListsController } = require('./lists.controller');
const { ListsAuthz } = require('./lists.authz');
const { AuthMiddleware } = require('../auth/auth.middleware');
const { BoardAuthz } = require('../boards/boards.authz');
const { ActivityLoggerMiddleware, ActivityTypes } = require('../activities');

const router = express.Router();

router.post(
    '/v1/boards/:boardId/lists',
    AuthMiddleware.verifyToken,
    BoardAuthz.verifyBoardMember,
    ListsValidator.createList,
    ActivityLoggerMiddleware.logActivity(ActivityTypes.LIST_CREATED),
    ListsController.createList
);

router.get(
    '/v1/boards/:boardId/lists',
    AuthMiddleware.verifyToken,
    BoardAuthz.verifyBoardGeneralUser,
    ListsValidator.getListsByBoard,
    ListsController.getListsByBoard
);

router.get(
    '/v1/lists/:listId',
    AuthMiddleware.verifyToken,
    ListsAuthz.verifyListAccess,
    ListsValidator.getListById,
    ListsController.getListById
);

router.put(
    '/v1/lists/:listId',
    AuthMiddleware.verifyToken,
    ListsAuthz.verifyListMemberAccess, // Check MEMBER access or higher
    ListsValidator.updateList,
    ActivityLoggerMiddleware.logActivity(ActivityTypes.LIST_UPDATED),
    ListsController.updateList
);

router.delete(
    '/v1/lists/:listId',
    AuthMiddleware.verifyToken,
    ListsAuthz.verifyListMemberAccess,
    ListsValidator.deleteList,
    ActivityLoggerMiddleware.logActivity(ActivityTypes.LIST_DELETED),
    ListsController.deleteList
);

router.put(
    '/v1/lists/:listId/position',
    AuthMiddleware.verifyToken,
    ListsAuthz.verifyListMemberAccess,
    ListsValidator.updateListPosition,
    ActivityLoggerMiddleware.logActivity(ActivityTypes.LIST_MOVED),
    ListsController.updateListPosition
);



module.exports = { listsRoutes: router };