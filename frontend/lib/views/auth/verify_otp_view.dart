import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../controllers/auth_controller.dart';
import '../../config/routes.dart';

class VerifyOTPView extends StatefulWidget {
  final String email;
  final String source; // 'register' or 'forgot_password'

  const VerifyOTPView({
    super.key,
    required this.email,
    this.source = 'register', // Default to register
  });

  @override
  State<VerifyOTPView> createState() => _VerifyOTPViewState();
}

class _VerifyOTPViewState extends State<VerifyOTPView> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Clear any previous messages when entering verify OTP page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authController.clearMessages();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                         MediaQuery.of(context).padding.top - 40,
            ),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Back button and Logo
                    Row(
                      children: [
                        GestureDetector(
                          onTap: AppRoutes.back,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'TaskBundle',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Title text
                    Text(
                      'Verify',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Code,',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description text
                    Text(
                      'Please enter the verification code we sent to ${widget.email}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // OTP field
                    CustomTextField(
                      label: 'Verification Code',
                      hint: 'Enter 6-digit code',
                      controller: _otpController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mã xác thực';
                        }
                        if (value.length != 6) {
                          return 'Mã xác thực phải có 6 chữ số';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Mã xác thực chỉ chứa số';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Resend code link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the code? ",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: _resendCode,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Resend',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Flexible space
                    const Spacer(),

                    // Message display
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Obx(() {
                        final hasError = _authController.errorMessage.value.isNotEmpty;
                        final hasSuccess = _authController.successMessage.value.isNotEmpty;
                        if (!hasError && !hasSuccess) return const SizedBox.shrink();

                        final isError = hasError;
                        final text = isError ? _authController.errorMessage.value : _authController.successMessage.value;
                        final bgColor = isError ? Colors.red.shade50 : Colors.green.shade50;
                        final borderColor = isError ? Colors.red.shade200 : Colors.green.shade200;
                        final iconColor = isError ? Colors.red.shade600 : Colors.green.shade600;
                        final textColor = isError ? Colors.red.shade700 : Colors.green.shade700;
                        final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: bgColor,
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(icon, color: iconColor, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(text, style: TextStyle(color: textColor, fontSize: 14))),
                            ],
                          ),
                        );
                      }),
                    ),

                    // Verify button
                    Obx(() => CustomButton(
                      text: 'Verify Code',
                      fullWidth: true,
                      isLoading: _authController.isLoading.value,
                      onPressed: _handleVerifyOTP,
                    )),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleVerifyOTP() async {
    if (_formKey.currentState!.validate()) {
      // Verify OTP with backend first - use different method depending on source
      bool success;
      if (widget.source == 'forgot_password') {
        success = await _authController.verifyForgotPassword(
          widget.email,
          _otpController.text.trim(),
        );
      } else {
        success = await _authController.verifyEmail(
          widget.email,
          _otpController.text.trim(),
        );
      }

      if (success) {
        // After successful verification, navigate based on source
        Future.delayed(const Duration(seconds: 1), () {
          if (widget.source == 'forgot_password') {
            // From forgot password → go to change password
            Get.toNamed('/change-password', arguments: {
              'email': widget.email,
              'otp': _otpController.text.trim(),
            });
          } else {
            // From register → return to login
            AppRoutes.toLogin();
          }
        });
      }
    }
  }

  void _resendCode() {
    if (widget.source == 'forgot_password') {
      // Resend OTP for forgot password
      _authController.forgotPassword(widget.email);
    } else {
      // Resend verification code for register by calling register again
      _authController.resendVerificationCode(widget.email);
    }
  }
}
