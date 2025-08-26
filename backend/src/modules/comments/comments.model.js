const mongoose = require('mongoose');

const CommentsSchema = new mongoose.Schema({
    content: {
        type: String,
        required: true,
        trim: true,
    },
    cardId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'cards',
        required: true,
    },
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'users',
        required: true,
    },
    isEdited: {
        type: Boolean,
        default: false,
    },
    editedAt: {
        type: Date,
        default: null,
    },
    deletedAt: {
        type: Date,
        default: null,
        description: 'Timestamp to deletion',
    },
    isDeleted: {
        type: Boolean,
        default: false,
    },
}, {
    timestamps: true
});

const MAX_COMMENTS_PER_CARD = 100;

const CommentsModel = mongoose.model('comments', CommentsSchema);

module.exports = {
    CommentsModel,
    MAX_COMMENTS_PER_CARD
};