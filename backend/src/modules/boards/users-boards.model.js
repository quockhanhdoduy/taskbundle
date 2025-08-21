const mongoose = require('mongoose');
const { BoardRoles } = require('./boards.const');

const UsersBoardsSchema = new mongoose.Schema({
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
    invitedAt: {
        type: Date,
        default: null,
        description: 'Timestamp to invitation',
    },
    role: {
        type: String,
        enum: Object.values(BoardRoles),
        required: true,
    },
    accepted: {
        type: Boolean,
        required: true,
        default: false,
    },
});

const UsersBoardsModel = mongoose.model('users_boards', UsersBoardsSchema);

module.exports = {UsersBoardsModel};