const nodemailer = require('nodemailer');
const { getVerificationMailTemplate, getOTPMailTemplate, inviteUserToBoardTemplate } = require('./email.templates');
const { env } = require('../../utils');

// Tạo transporter với Gmail SMTP
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: env.GMAIL_USER,
        pass: env.GMAIL_APP_PASSWORD
    }
});

/**
 * Email Service using Gmail SMTP
 */

const sendVerificationEmail = async (user, code) => {
    const template = getVerificationMailTemplate(user.name, code);

    const mailOptions = {
        from: `"TaskBundle" <${env.GMAIL_USER}>`,
        to: user.email,
        subject: '[TaskBundle] Verification Code',
        html: template,
    };

    try {
        const result = await transporter.sendMail(mailOptions);
        console.log('Verification email sent:', result.messageId);
        return result;
    } catch (error) {
        console.error('Send verification email failed:', error);
        throw new Error('Send verification email failed');
    }
}

const sendOTPMail = async (user, otp) => {
    const template = getOTPMailTemplate(user.name, otp);

    const mailOptions = {
        from: `"TaskBundle" <${env.GMAIL_USER}>`,
        to: user.email,
        subject: '[TaskBundle] OTP',
        html: template,
    };

    try {
        const result = await transporter.sendMail(mailOptions);
        console.log('OTP email sent:', result.messageId);
        return result;
    } catch (error) {
        console.error('Send OTP email failed:', error);
        throw new Error('Send OTP email failed');
    }
}

 /**
 * sendInviteToBoardEmail: Send an email to invite a user to a board!!!
 * @param {*} user Object - Invited User
 * @param {*} sender Object - Sender
 * @param {*} board Object - Board
 * @param {*} acceptUrl String - Url for user to accept
 * @returns data
 */
const sendInviteToBoardEmail = async (user, sender, board, acceptUrl) => {

    // Validation: Kiểm tra các parameters bắt buộc
    if (!user || !user.name || !user.email) {
        throw new Error('User object is invalid or missing name/email');
    }
    if (!sender || !sender.name) {
        throw new Error('Sender object is invalid or missing name');
    }
    if (!board || !board.name) {
        throw new Error('Board object is invalid or missing name');
    }
    if (!acceptUrl) {
        throw new Error('Accept URL is required');
    }

    const template = inviteUserToBoardTemplate(
        user.name,
        sender.name,
        board.name,
        acceptUrl
    );

    const mailOptions = {
        from: `"TaskBundle" <${env.GMAIL_USER}>`,
        to: user.email,
        subject: '[TaskBundle] Invite User To Board',
        html: template,
    };

    try {
        const result = await transporter.sendMail(mailOptions);
        console.log(`Invite User To Board Email sent: ${result.messageId}`);
        return result;
    } catch (error) {
        console.log(`Invite User To Board Email met error: ${JSON.stringify(error)}`);
        return null;
    }
};

 module.exports = { sendVerificationEmail, sendOTPMail, sendInviteToBoardEmail };
