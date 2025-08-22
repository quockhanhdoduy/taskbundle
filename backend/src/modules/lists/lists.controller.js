const { ResponseHandler, StatusCodes } = require("../../utils");
const { ListsService } = require("./lists.service");

class ListsController {
    async createList(req, res) {
        const data = req.body;
        const user = req.user;

        try {
            const list = await ListsService.createList(data);
            console.log(`User ${user.email} created new list: ${list.name} in board ${data.boardId}`);

            return ResponseHandler.success(res, StatusCodes.CREATED, list);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }


    async getListsByBoard(req, res) {
        const { boardId } = req.params;

        try {
            const lists = await ListsService.getListsByBoardId(boardId);

            return ResponseHandler.success(res, StatusCodes.OK, lists);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async updateList(req, res) {
        const { listId } = req.params;
        const data = req.body;
        const user = req.user;

        try {
            const existingList = await ListsService.findOneList({ _id: listId });
            if (!existingList) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'List not found for update!'
                );
            }

            const updatedList = await ListsService.updateList(listId, data);
            console.log(`User ${user.email} updated list: ${updatedList.name}`);

            return ResponseHandler.success(res, StatusCodes.OK, updatedList);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }


    async deleteList(req, res) {
        const { listId } = req.params;
        const user = req.user;

        try {
            const existingList = await ListsService.findOneList({ _id: listId });
            if (!existingList) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'List not found for deletion!'
                );
            }

            const deletedList = await ListsService.deleteList(listId);
            console.log(`User ${user.email} deleted list: ${deletedList.name}`);

            return ResponseHandler.success(res, StatusCodes.OK, {
                message: 'List deleted successfully!',
                deletedList
            });
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }


    async updateListPosition(req, res) {
        const { listId } = req.params;
        const { position } = req.body;
        const user = req.user;

        try {
            const existingList = await ListsService.findOneList({ _id: listId });
            if (!existingList) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.NOT_FOUND,
                    'List not found for position update!'
                );
            }

            // Check if position is valid (not exceed lists count in board)
            const listsCount = await ListsService.getListsCount(existingList.boardId);
            if (position >= listsCount) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.BAD_REQUEST,
                    `Position cannot be greater than ${listsCount - 1}!`
                );
            }

            const updatedList = await ListsService.updateListPosition(listId, position);
            console.log(`User ${user.email} updated position of list: ${updatedList.name} to position ${position}`);

            return ResponseHandler.success(res, StatusCodes.OK, updatedList);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }


}

module.exports = { ListsController: new ListsController() };