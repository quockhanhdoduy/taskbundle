const bcrypt = require('bcrypt');
const dotenv = require('dotenv');

dotenv.config();

const SALT_ROUNDS = parseInt(process.env.SALT_ROUNDS || '10', 10);

const hashPassword = async (password) => {
    if (!password) {
        throw new Error('Password is required');
    }

    const salt = await bcrypt.genSalt(SALT_ROUNDS);
    const hashedPassword = await bcrypt.hash(password, salt);
    return hashedPassword;
}

const comparePassword = async (password, hashedPassword) => {
    if (!password || !hashedPassword) {
        throw new Error('Password and hashed password are required');
    }

    return await bcrypt.compare(password, hashedPassword);
}

module.exports = {
    hashPassword,
    comparePassword,
}
