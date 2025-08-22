const express = require('express');

const { ListsValidator } = require('./lists.validator');
const { ListsController } = require('./lists.controller');
const { ListsAuthz } = require('./lists.authz');
const { AuthMiddleware } = require('../auth/auth.middleware');
const { BoardAuthz } = require('../boards/boards.authz');

const router = express.Router();

router.post(
    '/v1/boards/:boardId/lists',
    AuthMiddleware.verifyToken,
    BoardAuthz.verifyBoardMember,
    ListsValidator.createList,
    ListsController.createList
);

router.get(
    '/v1/boards/:boardId/lists',
    AuthMiddleware.verifyToken,
    BoardAuthz.verifyBoardGeneralUser,
    ListsValidator.getListsByBoard,
    ListsController.getListsByBoard
);

router.put(
    '/v1/lists/:listId',
    AuthMiddleware.verifyToken,
    ListsAuthz.verifyListMemberAccess, // Check MEMBER access or higher
    ListsValidator.updateList,
    ListsController.updateList
);

router.delete(
    '/v1/lists/:listId',
    AuthMiddleware.verifyToken,
    ListsAuthz.verifyListMemberAccess,
    ListsValidator.deleteList,
    ListsController.deleteList
);

router.put(
    '/v1/lists/:listId/position',
    AuthMiddleware.verifyToken,
    ListsAuthz.verifyListMemberAccess,
    ListsValidator.updateListPosition,
    ListsController.updateListPosition
);



module.exports = { listsRoutes: router };