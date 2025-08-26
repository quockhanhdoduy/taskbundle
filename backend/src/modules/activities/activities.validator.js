const validator = require('validator');

const { ResponseHandler, StatusCodes } = require('../../utils');
const { ActivityTypes } = require('./activities.const');

class ActivitiesValidator {
    /**
     * Validate request to get board activities
     */
    getBoardActivities(req, res, next) {
        const { boardId } = req.params;
        const { page, limit, type } = req.query;

        if (!boardId || !validator.isMongoId(boardId)) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Invalid Board ID!'
            );
        }

        const errors = [];

        if (page !== undefined) {
            const pageNum = parseInt(page);
            if (isNaN(pageNum) || pageNum < 1) {
                errors.push('Page must be a positive integer!');
            }
        }

        if (limit !== undefined) {
            errors.push('Limit parameter is not allowed. Page size is fixed at 10 activities.');
        }

        if (type !== undefined) {
            if (!Object.values(ActivityTypes).includes(type)) {
                errors.push('Invalid activity type!');
            }
        }

        if (errors.length > 0) {
            return ResponseHandler.error(
                res,
                StatusCodes.BAD_REQUEST,
                'Invalid query parameters!',
                { data: errors }
            );
        }

        return next();
    }
}

module.exports = { ActivitiesValidator: new ActivitiesValidator() };
