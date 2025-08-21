const validator = require('validator');

const { ResponseHandler, StatusCodes } = require('../../utils');
const { BoardRoles } = require('./boards.const');

class BoardsValidator {
  createBoard(req, res, next) {
    const data = req.body;
    if (!data || !typeof data === 'object' || Object.keys(data).length === 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.NOT_ACCEPTABLE,
        'Not have data to create new board!!!'
      );
    }
    const errors = [];

    if (
      !data.name ||
      typeof data.name !== 'string' ||
      !validator.isLength(data.name, { min: 1, max: 150 })
    ) {
      errors.push('Name invalid type STRING, or over length 150 chars!');
    }

    if (data.description && typeof data.description !== 'string') {
      errors.push('Description must be string!');
    }

    if (
      data.background &&
      (typeof data.background !== 'string' || !validator.isURL(data.background))
    ) {
      errors.push('Background must be a image url!');
    }

    if (errors.length > 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.FORBIDDEN,
        'Invalid data input!',
        { data: errors }
      );
    }

    return next();
  }

  updateInfo(req, res, next) {
    const data = req.body;
    if (!data || !typeof data === 'object' || Object.keys(data).length === 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.NOT_ACCEPTABLE,
        'Not have data to update board info!!!'
      );
    }
    const errors = [];

    if (
      data.name &&
      (typeof data.name !== 'string' ||
        !validator.isLength(data.name, { min: 1, max: 150 }))
    ) {
      errors.push('Name invalid type STRING, or over length 150 chars!');
    }

    if (data.description && typeof data.description !== 'string') {
      errors.push('Description must be string!');
    }

    if (
      data.background &&
      (typeof data.background !== 'string' || !validator.isURL(data.background))
    ) {
      errors.push('Background must be a image url!');
    }

    if (errors.length > 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.FORBIDDEN,
        'Invalid data input!',
        { data: errors }
      );
    }

    return next();
  }

  inviteMember(req, res, next) {
    const data = req.body;
    if (!data || !typeof data === 'object' || Object.keys(data).length === 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.NOT_ACCEPTABLE,
        'Not have data to invite user to board!!!'
      );
    }
    const errors = [];

    if (!data.email || !validator.isEmail(data.email)) {
      errors.push('Missing or Invalid Email!');
    }

    if (
      !data.role ||
      typeof data.role !== 'string' ||
      !Object.values(BoardRoles).includes(data.role)
    ) {
      errors.push('Missing or invalid role of user in board!');
    }

    if (errors.length > 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.FORBIDDEN,
        'Invalid data input!',
        { data: errors }
      );
    }

    return next();
  }

  acceptInvitation(req, res, next) {
    const data = req.params;
    if (!data || !typeof data === 'object' || Object.keys(data).length === 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.NOT_ACCEPTABLE,
        'Not have data to accept invitation of user to board!!!'
      );
    }
    const errors = [];

    if (!data.email || !validator.isEmail(data.email)) {
      errors.push('Missing or Invalid Email!');
    }

    if (!data.boardId || !validator.isMongoId(data.boardId)) {
      errors.push('Missing or Invalid Board!');
    }

    if (errors.length > 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.FORBIDDEN,
        'Invalid data input!',
        { data: errors }
      );
    }

    return next();
  }

  getListBoardUsers(req, res, next) {
    const boardId = req.params?.boardId;
    const errors = [];
    if (!boardId || !validator.isMongoId(boardId)) {
      errors.push('Missing or Invalid Board!');
    }

    if (errors.length > 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.FORBIDDEN,
        'Invalid data input!',
        { data: errors }
      );
    }

    return next();
  }

  updateMemberRole(req, res, next) {
    const boardId = req.params?.boardId;
    const data = req.body;
    if (!data || !typeof data === 'object' || Object.keys(data).length === 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.NOT_ACCEPTABLE,
        'Not have data to update role of user in board!!!'
      );
    }

    const errors = [];
    if (!boardId || !validator.isMongoId(boardId)) {
      errors.push('Missing or Invalid Board!');
    }

    if (!data.email || !validator.isEmail(data.email)) {
      errors.push('Missing or Invalid Email!');
    }

    if (
      !data.role ||
      typeof data.role !== 'string' ||
      !Object.values(BoardRoles).includes(data.role)
    ) {
      errors.push('Missing or invalid role of user in board!');
    }

    if (errors.length > 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.FORBIDDEN,
        'Invalid data input!',
        { data: errors }
      );
    }

    return next();
  }

  removeMember(req, res, next) {
    const boardId = req.params?.boardId;
    const email = req.params?.email;
    const errors = [];
    if (!boardId || !validator.isMongoId(boardId)) {
      errors.push('Missing or Invalid Board!');
    }

    if (!email || !validator.isEmail(email)) {
      errors.push('Missing or Invalid Email!');
    }

    if (errors.length > 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.FORBIDDEN,
        'Invalid data input!',
        { data: errors }
      );
    }

    return next();
  }

  leaveBoard(req, res, next) {
    const boardId = req.params?.boardId;
    const errors = [];
    if (!boardId || !validator.isMongoId(boardId)) {
      errors.push('Missing or Invalid Board!');
    }

    if (errors.length > 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.FORBIDDEN,
        'Invalid data input!',
        { data: errors }
      );
    }

    return next();
  }

  closeBoard(req, res, next) {
    const boardId = req.params?.boardId;
    const errors = [];
    if (!boardId || !validator.isMongoId(boardId)) {
      errors.push('Missing or Invalid Board!');
    }

    if (errors.length > 0) {
      return ResponseHandler.error(
        res,
        StatusCodes.FORBIDDEN,
        'Invalid data input!',
        { data: errors }
      );
    }
    return next();
  }
}

module.exports = { BoardsValidator: new BoardsValidator() };
