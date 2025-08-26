const { ResponseHandler, StatusCodes } = require('../../utils');
const { CommentsService } = require('./comments.service');
const { CardsAuthz } = require('../cards/cards.authz');

class CommentsAuthz {
    /**
     * verifyCommentAccess: Check if user has access to comment through card access
     */
    async verifyCommentAccess(req, res, next) {
        try {
            const { commentId } = req.params;

            // Get comment information with card details
            const comment = await CommentsService.findOneComment({ _id: commentId });
            if (!comment) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'Comment not found'
                );
            }

            // Check card access through cards authorization
            req.params.cardId = comment.cardId._id.toString();
            return CardsAuthz.verifyCardAccess(req, res, next);
        } catch (error) {
            return ResponseHandler.error(
                res,
                StatusCodes.INTERNAL_SERVER_ERROR,
                error.message
            );
        }
    }

    /**
     * verifyCommentOwnership: Check if user owns the comment
     */
    async verifyCommentOwnership(req, res, next) {
        try {
            const { commentId } = req.params;
            const user = req.user;

            const comment = await CommentsService.findOneComment({ _id: commentId });
            if (!comment) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'Comment not found'
                );
            }

            // Check if user owns the comment
            if (comment.userId._id.toString() !== user._id.toString()) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.FORBIDDEN,
                    'You can only edit your own comments'
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
     * verifyCommentDeleteAccess: Check if user can delete comment (owner cmt or board admin)
     */
    async verifyCommentDeleteAccess(req, res, next) {
        try {
            const { commentId } = req.params;
            const user = req.user;

            const comment = await CommentsService.findOneComment({ _id: commentId });
            if (!comment) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'Comment not found'
                );
            }

            if (comment.userId._id.toString() === user._id.toString()) {
                return next();
            }

            req.params.cardId = comment.cardId._id.toString();
            return CardsAuthz.verifyCardMemberAccess(req, res, next);
        } catch (error) {
            return ResponseHandler.error(
                res,
                StatusCodes.INTERNAL_SERVER_ERROR,
                error.message
            );
        }
    }


}

module.exports = { CommentsAuthz: new CommentsAuthz() };
