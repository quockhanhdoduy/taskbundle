const dotenv = require('dotenv');

dotenv.config();

const RESEND_API_KEY = process.env.RESEND_API_KEY;

module.exports = {
    RESEND_API_KEY,
};