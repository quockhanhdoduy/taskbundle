const { BoardsModel } = require('./boards.model');
const { UsersBoardsModel } = require('./users-boards.model');
const { env } = require('../../utils');

class BoardsService {
    /**
   * create: Create new board
   * @param {*} data Object
   * @returns board
   */
  async createBoard(data) {
    try {
        const board = await BoardsModel.create({...data});
        return board;
    } catch (error) {
        throw new Error(
            error.message || 'Error creating board'
        );
    }
  }

   /**
   * inviteUserToBoard: Invite a user to a board
   * @param {*} data.userId String
   * @param {*} data.boardId String
   * @param {*} data.role BoardRoles
   * @param {*} data.accepted Boolean
   * @returns users_boards
   */
  async inviteUserToBoard(data) {
    const { userId, boardId, role, accepted } = data;
    try {
        const invited = await UsersBoardsModel.create({
            userId: userId,
            boardId: boardId,
            role,
            accepted,
        });
        return invited;
    } catch (error) {
        throw new Error(
            error.message || 'Error inviting user to board'
        );
    }
  }

  /**
   * getAllByFilters: Get all boards by filters
   * @param {*} filters._id String | Array[]
   * @param {*} filters.name String
   * @param {*} filters.is_star Boolean
   * @param {*} filters.is_followed Boolean
   * @param {*} filters.near_viewed Boolean
   * @param {*} filters.accepted Boolean
   * @param {*} filters.role BoardRoles
   * @return boards
   */
  async getAllBoardsByFilters(filters) {
    const query = {isDeleted: false};
    if (filters._id) {
        query._id = filters._id;
    }
    if (filters.name) {
        query.name = {$regex: filters.name, $options: 'i'};
    }

    let userBoards = [];
    if (filters.userId) {
        const subQuery = { userId: filters.userId };

        if (filters.accepted || filters.accepted === false) {
            subQuery.accepted = filters.accepted;
        }

        if (filters.role) {
            subQuery.role = filters.role;
        }

        const sQ = UsersBoardsModel.find(subQuery);

        userBoards = await sQ.select('boardId');
        if (userBoards.length === 0 && filters.accepted === false) {
            throw new Error('User not found in any board');
        }

        if(userBoards.length > 0) {
            userBoards = userBoards.map(board => board.boardId);
            query._id = {$in: userBoards};
        } else {
            query._id = {$in: []};
        }
    }

    try {
        const boards = await BoardsModel.find(query).sort({
            createdAt: -1,
        });
        return boards;
    } catch (error) {
        throw new Error(
            error.message || 'Error getting boards'
        );
    }
}

    /**
   * findOneUsersBoards: Find a UsersBoards to check role user on board,
   * or, accept invite, or, validate to remove user out of board
   * @param {*} filters.accepted Boolean
   * @param {*} filters.role BoardRoles
   * @param {*} filters.userId String
   * @param {*} filters.boardId String
   * @returns usersBoards
   */
  async findOneUsersBoards(filters) {
    const query = {};

    if (filters.accepted || filters.accepted === false) {
        query.accepted = filters.accepted;
    }
    if (filters.role) {
        query.role = filters.role;
    }
    if (filters.userId) {
        query.userId = filters.userId;
    }
    if (filters.boardId) {
        query.boardId = filters.boardId;
    }
    try {
        const result = await UsersBoardsModel.findOne(query);
    return result;
    } catch (error) {
        throw new Error(
            error.message || 'Error finding users boards'
        );
    }
}



  /**
   * findOneBoard: Find a board to action something
   * @param {*} filters._id String | Array[]
   * @param {*} filters.name String
   * @param {*} filters.is_star Boolean
   * @param {*} filters.is_followed Boolean
   * @returns board
   */
  async findOneBoard(filters) {
    const query = {isDeleted: false};
    if (filters._id) {
        query._id = filters._id;
    }
    if (filters.name) {
        query.name = {$regex: filters.name, $options: 'i'};
    }
    try {
        const result = await BoardsModel.findOne(query);
        return result;
    } catch (error) {
        throw new Error(
            error.message || 'Error finding board'
        );
    }
  }

  /**
   * updateOneBoardInfo: Update a board by _id
   * @param {*} _id String
   * @param {*} data Object
   * @returns board
   */
  async updateOneBoardInfo(_id, data) {
    const dataUpdate = {};
    if (data.name) {
        dataUpdate.name = data.name;
    }
    if (data.description) {
        dataUpdate.description = data.description;
    }
    try {
        const updated = await BoardsModel.findByIdAndUpdate(_id, dataUpdate, {new: true});
        return updated;
    } catch (error) {
        throw new Error(
            error.message || 'Error updating board info'
        );
    }
  }

