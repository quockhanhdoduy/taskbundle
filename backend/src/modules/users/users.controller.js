const moment = require('moment-timezone');

const { UsersService } = require('./users.service');
const { hashPassword, comparePassword } = require('../../utils/password.util');
const { ResponseHandler, StatusCodes } = require('../../utils/response-handler.util');
const { sendVerificationEmail } = require('../email/email.service');

class UsersController {
    async viewMyProfile(req, res) {
        const user = req.user;
        return ResponseHandler.success(res, StatusCodes.OK, user);
    }

    async updateMyProfile(req, res) {
        const user = req.user;
        const data = req.body;
        try {
            const updated = await UsersService.updateOne(user._id, data);
            return ResponseHandler.success(res, StatusCodes.OK, updated);
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async changePassword(req, res) {
        const user = req.user;
        const data = req.body;
        try {
            const existUser = await UsersService.findOne({_id: user._id});
            if (!existUser) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, 'User not found');
            }

            const isMatch = await comparePassword(data.password, existUser.password);
            if (!isMatch) {
                return ResponseHandler.error(res, StatusCodes.NOT_ACCEPTABLE, 'Old password is incorrect');
            }
            const newHashedPassword = await hashPassword(data.new_password);
            const changed = await UsersService.changePassword(user._id, newHashedPassword);

            return ResponseHandler.success(res, StatusCodes.OK, {success: changed});
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }



    async viewUserGeneralInfo(req, res) {
        const user = req.user;
        try {
            const userInfo = await UsersService.findOne({_id: user._id});
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

            return ResponseHandler.success(res, StatusCodes.OK, result);

        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async forgotPassword(req, res) {
        const data = req.body;
        if (!data?.email) {
            return ResponseHandler.error(res, StatusCodes.BAD_REQUEST, "Email is required");
        }

        try {
            const user = await UsersService.findOne({email: data.email});
            if (!user) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, "User not found");
            }

            // Tạo mã mới và cập nhật TTL
            const newCode = Math.floor(100000 + Math.random() * 900000);
            const newTtl = moment().add(15, 'minute').unix();

            // Cập nhật mã mới vào database
            await UsersService.updateOne(
                user._id,
                {
                    'verification.code': newCode,
                    'verification.ttl': newTtl
                }
            );

            // Gửi OTP email với mã mới (không block nếu lỗi email)
            try {
                await sendVerificationEmail(user, newCode);
            } catch (e) {
                console.log('Skip email error in forgot password:', e?.message || e);
            }

            return ResponseHandler.success(res, StatusCodes.OK, "OTP sent successfully", {
                success: true,
                email: user.email
            });
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async verifyForgotPassword(req, res) {
        const data = req.body;
        if (!data?.email || !data?.code) {
            return ResponseHandler.error(res, StatusCodes.BAD_REQUEST, "Email and code are required");
        }

        try {
            const result = await UsersService.verifyForgotPassword(data.email, data.code);
            if (result) {
                return ResponseHandler.success(res, StatusCodes.OK, "OTP verified successfully", {
                    success: true,
                    email: data.email
                });
            }
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.BAD_REQUEST, error.message);
        }
    }

    async resetPassword(req, res) {
        const data = req.body;
        if (!data?.email || !data?.code || !data?.newPassword) {
            return ResponseHandler.error(res, StatusCodes.BAD_REQUEST, "Email, code and new password are required");
        }

        try {
            await UsersService.verifyForgotPassword(data.email, data.code);

            const hashedPassword = await hashPassword(data.newPassword);

            // Tìm user bằng email để lấy _id
            const user = await UsersService.findOne({ email: data.email });
            if (!user) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, "User not found");
            }

            const updated = await UsersService.updateOne(
                user._id,
                { password: hashedPassword }
            );

            if (updated) {
                return ResponseHandler.success(res, StatusCodes.OK, "Password reset successfully", {
                    success: true,
                    email: data.email
                });
            } else {
                return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, "Failed to reset password");
            }
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.BAD_REQUEST, error.message);
        }
    }
}

module.exports = { UsersController: new UsersController() };









