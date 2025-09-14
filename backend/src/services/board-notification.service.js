const notificationService = require('./notification.service');
const notificationHelper = require('./notification-helper.service');

class BoardNotificationService {
  async sendCommentNotification(comment, card, board, currentUserId) {
    try {
      const recipientTokens = await notificationHelper.getBoardMemberTokens(board._id, currentUserId);

      if (recipientTokens.length === 0) {
        console.log('No FCM tokens found for board members');
        return;
      }

      await notificationService.sendCustomNotification(
        'New Comment',
        `${comment.author.name} commented on card "${card.title}"`,
        {
          type: 'comment',
          boardId: board._id.toString(),
          cardId: card._id.toString(),
          commentId: comment._id.toString(),
          authorId: comment.author._id.toString(),
          authorName: comment.author.name,
        },
        recipientTokens
      );

      console.log(`Comment notification sent to ${recipientTokens.length} users`);
    } catch (error) {
      console.error('Error sending comment notification:', error);
    }
  }

  async sendCardNotification(card, board, currentUserId) {
    try {
      const recipientTokens = await notificationHelper.getBoardMemberTokens(board._id, currentUserId);

      if (recipientTokens.length === 0) {
        console.log('No FCM tokens found for board members');
        return;
      }

      await notificationService.sendCustomNotification(
        'New Card',
        `Card "${card.title}" was created in board "${board.name}"`,
        {
          type: 'card',
          boardId: board._id.toString(),
          cardId: card._id.toString(),
          authorId: card.author._id.toString(),
          authorName: card.author.name,
        },
        recipientTokens
      );

      console.log(`Card notification sent to ${recipientTokens.length} users`);
    } catch (error) {
      console.error('Error sending card notification:', error);
    }
  }

  async sendMemberNotification(board, newMember, currentUserId) {
    try {
      const recipientTokens = await notificationHelper.getBoardMemberTokens(board._id, currentUserId);

      if (recipientTokens.length === 0) {
        console.log('No FCM tokens found for board members');
        return;
      }

      await notificationService.sendCustomNotification(
        'New Member',
        `${newMember.name} joined board "${board.name}"`,
        {
          type: 'member',
          boardId: board._id.toString(),
          memberId: newMember._id.toString(),
          memberName: newMember.name,
        },
        recipientTokens
      );

      console.log(`Member notification sent to ${recipientTokens.length} users`);
    } catch (error) {
      console.error('Error sending member notification:', error);
    }
  }

  async sendDueDateReminder(card, board) {
    try {
      const recipientTokens = await notificationHelper.getCardAssignedUserTokens(card._id);

      if (recipientTokens.length === 0) {
        console.log('No FCM tokens found for assigned users');
        return;
      }

      await notificationService.sendCustomNotification(
        'Deadline Reminder',
        `Card "${card.title}" is due soon (${card.dueDate})`,
        {
          type: 'deadline',
          boardId: board._id.toString(),
          cardId: card._id.toString(),
          dueDate: card.dueDate,
        },
        recipientTokens
      );

      console.log(`Due date reminder sent to ${recipientTokens.length} users`);
    } catch (error) {
      console.error('Error sending due date reminder:', error);
    }
  }

  async sendOverdueNotification(card, board) {
    try {
      const recipientTokens = await notificationHelper.getCardAssignedUserTokens(card._id);

      if (recipientTokens.length === 0) {
        console.log('No FCM tokens found for assigned users');
        return;
      }

      await notificationService.sendCustomNotification(
        'Overdue Card',
        `Card "${card.title}" is overdue (${card.dueDate})`,
        {
          type: 'overdue',
          boardId: board._id.toString(),
          cardId: card._id.toString(),
          dueDate: card.dueDate,
        },
        recipientTokens
      );

      console.log(`Overdue notification sent to ${recipientTokens.length} users`);
    } catch (error) {
      console.error('Error sending overdue notification:', error);
    }
  }
}

module.exports = new BoardNotificationService();



