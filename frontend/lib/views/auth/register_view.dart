import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_password_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/validators.dart';
import '../../config/routes.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Clear any previous messages when entering register page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authController.clearMessages();
    });
  }


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

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

                    // Logo and App name
                    Row(
                      children: [
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

                    const SizedBox(height: 32),

                    // Title text
                    Text(
                      'Create New',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Account,',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Name field
                    CustomTextField(
                      label: 'Name',
                      hint: 'ex: Harry Potter',
                      controller: _nameController,
                      validator: Validators.name,
                    ),

                    const SizedBox(height: 18),

                    // Email field
                    CustomTextField(
                      label: 'Email',
                      hint: 'ex: example@email.com',
                      controller: _emailController,
                      validator: Validators.email,
                    ),

                    const SizedBox(height: 18),

                    // Password field
                    CustomPasswordField(
                      label: 'Password',
                      hint: 'Strong password (8+ chars, A-z, 0-9, !@#)',
                      controller: _passwordController,
                      validator: Validators.password,
                    ),

                    // Flexible space - co giãn theo bàn phím
                    SizedBox(height: keyboardHeight > 0 ? 12 : 16),
                      Container(
                        height: 40, // fixed height
                        margin: const EdgeInsets.only(bottom: 6),
                      alignment: Alignment.center,
                      child: Obx(() {
                        // Show success message
                        if (_authController.successMessage.value.isNotEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              border: Border.all(color: Colors.green.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _authController.successMessage.value,
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        // Show error message
                        else if (_authController.errorMessage.value.isNotEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              border: Border.all(color: Colors.red.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _authController.errorMessage.value,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        // Empty space when no message
                        return const SizedBox.shrink();
                      }),
                    ),

                    // Create Account button
                    Obx(() => CustomButton(
                      text: 'Create Account',
                      fullWidth: true,
                      isLoading: _authController.isLoading.value,
                      onPressed: _handleRegister,
                    )),

                    const SizedBox(height: 16),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have account? ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: AppRoutes.toLogin,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      // Clear previous messages safely after current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _authController.errorMessage.value = '';
        _authController.successMessage.value = '';
      });

      bool success = await _authController.register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      // Navigate to verify OTP if registration successful
      if (success) {
        Future.delayed(const Duration(seconds: 2), () {
          AppRoutes.toVerifyOTP(_emailController.text.trim());
        });
      }
    }
  }
}