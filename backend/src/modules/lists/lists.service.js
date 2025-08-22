const { ListsModel } = require('./lists.model');

class ListsService {
    /**
     * createList: Create new list in board
     * @param {*} data Object
     * @returns list
     */
    async createList(data) {
        try {
            // Get highest position in board to set position for new list
            const maxPositionList = await ListsModel.findOne({
                boardId: data.boardId,
                isDeleted: false
            }).sort({ position: -1 });

            const newPosition = maxPositionList ? maxPositionList.position + 1 : 0;

            const list = await ListsModel.create({
                ...data,
                position: newPosition
            });
            return list;
        } catch (error) {
            throw new Error(
                error.message || 'Error creating list'
            );
        }
    }

    /**
     * getListsByBoardId: Get all lists in board
     * @param {String} boardId
     * @returns lists array
     */
    async getListsByBoardId(boardId) {
        try {
            const lists = await ListsModel.find({
                boardId: boardId,
                isDeleted: false
            }).sort({ position: 1 });
            return lists;
        } catch (error) {
            throw new Error(
                error.message || 'Error getting lists'
            );
        }
    }

    /**
     * findOneList: Find one list by filter
     * @param {Object} filter
     * @returns list
     */
    async findOneList(filter) {
        try {
            const list = await ListsModel.findOne({
                ...filter,
                isDeleted: false
            });
            return list;
        } catch (error) {
            throw new Error(
                error.message || 'Error finding list'
            );
        }
    }

    /**
     * updateList: Update list information
     * @param {String} listId
     * @param {Object} data
     * @returns updated list
     */
    async updateList(listId, data) {
        try {
            const updatedList = await ListsModel.findByIdAndUpdate(
                listId,
                { ...data },
                { new: true }
            );
            return updatedList;
        } catch (error) {
            throw new Error(
                error.message || 'Error updating list'
            );
        }
    }

    /**
     * deleteList: Delete list (soft delete)
     * @param {String} listId
     * @returns deleted list
     */
    async deleteList(listId) {
        try {
            const deletedList = await ListsModel.findByIdAndUpdate(
                listId,
                {
                    isDeleted: true,
                    deletedAt: new Date()
                },
                { new: true }
            );
            return deletedList;
        } catch (error) {
            throw new Error(
                error.message || 'Error deleting list'
            );
        }
    }

    /**
     * updateListPosition: Update list position
     * @param {String} listId
     * @param {Number} newPosition
     * @returns updated list
     */
    async updateListPosition(listId, newPosition) {
        try {
            const list = await this.findOneList({ _id: listId });
            if (!list) {
                throw new Error('List not found');
            }

            const oldPosition = list.position;
            const boardId = list.boardId;

            // If moving up (decrease position)
            if (newPosition < oldPosition) {
                await ListsModel.updateMany(
                    {
                        boardId: boardId,
                        position: { $gte: newPosition, $lt: oldPosition },
                        isDeleted: false,
                        _id: { $ne: listId }
                    },
                    { $inc: { position: 1 } }
                );
            }
            // If moving down (increase position)
            else if (newPosition > oldPosition) {
                await ListsModel.updateMany(
                    {
                        boardId: boardId,
                        position: { $gt: oldPosition, $lte: newPosition },
                        isDeleted: false,
                        _id: { $ne: listId }
                    },
                    { $inc: { position: -1 } }
                );
            }

            // Update position of current list
            const updatedList = await ListsModel.findByIdAndUpdate(
                listId,
                { position: newPosition },
                { new: true }
            );

            return updatedList;
        } catch (error) {
            throw new Error(
                error.message || 'Error updating list position'
            );
        }
    }



    /**
     * getListsCount: Count number of lists in board
     * @param {String} boardId
     * @returns count
     */
    async getListsCount(boardId) {
        try {
            const count = await ListsModel.countDocuments({
                boardId: boardId,
                isDeleted: false
            });
            return count;
        } catch (error) {
            throw new Error(
                error.message || 'Error counting lists'
            );
        }
    }
}

module.exports = { ListsService: new ListsService() };