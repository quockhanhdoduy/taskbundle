const { ResponseHandler, StatusCodes } = require("../../utils");
const { CommentsService } = require("./comments.service");
const boardNotificationService = require('../../services/board-notification.service');

class CommentsController {
    /**
     * createComment: Create new comment for card
     */
    async createComment(req, res) {
        const data = req.body;
        const user = req.user;

        try {
            const commentData = {
                ...data,
                userId: user._id
            };

            const comment = await CommentsService.createComment(commentData);
            console.log(`User ${user.email} created new comment on card ${data.cardId}`);

            try {
                const { card, board } = await notificationHelper.getCardAndBoardInfo(data.cardId);
                await boardNotificationService.sendCommentNotification(
                    {
                        _id: comment._id,
                        author: {
                            _id: user._id,
                            name: user.name || user.email
                        }
                    },
                    card,
                    board,
                    user._id
                );
            } catch (notificationError) {
                console.error('Error sending comment notification:', notificationError);
            }

            return ResponseHandler.success(res, StatusCodes.CREATED, comment);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    /**
     * getCommentsByCard: Get all comments for a specific card
     */
    async getCommentsByCard(req, res) {
        const { cardId } = req.params;
        const { page, limit, sortBy, sortOrder } = req.query;

        try {
            const options = {
                page: parseInt(page) || 1,
                limit: parseInt(limit) || 50,
                sortBy: sortBy || 'createdAt',
                sortOrder: sortOrder || 'desc'
            };

            const result = await CommentsService.getAllCommentsWithCount(cardId, options);
            return ResponseHandler.success(res, StatusCodes.OK, result);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    /**
     * updateComment: Update comment content
     */
    async updateComment(req, res) {
        const { commentId } = req.params;
        const data = req.body;
        const user = req.user;

        try {
            const updatedComment = await CommentsService.updateComment(commentId, data, user._id);
            console.log(`User ${user.email} updated comment ${commentId}`);

            return ResponseHandler.success(res, StatusCodes.OK, updatedComment);
        } catch (error) {
            if (error.message.includes('not found')) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, error.message);
            }
            if (error.message.includes('only edit your own')) {
                return ResponseHandler.error(res, StatusCodes.FORBIDDEN, error.message);
            }
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    /**
     * deleteComment: Soft delete comment
     */
    async deleteComment(req, res) {
        const { commentId } = req.params;
        const user = req.user;

        try {
            await CommentsService.deleteComment(commentId, user._id);
            console.log(`User ${user.email} deleted comment ${commentId}`);

            return ResponseHandler.success(res, StatusCodes.OK, { message: 'Comment deleted successfully' });
        } catch (error) {
            if (error.message.includes('not found')) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, error.message);
            }
            if (error.message.includes('only delete your own')) {
                return ResponseHandler.error(res, StatusCodes.FORBIDDEN, error.message);
            }
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    /**
     * getComment: Get single comment details
     */
    async getComment(req, res) {
        const { commentId } = req.params;

        try {
            const comment = await CommentsService.findOneComment({ _id: commentId });
            if (!comment) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'Comment not found');
            }

            return ResponseHandler.success(res, StatusCodes.OK, comment);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }


}

module.exports = { CommentsController: new CommentsController() };