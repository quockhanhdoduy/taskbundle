const validator = require('validator');

const { BoardsService } = require('./boards.service');
const { BoardRoles } = require('./boards.const');
const { ResponseHandler, StatusCodes } = require('../../utils');

class BoardAuthz {
  /**
   * verifyBoardAdmin: Middleware function check admin of a board to handle specific feature belong to admin role
   * role = BoardRoles.ADMIN
   * req.params.boardId -> required
   */
  async verifyBoardAdmin(req, res, next) {
    const user = req.user;
    const boardId = req.params?.boardId;
    if (!boardId || !validator.isMongoId(boardId)) {
      return ResponseHandler.error(
        res,
        StatusCodes.FORBIDDEN,
        'Invalid board ID!!!'
      );
    }

    const existBoard = await BoardsService.findOneBoard({ _id: boardId });
    if (!existBoard) {
      return ResponseHandler.error(
        res,
        StatusCodes.NOT_FOUND,
        'Not found board to action on board!!!'
      );
    }

    req.board = existBoard;

    // Check if board is closed (isDeleted = true means board is closed)
    // Skip this check for close board endpoint
    if (req.route && !req.route.path.includes('/close') && existBoard.isDeleted) {
      return ResponseHandler.error(
        res,
        StatusCodes.FORBIDDEN,
        'Cannot perform operations on a closed board!'
      );
    }

    if (!user) {
      return ResponseHandler.error(
        res,
        StatusCodes.UNAUTHORIZED,
        'Unauthorize user to action on board!!!'
      );
    }
    // Check admin role for user on board
    const uB = await BoardsService.findOneUsersBoards({
      userId: user._id,
      boardId: boardId,
      role: BoardRoles.ADMIN,
      accepted: true,
    });
    if (!uB) {
      return ResponseHandler.error(
        res,
        StatusCodes.FORBIDDEN,
        'User is not board ADMIN!!!'
      );
    }
    return next();
  }

  /**
   * verifyBoardUser: Middleware function check member [ADMIN, MEMBER]
   * of a board to handle specific feature belong to member [ADMIN, MEMBER]
   * req.params.boardId -> required
   */
  async verifyBoardMember(req, res, next) {
    const user = req.user;
    const boardId = req.params?.boardId;
    if (!boardId || !validator.isMongoId(boardId)) {
      return ResponseHandler.error(
        res,
        StatusCodes.FORBIDDEN,
        'Invalid board ID!!!'
      );
    }

    const existBoard = await BoardsService.findOneBoard({ _id: boardId });
    if (!existBoard) {
      return ResponseHandler.error(
        res,
        StatusCodes.NOT_FOUND,
        'Not found board to action on board!!!'
      );
    }

    req.board = existBoard;

    if (existBoard.isDeleted) {
      return ResponseHandler.error(
        res,
        StatusCodes.FORBIDDEN,
        'Cannot perform operations on a closed board!'
      );
    }

    if (!user) {
      return ResponseHandler.error(
        res,
        StatusCodes.UNAUTHORIZED,
        'Unauthorize user to action on board!!!'
      );
    }

    const uB = await BoardsService.findOneUsersBoards({
      userId: user._id,
      boardId: boardId,
      accepted: true,
    });
    if (!uB) {
      return ResponseHandler.error(
        res,
        StatusCodes.FORBIDDEN,
        'User is not belong to the board!!!'
      );
    }
    // Check role of user in board is ADMIN or MEMBER
    if (![BoardRoles.ADMIN, BoardRoles.MEMBER].includes(uB.role)) {
      return ResponseHandler.error(
        res,
        StatusCodes.FORBIDDEN,
        'User does not have permission to action on the board!!!'
      );
    }
    return next();
  }

  /**
   * verifyBoardUser: Middleware function check user [ADMIN, MEMBER, VIEWER]
   * of a board to handle specific feature belong to user [ADMIN, MEMBER, VIEWER]
   * req.params.boardId -> required
   */
  async verifyBoardGeneralUser(req, res, next) {
    const user = req.user;
    const boardId = req.params?.boardId;
    if (!boardId || !validator.isMongoId(boardId)) {
      return ResponseHandler.error(
        res,
        StatusCodes.FORBIDDEN,
        'Invalid board ID!!!'
      );
    }

    const board = await BoardsService.findOneBoard({ _id: boardId });
    if (!board) {
      return ResponseHandler.error(
        res,
        StatusCodes.NOT_FOUND,
        'Not found board to action on board!!!'
      );
    }

    req.board = board;

    if (!user) {
      return ResponseHandler.error(
        res,
        StatusCodes.UNAUTHORIZED,
        'Unauthorize user to action on board!!!'
      );
    }
    // Check user belong to board
    const uB = await BoardsService.findOneUsersBoards({
      userId: user._id,
      boardId: boardId,
      accepted: true,
    });
    if (!uB) {
      return ResponseHandler.error(
        res,
        StatusCodes.FORBIDDEN,
        'User is not belong to the board!!!'
      );
    }
    return next();
  }
}

module.exports = { BoardAuthz: new BoardAuthz() };
