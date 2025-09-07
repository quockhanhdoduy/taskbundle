const { UsersService } = require("../users/users.service");
const { generateJWT, verifyRefreshJWT } = require("./auth.jwt");
const { ResponseHandler, StatusCodes , hashPassword, comparePassword} = require("../../utils");
const { sendVerificationEmail } = require("../email/email.service");
const moment = require('moment');

class AuthController {
    async register(req, res) {
        const data = req.body;
        const existEmail = await UsersService.findOne({email: data.email});

        if (existEmail) {
            // Nếu email đã tồn tại, tạo mã mới và gửi lại verification code
            try {
                // Tạo mã mới và cập nhật TTL
                const newCode = Math.floor(100000 + Math.random() * 900000);
                const newTtl = moment().add(15, 'minute').unix();

                // Cập nhật mã mới vào database
                await UsersService.updateOne(
                    existEmail._id,
                    {
                        'verification.code': newCode,
                        'verification.ttl': newTtl
                    }
                );

                // Gửi email với mã mới
                await sendVerificationEmail(existEmail, newCode);
                return ResponseHandler.success(res, StatusCodes.OK, "Verification code sent successfully", {
                    success: true,
                    email: existEmail.email
                });
            } catch (e) {
                console.log('Skip email error in resend:', e?.message || e);
                return ResponseHandler.success(res, StatusCodes.OK, "Verification code sent successfully", {
                    success: true,
                    email: existEmail.email
                });
            }
        }

        try {
            const hashed = await hashPassword(data.password);
            data.password = hashed;

            const user = await UsersService.create(data);
            // Try to send verification email but do not block registration
            try {
                await sendVerificationEmail(user, user.verification.code);
            } catch (e) {
                console.log('Skip email error in register:', e?.message || e);
            }

            return ResponseHandler.success(res, StatusCodes.CREATED, "User created successfully", {
                success: true,
                email: user.email
            });
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async verifyUser(req, res) {
        const data = req.body;
        try {
            const user = await UsersService.verifyUser(data.email, data.code);
            return ResponseHandler.success(res, StatusCodes.OK, "User verified successfully", { success: true });
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async login(req, res) {
        const data = req.body;
        try {
            const user = await UsersService.findOne({
                email: data.email,
                isVerified: true,
                });
            if (!user) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, "User not found");
            }

            const matched = await comparePassword(data.password, user.password);
            if (!matched) {
                return ResponseHandler.error(res, StatusCodes.UNAUTHORIZED, "Invalid password");
            }

            const token = generateJWT(user);
            return ResponseHandler.success(res, StatusCodes.CREATED, {...token});
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message || 'Login failed');
        }
    }

    async refreshLogin(req, res) {
        const data = req.body;
        if(!data?.refreshToken || !data?.refreshToken?.length) {
            return ResponseHandler.error(res, StatusCodes.FORBIDDEN, "Refresh token is required");
        }
        try {
            const decode = verifyRefreshJWT(data.refreshToken);
            const user = await UsersService.findOne({
                email: decode.email,
                isVerified: true,
            });
            if (!user) {
                return ResponseHandler.error(res, StatusCodes.NOT_FOUND, "User not found");
            }

            const token = generateJWT(user);
            return ResponseHandler.success(res, StatusCodes.CREATED, {...token});
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message || 'Refresh token is invalid');
        }
    }

}

module.exports = { AuthController: new AuthController() };
