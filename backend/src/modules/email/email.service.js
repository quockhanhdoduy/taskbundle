const { Resend } = require('resend');
const { RESEND_API_KEY } = require('./email.const');
const { getVerificationMailTemplate, getOTPMailTemplate } = require('./email.templates');

const resend = new Resend(RESEND_API_KEY);

/**
 You can only send testing emails to your own email address [The email registered to resend (ex: quockhanh.qkdd@gmail.com)].
 To send emails to other recipients, please verify a domain at resend.com/domains,
 and change the `from` address to an email using this domain.
 */

 const sendVerificationEmail = async (user, code) => {
    const template = getVerificationMailTemplate(user.name, code);
    const { data, error } = await resend.emails.send({
        from: '"TaskBundle" <onboarding@resend.dev>',
        to: [user.email],
        subject: '[TaskBundle] Verification Code',
        html: template,
    });

    if (error) {
        throw new Error('Send verification email failed');
    }

    return data;
 }

 const sendOTPMail = async (user, otp) => {
    const template = getOTPMailTemplate(user.name, otp);
    const { data, error } = await resend.emails.send({
        from: '"TaskBundle" <onboarding@resend.dev>',
        to: [user.email],
        subject: '[TaskBundle] OTP',
        html: template,
    });

    if (error) {
        throw new Error('Send OTP email failed');
    }

    return data;
 }

 module.exports = { sendVerificationEmail, sendOTPMail };
