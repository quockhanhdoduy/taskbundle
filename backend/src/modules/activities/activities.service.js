const { ActivitiesModel } = require('./activities.model');
const { PAGE_SIZE } = require('./activities.const');

class ActivitiesService {
    /**
     * Create a new activity log
     * @param {Object} activityData
     * @param {String} activityData.type
     * @param {String} activityData.userId
     * @param {String} activityData.boardId
     * @param {String} activityData.entityType
     * @param {String} activityData.entityId
     * @param {String} activityData.description
     * @returns {Promise<Object>} Created activity
     */
    async createActivity(activityData) {
        try {
            const activity = new ActivitiesModel(activityData);
            return await activity.save();
        } catch (error) {
            console.error('Error creating activity:', error);
            // Don't throw error to avoid breaking main functionality
            return null;
        }
    }

    /**
     * Get activities for a specific board
     * @param {String} boardId
     * @param {Object} options
     * @param {Number} [options.page=1]
     * @param {String} [options.type]
     * @returns {Promise<Object>}
     */
    async getBoardActivities(boardId, options = {}) {
        try {
            const page = Math.max(1, parseInt(options.page) || 1);
            const limit = PAGE_SIZE;
            const skip = (page - 1) * limit;

            const query = {
                boardId
            };

            if (options.type) {
                query.type = options.type;
            }

            const activities = await ActivitiesModel
                .find(query)
                .populate('userId', 'name email')
                .sort({ createdAt: -1 })
                .limit(limit)
                .skip(skip);

            // Get total count for pagination
            const total = await ActivitiesModel.countDocuments(query);

            return {
                activities,
                pagination: {
                    page,
                    limit,
                    total,
                    pages: Math.ceil(total / limit),
                    hasNext: page < Math.ceil(total / limit),
                    hasPrev: page > 1
                }
            };
        } catch (error) {
            console.error('Error getting board activities:', error);
            throw error;
        }
    }
}

module.exports = { ActivitiesService: new ActivitiesService() };
