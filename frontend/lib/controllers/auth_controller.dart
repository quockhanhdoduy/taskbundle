import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../config/api_endpoints.dart';

class AuthController extends GetxController {
  final _storageService = StorageService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var successMessage = ''.obs;
  var isAuthenticated = false.obs;

  // Clear all messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  // Force clear messages (for navigation)
  void forceCleanState() {
    clearMessages();
    isLoading.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    _checkToken();
  }

  // Check if response indicates success
  bool _isSuccess(Map<String, dynamic> result) {
    try {
      var success = result['success'];
      var status = result['status'];
      if (success == true || status == 'success') return true;

      var data = result['data'];
      if (data is Map && data['success'] == true) return true;

      return false;
    } catch (e) {
      return false;
    }
  }

  // Get error message from response
  String _getErrorMessage(Map<String, dynamic> result, [String defaultMessage = 'Operation failed']) {
    try {
      // First check if it's an error status response (backend format)
      var status = result['status'];
      if (status is String && status.toLowerCase() == 'error') {
        var message = result['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
        // Handle case where message is an object with data array (validation errors)
        if (message is Map<String, dynamic> && message['data'] is List) {
          List<String> errors = List<String>.from(message['data']);
          if (errors.any((error) => error.contains('Invalid password, cannot login!'))) {
            return 'Invalid password';
          }
          return errors.join(', ');
        }
      }

      // Check for message field directly
      var message = result['message'];
      if (message is String && message.isNotEmpty && message.toLowerCase() != 'success') {
        // Special handling for password validation error
        if (message.contains('Invalid password, cannot login!')) {
          return 'Invalid password';
        }
        return message;
      }

      // Check for error field (could contain detailed errors)
      var error = result['error'];
      if (error is Map<String, dynamic>) {
        var errorMessage = error['message'];
        if (errorMessage is String && errorMessage.isNotEmpty) {
          return errorMessage;
        }
        // Check if error contains data array
        var errorData = error['data'];
        if (errorData is List && errorData.isNotEmpty) {
          List<String> errors = List<String>.from(errorData);
          if (errors.any((err) => err.contains('Invalid password, cannot login!'))) {
            return 'Invalid password';
          }
          return errors.join(', ');
        }
      }

      // Check data field for nested message or error array
      var data = result['data'];
      if (data is List && data.isNotEmpty) {
        // Handle validation error arrays from backend
        // Special handling for password validation error during login
        List<String> errors = List<String>.from(data);
        if (errors.any((error) => error.contains('Invalid password, cannot login!'))) {
          return 'Invalid password';
        }
        return errors.join(', ');
      } else if (data is Map) {
        var dataMessage = data['message'];
        if (dataMessage is String && dataMessage.isNotEmpty) {
          return dataMessage;
        }
      }

      return defaultMessage;
    } catch (e) {
      return defaultMessage;
    }
  }

  Future<void> _checkToken() async {
    final token = await _storageService.getToken();
    if (token != null) {
      ApiService.setToken(token);
      isAuthenticated.value = true;
    } else {
      isAuthenticated.value = false;
    }
  }


  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final result = await ApiService.post(ApiEndpoints.authLogin, {
        'email': email,
        'password': password,
      });


      if (_isSuccess(result)) {
        // Save tokens
        String token = result['data']['token'] ?? result['data']['accessToken'];
        await _storageService.saveToken(token);
        if (result['data']['refreshToken'] != null) {
          await _storageService.saveRefreshToken(result['data']['refreshToken']);
        }
        ApiService.setToken(token);

        // Save user data if available
        if (result['data']['user'] != null) {
          await _storageService.saveUserData(result['data']['user']);
        }

        isAuthenticated.value = true;
        successMessage.value = 'Login successful!';
        return true;
      } else {
        errorMessage.value = _getErrorMessage(result, 'Login failed');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Connection error: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }


  Future<bool> register(String email, String password, String displayName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final result = await ApiService.post(ApiEndpoints.authRegister, {
        'email': email,
        'password': password,
        'name': displayName,
      });

      if (_isSuccess(result)) {
        successMessage.value = 'Registration successful!';
        return true;
      } else {
        errorMessage.value = _getErrorMessage(result, 'Register failed');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Connection error: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyEmail(String email, String otp) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      // Validate OTP format before parsing
      if (otp.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(otp)) {
        errorMessage.value = 'Verification code must be 6 digits';
        return false;
      }

      final result = await ApiService.put(ApiEndpoints.authVerification, {
        'email': email,
        'code': int.parse(otp),
      });

      if (_isSuccess(result)) {
        successMessage.value = 'Email verification successful';
        return true;
      } else {
        errorMessage.value = _getErrorMessage(result, 'Email verification failed');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Connection error: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Gửi lại verification code cho register bằng cách gọi lại register endpoint
  Future<bool> resendVerificationCode(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      // Gọi register endpoint để gửi lại verification code
      // Backend sẽ kiểm tra email đã tồn tại và chỉ gửi lại email
      final result = await ApiService.post(ApiEndpoints.authRegister, {
        'email': email,
        'password': 'Temp123!@#', // Password mạnh tạm thời, backend sẽ bỏ qua nếu email đã tồn tại
        'name': 'Resend User', // Name tạm thời
      });

      if (_isSuccess(result)) {
        successMessage.value = 'Verification code has been resent';
        return true;
      } else {
        errorMessage.value = _getErrorMessage(result, 'Failed to resend code');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Connection error: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
    ApiService.clearToken();

    // Clear all states
    isAuthenticated.value = false;
    clearMessages();

    Get.offAllNamed('/login');
  }

  // Verify forgot password OTP
  Future<bool> verifyForgotPassword(String email, String otp) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      if (otp.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(otp)) {
        errorMessage.value = 'Verification code must be 6 digits';
        return false;
      }

      final result = await ApiService.put(ApiEndpoints.userVerifyForgotPassword, {
        'email': email,
        'code': int.parse(otp),
      });

      if (_isSuccess(result)) {
        successMessage.value = 'OTP verification successful';
        return true;
      } else {
        errorMessage.value = _getErrorMessage(result, 'OTP verification failed');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Connection error: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Forgot password
  Future<bool> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final result = await ApiService.post(ApiEndpoints.userForgotPassword, {
        'email': email,
      });

      if (_isSuccess(result)) {
        successMessage.value = 'Verification code has been sent to your email. Please check your inbox.';
        return true;
      } else {
        errorMessage.value = _getErrorMessage(result, 'Forgot password failed');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Connection error: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password with OTP
  Future<bool> resetPasswordWithOTP(String email, String otp, String newPassword) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Sử dụng endpoint reset password mới - verify OTP + đổi password trong 1 lần
      final result = await ApiService.post(ApiEndpoints.userResetPassword, {
        'email': email,
        'code': int.parse(otp),
        'newPassword': newPassword,
      });

      if (_isSuccess(result)) {
        successMessage.value = 'Password changed successfully';
        // Chuyển về trang login sau khi đổi mật khẩu thành công
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAllNamed('/login');
        });
        return true;
      } else {
        errorMessage.value = _getErrorMessage(result, 'Change password failed');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Connection error: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) {
        errorMessage.value = 'No refresh token available';
        return false;
      }

      final result = await ApiService.post(ApiEndpoints.authRefreshLogin, {
        'refreshToken': refreshToken,
      });

      if (result['status'] == 'success' || result['success'] == true) {
        // Save new tokens
        await _storageService.saveToken(result['data']['accessToken']);
        if (result['data']['refreshToken'] != null) {
          await _storageService.saveRefreshToken(result['data']['refreshToken']);
        }
        ApiService.setToken(result['data']['accessToken']);

        isAuthenticated.value = true;

        return true;
      } else {
        errorMessage.value = _getErrorMessage(result, 'Token refresh failed');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Connection error: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }


}
