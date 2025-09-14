const firebaseAdmin = require('./firebase-admin.service');

class NotificationService {
  constructor() {
    this.firebaseAdmin = firebaseAdmin;
  }

  async sendNewCommentNotification(comment, card, board, recipientTokens) {
    try {
      const notification = {
        title: 'New Comment',
        body: `${comment.author.name} commented on card "${card.title}"`,
        data: {
          type: 'comment',
          boardId: board._id.toString(),
          cardId: card._id.toString(),
          commentId: comment._id.toString(),
          authorId: comment.author._id.toString(),
          authorName: comment.author.name,
        },
      };

      if (recipientTokens.length === 1) {
        return await this.firebaseAdmin.sendToDevice(recipientTokens[0], notification);
      } else {
        return await this.firebaseAdmin.sendToMultipleDevices(recipientTokens, notification);
      }
      } catch (error) {
        console.error('Error sending new comment notification:', error);
        throw error;
      }
  }

  async sendNewCardNotification(card, board, recipientTokens) {
    try {
      const notification = {
        title: 'New Card',
        body: `Card "${card.title}" was created in board "${board.name}"`,
        data: {
          type: 'card',
          boardId: board._id.toString(),
          cardId: card._id.toString(),
          authorId: card.author._id.toString(),
          authorName: card.author.name,
        },
      };

      if (recipientTokens.length === 1) {
        return await this.firebaseAdmin.sendToDevice(recipientTokens[0], notification);
      } else {
        return await this.firebaseAdmin.sendToMultipleDevices(recipientTokens, notification);
      }
      } catch (error) {
        console.error('Error sending new card notification:', error);
        throw error;
      }
  }

  async sendNewMemberNotification(board, newMember, recipientTokens) {
    try {
      const notification = {
        title: 'New Member',
        body: `${newMember.name} joined board "${board.name}"`,
        data: {
          type: 'member',
          boardId: board._id.toString(),
          memberId: newMember._id.toString(),
          memberName: newMember.name,
        },
      };

      if (recipientTokens.length === 1) {
        return await this.firebaseAdmin.sendToDevice(recipientTokens[0], notification);
      } else {
        return await this.firebaseAdmin.sendToMultipleDevices(recipientTokens, notification);
      }
      } catch (error) {
        console.error('Error sending new member notification:', error);
        throw error;
      }
  }

  async sendDeadlineReminderNotification(card, board, recipientTokens) {
    try {
      const notification = {
        title: 'Deadline Reminder',
        body: `Card "${card.title}" is due soon (${card.dueDate})`,
        data: {
          type: 'deadline',
          boardId: board._id.toString(),
          cardId: card._id.toString(),
          dueDate: card.dueDate,
        },
      };

      if (recipientTokens.length === 1) {
        return await this.firebaseAdmin.sendToDevice(recipientTokens[0], notification);
      } else {
        return await this.firebaseAdmin.sendToMultipleDevices(recipientTokens, notification);
      }
      } catch (error) {
        console.error('Error sending deadline reminder notification:', error);
        throw error;
      }
  }

  async sendCustomNotification(title, body, data, recipientTokens) {
    try {
      const notification = {
        title,
        body,
        data: data || {},
      };

      if (recipientTokens.length === 1) {
        return await this.firebaseAdmin.sendToDevice(recipientTokens[0], notification);
      } else {
        return await this.firebaseAdmin.sendToMultipleDevices(recipientTokens, notification);
      }
      } catch (error) {
        console.error('Error sending custom notification:', error);
        throw error;
      }
  }

  async sendToTopic(topic, title, body, data) {
    try {
      const notification = {
        title,
        body,
        data: data || {},
      };

      return await this.firebaseAdmin.sendToTopic(topic, notification);
    } catch (error) {
      console.error('Error sending notification to topic:', error);
      throw error;
    }
  }

  // Subscribe user to board notifications
  async subscribeToBoard(userTokens, boardId) {
    try {
      const topic = `board_${boardId}`;
      return await this.firebaseAdmin.subscribeToTopic(userTokens, topic);
    } catch (error) {
      console.error('Error subscribing to board:', error);
      throw error;
    }
  }

  // Unsubscribe user from board notifications
  async unsubscribeFromBoard(userTokens, boardId) {
    try {
      const topic = `board_${boardId}`;
      return await this.firebaseAdmin.unsubscribeFromTopic(userTokens, topic);
    } catch (error) {
      console.error('Error unsubscribing from board:', error);
      throw error;
    }
  }

  // Subscribe user to general notifications
  async subscribeToGeneral(userTokens, userId) {
    try {
      const topic = `user_${userId}`;
      return await this.firebaseAdmin.subscribeToTopic(userTokens, topic);
    } catch (error) {
      console.error('Error subscribing to general notifications:', error);
      throw error;
    }
  }

  // Unsubscribe user from general notifications
  async unsubscribeFromGeneral(userTokens, userId) {
    try {
      const topic = `user_${userId}`;
      return await this.firebaseAdmin.unsubscribeFromTopic(userTokens, topic);
    } catch (error) {
      console.error('Error unsubscribing from general notifications:', error);
      throw error;
    }
  }
}

module.exports = new NotificationService();