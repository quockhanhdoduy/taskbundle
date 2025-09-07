import 'package:get/get.dart';
import '../services/api_service.dart';
import '../config/api_endpoints.dart';

class UserController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;


  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      return await ApiService.get(ApiEndpoints.userProfile);
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
      Get.snackbar('Lỗi', errorMessage.value);
      return {'success': false, 'message': errorMessage.value};
    } finally {
      isLoading.value = false;
    }
  }

  // Lấy thông tin user công khai
  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      return await ApiService.get(ApiEndpoints.userInfo(userId));
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
      Get.snackbar('Lỗi', errorMessage.value);
      return {'success': false, 'message': errorMessage.value};
    } finally {
      isLoading.value = false;
    }
  }

  // Đổi mật khẩu
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await ApiService.put(ApiEndpoints.userChangePassword, {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });

      if (result['status'] == 'success' || result['success'] == true) {
        Get.snackbar('Thành công', 'Đổi mật khẩu thành công');
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Đổi mật khẩu thất bại';
        Get.snackbar('Lỗi', errorMessage.value);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
      Get.snackbar('Lỗi', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Quên mật khẩu - gửi OTP
  Future<bool> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await ApiService.post(ApiEndpoints.userForgotPassword, {
        'email': email,
      });

      if (result['status'] == 'success' || result['success'] == true) {
        Get.snackbar('Thành công', 'OTP đã được gửi đến email của bạn');
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Gửi OTP thất bại';
        Get.snackbar('Lỗi', errorMessage.value);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
      Get.snackbar('Lỗi', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }


}
