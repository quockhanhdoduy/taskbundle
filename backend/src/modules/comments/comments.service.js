const { CommentsModel } = require('./comments.model');

class CommentsService {
    /**
     * createComment: Create new comment for card
     * @param {Object} data Comment data
     * @returns {Object} comment
     */
    async createComment(data) {
        try {
            const comment = await CommentsModel.create(data);
            return comment;
        } catch (error) {
            throw new Error(error.message || 'Error creating comment');
        }
    }

    /**
     * findOneComment: Find comment by filter
     * @param {Object} filter Filter criteria
     * @returns {Object} comment
     */
    async findOneComment(filter) {
        try {
            const comment = await CommentsModel.findOne({
                ...filter,
                isDeleted: false
            }).populate('userId', 'name email')
              .populate('cardId', 'title');
            return comment;
        } catch (error) {
            throw new Error(error.message || 'Error finding comment');
        }
    }

    /**
     * getCommentsByCardId: Get all comments for a card
     * @param {String} cardId Card ID
     * @param {Object} options Query options (page, limit, sort)
     * @returns {Array} comments
     */
    async getCommentsByCardId(cardId, options = {}) {
        try {
            const {
                page = 1,
                limit = 10,
                sortBy = 'createdAt',
                sortOrder = 'desc'
            } = options;

            const skip = (page - 1) * limit;
            const sortOptions = {};
            sortOptions[sortBy] = sortOrder === 'desc' ? -1 : 1;

            const comments = await CommentsModel.find({
                cardId,
                isDeleted: false
            })
            .populate('userId', 'name email')
            .sort(sortOptions)
            .skip(skip)
            .limit(limit);

            return comments;
        } catch (error) {
            throw new Error(error.message || 'Error getting comments');
        }
    }

    /**
     * updateComment: Update comment content
     * @param {String} commentId Comment ID
     * @param {Object} data Update data
     * @param {String} userId User ID for ownership check
     * @returns {Object} updated comment
     */
    async updateComment(commentId, data, userId) {
        try {
            const comment = await this.findOneComment({ _id: commentId });
            if (!comment) {
                throw new Error('Comment not found');
            }

            if (comment.userId._id.toString() !== userId.toString()) {
                throw new Error('You can only edit your own comments');
            }

            const updateData = {
                ...data,
                isEdited: true,
                editedAt: new Date()
            };

            const updatedComment = await CommentsModel.findByIdAndUpdate(
                commentId,
                updateData,
                { new: true }
            ).populate('userId', 'name email');

            return updatedComment;
        } catch (error) {
            throw new Error(error.message || 'Error updating comment');
        }
    }

    /**
     * deleteComment: Soft delete comment
     * @param {String} commentId Comment ID
     * @param {String} userId User ID for ownership check
     * @returns {Object} deleted comment
     */
    async deleteComment(commentId, userId) {
        try {
            const comment = await this.findOneComment({ _id: commentId });
            if (!comment) {
                throw new Error('Comment not found');
            }

            if (comment.userId._id.toString() !== userId.toString()) {
                throw new Error('You can only delete your own comments');
            }

            const deletedComment = await CommentsModel.findByIdAndUpdate(
                commentId,
                {
                    isDeleted: true,
                    deletedAt: new Date()
                },
                { new: true }
            );

            return deletedComment;
        } catch (error) {
            throw new Error(error.message || 'Error deleting comment');
        }
    }

    /**
     * countCommentsByCardId: Count comments for a card
     * @param {String} cardId Card ID
     * @returns {Number} count
     */
    async countCommentsByCardId(cardId) {
        try {
            const count = await CommentsModel.countDocuments({
                cardId,
                isDeleted: false
            });
            return count;
        } catch (error) {
            throw new Error(error.message || 'Error counting comments');
        }
    }

    /**
     * checkCommentOwnership: Check if user owns the comment
     * @param {String} commentId Comment ID
     * @param {String} userId User ID
     * @returns {Boolean} isOwner
     */
    async checkCommentOwnership(commentId, userId) {
        try {
            const comment = await CommentsModel.findOne({
                _id: commentId,
                userId,
                isDeleted: false
            });
            return !!comment;
        } catch (error) {
            throw new Error(error.message || 'Error checking comment ownership');
        }
    }

    /**
     * getAllCommentsWithCount: Get comments with total count for pagination
     * @param {String} cardId Card ID
     * @param {Object} options Query options
     * @returns {Object} { comments, total, page, totalPages }
     */
    async getAllCommentsWithCount(cardId, options = {}) {
        try {
            const {
                page = 1,
                limit = 10
            } = options;

            const comments = await this.getCommentsByCardId(cardId, options);
            const total = await this.countCommentsByCardId(cardId);
            const totalPages = Math.ceil(total / limit);

            return {
                comments,
                total,
                page: parseInt(page),
                totalPages,
                hasNext: page < totalPages,
                hasPrev: page > 1
            };
        } catch (error) {
            throw new Error(error.message || 'Error getting comments with count');
        }
    }
}

module.exports = { CommentsService: new CommentsService() };