  // This solution is just use the sever url to generate accept_url
  // -> the better solution must be generated from the website url
  // -> Method PUT -> With logged in account to accept!!!
  generateAcceptUrl(boardId, invitedEmail) {
    const url = `${env.SERVER_URL}/boards/${boardId}/accept-invites/${invitedEmail}`;
    console.log(`Generate accept url: ${url}`);
    return url;
  }

  /**
   * removeUserOfBoard: Remove a user out of a board
   * @param {*} userId String
   * @param {*} boardId String
   * @returns Boolean
   */
  async removeUserOfBoard(userId, boardId) {
    try {
      const removed = await UsersBoardsModel.deleteOne({
        userId: userId,
        boardId: boardId,
      });
      if (removed.deletedCount > 0) {
        return true;
      }
      return false;
    } catch (error) {
      throw new Error(
        error.message || 'removeUserOfBoard met: Internal Server Error!!!'
      );
    }
  }

  /**
   * acceptInvitation: User accept the invitation to a board
   * @param {*} userId String
   * @param {*} boardId String
   * @returns Boolean
   */
  async acceptInvitation(userId, boardId) {
    try {
      const accepted = await UsersBoardsModel.updateOne(
        {
          userId: userId,
          boardId: boardId,
        },
        { accepted: true }
      );
      if (accepted.modifiedCount > 0) {
        return true;
      }
      return false;
    } catch (error) {
      throw new Error(
        error.message || 'acceptInvitation met: Internal Server Error!!!'
      );
    }
  }

  /**
   * generateSuccessfullyAcceptedUI: Generate a professional UI accepted invitation
   * @param {*} BOARD_NAME String
   * @param {*} LANDING_PAGE_URL String
   * @returns html
   */
  generateSuccessfullyAcceptedUI(
    BOARD_NAME,
  ) {
    return `
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Invitation Accepted</title>
      <style>
        body { font-family: Arial, sans-serif; background: #f2f2f2; text-align: center; padding: 50px; color: #333; }
        .container { background: #fff; padding: 40px; border-radius: 8px; display: inline-block; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
        h1 { color: #2D9CDB; }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>Invitation Accepted!</h1>
        <p>You have successfully joined the board: <strong>${BOARD_NAME}</strong>.</p>
        <p>Start collaborating with your team now.</p>
      </div>
    </body>
    </html>
  `;
  }

  /**
   * getBoardUsersInfo: Get all users information of a board
   * @param {*} boardId String
   * @returns users
   */
  async getBoardUsersInfo(boardId) {
    try {
      const usersBoards = await UsersBoardsModel.find({
        boardId: boardId,
      }).populate({ path: 'userId', select: '_id email name is_verified' });
      const result = usersBoards.map((uB) => {
        const user = JSON.parse(JSON.stringify(uB.userId));
        return { ...user, role: uB.role };
      });
      return result;
    } catch (error) {
      throw new Error(
        error.message || 'getBoardMembersInfo met: Internal Server Error!!!'
      );
    }
  }

  /**
   * updateBoardMemberRole: Update role for a member in a board
   * @param {*} userId String
   * @param {*} boardId String
   * @param {*} role BoardRoles
   * @returns Boolean
   */
  async updateBoardMemberRole(userId, boardId, role) {
    try {
      const updated = await UsersBoardsModel.updateOne(
        {
          userId: userId,
          boardId: boardId,
        },
        { role }
      );
      if (updated.modifiedCount > 0) {
        return true;
      }
      return false;
    } catch (error) {
      throw new Error(
        error.message || 'updateBoardMemberRole met: Internal Server Error!!!'
      );
    }
  }

  /**
   * closeBoard: Close a board (soft delete)
   * @param {*} boardId String
   * @returns Boolean
   */
  async closeBoard(boardId) {
    try {
      const updated = await BoardsModel.updateOne(
        {
          _id: boardId,
          isDeleted: false
        },
        {
          isDeleted: true,
          deletedAt: new Date()
        }
      );
      if (updated.modifiedCount > 0) {
        return true;
      }
      return false;
    } catch (error) {
      throw new Error(
        error.message || 'Error closing board'
      );
    }
  }


}



module.exports = {BoardsService: new BoardsService()};