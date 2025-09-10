import 'package:get/get.dart';
import '../services/api_service.dart';
import '../config/api_endpoints.dart';

class UserController extends GetxController {
  var isLoading = false.obs;
  var userProfileData = <String, dynamic>{}.obs;
  var errorMessage = ''.obs;

  // Get user profile from server
  Future<Map<String, dynamic>?> loadUserProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await ApiService.get(ApiEndpoints.userProfile);

      if (result['success'] == true || result['status'] == 'success') {
        // Update local data
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

  // Update user profile
  Future<Map<String, dynamic>?> updateUserProfile(Map<String, dynamic> data) async {
    try {
      errorMessage.value = '';

      final result = await ApiService.put(ApiEndpoints.updateProfile, data);

      if (result['success'] == true || result['status'] == 'success') {
        // Update local data
        final updatedData = Map<String, dynamic>.from(result['data'] ?? {});
        userProfileData.value = updatedData;
        return updatedData;
      } else {
        // Handle different error cases
        String errorMsg = result['message'] ?? 'Failed to update profile';

        // Special handling for specific error messages
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

  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      errorMessage.value = '';

      final result = await ApiService.put(ApiEndpoints.changePassword, {
        'password': currentPassword,
        'new_password': newPassword,
      });

      // Check if request was successful
      if (result['success'] == true || result['status'] == 'success') {
        return true;
      } else {
        // Handle different error cases
        String errorMsg = result['message'] ?? 'Failed to change password';

        // Special handling for specific error messages
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

  // Upload avatar
  Future<bool> uploadAvatar(String imagePath) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implement file upload
      // This would typically use a multipart request
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

  // Get user statistics (placeholder - no API endpoint available)
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      // No API endpoint available, return empty stats
      return {};
    } catch (e) {
      return {};
    }
  }
}