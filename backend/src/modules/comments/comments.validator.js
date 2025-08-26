const validator = require('validator');

const { ResponseHandler, StatusCodes } = require('../../utils');
const { MAX_COMMENTS_PER_CARD } = require('./comments.model');
const { CommentsService } = require('./comments.service');
const { CardsService } = require('../cards/cards.service');

class CommentsValidator {
    /**
     * createComment: Validate comment creation data
     */
    async createComment(req, res, next) {
        const data = req.body;
        const { cardId } = req.params;

        if (!data || typeof data !== 'object' || Object.keys(data).length === 0) {
            return ResponseHandler.error(
                res,
                StatusCodes.NOT_ACCEPTABLE,
                'No data provided to create new comment!'
            );
        }

        if (!cardId || !validator.isMongoId(cardId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Invalid Card ID!'
            );
        }

        const errors = [];

        // Validate content
        if (!data.content || typeof data.content !== 'string') {
            errors.push('Comment content is required and must be a string!');
        } else if (!validator.isLength(data.content.trim(), { min: 1, max: 2000 })) {
            errors.push('Comment content must be between 1 and 2000 characters!');
        }

        if (errors.length > 0) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Invalid input data!',
                { data: errors }
            );
        }

        try {
            const card = await CardsService.findOneCard({ _id: cardId });
            if (!card) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'Card not found or deleted!'
                );
            }

            // Check comments limit
            const commentsCount = await CommentsService.countCommentsByCardId(cardId);
            if (commentsCount >= MAX_COMMENTS_PER_CARD) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.BAD_REQUEST,
                    `Maximum ${MAX_COMMENTS_PER_CARD} comments per card allowed!`
                );
            }

            req.body.cardId = cardId;
            next();
        } catch (error) {
            return ResponseHandler.error(
                res,
                StatusCodes.INTERNAL_SERVER_ERROR,
                error.message
            );
        }
    }

    /**
     * getCommentsByCard: Validate get comments request
     */
    async getCommentsByCard(req, res, next) {
        const { cardId } = req.params;
        const { page, limit, sortBy, sortOrder } = req.query;

        if (!cardId || !validator.isMongoId(cardId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Invalid Card ID!'
            );
        }

        const errors = [];

        // Validate pagination parameters
        if (page && (!validator.isNumeric(page.toString()) || parseInt(page) < 1)) {
            errors.push('Page must be a positive number!');
        }

        if (limit && (!validator.isNumeric(limit.toString()) || parseInt(limit) < 1 || parseInt(limit) > 100)) {
            errors.push('Limit must be a number between 1 and 100!');
        }

        // Validate sort parameters
        const allowedSortFields = ['createdAt', 'updatedAt', 'content'];
        if (sortBy && !allowedSortFields.includes(sortBy)) {
            errors.push(`SortBy must be one of: ${allowedSortFields.join(', ')}`);
        }

        const allowedSortOrders = ['asc', 'desc'];
        if (sortOrder && !allowedSortOrders.includes(sortOrder)) {
            errors.push(`SortOrder must be one of: ${allowedSortOrders.join(', ')}`);
        }

        if (errors.length > 0) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Invalid query parameters!',
                { data: errors }
            );
        }

        try {
            // Check if card exists
            const card = await CardsService.findOneCard({ _id: cardId });
            if (!card) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'Card not found or deleted!'
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

    /**
     * updateComment: Validate comment update data
     */
    async updateComment(req, res, next) {
        const data = req.body;
        const { commentId } = req.params;

        if (!commentId || !validator.isMongoId(commentId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Invalid Comment ID!'
            );
        }

        if (!data || typeof data !== 'object' || Object.keys(data).length === 0) {
            return ResponseHandler.error(
                res,
                StatusCodes.NOT_ACCEPTABLE,
                'No data provided to update comment!'
            );
        }

        const errors = [];

        // Validate content if provided
        if (data.content !== undefined) {
            if (typeof data.content !== 'string') {
                errors.push('Comment content must be a string!');
            } else if (!validator.isLength(data.content.trim(), { min: 1, max: 2000 })) {
                errors.push('Comment content must be between 1 and 2000 characters!');
            }
        }

        // Remove fields that shouldn't be updated directly
        delete data.userId;
        delete data.cardId;
        delete data.isDeleted;
        delete data.deletedAt;
        delete data.createdAt;
        delete data.updatedAt;

        if (errors.length > 0) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Invalid input data!',
                { data: errors }
            );
        }

        try {
            // Check if comment exists
            const comment = await CommentsService.findOneComment({ _id: commentId });
            if (!comment) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'Comment not found or deleted!'
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

    /**
     * deleteComment: Validate comment deletion
     */
    async deleteComment(req, res, next) {
        const { commentId } = req.params;

        if (!commentId || !validator.isMongoId(commentId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Invalid Comment ID!'
            );
        }

        try {
            // Check if comment exists
            const comment = await CommentsService.findOneComment({ _id: commentId });
            if (!comment) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'Comment not found or deleted!'
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

    /**
     * getComment: Validate get single comment request
     */
    async getComment(req, res, next) {
        const { commentId } = req.params;

        if (!commentId || !validator.isMongoId(commentId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Invalid Comment ID!'
            );
        }

        next();
    }


}

module.exports = { CommentsValidator: new CommentsValidator() };
