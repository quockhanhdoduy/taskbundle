const validator = require('validator');

const { ResponseHandler, StatusCodes } = require('../../utils');
const { verifyJWT } = require('./auth.jwt');
const { UserService } = require('../user/user.service');

class AuthMiddleware {
    async verifyToken(req, res, next) {
        const token = req.headers?.authorization;
        if (!token || typeof token !== 'string' || token.length === 0) {
            console.log('No token provided');
            return ResponseHandler.error(res, StatusCodes.UNAUTHORIZED, 'No token provided');
        }
        //Format: Bearer <token>
        const tokenData = token.split(' ');
        //Check format
        if (tokenData[0] !== 'Bearer') {
            return ResponseHandler.error(res, StatusCodes.UNAUTHORIZED, 'Invalid token format');
        }
        //check token
        try {
            const userInfo = verifyJWT(tokenData[1]);
            const user = await UserService.findOne({email: userInfo.email});
            if (!user) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'User not found');
            }
            //check verified user
            if (!user.isVerified) {
                return ResponseHandler.error(res, StatusCodes.UNAUTHORIZED, 'User not verified');
            }
            req.user = userInfo;
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.UNAUTHORIZED, 'Invalid token');
        }
        return next();
    }

    registerValidate(req, res, next) {
        const data = req.body;
        if(!data || typeof data !== 'object') {
            return ResponseHandler.error(res, StatusCodes.BAD_REQUEST, 'Not have data to register');
        }
        const errors = [];

        if(!data.email || !validator.isEmail(data.email)) {
            errors.push('Missing or invalid email');
        }

        if(!data.password || typeof data.password !== 'string' || !validator.isStrongPassword(data.password)) {
            // Strong password: minLength: 8, minLowercase: 1, minUppercase: 1, minNumbers: 1, minSymbols: 1
            errors.push('Not a strong password: minLength: 8, minLowercase: 1, minUppercase: 1, minNumbers: 1, minSymbols: 1');
        }

        if(!data.name || typeof data.name !== 'string' || !validator.isLength(data.name, {min: 1, max: 150})) {
            errors.push('Not have name, or invalid type STRING, or over length 150 chars!');
        }

        if (errors.length > 0) {
            return ResponseHandler.error(res, StatusCodes.BAD_REQUEST, {data: errors});
        }
        return next();
    }

    verifyUserValidate(req, res, next) {
        const data = req.body;
        if (!data || typeof data !== 'object') {
            return ResponseHandler.error(res, StatusCodes.BAD_REQUEST, 'Not have data to verify user');
        }
        const errors = [];

        if (!data.email || !validator.isEmail(data.email)) {
            errors.push('Missing or invalid email');
        }

        if (!data.code || typeof data.code !== 'number' || data.code.toString().length !== 6) {
            errors.push('Missing or invalid code');
        }

        if (errors.length > 0) {
            return ResponseHandler.error(res, StatusCodes.BAD_REQUEST, {data: errors});
        }
        return next();
    }

    loginValidate(req, res, next) {
        const data = req.body;
        if (!data || typeof data !== 'object') {
            return ResponseHandler.error(res, StatusCodes.BAD_REQUEST, 'Not have data to login');
        }

        const errors = [];

        if (!data.email || !validator.isEmail(data.email)) {
            errors.push('Missing or invalid email');
        }

        if (!data.password || typeof data.password !== 'string' || !validator.isStrongPassword(data.password)) {
            errors.push('Invalid password, cannot login!');
        }

        if (errors.length > 0) {
            return ResponseHandler.error(res, StatusCodes.BAD_REQUEST, {data: errors});
        }
        return next();
    }
}

module.exports = { AuthMiddleware: new AuthMiddleware() };