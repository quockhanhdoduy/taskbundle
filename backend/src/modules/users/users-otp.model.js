const mongoose = require('mongoose');

const UsersOTPSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'users',
    },
    otp: {
      type: Number,
      required: true,
    },
    ttl: {
      type: Number,
      required: true,
    },

  },
  {
    timestamps: true,
    versionKey: false,
  }
);

const UsersOTPModel = mongoose.model('users-otp', UsersOTPSchema);

module.exports = { UsersOTPModel };
