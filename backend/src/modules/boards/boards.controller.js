const { ResponseHandler, StatusCodes } = require("../../utils");
const { BoardRoles } = require("./boards.const");
const { BoardsService } = require("./boards.service");
const { UsersService } = require("../users/users.service");
const { sendInviteToBoardEmail } = require("../email/email.service");

class BoardsController {
    async createBoard(req, res) {
        const data = req.body;
        const user = req.user;

        try {
            const board = await BoardsService.createBoard(data);
            const invitedUsers = await BoardsService.inviteUserToBoard({
                userId: user._id,
                boardId: board._id,
                role: BoardRoles.ADMIN,
                accepted: true
            });
            console.log(`Create new board: ${board.name}`);
            console.log(`Assign owner: ${JSON.stringify(invitedUsers)}`);

            return ResponseHandler.success(res, StatusCodes.CREATED, board);

        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async homeView(req, res) {
        const user = req.user;
        try {
            const [allUserBoards, ownerBoards] = await Promise.all([
                BoardsService.getAllBoardsByFilters({
                    userId: user._id,
                    accepted: true,
                  }), // Get all boards that user is in them
                  BoardsService.getAllBoardsByFilters({
                    // Get all boards that user is owner
                    userId: user._id,
                    role: BoardRoles.ADMIN,
                  }),
            ]);

            // Filter out boards where user is admin
            const ownerBoardIds = ownerBoards.map(board => board._id.toString());
            const invitedBoards = allUserBoards.filter(board =>
                !ownerBoardIds.includes(board._id.toString())
            );

            return ResponseHandler.success(res, StatusCodes.OK, {
                invitedBoards: invitedBoards,
                ownerBoards: ownerBoards,
            });
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message || 'Error getting boards');
        }
    }

    async updateInfo(req, res) {
        const data = req.body;
        const boardId = req.params?.boardId;
        try {
            const updatedBoard = await BoardsService.updateOneBoardInfo(boardId, data);
            return ResponseHandler.success(res, StatusCodes.OK, updatedBoard);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message || 'Error updating board info');
        }
    }

    async inviteMember(req, res) {
        const data = req.body;
        const boardId = req.params?.boardId;
        const user = req.user;

        try {

           const board = await BoardsService.findOneBoard({
            _id: boardId,
            isDeleted: false
           });
           if (!board) {
            return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'Board not found');
           }

           // find user
            const existUser = await UsersService.findOne({
            email: data.email,
            isVerified: true
           });
           if (!existUser) {
            return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'User not found');
           }
           // check if user is already in board
           const existUsersBoards = await BoardsService.findOneUsersBoards({
            userId: existUser._id,
            boardId: boardId,
           });
           if (existUsersBoards) {
            return ResponseHandler.error(res, StatusCodes.BAD_REQUEST, 'User already in board');
           }
           const invitedUsers = await BoardsService.inviteUserToBoard({
            userId: existUser._id,
            boardId,
            role: data.role,
            accepted: false
           });

