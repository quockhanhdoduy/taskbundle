import 'package:get/get.dart';
import '../services/api_service.dart';
import '../config/api_endpoints.dart';

class ActivityController extends GetxController {
  var isLoading = false.obs;
  var activities = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  // Get board activity history
  Future<void> getBoardActivities(String boardId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await ApiService.get(ApiEndpoints.boardActivities(boardId));

      if (result['status'] == 'success' || result['success'] == true) {
        activities.value = List<Map<String, dynamic>>.from(result['data'] ?? []);
      } else {
        errorMessage.value = result['message'] ?? 'Lỗi khi tải lịch sử hoạt động';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh activity history
  Future<void> refreshActivities(String boardId) async {
    await getBoardActivities(boardId);
  }
}

