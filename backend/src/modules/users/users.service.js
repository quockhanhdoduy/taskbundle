const moment = require("moment-timezone");

const  {UsersModel}  = require("./users.model");

class UsersService {
        /**
     * create: Create new user
     * @param {*} data Object
     * @returns user
     */
    async create(data) {
        try {
            const user = await UsersModel.create({...data});
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
        const user = await UsersModel.findOne(query);
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
        const users = await UsersModel.find(query);
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
        const verified = await UsersModel.updateOne(
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
   * verifyForgotPassword: Verify OTP for forgot password (user already verified)
   * @param {*} email String
   * @param {*} code Number
   * @returns Boolean
   */
  async verifyForgotPassword(email, code) {
    const user = await this.findOne({
        email,
        isVerified: true, // User đã verified rồi
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

    return true; // Chỉ verify OTP, không cần update isVerified
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

        if (data['verification.code']) {
            dataUpdate['verification.code'] = data['verification.code'];
        }
        if (data['verification.ttl']) {
            dataUpdate['verification.ttl'] = data['verification.ttl'];
        }
        if (data.password) {
            dataUpdate.password = data.password;
        }

        try {
            const updated = await UsersModel.findByIdAndUpdate(
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
            const changed = await UsersModel.updateOne(
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



}

module.exports = { UsersService: new UsersService() };