const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  title: {
    type: String,
    required: true,
    trim: true
  },
  body: {
    type: String,
    required: true,
    trim: true
  },
  type: {
    type: String,
    required: true,
    enum: ['general', 'board', 'card', 'test'],
    default: 'general'
  },
  isRead: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

const NotificationsModel = mongoose.model('Notification', notificationSchema);

module.exports = { NotificationsModel };
