const validator = require('validator');

const { ListsService } = require('./lists.service');
const { BoardsService } = require('../boards/boards.service');
const { ResponseHandler, StatusCodes } = require('../../utils');
const { BoardRoles } = require('../boards/boards.const');


class ListsAuthz {
    /**
     * verifyListAccess: Check if user has access to list
     * Check through the board that the list belongs to
     */
    async verifyListAccess(req, res, next) {
        const user = req.user;
        const { listId } = req.params;

        if (!listId || !validator.isMongoId(listId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Invalid List ID!!!'
            );
        }

        try {
            const list = await ListsService.findOneList({ _id: listId });
            if (!list) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'List not found!'
                );
            }

            const board = await BoardsService.findOneBoard({ _id: list.boardId });
            if (!board) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'Board containing this list not found!'
                );
            }

            const userBoard = await BoardsService.findOneUsersBoards({
                userId: user._id,
                boardId: list.boardId,
                accepted: true,
            });

            if (!userBoard) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.FORBIDDEN,
                    'You do not have permission to access this list!'
                );
            }

            // Add information to request for use in controller
            req.list = list;
            req.board = board;
            req.userBoard = userBoard;

            return next();
        } catch (error) {
            return ResponseHandler.error(
                res,
                StatusCodes.INTERNAL_SERVER_ERROR,
                error.message
            );
        }
    }

    /**
     * verifyListMemberAccess: Check if user has member access or higher on board containing list
     * For operations like create, edit, delete list
     */
    async verifyListMemberAccess(req, res, next) {
        const user = req.user;
        const { listId } = req.params;

        if (!listId || !validator.isMongoId(listId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Invalid List ID!!!'
            );
        }

        try {
            const list = await ListsService.findOneList({ _id: listId });
            if (!list) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'List not found!'
                );
            }

            // Check if board exists
            const board = await BoardsService.findOneBoard({ _id: list.boardId });
            if (!board) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'Board containing this list not found!'
                );
            }

            const userBoard = await BoardsService.findOneUsersBoards({
                userId: user._id,
                boardId: list.boardId,
                accepted: true,
            });

            if (!userBoard) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.FORBIDDEN,
                    'You do not have permission to access this list!'
                );
            }

            if (![BoardRoles.ADMIN, BoardRoles.MEMBER].includes(userBoard.role)) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.FORBIDDEN,
                    'You do not have permission to perform this operation on the list!'
                );
            }


            req.list = list;
            req.board = board;
            req.userBoard = userBoard;

            return next();
        } catch (error) {
            return ResponseHandler.error(
                res,
                StatusCodes.INTERNAL_SERVER_ERROR,
                error.message
            );
        }
    }
}

module.exports = { ListsAuthz: new ListsAuthz() };
