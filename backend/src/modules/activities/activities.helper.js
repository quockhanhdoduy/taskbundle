const { ActivitiesService } = require('./activities.service');
const { ActivityTypes, EntityTypes } = require('./activities.const');

/**
 * Helper class for logging activities across the application
 * This provides a simple interface for other modules to log activities
 */
class ActivitiesHelper {
    /**
     * Log a board activity
     * @param {String} type
     * @param {String} userId
     * @param {String} boardId
     * @param {String} description
     */
    async logBoardActivity(type, userId, boardId, description) {
        return await this.logActivity(type, userId, boardId, EntityTypes.BOARD, boardId, description);
    }

    /**
     * Log a list activity
     * @param {String} type
     * @param {String} userId
     * @param {String} boardId
     * @param {String} listId
     * @param {String} description
     */
    async logListActivity(type, userId, boardId, listId, description) {
        return await this.logActivity(type, userId, boardId, EntityTypes.LIST, listId, description);
    }

    /**
     * Log a card activity
     * @param {String} type
     * @param {String} userId
     * @param {String} boardId
     * @param {String} cardId
     * @param {String} description
     */
    async logCardActivity(type, userId, boardId, cardId, description) {
        return await this.logActivity(type, userId, boardId, EntityTypes.CARD, cardId, description);
    }

    /**
     * Log a comment activity
     * @param {String} type
     * @param {String} userId
     * @param {String} boardId
     * @param {String} commentId
     * @param {String} description
     */
    async logCommentActivity(type, userId, boardId, commentId, description) {
        return await this.logActivity(type, userId, boardId, EntityTypes.COMMENT, commentId, description);
    }

    /**
     * Generic activity logging function
     * @param {String} type
     * @param {String} userId
     * @param {String} boardId
     * @param {String} entityType
     * @param {String} entityId
     * @param {String} description
     */
    async logActivity(type, userId, boardId, entityType, entityId, description) {
        try {
            return await ActivitiesService.createActivity({
                type,
                userId,
                boardId,
                entityType,
                entityId,
                description
            });
        } catch (error) {
            // Log error but don't throw to avoid breaking main functionality
            console.error('Failed to log activity:', {
                type,
                userId,
                boardId,
                entityType,
                entityId,
                error: error.message
            });
            return null;
        }
    }

    /**
     * Generate standard descriptions for common activities
     */
    getStandardDescription(type, entityName, userName, additionalInfo = '') {
        const descriptions = {
            // Board activities
            [ActivityTypes.BOARD_CREATED]: `${userName} created board "${entityName}"`,
            [ActivityTypes.BOARD_UPDATED]: `${userName} updated board "${entityName}"`,
            [ActivityTypes.BOARD_MEMBER_ADDED]: `${userName} added member to board "${entityName}"`,
            [ActivityTypes.BOARD_MEMBER_REMOVED]: `${userName} removed member from board "${entityName}"`,
            [ActivityTypes.BOARD_MEMBER_ROLE_CHANGED]: `${userName} changed member role in board "${entityName}"`,

            // List activities
            [ActivityTypes.LIST_CREATED]: `${userName} created list "${entityName}"`,
            [ActivityTypes.LIST_UPDATED]: `${userName} updated list "${entityName}"`,
            [ActivityTypes.LIST_DELETED]: `${userName} deleted list "${entityName}"`,
            [ActivityTypes.LIST_MOVED]: `${userName} moved list "${entityName}"`,

            // Card activities
            [ActivityTypes.CARD_CREATED]: `${userName} created card "${entityName}"`,
            [ActivityTypes.CARD_UPDATED]: `${userName} updated card "${entityName}"`,
            [ActivityTypes.CARD_DELETED]: `${userName} deleted card "${entityName}"`,
            [ActivityTypes.CARD_MOVED]: `${userName} moved card "${entityName}"`,
            [ActivityTypes.CARD_ASSIGNED]: `${userName} assigned card "${entityName}"`,
            [ActivityTypes.CARD_UNASSIGNED]: `${userName} unassigned card "${entityName}"`,
            [ActivityTypes.CARD_COMPLETED]: `${userName} completed card "${entityName}"`,
            [ActivityTypes.CARD_UNCOMPLETED]: `${userName} marked card "${entityName}" as incomplete`,
            [ActivityTypes.CARD_DUE_DATE_SET]: `${userName} set due date for card "${entityName}"`,
            [ActivityTypes.CARD_DUE_DATE_CHANGED]: `${userName} changed due date for card "${entityName}"`,
            [ActivityTypes.CARD_DUE_DATE_REMOVED]: `${userName} removed due date from card "${entityName}"`,
            [ActivityTypes.CARD_ATTACHMENT_ADDED]: `${userName} added attachment to card "${entityName}"`,
            [ActivityTypes.CARD_ATTACHMENT_REMOVED]: `${userName} removed attachment from card "${entityName}"`,

            // Comment activities
            [ActivityTypes.COMMENT_ADDED]: `${userName} added comment to card "${entityName}"`
        };

        let description = descriptions[type] || `${userName} performed action on "${entityName}"`;

        if (additionalInfo) {
            description += ` ${additionalInfo}`;
        }

        return description;
    }
}

module.exports = { ActivitiesHelper: new ActivitiesHelper(), ActivityTypes, EntityTypes };
