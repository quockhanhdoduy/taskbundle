import 'package:get/get.dart';
import '../models/board.dart';
import '../models/card.dart';
import '../models/list.dart';

/// Service để đồng bộ dữ liệu giữa các controller
class SyncService extends GetxService {
  static SyncService get instance => Get.find<SyncService>();

  // Events để thông báo thay đổi dữ liệu
  final RxString _boardUpdatedEvent = ''.obs;
  final RxString _cardUpdatedEvent = ''.obs;
  final RxString _listUpdatedEvent = ''.obs;
  final RxBool _homeRefreshNeeded = false.obs;

  // Getters for reactive streams
  RxString get boardUpdatedEvent => _boardUpdatedEvent;
  RxString get cardUpdatedEvent => _cardUpdatedEvent;
  RxString get listUpdatedEvent => _listUpdatedEvent;
  RxBool get homeRefreshNeeded => _homeRefreshNeeded;

  /// Thông báo board đã được cập nhật
  void notifyBoardUpdated(String boardId, {Board? updatedBoard}) {
    _boardUpdatedEvent.value = '${boardId}_${DateTime.now().millisecondsSinceEpoch}';
    _homeRefreshNeeded.value = true;

    // Gửi event để các controller khác lắng nghe
    Get.find<SyncService>()._broadcastBoardUpdate(boardId, updatedBoard);
  }

  /// Thông báo board đã bị xóa
  void notifyBoardDeleted(String boardId) {
    _boardUpdatedEvent.value = 'deleted_${boardId}_${DateTime.now().millisecondsSinceEpoch}';
    _homeRefreshNeeded.value = true;

    // Gửi event để các controller khác lắng nghe
    Get.find<SyncService>()._broadcastBoardDeleted(boardId);
  }

  /// Thông báo card đã được cập nhật
  void notifyCardUpdated(String cardId, String boardId, {TaskCard? updatedCard}) {
    _cardUpdatedEvent.value = '${cardId}_${DateTime.now().millisecondsSinceEpoch}';

    // Cũng cần cập nhật board counts
    _homeRefreshNeeded.value = true;

    Get.find<SyncService>()._broadcastCardUpdate(cardId, boardId, updatedCard);
  }

  /// Thông báo list đã được cập nhật
  void notifyListUpdated(String listId, String boardId, {TaskList? updatedList}) {
    _listUpdatedEvent.value = '${listId}_${DateTime.now().millisecondsSinceEpoch}';
    _homeRefreshNeeded.value = true;

    Get.find<SyncService>()._broadcastListUpdate(listId, boardId, updatedList);
  }

  /// Reset home refresh flag
  void resetHomeRefreshFlag() {
    _homeRefreshNeeded.value = false;
  }

  // Private methods để broadcast events
  void _broadcastBoardUpdate(String boardId, Board? updatedBoard) {
    // Simple approach: just trigger events, let listeners handle the rest
    print('SyncService: Broadcasting board update for $boardId');
  }

  void _broadcastBoardDeleted(String boardId) {
    // Simple approach: just trigger events, let listeners handle the rest
    print('SyncService: Broadcasting board deletion for $boardId');
  }

  void _broadcastCardUpdate(String cardId, String boardId, TaskCard? updatedCard) {
    // Simple approach: just trigger events, let listeners handle the rest
    print('SyncService: Broadcasting card update for $cardId in board $boardId');
  }

  void _broadcastListUpdate(String listId, String boardId, TaskList? updatedList) {
    // Simple approach: just trigger events, let listeners handle the rest
    print('SyncService: Broadcasting list update for $listId in board $boardId');
  }
}

