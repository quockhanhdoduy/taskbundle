const mongoose = require('mongoose');
const { ActivityTypes, EntityTypes } = require('./activities.const');

const ActivitiesSchema = new mongoose.Schema({
    type: {
        type: String,
        required: true,
        enum: Object.values(ActivityTypes),
    },

    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'users',
        required: true,
    },

    boardId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'boards',
        required: true,
    },

    entityType: {
        type: String,
        enum: Object.values(EntityTypes),
        required: true,
    },

    entityId: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
    },

    description: {
        type: String,
        required: true,
    },
}, {
    timestamps: { createdAt: true, updatedAt: false }
});

const ActivitiesModel = mongoose.model('activities', ActivitiesSchema);

module.exports = { ActivitiesModel };
