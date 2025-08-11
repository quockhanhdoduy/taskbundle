const moment = require('moment-timezone');

const { UserService } = require('./users.service');
const { hashPassword, comparePassword } = require('../../utils/password.util');
const { ResponseHandler, StatusCodes } = require('../../utils/response-handler.util');
const { sendVerificationEmail} = require('../email/email.service');

class UsersController {
    async viewMyProfile(req, res) {
        const user = req.user;
        return ResponseHandler.success(res, StatusCodes.OK, user);
    }

    async updateMyProfile(req, res) {
        const user = req.user;
        const data = req.body;
        try {
            const updated = await UserService.updateOne(user._id, data);
            return ResponseHandler.success(res, StatusCodes.OK, updated);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async changePassword(req, res) {
        const user = req.user;
        const data = req.body;
        try {
            const existUser = await UserService.findOne({_id: user._id});
            if (!existUser) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'User not found');
            }

            const isMatch = await comparePassword(data.oldPassword, existUser.password);
            if (!isMatch) {
                return ResponseHandler.error(res, StatusCodes.NOT_ACCEPTABLE, 'Old password is incorrect');
            }
            const newHashedPassword = await hashPassword(data.newPassword);
            const changed = await UserService.changePassword(user._id, newHashedPassword);

            return ResponseHandler.success(res, StatusCodes.OK, {success: changed});
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async forgotPassword(req, res) {
        const data = req.body;
        try {
            const user = await UserService.findOne({email: data.email , isVerified: true});
            if (!user) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'User not found');
            }
            const otp = await UserService.generateOtp(user._id);

            console.log(`OTP: ${otp.otp}`);
            sendOTPMail(user, otp.otp);

            return ResponseHandler.success(res, StatusCodes.OK, {success: true});
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async changePasswordWithOTP(req, res) {
        const data = req.body;
        try {
            const user = await UserService.findOne({email: data.email, isVerified: true});
            if (!user) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'User not found');
            }
            const otp = await UserService.findOneUserOTP({user: user._id, otp: data.otp});
            if (!otp) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'OTP not found');
            }

            const current = moment().unix();
            if (current > otp.ttl) {
                return ResponseHandler.error(res, StatusCodes.BAD_REQUEST, 'OTP expired');
            }

            const newHashedPassword = await hashPassword(data.newPassword);
            const changed = await UserService.changePassword(user._id, newHashedPassword);

            await UserService.removeOTP(user._id);

            return ResponseHandler.success(res, StatusCodes.OK, {success: changed});
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);

        }
    }

    async viewUserGeneralInfo(req, res) {
        const user = req.user;
        try {
            const userInfo = await UserService.findOne({_id: user._id});
            if (!userInfo) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'User not found');
            }

            const result = {
                _id: userInfo._id,
                email: userInfo.email,
                name: userInfo.name,
                isVerified: userInfo.isVerified,
                createdAt: userInfo.createdAt,
                updatedAt: userInfo.updatedAt,
            }

            return ResponseHandler.success(res, StatusCodes.OK, userInfo);

        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }
}








