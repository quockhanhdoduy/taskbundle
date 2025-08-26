const { CardsModel } = require('./cards.model');

class CardsService {
    /**
     * createCard: Create new card in list
     * @param {*} data Object
     * @returns card
     */
    async createCard(data) {
        try {
            const maxPositionCard = await CardsModel.findOne({
                listId: data.listId,
                isDeleted: false
            }).sort({ position: -1 });

            const newPosition = maxPositionCard ? maxPositionCard.position + 1 : 0;

            const card = await CardsModel.create({
                ...data,
                position: newPosition
            });
            return card;
        } catch (error) {
            throw new Error(error.message || 'Error creating card');
        }
    }

    /**
     * findOneCard: Find card by filter
     * @param {*} filter Object
     * @returns card
     */
    async findOneCard(filter) {
        try {
            const card = await CardsModel.findOne({
                ...filter,
                isDeleted: false
            }).populate('assignedUsers', 'name email')
              .populate('listId', 'name boardId');
            return card;
        } catch (error) {
            throw new Error(error.message || 'Error finding card');
        }
    }

    /**
     * getCardsByListId: Get all cards in list
     * @param {*} listId String
     * @returns cards
     */
    async getCardsByListId(listId) {
        try {
            const cards = await CardsModel.find({
                listId: listId,
                isDeleted: false
            }).sort({ position: 1 })
              .populate('assignedUsers', 'name email')
              .populate('listId', 'name boardId');
            return cards;
        } catch (error) {
            throw new Error(error.message || 'Error getting cards');
        }
    }

    /**
     * updateCard: Update card information
     * @param {*} cardId String
     * @param {*} data Object
     * @returns card
     */
    async updateCard(cardId, data) {
        try {
            const card = await CardsModel.findByIdAndUpdate(
                cardId,
                { ...data },
                { new: true, runValidators: true }
            ).populate('assignedUsers', 'name email')
             .populate('listId', 'name boardId');
            return card;
        } catch (error) {
            throw new Error(error.message || 'Error updating card');
        }
    }

    /**
     * deleteCard: Soft delete card
     * @param {*} cardId String
     * @returns card
     */
    async deleteCard(cardId) {
        try {
            const card = await CardsModel.findByIdAndUpdate(
                cardId,
                {
                    isDeleted: true,
                    deletedAt: new Date()
                },
                { new: true }
            );
            return card;
        } catch (error) {
            throw new Error(error.message || 'Error deleting card');
        }
    }

    /**
     * countCardsByListId: Count cards in list
     * @param {*} listId String
     * @returns number
     */
    async countCardsByListId(listId) {
        try {
            const count = await CardsModel.countDocuments({
                listId: listId,
                isDeleted: false
            });
            return count;
        } catch (error) {
            throw new Error(error.message || 'Error counting cards');
        }
    }

    /**
     * updateCardPosition: Update card position
     * @param {*} cardId String
     * @param {*} newPosition Number
     * @param {*} [newListId] String (optional)
     * @returns card
     */
    async updateCardPosition(cardId, newPosition, newListId = null) {
        try {
            const card = await CardsModel.findById(cardId);
            if (!card) {
                throw new Error('Card not found');
            }

            const oldListId = card.listId;
            const targetListId = newListId || oldListId;

            if (newListId && newListId !== oldListId.toString()) {
                // Update positions in old list
                await CardsModel.updateMany(
                    {
                        listId: oldListId,
                        position: { $gt: card.position },
                        isDeleted: false
                    },
                    { $inc: { position: -1 } }
                );

                // Update positions in new list
                await CardsModel.updateMany(
                    {
                        listId: targetListId,
                        position: { $gte: newPosition },
                        isDeleted: false
                    },
                    { $inc: { position: 1 } }
                );

                card.listId = targetListId;
                card.position = newPosition;
            } else {
                // Move within same list
                if (newPosition > card.position) {
                    await CardsModel.updateMany(
                        {
                            listId: targetListId,
                            position: { $gt: card.position, $lte: newPosition },
                            isDeleted: false
                        },
                        { $inc: { position: -1 } }
                    );
                } else if (newPosition < card.position) {
                    await CardsModel.updateMany(
                        {
                            listId: targetListId,
                            position: { $gte: newPosition, $lt: card.position },
                            isDeleted: false
                        },
                        { $inc: { position: 1 } }
                    );
                }
                card.position = newPosition;
            }

            await card.save();
            return card;
        } catch (error) {
            throw new Error(error.message || 'Error updating card position');
        }
    }

    /**
     * moveCardToList: Move card to different list
     * @param {*} cardId String
     * @param {*} targetListId String
     * @param {*} position Number
     * @returns card
     */
    async moveCardToList(cardId, targetListId, position) {
        return this.updateCardPosition(cardId, position, targetListId);
    }

