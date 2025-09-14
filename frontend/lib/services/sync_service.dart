import 'package:get/get.dart';
import '../models/board.dart';
import '../models/card.dart';
import '../models/list.dart';

/// Service to sync data between controllers
class SyncService extends GetxService {
  static SyncService get instance => Get.find<SyncService>();

  // Events to notify data changes
  final RxString _boardUpdatedEvent = ''.obs;
  final RxString _cardUpdatedEvent = ''.obs;
  final RxString _listUpdatedEvent = ''.obs;
  final RxBool _homeRefreshNeeded = false.obs;

  // Getters for reactive streams
  RxString get boardUpdatedEvent => _boardUpdatedEvent;
  RxString get cardUpdatedEvent => _cardUpdatedEvent;
  RxString get listUpdatedEvent => _listUpdatedEvent;
  RxBool get homeRefreshNeeded => _homeRefreshNeeded;

  /// Notify that board has been updated
  void notifyBoardUpdated(String boardId, {Board? updatedBoard}) {
    _boardUpdatedEvent.value = '${boardId}_${DateTime.now().millisecondsSinceEpoch}';
    _homeRefreshNeeded.value = true;

    // Send event for other controllers to listen
    Get.find<SyncService>()._broadcastBoardUpdate(boardId, updatedBoard);
  }

  /// Notify that board has been deleted
  void notifyBoardDeleted(String boardId) {
    _boardUpdatedEvent.value = 'deleted_${boardId}_${DateTime.now().millisecondsSinceEpoch}';
    _homeRefreshNeeded.value = true;

    // Send event for other controllers to listen
    Get.find<SyncService>()._broadcastBoardDeleted(boardId);
  }

  /// Notify that card has been updated
  void notifyCardUpdated(String cardId, String boardId, {TaskCard? updatedCard}) {
    _cardUpdatedEvent.value = '${cardId}_${DateTime.now().millisecondsSinceEpoch}';

    // Also need to update board counts
    _homeRefreshNeeded.value = true;

    Get.find<SyncService>()._broadcastCardUpdate(cardId, boardId, updatedCard);
  }

  /// Notify that list has been updated
  void notifyListUpdated(String listId, String boardId, {TaskList? updatedList}) {
    _listUpdatedEvent.value = '${listId}_${DateTime.now().millisecondsSinceEpoch}';
    _homeRefreshNeeded.value = true;

    Get.find<SyncService>()._broadcastListUpdate(listId, boardId, updatedList);
  }

  /// Reset home refresh flag
  void resetHomeRefreshFlag() {
    _homeRefreshNeeded.value = false;
  }

  // Private methods to broadcast events
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

