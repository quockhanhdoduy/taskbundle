const { ResponseHandler, StatusCodes } = require("../../utils");
const { CardsService } = require("./cards.service");
const { FileUploadService } = require("../../services/file-upload.service");
const boardNotificationService = require('../../services/board-notification.service');

class CardsController {
    async createCard(req, res) {
        const data = req.body;
        const user = req.user;

        try {
            const card = await CardsService.createCard(data);
            console.log(`User ${user.email} created new card: ${card.title} in list ${data.listId}`);

            try {
                const { card: cardInfo, board } = await notificationHelper.getCardAndBoardInfo(card._id);
                await boardNotificationService.sendCardNotification(
                    {
                        ...cardInfo,
                        author: {
                            _id: user._id,
                            name: user.name || user.email
                        }
                    },
                    board,
                    user._id
                );
            } catch (notificationError) {
                console.error('Error sending card notification:', notificationError);
            }

            return ResponseHandler.success(res, StatusCodes.CREATED, card);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async getCardsByList(req, res) {
        const { listId } = req.params;

        try {
            const cards = await CardsService.getCardsByListId(listId);
            return ResponseHandler.success(res, StatusCodes.OK, cards);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async getCard(req, res) {
        const { cardId } = req.params;

        console.log('DEBUG - getCard - cardId:', cardId);
        console.log('DEBUG - getCard - req.params:', req.params);
        console.log('DEBUG - getCard - req.url:', req.url);

        try {
            const card = await CardsService.findOneCard({ _id: cardId });
            if (!card) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'Card not found');
            }

            return ResponseHandler.success(res, StatusCodes.OK, card);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async updateCard(req, res) {
        const { cardId } = req.params;
        const data = req.body;
        const user = req.user;

        try {
            const existingCard = await CardsService.findOneCard({ _id: cardId });
            if (!existingCard) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'Card not found');
            }

            const updatedCard = await CardsService.updateCard(cardId, data);
            console.log(`User ${user.email} updated card: ${updatedCard.title}`);

            return ResponseHandler.success(res, StatusCodes.OK, updatedCard);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async deleteCard(req, res) {
        const { cardId } = req.params;
        const user = req.user;

        try {
            const existingCard = await CardsService.findOneCard({ _id: cardId });
            if (!existingCard) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'Card not found');
            }

            await CardsService.deleteCard(cardId);
            console.log(`User ${user.email} deleted card: ${existingCard.title}`);

                        return ResponseHandler.success(res, StatusCodes.OK, {
                message: 'Card deleted successfully'
            });
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async updateCardPosition(req, res) {
        const { cardId } = req.params;
        const { position, listId } = req.body;
        const user = req.user;

        try {
            const existingCard = await CardsService.findOneCard({ _id: cardId });
            if (!existingCard) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'Card not found');
            }

            const updatedCard = await CardsService.updateCardPosition(cardId, position, listId);
            console.log(`User ${user.email} moved card: ${updatedCard.title} to position ${position}`);

            return ResponseHandler.success(res, StatusCodes.OK, updatedCard);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async moveCardToList(req, res) {
        const { cardId } = req.params;
        const { targetListId, position } = req.body;
        const user = req.user;

        try {
            const existingCard = await CardsService.findOneCard({ _id: cardId });
            if (!existingCard) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'Card not found');
            }

            const updatedCard = await CardsService.moveCardToList(cardId, targetListId, position);
            console.log(`User ${user.email} moved card: ${updatedCard.title} to list ${targetListId}`);

            return ResponseHandler.success(res, StatusCodes.OK, updatedCard);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async assignUser(req, res) {
        const { cardId } = req.params;
        const { userId } = req.body;
        const user = req.user;

        try {
            const existingCard = await CardsService.findOneCard({ _id: cardId });
            if (!existingCard) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'Card not found');
            }

            const updatedCard = await CardsService.assignUserToCard(cardId, userId);
            console.log(`User ${user.email} assigned user ${userId} to card: ${updatedCard.title}`);

            return ResponseHandler.success(res, StatusCodes.OK, updatedCard);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async unassignUser(req, res) {
        const { cardId } = req.params;
        const { userId } = req.body;
        const user = req.user;

        try {
            const existingCard = await CardsService.findOneCard({ _id: cardId });
            if (!existingCard) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'Card not found');
            }

            const updatedCard = await CardsService.unassignUserFromCard(cardId, userId);
            console.log(`User ${user.email} unassigned user ${userId} from card: ${updatedCard.title}`);

            return ResponseHandler.success(res, StatusCodes.OK, updatedCard);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async getCardMembers(req, res) {
        const { cardId } = req.params;

        try {
            const members = await CardsService.getCardMembers(cardId);
            return ResponseHandler.success(res, StatusCodes.OK, members);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async assignMultipleUsers(req, res) {
        const { cardId } = req.params;
        const { userIds } = req.body;
        const user = req.user;

        try {
            const existingCard = await CardsService.findOneCard({ _id: cardId });
            if (!existingCard) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'Card not found');
            }

            const updatedCard = await CardsService.assignMultipleUsers(cardId, userIds);
            console.log(`User ${user.email} assigned multiple users to card: ${updatedCard.title}`);

            return ResponseHandler.success(res, StatusCodes.OK, updatedCard);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async updateDueDate(req, res) {
        const { cardId } = req.params;
        const { dueDate } = req.body;
        const user = req.user;

        try {
            const existingCard = await CardsService.findOneCard({ _id: cardId });
            if (!existingCard) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'Card not found');
            }

            const updatedCard = await CardsService.updateCardDueDate(cardId, dueDate);
            console.log(`User ${user.email} updated due date for card: ${updatedCard.title}`);

            return ResponseHandler.success(res, StatusCodes.OK, updatedCard);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async updateCompletion(req, res) {
        const { cardId } = req.params;
        const { isCompleted } = req.body;
        const user = req.user;

        try {
            const existingCard = await CardsService.findOneCard({ _id: cardId });
            if (!existingCard) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'Card not found');
            }

            let updatedCard;
            if (isCompleted) {
                updatedCard = await CardsService.markCardCompleted(cardId);
                console.log(`User ${user.email} marked card as completed: ${updatedCard.title}`);
            } else {
                updatedCard = await CardsService.markCardIncomplete(cardId);
                console.log(`User ${user.email} marked card as incomplete: ${updatedCard.title}`);
            }

            return ResponseHandler.success(res, StatusCodes.OK, updatedCard);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async addAttachment(req, res) {
        const { cardId } = req.params;
        const user = req.user;
        const attachmentData = req.uploadResult;

        try {
            const existingCard = await CardsService.findOneCard({ _id: cardId });
            if (!existingCard) {
                if (attachmentData && attachmentData.url) {
                    try {
                        const urlParts = attachmentData.url.split('/');
                        const publicIdWithExt = urlParts[urlParts.length - 1];
                        const publicId = publicIdWithExt.split('.')[0];
                        await FileUploadService.deleteFileFromCloudinary(publicId);
                    } catch (cleanupError) {
                        console.error('Error cleaning up file:', cleanupError.message);
                    }
                }
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'Card not found');
            }

            const attachment = {
                ...attachmentData,
                uploadedBy: user._id
            };

            const updatedCard = await CardsService.addAttachmentToCard(cardId, attachment);
            console.log(`User ${user.email} added attachment to card: ${updatedCard.title}`);

            return ResponseHandler.success(res, StatusCodes.CREATED, {
                message: 'Attachment added successfully',
                card: updatedCard,
                attachment: attachment
            });
        } catch (error) {
            if (attachmentData && attachmentData.url) {
                try {
                    const urlParts = attachmentData.url.split('/');
                    const publicIdWithExt = urlParts[urlParts.length - 1];
                    const publicId = publicIdWithExt.split('.')[0];
                    await FileUploadService.deleteFileFromCloudinary(publicId);
                    console.log('Cleaned up uploaded file due to error');
                } catch (cleanupError) {
                    console.error('Error cleaning up file:', cleanupError.message);
                }
            }

            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async removeAttachment(req, res) {
        const { cardId, attachmentId } = req.params;
        const user = req.user;

        try {
            const existingCard = await CardsService.findOneCard({ _id: cardId });
            if (!existingCard) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'Card not found');
            }

            const attachment = existingCard.attachments.find(
                att => att._id.toString() === attachmentId
            );

            if (!attachment) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'Attachment not found');
            }

            const updatedCard = await CardsService.removeAttachmentFromCard(cardId, attachmentId);

            console.log(`User ${user.email} removed attachment from card: ${updatedCard.title}`);

            return ResponseHandler.success(res, StatusCodes.OK, {
                message: 'Attachment removed successfully',
                card: updatedCard
            });
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async getAttachments(req, res) {
        const { cardId } = req.params;

        try {
            const attachments = await CardsService.getCardAttachments(cardId);
            return ResponseHandler.success(res, StatusCodes.OK, attachments);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }
}

module.exports = { CardsController: new CardsController() };