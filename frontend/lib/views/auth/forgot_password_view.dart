import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/validators.dart';
import '../../config/routes.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Clear any previous messages when entering forgot password page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authController.clearMessages();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
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
                      'Reset',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Password,',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description text
                    Text(
                      'The verification code will be sent to your mailbox. Please check it',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Email field
                    CustomTextField(
                      label: 'Email',
                      hint: 'ex: example@email.com',
                      controller: _emailController,
                      validator: Validators.email,
                    ),

                    // Flexible space
                    const Spacer(),

                    // Reset Password button
                    Obx(() => CustomButton(
                      text: 'Reset Password',
                      fullWidth: true,
                      isLoading: _authController.isLoading.value,
                      onPressed: _handleResetPassword,
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

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      bool success = await _authController.forgotPassword(
        _emailController.text.trim(),
      );

      if (success) {
        // Navigate to verify OTP with forgot_password source
        Future.delayed(const Duration(seconds: 1), () {
          AppRoutes.toVerifyOTP(_emailController.text.trim(), source: 'forgot_password');
        });
      }
    }
  }
}
