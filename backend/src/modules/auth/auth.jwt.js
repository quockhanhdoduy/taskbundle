const jwt = require('jsonwebtoken');
const { env } = require('../../utils/environment');

const jwtAlgorithm = 'HS256';

const generateJWT = (payload = {}) => {
    if (typeof payload !== 'object' || Object.keys(payload).length === 0) {
        throw new Error('Payload must be an object with at least one key');
    }

    const userInfo = {
        _id: payload._id,
        email: payload.email,
        name: payload.name,
        isVerified: payload.isVerified,
        createdAt: payload.createdAt,
        updatedAt: payload.updatedAt,
    }

    const token = jwt.sign(userInfo, env.JWT_SECRET, {
        expiresIn: env.JWT_EXPIRES_IN,
        algorithm: jwtAlgorithm,
    });

    const refreshToken = jwt.sign(userInfo, env.JWT_REFRESH_SECRET, {
        expiresIn: env.JWT_REFRESH_EXPIRES_IN,
        algorithm: jwtAlgorithm,
    });

    return { token, refreshToken };
};

const verifyJWT = (token = '') => {
    if (!token || !token.length) {
        throw new Error('Token is required');
    }

    const userInfo = jwt.verify(token, env.JWT_SECRET, {
        algorithms: [jwtAlgorithm],
    });

    return {
        _id: userInfo._id,
        email: userInfo.email,
        name: userInfo.name,
        isVerified: userInfo.isVerified,
        createdAt: userInfo.createdAt,
        updatedAt: userInfo.updatedAt,
    }
};

const verifyRefreshJWT = (refreshToken = '') => {
    if (!refreshToken || !refreshToken.length) {
        throw new Error('Refresh token is required');
    }

    const userInfo = jwt.verify(refreshToken, env.JWT_REFRESH_SECRET, {
        algorithms: [jwtAlgorithm],
    });

    return {
        email: userInfo.email,
    }
}

module.exports = { generateJWT, verifyJWT, verifyRefreshJWT };