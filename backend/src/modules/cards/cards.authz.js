const { ResponseHandler, StatusCodes } = require('../../utils');
const { CardsService } = require('./cards.service');
const { ListsAuthz } = require('../lists/lists.authz');

class CardsAuthz {
    /**
     * verifyCardAccess: Check if user has access to card
     * Through checking list/board access permissions
     */
    async verifyCardAccess(req, res, next) {
        try {
            const { cardId } = req.params;

            // Debug logging
            console.log('DEBUG - verifyCardAccess - cardId:', cardId);
            console.log('DEBUG - verifyCardAccess - req.params:', req.params);
            console.log('DEBUG - verifyCardAccess - req.url:', req.url);

            // Get card information with list details
            const card = await CardsService.findOneCard({ _id: cardId });
            if (!card) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
'Card not found'
                );
            }

            // Check list access through lists authorization
            req.params.listId = card.listId._id.toString();
            return ListsAuthz.verifyListAccess(req, res, next);
        } catch (error) {
            return ResponseHandler.error(
                res,
                StatusCodes.INTERNAL_SERVER_ERROR,
                error.message
            );
        }
    }

    /**
     * verifyCardMemberAccess: Check if user has permission to edit card
     * Through checking list/board member permissions
     */
    async verifyCardMemberAccess(req, res, next) {
        try {
            const { cardId } = req.params;

            // Get card information with list details
            const card = await CardsService.findOneCard({ _id: cardId });
            if (!card) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
'Card not found'
                );
            }

            // Check list member access through lists authorization
            req.params.listId = card.listId._id.toString();
            return ListsAuthz.verifyListMemberAccess(req, res, next);
        } catch (error) {
            return ResponseHandler.error(
                res,
                StatusCodes.INTERNAL_SERVER_ERROR,
                error.message
            );
        }
    }

    /**
     * verifyCardOwnership: Check if user is owner of card
     * (Can be used for deleting attachment of only themselves)
     */
    async verifyCardOwnership(req, res, next) {
        try {
            const { cardId } = req.params;
            const user = req.user;

            const card = await CardsService.findOneCard({ _id: cardId });
            if (!card) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
'Card not found'
                );
            }

            // Check if user is assigned to this card
            const isAssigned = card.assignedUsers.some(
                assignedUser => assignedUser._id.toString() === user._id.toString()
            );

            if (!isAssigned) {
                req.params.listId = card.listId._id.toString();
                return ListsAuthz.verifyListMemberAccess(req, res, next);
            }

            // Nếu được assign vào card, cho phép truy cập
            next();
        } catch (error) {
            return ResponseHandler.error(
                res,
                StatusCodes.INTERNAL_SERVER_ERROR,
                error.message
            );
        }
    }


}

module.exports = { CardsAuthz: new CardsAuthz() };
