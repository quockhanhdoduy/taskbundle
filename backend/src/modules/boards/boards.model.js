const mongoose = require('mongoose');

const BoardsSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
    },
    description: {
        type: String,
        required: true,
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

const BoardsModel = mongoose.model('boards', BoardsSchema);

module.exports = {BoardsModel};