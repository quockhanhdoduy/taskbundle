const mongoose = require('mongoose');

const ListsSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        trim: true,
    },
    boardId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'boards',
        required: true,
    },
    position: {
        type: Number,
        required: true,
        default: 0,
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
},
{
    timestamps: true
});

// Maximum 10 lists per board limit
const MAX_LISTS_PER_BOARD = 10;

const ListsModel = mongoose.model('lists', ListsSchema);

module.exports = { ListsModel, MAX_LISTS_PER_BOARD };