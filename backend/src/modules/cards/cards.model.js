const mongoose = require('mongoose');

const CardsSchema = new mongoose.Schema({
    title: {
        type: String,
        required: true,
        trim: true,
    },
    description: {
        type: String,
        default: '',
        trim: true,
    },
    listId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'lists',
        required: true,
    },
    position: {
        type: Number,
        required: true,
        default: 0,
    },

    dueDate: {
        type: Date,
        default: null,
    },
    completedDate: {
        type: Date,
        default: null,
    },

    isCompleted: {
        type: Boolean,
        default: false,
    },

    assignedUsers: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'users',
    }],

    attachments: [{
        url: {
            type: String,
            required: true
        },
        uploadedBy: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'users',
            required: true
        },
        uploadedAt: {
            type: Date,
            default: Date.now
        }
    }],

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


const MAX_CARDS_PER_LIST = 50;
const MAX_ATTACHMENTS_PER_CARD = 20;

const CardsModel = mongoose.model('cards', CardsSchema);

module.exports = {
    CardsModel,
    MAX_CARDS_PER_LIST,
    MAX_ATTACHMENTS_PER_CARD
};