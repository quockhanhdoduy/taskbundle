const validator = require('validator');

const { ResponseHandler, StatusCodes } = require('../../utils');
const { MAX_CARDS_PER_LIST, MAX_ATTACHMENTS_PER_CARD } = require('./cards.model');
const { CardsService } = require('./cards.service');
const { ListsService } = require('../lists/lists.service');

class CardsValidator {
    async createCard(req, res, next) {
        const data = req.body;
        const { listId } = req.params;

        if (!data || typeof data !== 'object' || Object.keys(data).length === 0) {
            return ResponseHandler.error(
                res,
                StatusCodes.NOT_ACCEPTABLE,
'No data provided to create new card!'
            );
        }

        if (!listId || !validator.isMongoId(listId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid List ID!'
            );
        }

        const errors = [];

        if (
            !data.title ||
            typeof data.title !== 'string' ||
            !validator.isLength(data.title, { min: 1, max: 200 })
        ) {
            errors.push('Card title must be a string and not exceed 200 characters!');
        }

        if (data.description && typeof data.description !== 'string') {
            errors.push('Card description must be a string!');
        }

        if (data.description && !validator.isLength(data.description, { max: 2000 })) {
            errors.push('Card description must not exceed 2000 characters!');
        }

        if (data.dueDate && !validator.isISO8601(data.dueDate)) {
            errors.push('Due date must be a valid ISO 8601 date!');
        }

        if (data.isCompleted && typeof data.isCompleted !== 'boolean') {
            errors.push('isCompleted must be a boolean value!');
        }

        if (data.assignedUsers && !Array.isArray(data.assignedUsers)) {
            errors.push('assignedUsers must be an array!');
        }

        if (data.assignedUsers) {
            for (const userId of data.assignedUsers) {
                if (!validator.isMongoId(userId)) {
                    errors.push('All assigned user IDs must be valid MongoDB ObjectId!');
                    break;
                }
            }
        }

        if (errors.length > 0) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid input data!',
                { data: errors }
            );
        }

        // Check if list exists
        try {
            const list = await ListsService.findOneList({ _id: listId });
            if (!list) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'List not found or deleted!'
                );
            }

            // Check if list has maximum cards limit
            const cardsCount = await CardsService.countCardsByListId(listId);
            if (cardsCount >= MAX_CARDS_PER_LIST) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.BAD_REQUEST,
                    `Maximum ${MAX_CARDS_PER_LIST} cards per list!`
                );
            }

            // Add listId to request body
            req.body.listId = listId;
            next();
        } catch (error) {
            return ResponseHandler.error(
                res,
                StatusCodes.INTERNAL_SERVER_ERROR,
                error.message
            );
        }
    }

    async getCardsByList(req, res, next) {
        const { listId } = req.params;

        if (!listId || !validator.isMongoId(listId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid List ID!'
            );
        }

        try {
            const list = await ListsService.findOneList({ _id: listId });
            if (!list) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'List not found or deleted!'
                );
            }

            next();
        } catch (error) {
            return ResponseHandler.error(
                res,
                StatusCodes.INTERNAL_SERVER_ERROR,
                error.message
            );
        }
    }

    async getCard(req, res, next) {
        const { cardId } = req.params;

        if (!cardId || !validator.isMongoId(cardId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid Card ID!'
            );
        }

        next();
    }

    async updateCard(req, res, next) {
        const { cardId } = req.params;
        const data = req.body;

        if (!cardId || !validator.isMongoId(cardId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid Card ID!'
            );
        }

        if (!data || typeof data !== 'object' || Object.keys(data).length === 0) {
            return ResponseHandler.error(
                res,
                StatusCodes.NOT_ACCEPTABLE,
'No data provided to update card!'
            );
        }

        const errors = [];

        if (data.title !== undefined) {
            if (
                !data.title ||
                typeof data.title !== 'string' ||
                !validator.isLength(data.title, { min: 1, max: 200 })
            ) {
                errors.push('Card title must be a string and not exceed 200 characters!');
            }
        }

        if (data.description !== undefined && typeof data.description !== 'string') {
            errors.push('Card description must be a string!');
        }

        if (data.description && !validator.isLength(data.description, { max: 2000 })) {
            errors.push('Card description must not exceed 2000 characters!');
        }

        if (data.dueDate !== undefined && data.dueDate !== null && !validator.isISO8601(data.dueDate)) {
            errors.push('Due date must be a valid ISO 8601 date!');
        }

        if (data.isCompleted !== undefined && typeof data.isCompleted !== 'boolean') {
            errors.push('isCompleted must be a boolean value!');
        }

        if (data.assignedUsers !== undefined && !Array.isArray(data.assignedUsers)) {
            errors.push('assignedUsers must be an array!');
        }

        if (data.assignedUsers) {
            for (const userId of data.assignedUsers) {
                if (!validator.isMongoId(userId)) {
                    errors.push('All assigned user IDs must be valid MongoDB ObjectId!');
                    break;
                }
            }
        }

        if (errors.length > 0) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid input data!',
                { data: errors }
            );
        }

        next();
    }

    async deleteCard(req, res, next) {
        const { cardId } = req.params;

        if (!cardId || !validator.isMongoId(cardId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid Card ID!'
            );
        }

        next();
    }

    async updateCardPosition(req, res, next) {
        const { cardId } = req.params;
        const { position, listId } = req.body;

        if (!cardId || !validator.isMongoId(cardId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid Card ID!'
            );
        }

        const errors = [];

        if (position === undefined || typeof position !== 'number' || position < 0) {
            errors.push('Position must be a non-negative number!');
        }

        if (listId && !validator.isMongoId(listId)) {
            errors.push('List ID must be a valid MongoDB ObjectId!');
        }

        if (errors.length > 0) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid input data!',
                { data: errors }
            );
        }

        // If moving to different list, check if list exists
        if (listId) {
            try {
                const list = await ListsService.findOneList({ _id: listId });
                if (!list) {
                    return ResponseHandler.error(
                        res,
                        StatusCodes.NOT_FOUND,
                        'Target list not found or deleted!'
                    );
                }
            } catch (error) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.INTERNAL_SERVER_ERROR,
                    error.message
                );
            }
        }

        next();
    }

    async moveCardToList(req, res, next) {
        const { cardId } = req.params;
        const { targetListId, position } = req.body;

        if (!cardId || !validator.isMongoId(cardId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid Card ID!'
            );
        }

        if (!targetListId || !validator.isMongoId(targetListId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Target List ID must be a valid MongoDB ObjectId!'
            );
        }

        if (position === undefined || typeof position !== 'number' || position < 0) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Position must be a non-negative number!'
            );
        }

        try {
            const list = await ListsService.findOneList({ _id: targetListId });
            if (!list) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'Target list not found or deleted!'
                );
            }

            next();
        } catch (error) {
            return ResponseHandler.error(
                res,
                StatusCodes.INTERNAL_SERVER_ERROR,
                error.message
            );
        }
    }

    async assignUser(req, res, next) {
        const { cardId } = req.params;
        const { userId } = req.body;

        if (!cardId || !validator.isMongoId(cardId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid Card ID!'
            );
        }

        if (!userId || !validator.isMongoId(userId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid User ID!'
            );
        }

        next();
    }

    async unassignUser(req, res, next) {
        const { cardId } = req.params;
        const { userId } = req.body;

        if (!cardId || !validator.isMongoId(cardId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid Card ID!'
            );
        }

        if (!userId || !validator.isMongoId(userId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid User ID!'
            );
        }

        next();
    }

    async assignMultipleUsers(req, res, next) {
        const { cardId } = req.params;
        const { userIds } = req.body;

        if (!cardId || !validator.isMongoId(cardId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid Card ID!'
            );
        }

        if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'User IDs must be a non-empty array!'
            );
        }

        for (const userId of userIds) {
            if (!validator.isMongoId(userId)) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.BAD_REQUEST,
                    'All User IDs must be valid MongoDB ObjectId!'
                );
            }
        }

        next();
    }

    async updateDueDate(req, res, next) {
        const { cardId } = req.params;
        const { dueDate } = req.body;

        if (!cardId || !validator.isMongoId(cardId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid Card ID!'
            );
        }

        if (dueDate !== undefined && dueDate !== null && !validator.isISO8601(dueDate)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Due date must be a valid ISO 8601 date!'
            );
        }

        next();
    }

    async updateCompletion(req, res, next) {
        const { cardId } = req.params;
        const { isCompleted } = req.body;

        if (!cardId || !validator.isMongoId(cardId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid Card ID!'
            );
        }

        if (isCompleted === undefined || typeof isCompleted !== 'boolean') {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'isCompleted must be a boolean value!'
            );
        }

        next();
    }

    async addAttachment(req, res, next) {
        const { cardId } = req.params;

        if (!cardId || !validator.isMongoId(cardId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid Card ID!'
            );
        }

        // Check if attachment limit is reached
        try {
            const card = await CardsService.findOneCard({ _id: cardId });
            if (!card) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'Card not found!'
                );
            }

            if (card.attachments && card.attachments.length >= MAX_ATTACHMENTS_PER_CARD) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.BAD_REQUEST,
                    `Maximum ${MAX_ATTACHMENTS_PER_CARD} attachments per card!`
                );
            }

            next();
        } catch (error) {
            return ResponseHandler.error(
                res,
                StatusCodes.INTERNAL_SERVER_ERROR,
                error.message
            );
        }
    }

    async removeAttachment(req, res, next) {
        const { cardId, attachmentId } = req.params;

        if (!cardId || !validator.isMongoId(cardId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
'Invalid Card ID!'
            );
        }

        if (!attachmentId || !validator.isMongoId(attachmentId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Attachment ID must be a valid MongoDB ObjectId!'
            );
        }

        next();
    }
}

module.exports = { CardsValidator: new CardsValidator() };
