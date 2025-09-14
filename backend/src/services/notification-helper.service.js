const { CardsModel } = require('../modules/cards/cards.model');
const { BoardsModel } = require('../modules/boards/boards.model');
const { UsersModel } = require('../modules/users/users.model');
const { ListsModel } = require('../modules/lists/lists.model');

class NotificationHelperService {
  async getCardAndBoardInfo(cardId) {
    try {
      const card = await CardsModel.findById(cardId)
        .populate('listId', 'title boardId')
        .populate('assignedUsers', 'name email fcmToken')
        .lean();

      if (!card) {
        throw new Error('Card not found');
      }

      const board = await BoardsModel.findById(card.listId.boardId).lean();
      if (!board) {
        throw new Error('Board not found');
      }

      return {
        card: {
          _id: card._id,
          title: card.title,
          description: card.description,
          dueDate: card.dueDate,
          assignedUsers: card.assignedUsers
        },
        board: {
          _id: board._id,
          name: board.name
        }
      };
    } catch (error) {
      console.error('Error getting card and board info:', error);
      throw error;
    }
  }

  async getBoardInfo(boardId) {
    try {
      const board = await BoardsModel.findById(boardId).lean();
      if (!board) {
        throw new Error('Board not found');
      }

      return {
        _id: board._id,
        name: board.name
      };
    } catch (error) {
      console.error('Error getting board info:', error);
      throw error;
    }
  }

  async getUserInfo(userId) {
    try {
      const user = await UsersModel.findById(userId, 'name email fcmToken').lean();
      if (!user) {
        throw new Error('User not found');
      }

      return {
        _id: user._id,
        name: user.name,
        email: user.email,
        fcmToken: user.fcmToken
      };
    } catch (error) {
      console.error('Error getting user info:', error);
      throw error;
    }
  }

  async getBoardMemberTokens(boardId, excludeUserId = null) {
    try {
      const { UsersBoardsModel } = require('../modules/boards/users-boards.model');

      const boardMembers = await UsersBoardsModel.find({ boardId })
        .populate('userId', 'name email fcmToken')
        .lean();

      const tokens = boardMembers
        .filter(member =>
          member.userId &&
          member.userId.fcmToken &&
          (!excludeUserId || member.userId._id.toString() !== excludeUserId.toString())
        )
        .map(member => member.userId.fcmToken);

      return tokens;
    } catch (error) {
      console.error('Error getting board member tokens:', error);
      return [];
    }
  }

  async getCardAssignedUserTokens(cardId, excludeUserId = null) {
    try {
      const card = await CardsModel.findById(cardId)
        .populate('assignedUsers', 'name email fcmToken')
        .lean();

      if (!card) {
        return [];
      }

      const tokens = card.assignedUsers
        .filter(user =>
          user.fcmToken &&
          (!excludeUserId || user._id.toString() !== excludeUserId.toString())
        )
        .map(user => user.fcmToken);

      return tokens;
    } catch (error) {
      console.error('Error getting card assigned user tokens:', error);
      return [];
    }
  }

  async getUserToken(userId) {
    try {
      const user = await UsersModel.findById(userId, 'fcmToken').lean();
      return user?.fcmToken || null;
    } catch (error) {
      console.error('Error getting user token:', error);
      return null;
    }
  }

  async saveUserToken(userId, fcmToken) {
    try {
      await UsersModel.findByIdAndUpdate(userId, { fcmToken });
      console.log(`FCM token saved for user ${userId}`);
    } catch (error) {
      console.error('Error saving user token:', error);
      throw error;
    }
  }

  async getAllUserTokens(excludeUserId = null) {
    try {
      const users = await UsersModel.find(
        {
          fcmToken: { $exists: true, $ne: null },
          ...(excludeUserId ? { _id: { $ne: excludeUserId } } : {})
        },
        'fcmToken'
      ).lean();

      return users.map(user => user.fcmToken);
    } catch (error) {
      console.error('Error getting all user tokens:', error);
      return [];
    }
  }
}

module.exports = new NotificationHelperService();
