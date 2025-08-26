const { ActivitiesHelper } = require('./activities.helper');
const { CardsService } = require('../cards/cards.service');


class ActivityLoggerMiddleware {
    /**
     * Create activity logger middleware
     * @param {String} activityType
     * @param {Object} options
     */
    logActivity(activityType, options = {}) {
        return async (req, res, next) => {
            // Prevent duplicate middleware setup
            if (res._activityLoggerSetup) {
                return next();
            }
            res._activityLoggerSetup = true;

            // For delete operations, try to get entity info before deletion
            if (activityType.includes('DELETED') && req.params.cardId) {
                try {
                    const card = await CardsService.findOneCard({ _id: req.params.cardId });
                    if (card) {
                        req.preDeleteCardInfo = {
                            title: card.title,
                            boardId: card.listId?.boardId
                        };
                    }
                } catch (error) {
                    console.error('Error fetching card info before delete:', error);
                }
            }

            const originalSend = res.send;
            const originalJson = res.json;
            let responseHandled = false;

            const handleResponse = (data) => {
                if (res.statusCode >= 200 && res.statusCode < 300 && !responseHandled) {
                    responseHandled = true;
                    setImmediate(() => {
                        this.performLogging(req, res, data, activityType, options);
                    });
                }
                return data;
            };

            res.send = function(data) {
                handleResponse(data);
                return originalSend.call(this, data);
            };

            res.json = function(data) {
                handleResponse(data);
                return originalJson.call(this, data);
            };

            next();
        };
    }

    /**
     * Perform the actual activity logging
     */
    async performLogging(req, res, responseData, activityType, options) {
        try {
            const user = req.user;
            if (!user) return;

            let entityInfo = null;

            // Extract entity info based on activity type
            if (activityType.startsWith('CARD_')) {
                entityInfo = await this.extractCardInfo(req, responseData);
            } else if (activityType.startsWith('BOARD_')) {
                entityInfo = await this.extractBoardInfo(req, responseData);
            } else if (activityType.startsWith('COMMENT_')) {
                entityInfo = await this.extractCommentInfo(req, responseData);
            } else if (activityType.startsWith('LIST_')) {
                entityInfo = await this.extractListInfo(req, responseData);
            }

            if (!entityInfo || !entityInfo.boardId) return;

            // Generate description
            const userName = user.name || user.email || 'Unknown User';
            const description = ActivitiesHelper.getStandardDescription(
                activityType,
                entityInfo.entityName,
                userName,
                options.additionalInfo || ''
            );

            // Log activity based on entity type
            if (activityType.startsWith('CARD_')) {
                await ActivitiesHelper.logCardActivity(
                    activityType,
                    user._id,
                    entityInfo.boardId,
                    entityInfo.entityId,
                    description
                );
            } else if (activityType.startsWith('BOARD_')) {
                await ActivitiesHelper.logBoardActivity(
                    activityType,
                    user._id,
                    entityInfo.boardId,
                    description
                );
            } else if (activityType.startsWith('COMMENT_')) {
                await ActivitiesHelper.logCommentActivity(
                    activityType,
                    user._id,
                    entityInfo.boardId,
                    entityInfo.entityId,
                    description
                );
            } else if (activityType.startsWith('LIST_')) {
                await ActivitiesHelper.logListActivity(
                    activityType,
                    user._id,
                    entityInfo.boardId,
                    entityInfo.entityId,
                    description
                );
            }

        } catch (error) {
            console.error('Activity logging error:', error);
            // Don't throw - activity logging should not break main functionality
        }
    }

