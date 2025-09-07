import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/common/custom_password_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/validators.dart';
import '../../config/routes.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  late final String email;
  late final String otp;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    email = args['email'] ?? '';
    otp = args['otp'] ?? '';
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

                    Text(
                      'Create New',
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

                    Text(
                      'Your new password must be different from previously used passwords',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 40),

                    CustomPasswordField(
                      label: 'New Password',
                      hint: 'Strong password (8+ chars, A-z, 0-9, !@#)',
                      controller: _passwordController,
                      validator: Validators.password,
                    ),

                    const SizedBox(height: 18),

                    CustomPasswordField(
                      label: 'Confirm New Password',
                      hint: 'Re-enter your new password',
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng xác nhận mật khẩu';
                        }
                        if (value != _passwordController.text) {
                          return 'Mật khẩu xác nhận không khớp';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Obx(() => CustomButton(
                      text: 'Change Password',
                      fullWidth: true,
                      isLoading: _authController.isLoading.value,
                      onPressed: _handleChangePassword,
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

  void _handleChangePassword() {
    if (_formKey.currentState!.validate()) {
      _authController.resetPasswordWithOTP(
        email,
        otp,
        _passwordController.text,
      );
    }
  }
}


