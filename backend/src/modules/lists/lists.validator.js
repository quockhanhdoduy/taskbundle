const validator = require('validator');

const { ResponseHandler, StatusCodes } = require('../../utils');
const { MAX_LISTS_PER_BOARD } = require('./lists.model');
const { ListsService } = require('./lists.service');
const { BoardsService } = require('../boards/boards.service');

class ListsValidator {
    async createList(req, res, next) {
        const data = req.body;
        const { boardId } = req.params;

        if (!data || typeof data !== 'object' || Object.keys(data).length === 0) {
            return ResponseHandler.error(
                res,
                StatusCodes.NOT_ACCEPTABLE,
                'No data provided to create new list!!!'
            );
        }

        if (!boardId || !validator.isMongoId(boardId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Invalid Board ID!!!'
            );
        }

        const errors = [];

        if (
            !data.name ||
            typeof data.name !== 'string' ||
            !validator.isLength(data.name, { min: 1, max: 100 })
        ) {
            errors.push('List name must be a string and not exceed 100 characters!');
        }

        if (errors.length > 0) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Invalid input data!',
                { data: errors }
            );
        }

        // Check if board exists and is not closed
        try {
            const board = await BoardsService.findOneBoard({ _id: boardId });
            if (!board) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'Board not found!'
                );
            }

            // Check if board is closed
            if (board.isDeleted) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.FORBIDDEN,
                    'Cannot create list in a closed board!'
                );
            }
        } catch (error) {
            return ResponseHandler.error(
                res,
                StatusCodes.INTERNAL_SERVER_ERROR,
                'Error checking board status'
            );
        }

        // Check if board already has maximum lists
        try {
            const currentListsCount = await ListsService.getListsCount(boardId);
            if (currentListsCount >= MAX_LISTS_PER_BOARD) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.BAD_REQUEST,
                    `Cannot create more than ${MAX_LISTS_PER_BOARD} lists per board!`
                );
            }
        } catch (error) {
            return ResponseHandler.error(
                res,
                StatusCodes.INTERNAL_SERVER_ERROR,
                'Error checking lists count'
            );
        }

        // Add boardId to body for use in controller
        req.body.boardId = boardId;

        return next();
    }

    updateList(req, res, next) {
        const data = req.body;
        const { listId } = req.params;

        if (!listId || !validator.isMongoId(listId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Invalid List ID!!!'
            );
        }

        if (!data || typeof data !== 'object' || Object.keys(data).length === 0) {
            return ResponseHandler.error(
                res,
                StatusCodes.NOT_ACCEPTABLE,
                'No data provided to update list!!!'
            );
        }

        const errors = [];

        if (data.name !== undefined) {
            if (
                typeof data.name !== 'string' ||
                !validator.isLength(data.name, { min: 1, max: 100 })
            ) {
                errors.push('List name must be a string and not exceed 100 characters!');
            }
        }

        // Do not allow updating boardId, position through this route
        if (data.boardId !== undefined) {
            errors.push('Cannot change boardId of list!');
        }

        if (data.position !== undefined) {
            errors.push('Cannot change position through this route! Use separate position route.');
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

    deleteList(req, res, next) {
        const { listId } = req.params;

        if (!listId || !validator.isMongoId(listId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Invalid List ID!!!'
            );
        }

        return next();
    }

    getListsByBoard(req, res, next) {
        const { boardId } = req.params;

        if (!boardId || !validator.isMongoId(boardId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Board ID không hợp lệ!!!'
            );
        }

        return next();
    }

    getListById(req, res, next) {
        const { listId } = req.params;

        if (!listId || !validator.isMongoId(listId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Invalid List ID!!!'
            );
        }

        return next();
    }

    updateListPosition(req, res, next) {
        const { listId } = req.params;
        const { position } = req.body;

        if (!listId || !validator.isMongoId(listId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Invalid List ID!!!'
            );
        }

        if (position === undefined || !Number.isInteger(position) || position < 0) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Position must be a non-negative integer!'
            );
        }

        return next();
    }


}

module.exports = { ListsValidator: new ListsValidator() };
