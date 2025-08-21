const { env } = require('../../utils');

const RESEND_API_KEY = env.EMAIL_RESEND_API_KEY || 're_xxxxxxxxx';

module.exports = {
    RESEND_API_KEY,
};