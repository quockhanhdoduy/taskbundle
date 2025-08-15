const { UserService } = require("../users/users.service");
const { generateJWT, verifyRefreshJWT } = require("./auth.jwt");
const { ResponseHandler, StatusCodes , hashPassword, comparePassword} = require("../../utils");
const { sendVerificationEmail } = require("../../email/email.service");

class AuthController {
    async register(req, res) {
        const data = req.body;
        const existEmail = await UserService.findOne({email: data.email});
        if (existEmail) {
            return ResponseHandler.error(res, StatusCodes.BAD_REQUEST, "Email already exists");
        }
        try {
            const hashed = await hashPassword(data.password);
            data.password = hashed;

            const user = await UserService.create(data);

            sendVerificationEmail(user.email, user._id);

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
            const user = await UserService.verifyUser(data.email, data.code);
            return ResponseHandler.success(res, StatusCodes.OK, { success });
        } catch (error) {
            return ResponseHandler.error(res, StatusCodes.INTERNAL_SERVER_ERROR, error.message);
        }
    }

    async login(req, res) {
        const data = req.body;
        try {
            const user = await UserService.findOne({
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
            const user = await UserService.findOne({
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
