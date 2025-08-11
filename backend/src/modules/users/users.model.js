const mongoose = require('mongoose');
const moment = require('moment-timezone');

const userSchema = new mongoose.Schema({
    email: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        lowercase: true,
    },
    password: {
        type: String,
        required: true,
        description: 'SHA256 hash password'
    },
    name: {
        type: String,
        required: true,
    },
    isVerified: {
        type: Boolean,
        required: true,
        default: false,
    },
    verification: {
        code: {
            type: Number,
            required: true,
            default: () => Math.floor(100000 + Math.random() * 900000),
        },
        ttl: {
            type: Number,
            required: true,
            default: moment().add(15, 'minute').unix(),
        },
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

const UserModel = mongoose.model('User', userSchema);

module.exports = UserModel;
