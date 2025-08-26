const express = require('express');

const { CardsValidator } = require('./cards.validator');
const { CardsController } = require('./cards.controller');
const { CardsAuthz } = require('./cards.authz');
const { AuthMiddleware } = require('../auth/auth.middleware');
const { ListsAuthz } = require('../lists/lists.authz');
const { UploadMiddleware } = require('../../middlewares/upload.middleware');
const { ActivityLoggerMiddleware, ActivityTypes } = require('../activities');

const router = express.Router();



router.post(
    '/v1/lists/:listId/cards',
    AuthMiddleware.verifyToken,
    ListsAuthz.verifyListMemberAccess,
    CardsValidator.createCard,
    ActivityLoggerMiddleware.logActivity(ActivityTypes.CARD_CREATED),
    CardsController.createCard
);

// Get all cards in list
router.get(
    '/v1/lists/:listId/cards',
    AuthMiddleware.verifyToken,
    ListsAuthz.verifyListAccess,
    CardsValidator.getCardsByList,
    CardsController.getCardsByList
);

// Get specific card details
router.get(
    '/v1/cards/:cardId',
    AuthMiddleware.verifyToken,
    CardsAuthz.verifyCardAccess,
    CardsValidator.getCard,
    CardsController.getCard
);

// Update card information
router.put(
    '/v1/cards/:cardId',
    AuthMiddleware.verifyToken,
    CardsAuthz.verifyCardMemberAccess,
    CardsValidator.updateCard,
    ActivityLoggerMiddleware.logActivity(ActivityTypes.CARD_UPDATED),
    CardsController.updateCard
);

// Delete card (soft delete)
router.delete(
    '/v1/cards/:cardId',
    AuthMiddleware.verifyToken,
    CardsAuthz.verifyCardMemberAccess,
    CardsValidator.deleteCard,
    ActivityLoggerMiddleware.logActivity(ActivityTypes.CARD_DELETED),
    CardsController.deleteCard
);

// Position Routes - Cards position management

// Move card
router.put(
    '/v1/cards/:cardId/position',
    AuthMiddleware.verifyToken,
    CardsAuthz.verifyCardMemberAccess,
    CardsValidator.updateCardPosition,
    ActivityLoggerMiddleware.logActivity(ActivityTypes.CARD_MOVED),
    CardsController.updateCardPosition
);

// Move card to different list
router.put(
    '/v1/cards/:cardId/move-to-list',
    AuthMiddleware.verifyToken,
    CardsAuthz.verifyCardMemberAccess,
    CardsValidator.moveCardToList,
    ActivityLoggerMiddleware.logActivity(ActivityTypes.CARD_MOVED),
    CardsController.moveCardToList
);

// Members Routes - Cards members management

// Assign user to card
router.post(
    '/v1/cards/:cardId/assign',
    AuthMiddleware.verifyToken,
    CardsAuthz.verifyCardMemberAccess,
    CardsValidator.assignUser,
    ActivityLoggerMiddleware.logActivity(ActivityTypes.CARD_ASSIGNED),
    CardsController.assignUser
);

// Unassign user from card
router.delete(
    '/v1/cards/:cardId/unassign',
    AuthMiddleware.verifyToken,
    CardsAuthz.verifyCardMemberAccess,
    CardsValidator.unassignUser,
    ActivityLoggerMiddleware.logActivity(ActivityTypes.CARD_UNASSIGNED),
    CardsController.unassignUser
);

// Get card members list
router.get(
    '/v1/cards/:cardId/members',
    AuthMiddleware.verifyToken,
    CardsAuthz.verifyCardAccess,
    CardsController.getCardMembers
);

// Assign multiple users to card
router.post(
    '/v1/cards/:cardId/assign-multiple',
    AuthMiddleware.verifyToken,
    CardsAuthz.verifyCardMemberAccess,
    CardsValidator.assignMultipleUsers,
    CardsController.assignMultipleUsers
);

// Dates Routes - Date management

// Update due date
router.put(
    '/v1/cards/:cardId/due-date',
    AuthMiddleware.verifyToken,
    CardsAuthz.verifyCardMemberAccess,
    CardsValidator.updateDueDate,
    ActivityLoggerMiddleware.logActivity(ActivityTypes.CARD_DUE_DATE_SET),
    CardsController.updateDueDate
);

// Mark as completed/incomplete
router.put(
    '/v1/cards/:cardId/completion',
    AuthMiddleware.verifyToken,
    CardsAuthz.verifyCardMemberAccess,
    CardsValidator.updateCompletion,
    ActivityLoggerMiddleware.logActivity(ActivityTypes.CARD_COMPLETED),
    CardsController.updateCompletion
);

// Attachments Routes - File attachments management

// Upload attachment for card
router.post(
    '/v1/cards/:cardId/attachments',
    AuthMiddleware.verifyToken,
    CardsAuthz.verifyCardMemberAccess,
    CardsValidator.addAttachment,
    UploadMiddleware.uploadSingleFile,
    ActivityLoggerMiddleware.logActivity(ActivityTypes.CARD_ATTACHMENT_ADDED),
    CardsController.addAttachment
);

// Remove attachment from card
router.delete(
    '/v1/cards/:cardId/attachments/:attachmentId',
    AuthMiddleware.verifyToken,
    CardsAuthz.verifyCardMemberAccess,
    CardsValidator.removeAttachment,
    ActivityLoggerMiddleware.logActivity(ActivityTypes.CARD_ATTACHMENT_REMOVED),
    CardsController.removeAttachment
);

// Get card attachments list
router.get(
    '/v1/cards/:cardId/attachments',
    AuthMiddleware.verifyToken,
    CardsAuthz.verifyCardAccess,
    CardsController.getAttachments
);

module.exports = { cardsRoutes: router };