           //send invite email
           const sent = await sendInviteToBoardEmail(
            existUser,
            user,
            board,
            BoardsService.generateAcceptUrl(boardId, data.email)
           );
           //if cannot send invite email(include accept url)
           if (!sent) {
            //remove invitation and throw un-expectation error
            await BoardsService.removeUserOfBoard(existUser._id, boardId);
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, 'Can not invite member to board because of email service error');
           }
           //to do: send notification to user
           console.log(`Invite member to board: ${JSON.stringify(invitedUsers)}`);
           return ResponseHandler.success(res, StatusCodes.OK, invitedUsers);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message || 'Error inviting member to board');
        }
    }

    async acceptInvitation(req, res) {
        const boardId = req.params?.boardId;
        const invitedEmail = req.params?.email;
        try {
            const [board, user] = await Promise.all([
                BoardsService.findOneBoard({
                    _id: boardId,
                    isDeleted: false,
                }),
                UsersService.findOne({
                    email: invitedEmail,
                    isVerified: true,
                }),
            ]);
            if (!board || !user) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'Board or user not found');
            }
            const existInvitation = await BoardsService.findOneUsersBoards({
                userId: user._id,
                boardId: boardId,
                accepted: false,
            });
            if (!existInvitation) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'Invitation not found');
            }

            const accepted = await BoardsService.acceptInvitation(user._id, boardId);
            if (!accepted) {
                return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, {success: false});
            }
            const html = BoardsService.generateSuccessfullyAcceptedUI(board.name);

            //to do: send notification to user
            res.setHeader('Content-Type', 'text/html');
            return res.status(StatusCodes.OK).send(html);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message || 'Error accepting invitation');
        }
    }

    async getListBoardUsers(req, res) {
        const boardId = req.params?.boardId;
        try {
        const members = await BoardsService.getBoardUsersInfo(boardId);
        return ResponseHandler.success(res, StatusCodes.OK, members);
        } catch (error) {
        return ResponseHandler.error(
            res,
            StatusCodes.INTERNAL_SERVER_ERROR,
            error.message || 'Error getting list board users'
        );
        }
    }

    async updateMemberRole(req, res) {
        const data = req.body;
        const boardId = req.params?.boardId;
        try {
          const existUser = await UsersService.findOne({ email: data.email });
          if (!existUser) {
            return ResponseHandler.error(
              res,
              StatusCodes.NOT_FOUND,
              'Not found user, cannot update role for member of board!!!'
            );
          }

          const existUsersBoards = await BoardsService.findOneUsersBoards({
            userId: existUser._id,
            boardId: boardId,
          });
          if (!existUsersBoards) {
            return ResponseHandler.error(
              res,
              StatusCodes.NOT_FOUND,
              'Not a member of board, cannot update role!!!'
            );
          }
          const result = await BoardsService.updateBoardMemberRole(
            existUser._id,
            boardId,
            data.role
          );
          return ResponseHandler.success(res, StatusCodes.OK, { success: result });
        } catch (error) {
          return ResponseHandler.error(
            res,
            StatusCodes.INTERNAL_SERVER_ERROR,
            error.message || 'Error updating members role of board'
          );
        }
      }

      async removeMember(req, res) {
        const boardId = req.params?.boardId;
        const email = req.params?.email;
        try {
          const existUser = await UsersService.findOne({ email });
          if (!existUser) {
            return ResponseHandler.error(
              res,
              StatusCodes.NOT_FOUND,
              'Not found user, cannot remove member of board!!!'
            );
          }
          const existUsersBoards = await BoardsService.findOneUsersBoards({
            userId: existUser._id,
            boardId: boardId,
          });
          if (!existUsersBoards) {
            return ResponseHandler.error(
              res,
              StatusCodes.NOT_FOUND,
              'Not a member of board, cannot remove out of board!!!'
            );
          }
          if (existUsersBoards.role === BoardRoles.ADMIN) {
            return ResponseHandler.error(
              res,
              StatusCodes.INTERNAL_SERVER_ERROR,
              'ADMIN of board, cannot remove out of board!!!'
            );
          }

          const result = await BoardsService.removeUserOfBoard(
            existUser._id,
            boardId
          );
          return ResponseHandler.success(res, StatusCodes.OK, { success: result });
        } catch (error) {
          return ResponseHandler.error(
            res,
            StatusCodes.INTERNAL_SERVER_ERROR,
            error.message || 'Error removing member of board'
          );
        }
    }

    async leaveBoard(req, res) {
        const boardId = req.params?.boardId;
        const user = req.user;
        try {
          const result = await BoardsService.removeUserOfBoard(user._id, boardId);
          return ResponseHandler.success(res, StatusCodes.OK, { success: result });
        } catch (error) {
          return ResponseHandler.error(
            res,
            StatusCodes.INTERNAL_SERVER_ERROR,
            error.message || 'Error leaving board'
          );
        }
      }

    async closeBoard(req, res) {
        const boardId = req.params?.boardId;
        const user = req.user;
        try {

            const board = await BoardsService.findOneBoard({
                _id: boardId,
                isDeleted: false
            });
            if (!board) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'Board not found');
            }

            // check if user is admin of board
            const userBoard = await BoardsService.findOneUsersBoards({
                userId: user._id,
                boardId: boardId,
                role: BoardRoles.ADMIN
            });
            if (!userBoard) {
                return ResponseHandler.error(res, StatusCodes.FORBIDDEN, 'Only admin can close board');
            }


            const result = await BoardsService.closeBoard(boardId);
            if (!result) {
                return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, 'Failed to close board');
            }

            console.log(`Board closed: ${board.name} by user: ${user.email}`);
            return ResponseHandler.success(res, StatusCodes.OK, {
                success: true,
                message: 'Board closed successfully'
            });
        } catch (error) {
            return ResponseHandler.error(
                res,
                StatusCodes.INTERNAL_SERVER_ERROR,
                error.message || 'Error closing board'
            );
        }
    }
}

module.exports = { BoardsController: new BoardsController() };
