const { ResponseHandler, StatusCodes } = require("../../utils");
const { ActivitiesService } = require("./activities.service");

class ActivitiesController {
    /**
     * Get activities for a specific board
     */
    async getBoardActivities(req, res) {
        const { boardId } = req.params;
        const { page, limit, type } = req.query;
        const user = req.user;

        try {
            const options = {
                page: parseInt(page) || 1,
                limit: parseInt(limit) || 20,
                type: type || undefined
            };

            const result = await ActivitiesService.getBoardActivities(boardId, options);

            console.log(`User ${user.email} retrieved activities for board ${boardId}`);

            return ResponseHandler.success(res, StatusCodes.OK, result);
        } catch (error) {
            console.error('Error getting board activities:', error);
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }
}

module.exports = { ActivitiesController: new ActivitiesController() };
