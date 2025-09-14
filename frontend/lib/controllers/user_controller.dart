import 'package:get/get.dart';
import '../services/api_service.dart';
import '../config/api_endpoints.dart';

class UserController extends GetxController {
  var isLoading = false.obs;
  var userProfileData = <String, dynamic>{}.obs;
  var errorMessage = ''.obs;

  Future<Map<String, dynamic>?> loadUserProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await ApiService.get(ApiEndpoints.userProfile);

      if (result['success'] == true || result['status'] == 'success') {
        final data = Map<String, dynamic>.from(result['data'] ?? {});
        userProfileData.value = data;
        return data;
      } else {
        errorMessage.value = result['message'] ?? 'Failed to load profile';
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Connection error: ${e.toString()}';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> updateUserProfile(Map<String, dynamic> data) async {
    try {
      errorMessage.value = '';

      final result = await ApiService.put(ApiEndpoints.updateProfile, data);

      if (result['success'] == true || result['status'] == 'success') {
        final updatedData = Map<String, dynamic>.from(result['data'] ?? {});
        userProfileData.value = updatedData;
        return updatedData;
      } else {
        String errorMsg = result['message'] ?? 'Failed to update profile';

        if (errorMsg.contains('name') && errorMsg.contains('invalid')) {
          errorMsg = 'Invalid name format';
        } else if (errorMsg.contains('length')) {
          errorMsg = 'Name must be between 1-150 characters';
        }

        errorMessage.value = errorMsg;
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Connection error: ${e.toString()}';
      return null;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      errorMessage.value = '';

      final result = await ApiService.put(ApiEndpoints.changePassword, {
        'password': currentPassword,
        'new_password': newPassword,
      });

      if (result['success'] == true || result['status'] == 'success') {
        return true;
      } else {
        String errorMsg = result['message'] ?? 'Failed to change password';

        if (errorMsg.contains('Old password is incorrect') ||
            errorMsg.contains('incorrect') ||
            result['statusCode'] == 406) {
          errorMsg = 'Current password is incorrect';
        } else if (errorMsg.contains('password') && errorMsg.contains('weak')) {
          errorMsg = 'New password is not strong enough';
        } else if (errorMsg.contains('same')) {
          errorMsg = 'New password must be different from current password';
        }

        errorMessage.value = errorMsg;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Connection error: ${e.toString()}';
      return false;
    }
  }

  Future<bool> uploadAvatar(String imagePath) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      Get.snackbar('Info', 'Avatar upload feature coming soon!');
      return false;
    } catch (e) {
      errorMessage.value = 'Connection error: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> getUserStats() async {
    try {
      return {};
    } catch (e) {
      return {};
    }
  }
}