    /**
     * Extract card information
     */
    async extractCardInfo(req, responseData) {
        let cardId = req.params.cardId; // For update/delete routes
        let cardTitle = null;
        let boardId = null;

        // Try to extract from response data first
        if (responseData) {

            if (responseData.title) {
                cardTitle = responseData.title;
                boardId = responseData.listId?.boardId;
                cardId = cardId || responseData._id; // For create route
            }

            else if (responseData.card?.title) {
                cardTitle = responseData.card.title;
                boardId = responseData.card.listId?.boardId;
                cardId = cardId || responseData.card._id;
            }

            else if (responseData.data?.title) {
                cardTitle = responseData.data.title;
                boardId = responseData.data.listId?.boardId;
                cardId = cardId || responseData.data._id;
            }
        }


        if (!boardId && req.board?._id) {
            boardId = req.board._id;
        }

        // For create card route (/v1/lists/:listId/cards), get boardId from list
        if (!boardId && req.params.listId) {
            try {
                const { ListsService } = require('../lists/lists.service');
                const list = await ListsService.findOneList({ _id: req.params.listId });
                if (list) {
                    boardId = list.boardId;
                }
            } catch (error) {
                console.error('Error fetching list info for card:', error);
            }
        }

        // Use pre-delete info if available (for delete operations)
        if (req.preDeleteCardInfo) {
            cardTitle = cardTitle || req.preDeleteCardInfo.title;
            boardId = boardId || req.preDeleteCardInfo.boardId;
        }
        // Otherwise, fetch from database if we have cardId but missing info
        else if (cardId && (!cardTitle || !boardId)) {
            try {
                const card = await CardsService.findOneCard({ _id: cardId });
                if (card) {
                    cardTitle = cardTitle || card.title;
                    boardId = boardId || card.listId?.boardId;
                }
            } catch (error) {
                console.error('Error fetching card info:', error);
            }
        }

        return {
            entityId: cardId,
            entityName: cardTitle || 'Unknown Card',
            boardId: boardId
        };
    }

    /**
     * Extract board information
     */
    async extractBoardInfo(req, responseData) {
        let boardId = req.params.boardId; // For update/delete routes
        let boardName = null;

        // Try to extract from response data first
        if (responseData) {
            // For direct board response (create/update board)
            if (responseData.name) {
                boardName = responseData.name;
                boardId = boardId || responseData._id;
            }
            else if (responseData.data?.name) {
                boardName = responseData.data.name;
                boardId = boardId || responseData.data._id;
            }
        }

        // Fallback: try to get from request
        if (!boardName && req.board?.name) {
            boardName = req.board.name;
        }

        return {
            entityId: boardId,
            entityName: boardName || 'Unknown Board',
            boardId: boardId
        };
    }

    /**
     * Extract comment information
     */
    async extractCommentInfo(req, responseData) {
        let commentId = req.params.commentId; // For update/delete routes
        let boardId = null;
        let cardTitle = 'Unknown Card';


        if (responseData) {

            if (responseData._id) {
                commentId = commentId || responseData._id;
            }

            else if (responseData.data?._id) {
                commentId = commentId || responseData.data._id;
            }
        }

        // Try to get card info to find boardId
        const cardId = req.params.cardId;
        if (cardId) {
            try {
                const card = await CardsService.findOneCard({ _id: cardId });
                if (card) {
                    cardTitle = card.title;
                    boardId = card.listId?.boardId;
                }
            } catch (error) {
                console.error('Error fetching card info for comment:', error);
            }
        }

        return {
            entityId: commentId,
            entityName: cardTitle,
            boardId: boardId
        };
    }

    /**
     * Extract list information
     */
    async extractListInfo(req, responseData) {
        let listId = req.params.listId; // For update/delete routes
        let listName = null;
        let boardId = null;

        if (responseData) {
            if (responseData.name) {
                listName = responseData.name;
                boardId = responseData.boardId;
                listId = listId || responseData._id; // For create route
            }

            else if (responseData.data?.name) {
                listName = responseData.data.name;
                boardId = responseData.data.boardId;
                listId = listId || responseData.data._id;
            }
        }

        // Get boardId from URL params if available (create/get routes)
        if (!boardId && req.params.boardId) {
            boardId = req.params.boardId;
        }

        // Last resort: fetch from database if we have listId but missing info
        if (listId && (!listName || !boardId)) {
            try {
                const { ListsService } = require('../lists/lists.service');
                const list = await ListsService.findOneList({ _id: listId });
                if (list) {
                    listName = listName || list.name;
                    boardId = boardId || list.boardId;
                }
            } catch (error) {
                console.error('Error fetching list info:', error);
            }
        }

        return {
            entityId: listId,
            entityName: listName || 'Unknown List',
            boardId: boardId
        };
    }
}

module.exports = { ActivityLoggerMiddleware: new ActivityLoggerMiddleware() };
