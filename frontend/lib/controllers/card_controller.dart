import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../config/api_endpoints.dart';

class CardController extends GetxController {
  var isLoading = false.obs;
  var cards = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  // Lấy cards theo list
  Future<void> getCardsByList(String listId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await ApiService.get(ApiEndpoints.listCards(listId));

      if (result['status'] == 'success' || result['success'] == true) {
        cards.value = List<Map<String, dynamic>>.from(result['data'] ?? []);
      } else {
        errorMessage.value = result['message'] ?? 'Lỗi khi tải cards';
        Get.snackbar('Lỗi', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
      Get.snackbar('Lỗi', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Tạo card mới
  Future<bool> createCard(String listId, String title, String? description) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await ApiService.post(ApiEndpoints.listCards(listId), {
        'title': title,
        if (description != null) 'description': description,
      });

      if (result['status'] == 'success' || result['success'] == true) {
        Get.snackbar(
          'Success',
          'Card created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        await getCardsByList(listId); // Refresh danh sách
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Tạo card thất bại';
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

  // Cập nhật card
  Future<bool> updateCard(String cardId, String? title, String? description) async {
    try {
      isLoading.value = true;

      final Map<String, dynamic> data = {};
      if (title != null && title.isNotEmpty) {
        data['title'] = title;
      }
      if (description != null) {
        data['description'] = description;
      }

      final result = await ApiService.put(ApiEndpoints.cardUpdate(cardId), data);

      if (result['status'] == 'success' || result['success'] == true) {
        // Don't show snackbar here, let the UI handle it
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Cập nhật card thất bại';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Xóa card
  Future<bool> deleteCard(String cardId) async {
    try {
      isLoading.value = true;

      final result = await ApiService.delete(ApiEndpoints.cardDelete(cardId));

      if (result['status'] == 'success' || result['success'] == true) {
        Get.snackbar('Thành công', 'Xóa card thành công');
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Xóa card thất bại';
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

  // Upload attachment
  Future<bool> uploadAttachment(String cardId, String filePath) async {
    try {
      isLoading.value = true;

      final result = await ApiService.uploadFile(ApiEndpoints.cardAttachments(cardId), filePath, null);

      if (result['status'] == 'success' || result['success'] == true) {
        Get.snackbar('Thành công', 'Upload file thành công');
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Upload file thất bại';
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

  // Lấy chi tiết card
  Future<Map<String, dynamic>> getCardDetail(String cardId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final endpoint = ApiEndpoints.cardDetail(cardId);

      return await ApiService.get(endpoint);
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
      Get.snackbar('Lỗi', errorMessage.value);
      return {'success': false, 'message': errorMessage.value};
    } finally {
      isLoading.value = false;
    }
  }

  // Di chuyển vị trí card
  Future<bool> updateCardPosition(String cardId, int newPosition) async {
    try {
      isLoading.value = true;

      final result = await ApiService.put(ApiEndpoints.cardPosition(cardId), {
        'newPosition': newPosition,
      });

      if (result['status'] == 'success' || result['success'] == true) {
        Get.snackbar('Thành công', 'Di chuyển card thành công');
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Di chuyển card thất bại';
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

  // Chuyển card sang list khác
  Future<bool> moveCardToList(String cardId, String targetListId, int? newPosition) async {
    try {
      isLoading.value = true;

      final result = await ApiService.put(ApiEndpoints.cardMoveToList(cardId), {
        'targetListId': targetListId,
        if (newPosition != null) 'newPosition': newPosition,
      });

      if (result['status'] == 'success' || result['success'] == true) {
        Get.snackbar('Thành công', 'Chuyển card thành công');
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Chuyển card thất bại';
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

  // Assign user vào card
  Future<bool> assignUser(String cardId, String userId) async {
    try {
      isLoading.value = true;

      final result = await ApiService.post(ApiEndpoints.cardAssign(cardId), {
        'userId': userId,
      });

      if (result['status'] == 'success' || result['success'] == true) {
        Get.snackbar('Thành công', 'Assign user thành công');
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Assign user thất bại';
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

  // Unassign user khỏi card
  Future<bool> unassignUser(String cardId, String userId) async {
    try {
      isLoading.value = true;

      final result = await ApiService.delete(ApiEndpoints.cardUnassign(cardId));

      if (result['status'] == 'success' || result['success'] == true) {
        Get.snackbar('Thành công', 'Unassign user thành công');
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Unassign user thất bại';
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

  // Lấy danh sách members của card
  Future<Map<String, dynamic>> getCardMembers(String cardId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      return await ApiService.get(ApiEndpoints.cardMembers(cardId));
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
      Get.snackbar('Lỗi', errorMessage.value);
      return {'success': false, 'message': errorMessage.value};
    } finally {
      isLoading.value = false;
    }
  }

  // Assign nhiều user cùng lúc
  Future<bool> assignMultipleUsers(String cardId, List<String> userIds) async {
    try {
      isLoading.value = true;

      final result = await ApiService.post(ApiEndpoints.cardAssignMultiple(cardId), {
        'userIds': userIds,
      });

      if (result['status'] == 'success' || result['success'] == true) {
        Get.snackbar('Thành công', 'Assign users thành công');
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Assign users thất bại';
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

  // Set/Update due date
  Future<bool> updateDueDate(String cardId, String? dueDate) async {
    try {
      isLoading.value = true;

      final result = await ApiService.put(ApiEndpoints.cardDueDate(cardId), {
        'dueDate': dueDate,
      });

      if (result['status'] == 'success' || result['success'] == true) {
        // Don't show snackbar here, let the UI handle it
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Cập nhật due date thất bại';
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

  // Đánh dấu hoàn thành
  Future<bool> toggleCompletion(String cardId, bool isCompleted) async {
    try {
      isLoading.value = true;

      // Toggle completion API call

      final result = await ApiService.put(ApiEndpoints.cardCompletion(cardId), {
        'isCompleted': isCompleted,
      });

      // API response received

      if (result['status'] == 'success' || result['success'] == true) {
        // Toggle completion successful
        // Don't show snackbar here, let the UI handle it
        return true;
      } else {
        // Toggle completion failed
        errorMessage.value = result['message'] ?? 'Cập nhật trạng thái thất bại';
        return false;
      }
    } catch (e) {
      // Toggle completion error
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Lấy danh sách attachments
  Future<Map<String, dynamic>> getCardAttachments(String cardId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      return await ApiService.get(ApiEndpoints.cardAttachments(cardId));
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
      Get.snackbar('Lỗi', errorMessage.value);
      return {'success': false, 'message': errorMessage.value};
    } finally {
      isLoading.value = false;
    }
  }

  // Xóa attachment
  Future<bool> removeAttachment(String cardId, String attachmentId) async {
    try {
      isLoading.value = true;

      final result = await ApiService.delete(ApiEndpoints.cardRemoveAttachment(cardId, attachmentId));

      if (result['status'] == 'success' || result['success'] == true) {
        Get.snackbar('Thành công', 'Xóa attachment thành công');
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Xóa attachment thất bại';
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

  // Lấy thông tin list detail để lấy boardId
  Future<Map<String, dynamic>> getListDetail(String listId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      return await ApiService.get(ApiEndpoints.listDetail(listId));
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
      return {'success': false, 'message': errorMessage.value};
    } finally {
      isLoading.value = false;
    }
  }
}
