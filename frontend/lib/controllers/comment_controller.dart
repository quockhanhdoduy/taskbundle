import 'package:get/get.dart';
import '../services/api_service.dart';
import '../config/api_endpoints.dart';

class CommentController extends GetxController {
  var isLoading = false.obs;
  var comments = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  // Get card comments
  Future<void> getCardComments(String cardId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await ApiService.get(ApiEndpoints.cardComments(cardId));

      if (result['status'] == 'success' || result['success'] == true) {
        comments.value = List<Map<String, dynamic>>.from(result['data'] ?? []);
      } else {
        errorMessage.value = result['message'] ?? 'Lỗi khi tải comments';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Create new comment
  Future<bool> createComment(String cardId, String content) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await ApiService.post(ApiEndpoints.cardComments(cardId), {
        'content': content,
      });

      if (result['status'] == 'success' || result['success'] == true) {
        Get.snackbar('Success', 'Create comment successfully');
        await getCardComments(cardId);
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Tạo comment thất bại';
        Get.snackbar('Error', errorMessage.value);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get comment details
  Future<Map<String, dynamic>> getCommentDetail(String commentId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      return await ApiService.get(ApiEndpoints.commentDetail(commentId));
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
      return {'success': false, 'message': errorMessage.value};
    } finally {
      isLoading.value = false;
    }
  }

  // Update comment
  Future<bool> updateComment(String commentId, String content, String cardId) async {
    try {
      isLoading.value = true;

      final result = await ApiService.put(ApiEndpoints.commentUpdate(commentId), {
        'content': content,
      });

      if (result['status'] == 'success' || result['success'] == true) {
        Get.snackbar('Success', 'Update comment successfully');
        await getCardComments(cardId);
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Cập nhật comment thất bại';
        Get.snackbar('Error', errorMessage.value);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete comment
  Future<bool> deleteComment(String commentId, String cardId) async {
    try {
      isLoading.value = true;

      final result = await ApiService.delete(ApiEndpoints.commentDelete(commentId));

      if (result['status'] == 'success' || result['success'] == true) {
        Get.snackbar('Success', 'Delete comment successfully');
        await getCardComments(cardId);
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Xóa comment thất bại';
        Get.snackbar('Error', errorMessage.value);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
