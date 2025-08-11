const moment = require("moment-timezone");

const { UserModel } = require("./users.model");
const { UsersOTPModel } = require("./users-otp.model");

class UserService {
        /**
     * create: Create new user
     * @param {*} data Object
     * @returns user
     */
    async create(data) {
        try {
            const user = await UserModel.create(data);
            return user;
        } catch (error) {
            throw new Error(
                error.message || "Error creating user"
            );
        }
    }

    /**
     * findOne: Find a user by filters
     * @param {*} filters Object
     * @returns user
     */
    async findOne(filters = {}) {
        const query = {isDeleted: false}; // only active users

        if (filters._id) {
            query._id = filters._id;
    }
    if (filters.email) {
        query.email = filters.email;
    }
    if (filters.name) {
        query.name = { $regex: filters.name, $options: "i"}; // case insensitive
    }
    if (filters.isVerified || filters.isVerified === false) {
        query.isVerified = filters.isVerified;
    }
    // Find data base on time filter:
    if (filters.from_time || filters.to_time) {
        query.createdAt = {};
        if (filters.from_time) query.createdAt.$gte = filters.from_time;
        if (filters.to_time) query.createdAt.$lte = filters.to_time;
    }

    try {
        const user = await UserModel.findOne(query);
        return user;
    } catch (error) {
        throw new Error(
            error.message || "Error finding user"
        );
    }
    }

    /**
     * findMany: Get a list of users by filters
     * @param {*} filters Object
     * @returns users
     */
    async findMany(filters = {}) {
        const query = {isDeleted: false}; // only active users

    if (filters._id) {
            query._id = filters._id;
    }
    if (filters.email) {
        query.email = filters.email;
    }
    if (filters.name) {
        query.name = { $regex: filters.name, $options: "i"}; // case insensitive
    }
    if (filters.isVerified || filters.isVerified === false) {
        query.isVerified = filters.isVerified;
    }
    // Find data base on time filter:
    if (filters.from_time || filters.to_time) {
        query.createdAt = {};
        if (filters.from_time) query.createdAt.$gte = filters.from_time;
        if (filters.to_time) query.createdAt.$lte = filters.to_time;
    }

    try {
        const users = await UserModel.find(query);
        return users;
    } catch (error) {
        throw new Error(
            error.message || "Error finding user"
        );
    }
    }

    /**
   * verifyUser: Verify account for new user
   * @param {*} email String
   * @param {*} code String
   * @returns Boolean
   */
  async verifyUser(email, code) {
    const user = await this.findOne({
        email,
        isVerified: false,
        isDeleted: false,
    });

    if (!user) {
        throw new Error("User not found");
    }

    if (user.verification.code !== code) {
        throw new Error("Invalid verification code");
    }

    const current = moment().unix();

    if (user.verification.ttl < current) {
        throw new Error("Verification code expired");
    }

    try {
        const verified = await UserModel.UpdateOne(
            {email},
            {isVerified: true},
        );

        if (verified.modifiedCount <= 0) {
            throw new Error("Error verifying user");
        }

        return true;
    } catch (error) {
        throw new Error(
            error.message || "Error verifying user"
        );
    }
  }

    /**
   * updateOne: Update user general info
   * @param {*} _id String
   * @param {*} data Object
   * @returns user
   */

    async updateOne(_id, data) {
        const dataUpdate = {}

        if (data.name) {
            dataUpdate.name = data.name;
        }

        try {
            const updated = await UserModel.findByIdAndUpdate(
                _id,
                { ...dataUpdate },
                {new: true, select: "-password"});
        return updated;
        } catch (error) {
            throw new Error(
                error.message || "Error updating user"
            );
        }
    }

    /**
   * changePassword: Change user password
   * @param {*} _id String
   * @param {*} newPassword String
   * @returns Boolean
   */

    async changePassword(_id, newPassword) {
        try {
            const changed = await UserModel.UpdateOne(
                {_id},
                {password: newPassword},
            );

            if (changed.modifiedCount <= 0) {
                throw new Error("Error changing password");
            }

            return true;
        } catch (error) {
            throw new Error(
                error.message || "Error changing password"
            );
        }
    }

    /**
   * generateOtp: Generate otp to renew password
   * @param {*} userID String
   * @returns otp
   */

    async generateOtp(userID) {
        try {
            const otp = await UsersOTPModel.findOneAndUpdate(
                {user: userID},
                {
                    otp: Math.floor(100000 + Math.random() * 900000),
                    ttl: moment().add(15, "minutes").unix(),
                },
                {new: true, upsert: true},
            );

            return otp;
        } catch (error) {
            throw new Error(
                error.message || "Error generating otp"
            );
        }
    }

    /**
   * findOneUserOTP: Find user otp to verify change password
   * @param {*} userID String
   * @returns otp
   */

    async findOneUserOTP(userID) {
        try {
            const rs = await UsersOTPModel.findOne({user: userID}, otp);
            return rs;
        } catch (error) {
            throw new Error(
                error.message || "Error finding user otp"
            );
        }
    }

     /**
   * removeOTP: After change password with otp -> remove user otp
   * @param {*} userID String
   * @returns Boolean
   */
  async removeOTP(userID) {
    try {
      const otp = await UsersOTPModel.deleteOne({ user: userID });
      return otp;
    } catch (error) {
      throw new Error(
        error.message || 'removeOTP met: Internal Server Error!!!'
      );
    }
  }
}

module.exports = { UserService: new UserService() };