    /**
     * assignUserToCard: Assign user to card
     * @param {*} cardId String
     * @param {*} userId String
     * @returns card
     */
    async assignUserToCard(cardId, userId) {
        try {
            const card = await CardsModel.findByIdAndUpdate(
                cardId,
                { $addToSet: { assignedUsers: userId } },
                { new: true }
            ).populate('assignedUsers', 'name email');
            return card;
        } catch (error) {
            throw new Error(error.message || 'Error assigning user to card');
        }
    }

    /**
     * unassignUserFromCard: Unassign user from card
     * @param {*} cardId String
     * @param {*} userId String
     * @returns card
     */
    async unassignUserFromCard(cardId, userId) {
        try {
            const card = await CardsModel.findByIdAndUpdate(
                cardId,
                { $pull: { assignedUsers: userId } },
                { new: true }
            ).populate('assignedUsers', 'name email');
            return card;
        } catch (error) {
            throw new Error(error.message || 'Error unassigning user from card');
        }
    }

    /**
     * getCardMembers: Get card members list
     * @param {*} cardId String
     * @returns users
     */
    async getCardMembers(cardId) {
        try {
            const card = await CardsModel.findById(cardId)
                .populate('assignedUsers', 'name email')
                .select('assignedUsers');
            return card ? card.assignedUsers : [];
        } catch (error) {
            throw new Error(error.message || 'Error getting card members');
        }
    }

    /**
     * assignMultipleUsers: Assign multiple users to card
     * @param {*} cardId String
     * @param {*} userIds Array
     * @returns card
     */
    async assignMultipleUsers(cardId, userIds) {
        try {
            const card = await CardsModel.findByIdAndUpdate(
                cardId,
                { $addToSet: { assignedUsers: { $each: userIds } } },
                { new: true }
            ).populate('assignedUsers', 'name email');
            return card;
        } catch (error) {
            throw new Error(error.message || 'Error assigning multiple users to card');
        }
    }

    /**
     * updateCardDueDate: Update card due date
     * @param {*} cardId String
     * @param {*} dueDate Date
     * @returns card
     */
    async updateCardDueDate(cardId, dueDate) {
        try {
            const card = await CardsModel.findByIdAndUpdate(
                cardId,
                { dueDate: dueDate },
                { new: true }
            ).populate('assignedUsers', 'name email');
            return card;
        } catch (error) {
            throw new Error(error.message || 'Error updating card due date');
        }
    }

    /**
     * markCardCompleted: Mark card as completed
     * @param {*} cardId String
     * @returns card
     */
    async markCardCompleted(cardId) {
        try {
            const card = await CardsModel.findByIdAndUpdate(
                cardId,
                {
                    isCompleted: true,
                    completedDate: new Date()
                },
                { new: true }
            ).populate('assignedUsers', 'name email');
            return card;
        } catch (error) {
            throw new Error(error.message || 'Error marking card as completed');
        }
    }

    /**
     * markCardIncomplete: Mark card as incomplete
     * @param {*} cardId String
     * @returns card
     */
    async markCardIncomplete(cardId) {
        try {
            const card = await CardsModel.findByIdAndUpdate(
                cardId,
                {
                    isCompleted: false,
                    completedDate: null
                },
                { new: true }
            ).populate('assignedUsers', 'name email');
            return card;
        } catch (error) {
            throw new Error(error.message || 'Error marking card as incomplete');
        }
    }

    /**
     * addAttachmentToCard: Add attachment to card
     * @param {*} cardId String
     * @param {*} attachmentData Object
     * @returns card
     */
    async addAttachmentToCard(cardId, attachmentData) {
        try {
            const card = await CardsModel.findByIdAndUpdate(
                cardId,
                { $push: { attachments: attachmentData } },
                { new: true }
            ).populate('assignedUsers', 'name email');
            return card;
        } catch (error) {
            throw new Error(error.message || 'Error adding attachment to card');
        }
    }

    /**
     * removeAttachmentFromCard: Remove attachment from card
     * @param {*} cardId String
     * @param {*} attachmentId String
     * @returns card
     */
    async removeAttachmentFromCard(cardId, attachmentId) {
        try {
            const card = await CardsModel.findByIdAndUpdate(
                cardId,
                { $pull: { attachments: { _id: attachmentId } } },
                { new: true }
            ).populate('assignedUsers', 'name email');
            return card;
        } catch (error) {
            throw new Error(error.message || 'Error removing attachment from card');
        }
    }

    /**
     * getCardAttachments: Get card attachments list
     * @param {*} cardId String
     * @returns attachments
     */
    async getCardAttachments(cardId) {
        try {
            const card = await CardsModel.findById(cardId)
                .select('attachments')
                .populate('attachments.uploadedBy', 'name email');
            return card ? card.attachments : [];
        } catch (error) {
            throw new Error(error.message || 'Error getting card attachments');
        }
    }
}

module.exports = { CardsService: new CardsService() };