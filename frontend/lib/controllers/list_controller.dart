import 'package:get/get.dart';
import '../services/api_service.dart';
import '../config/api_endpoints.dart';

class ListController extends GetxController {
  var isLoading = false.obs;
  var lists = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  Future<void> getListsByBoard(String boardId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await ApiService.get(ApiEndpoints.boardLists(boardId));

      if (result['status'] == 'success' || result['success'] == true) {
        lists.value = List<Map<String, dynamic>>.from(result['data'] ?? []);
      } else {
        errorMessage.value = result['message'] ?? 'Lỗi khi tải lists';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createList(String boardId, String title) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await ApiService.post(ApiEndpoints.boardLists(boardId), {
        'title': title,
      });

      if (result['status'] == 'success' || result['success'] == true) {
        Get.snackbar('Success', 'Create list successfully');
        await getListsByBoard(boardId);
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Tạo list thất bại';
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

  Future<bool> updateList(String listId, String title, String boardId) async {
    try {
      isLoading.value = true;

      final result = await ApiService.put(ApiEndpoints.listUpdate(listId), {
        'title': title,
      });

      if (result['status'] == 'success' || result['success'] == true) {
        Get.snackbar('Success', 'Update list successfully');
        await getListsByBoard(boardId);
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Cập nhật list thất bại';
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

  Future<bool> deleteList(String listId, String boardId) async {
    try {
      isLoading.value = true;

      final result = await ApiService.delete(ApiEndpoints.listDelete(listId));

      if (result['status'] == 'success' || result['success'] == true) {
        Get.snackbar('Success', 'Delete list successfully');
        await getListsByBoard(boardId);
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Xóa list thất bại';
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

  Future<bool> updateListPosition(String listId, int newPosition, String boardId) async {
    try {
      isLoading.value = true;

      final result = await ApiService.put(ApiEndpoints.listPosition(listId), {
        'newPosition': newPosition,
      });

      if (result['status'] == 'success' || result['success'] == true) {
        Get.snackbar('Success', 'Move list successfully');
        await getListsByBoard(boardId);
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Di chuyển list thất bại';
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
