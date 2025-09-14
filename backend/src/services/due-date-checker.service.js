const { CardsModel } = require('../modules/cards/cards.model');
const { BoardsModel } = require('../modules/boards/boards.model');
const boardNotificationService = require('./board-notification.service');

class DueDateCheckerService {
  async checkDueDateReminders() {
    try {
      const now = new Date();
      const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000);
      const cardsDueSoon = await CardsModel.find({
        dueDate: {
          $gte: now,
          $lte: tomorrow
        },
        isCompleted: false,
        isDeleted: false
      }).populate('listId', 'boardId').lean();

      console.log(`Found ${cardsDueSoon.length} cards due soon`);

      for (const card of cardsDueSoon) {
        try {
          const board = await BoardsModel.findById(card.listId.boardId).lean();
          if (!board) continue;

          await boardNotificationService.sendDueDateReminder(card, board);
        } catch (error) {
          console.error(`Error sending reminder for card ${card._id}:`, error);
        }
      }
    } catch (error) {
      console.error('Error checking due date reminders:', error);
    }
  }

  async checkOverdueCards() {
    try {
      const now = new Date();
      const overdueCards = await CardsModel.find({
        dueDate: {
          $lt: now
        },
        isCompleted: false,
        isDeleted: false
      }).populate('listId', 'boardId').lean();

      console.log(`Found ${overdueCards.length} overdue cards`);

      for (const card of overdueCards) {
        try {
          const board = await BoardsModel.findById(card.listId.boardId).lean();
          if (!board) continue;

          await boardNotificationService.sendOverdueNotification(card, board);
        } catch (error) {
          console.error(`Error sending overdue notification for card ${card._id}:`, error);
        }
      }
    } catch (error) {
      console.error('Error checking overdue cards:', error);
    }
  }

  async runAllChecks() {
    console.log('Running due date checks...');
    await this.checkDueDateReminders();
    await this.checkOverdueCards();
    console.log('Due date checks completed');
  }
}

module.exports = new DueDateCheckerService();



