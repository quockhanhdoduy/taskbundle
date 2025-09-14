import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/list.dart';
import '../models/card.dart';
import '../models/board.dart';
import '../services/board_service.dart';
import '../services/sync_service.dart';
import '../services/api_service.dart';
import '../config/api_endpoints.dart';
import 'auth_controller.dart';
import 'card_controller.dart';

class BoardController extends GetxController {
  final RxList<TaskList> lists = <TaskList>[].obs;
  final RxMap<String, List<TaskCard>> cardsByList = <String, List<TaskCard>>{}.obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;
  final RxList<Board> allBoards = <Board>[].obs;
  final RxList<Board> ownerBoards = <Board>[].obs;
  final RxList<Board> invitedBoards = <Board>[].obs;
  final RxMap<String, int> boardMemberCounts = <String, int>{}.obs;
  final Rx<Board?> currentBoard = Rx<Board?>(null);

  String? boardId;

  @override
  void onInit() {
    super.onInit();
    _setupSyncListeners();
  }

  @override
  void onReady() {
    super.onReady();
    if (boardId != null) {
      loadBoardData();
    }
  }

  void setBoardId(String id) {
    boardId = id;
    _findCurrentBoard();
    loadBoardData();
  }

  Future<void> forceRefresh() async {
    if (boardId == null) return;

    lists.clear();
    cardsByList.clear();
    currentBoard.value = null;
    error.value = '';

    await _waitForAuthentication();
    await loadBoardData();
  }

  Future<bool> updateBoardName(String newName) async {
    if (boardId == null || boardId!.isEmpty) return false;

    try {
      isLoading.value = true;
      error.value = '';

      final result = await BoardService.updateBoard(boardId!, {'name': newName});

      if (result['success'] == true || result['status'] == 'success') {
        if (currentBoard.value != null) {
          currentBoard.value = currentBoard.value!.copyWith(name: newName);
          currentBoard.refresh();
        }

        final boardIndex = allBoards.indexWhere((b) => b.id == boardId);
        if (boardIndex != -1) {
          allBoards[boardIndex] = allBoards[boardIndex].copyWith(name: newName);
          allBoards.refresh();
        }

        _forceUIUpdate();
        SyncService.instance.notifyBoardUpdated(boardId!, updatedBoard: currentBoard.value);

        return true;
      } else {
        error.value = result['message'] ?? 'Failed to update board name';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteBoard() async {
    if (boardId == null || boardId!.isEmpty) return false;

    try {
      isLoading.value = true;
      error.value = '';

      final result = await BoardService.deleteBoard(boardId!);

      if (result['success'] == true || result['status'] == 'success') {
        allBoards.removeWhere((b) => b.id == boardId);
        ownerBoards.removeWhere((b) => b.id == boardId);
        invitedBoards.removeWhere((b) => b.id == boardId);

        currentBoard.value = null;
        lists.clear();
        cardsByList.clear();

        SyncService.instance.notifyBoardDeleted(boardId!);

        return true;
      } else {
        error.value = result['message'] ?? 'Failed to delete board';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> getBoardMembers() async {
    if (boardId == null || boardId!.isEmpty) return [];

    try {
      final result = await BoardService.getBoardMembers(boardId!);

      if (result['success'] == true || result['status'] == 'success') {
        final data = result['data'];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        if (data is Map<String, dynamic>) {
          final members = data['members'] ?? data['Users'] ?? data['users'] ?? data['data'];
          if (members is List) {
            return List<Map<String, dynamic>>.from(members);
          }
        }
        return [];
      } else {
        error.value = result['message'] ?? 'Failed to load board members';
        return [];
      }
    } catch (e) {
      error.value = e.toString();
      return [];
    }
  }

  Future<bool> inviteMemberToBoard(String email, {String role = 'MEMBER'}) async {
    if (boardId == null || boardId!.isEmpty) return false;

    try {
      final result = await BoardService.inviteMember(boardId!, email, role: role);

      if (result['success'] == true || result['status'] == 'success') {
        return true;
      } else {
        error.value = result['message'] ?? 'Failed to invite member';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    }
  }

  Future<bool> updateMemberRole(String email, String role) async {
    if (boardId == null || boardId!.isEmpty) return false;

    try {
      final result = await BoardService.updateMemberRole(boardId!, email, role);

      if (result['success'] == true || result['status'] == 'success') {
        return true;
      } else {
        error.value = result['message'] ?? 'Failed to update member role';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    }
  }

  Future<bool> removeMember(String email) async {
    if (boardId == null || boardId!.isEmpty) return false;

    try {
      final result = await BoardService.removeMember(boardId!, email);

      if (result['success'] == true || result['status'] == 'success') {
        return true;
      } else {
        error.value = result['message'] ?? 'Failed to remove member';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    }
  }

  Future<void> _waitForAuthentication() async {
    try {
      final authController = Get.find<AuthController>();

      for (int i = 0; i < 30; i++) {
        if (authController.isAuthenticated.value) {
          return;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  void _findCurrentBoard() {
    if (boardId != null) {
      final board = allBoards.firstWhereOrNull((b) => b.id == boardId);
      if (board != null) {
        currentBoard.value = board;
      } else {
        final allBoardsList = [...ownerBoards, ...invitedBoards];
        final foundBoard = allBoardsList.firstWhereOrNull((b) => b.id == boardId);
        if (foundBoard != null) {
          currentBoard.value = foundBoard;
        } else {
          currentBoard.value = null;
          _loadBoardsIfEmpty();
        }
      }
    }
  }

  Future<void> _loadBoardsIfEmpty() async {
    if (allBoards.isEmpty && ownerBoards.isEmpty && invitedBoards.isEmpty) {
      await loadBoards();
      if (boardId != null) {
        final allBoardsList = [...ownerBoards, ...invitedBoards];
        final foundBoard = allBoardsList.firstWhereOrNull((b) => b.id == boardId);
        if (foundBoard != null) {
          currentBoard.value = foundBoard;
        }
      }
    }
  }

  Future<void> loadBoardData() async {
    if (boardId == null) return;

    isLoading.value = true;
    error.value = '';

    try {
      final listsResponse = await BoardService.getListsByBoard(boardId!);

      if (listsResponse.success && listsResponse.data != null) {
        lists.value = listsResponse.data!;

        Map<String, List<TaskCard>> tempCardsByList = {};
        for (TaskList list in lists) {
          try {
            final cardsResponse = await BoardService.getCardsByList(list.id);
            if (cardsResponse.success && cardsResponse.data != null) {
              tempCardsByList[list.id] = cardsResponse.data!;
        } else {
              tempCardsByList[list.id] = [];
            }
          } catch (e) {
            tempCardsByList[list.id] = [];
          }
        }
        cardsByList.clear();
        for (var entry in tempCardsByList.entries) {
          cardsByList[entry.key] = entry.value;
        }
        cardsByList.refresh();

        if (boardId != null && boardId!.isNotEmpty) {
          _updateBoardCountsCache(boardId!, 'lists', lists.length);
          int totalCards = 0;
          for (var cards in tempCardsByList.values) {
            totalCards += cards.length;
          }
          _updateBoardCountsCache(boardId!, 'cards', totalCards);
        }
        _notifyHomeController();

      } else {
        error.value = listsResponse.message;
      }
    } catch (e) {
      error.value = 'Error loading board data: ${e.toString()}';
    }

      isLoading.value = false;
  }

  Future<void> createList(String name) async {
    if (boardId == null) return;

    try {
      final response = await BoardService.createList(boardId!, name);

      if (response.success && response.data != null) {
        lists.add(response.data!);
        cardsByList[response.data!.id] = [];
        _notifyHomeController();

        Get.snackbar(
          'Success',
          'List created successfully',
          backgroundColor: Get.theme.colorScheme.primary.withValues(alpha: 0.8),
          colorText: Get.theme.colorScheme.onPrimary,
        );
      } else {
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create list: ${e.toString()}',
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  Future<void> createCard(String listId, String title, [String? description]) async {
    try {
      final response = await BoardService.createCard(listId, title, description);

      if (response.success && response.data != null) {
        if (cardsByList[listId] == null) {
          cardsByList[listId] = [];
        }
        cardsByList[listId]!.add(response.data!);
        cardsByList.refresh();
        _notifyHomeController();

        Get.snackbar(
          'Success',
          'Card created successfully',
          backgroundColor: Get.theme.colorScheme.primary.withValues(alpha: 0.8),
          colorText: Get.theme.colorScheme.onPrimary,
        );
      } else {
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create card: ${e.toString()}',
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  void reorderLists(int fromIndex, int toIndex) {
    if (fromIndex == toIndex || fromIndex >= lists.length || toIndex < 0) {
      return;
    }

    toIndex = toIndex.clamp(0, lists.length - 1);
    final TaskList item = lists.removeAt(fromIndex);
    int finalIndex = toIndex;
    lists.insert(finalIndex, item);

    lists.refresh();
    update();

    Future.delayed(const Duration(milliseconds: 50), () {
      lists.refresh();
    });

    _updateListPositions();
  }

  void moveCardToList(TaskCard card, String fromListId, int fromIndex, String toListId) {
    if (cardsByList[fromListId] != null) {
      cardsByList[fromListId]!.removeAt(fromIndex);
    }

    if (cardsByList[toListId] == null) {
      cardsByList[toListId] = [];
    }
    cardsByList[toListId]!.add(card);

    cardsByList.refresh();
    _notifyHomeController();

    _moveCardToListOnServer(card.id, toListId);
  }

  void reorderCardsInList(String listId, int fromIndex, int toIndex) {
    final cards = cardsByList[listId];
    if (cards == null || fromIndex >= cards.length || toIndex < 0) {
      return;
    }

    if (toIndex > cards.length) {
      toIndex = cards.length;
    }

    final TaskCard item = cards.removeAt(fromIndex);
    int insertIndex = toIndex;
    if (toIndex > fromIndex) {
      insertIndex = toIndex - 1;
    }

    cards.insert(insertIndex, item);

    cardsByList.refresh();
    _notifyHomeController();

    _updateCardPositions(listId);
  }

  void moveCardToListAtPosition(TaskCard card, String fromListId, int fromIndex, String toListId, int toIndex) {
    final fromCards = cardsByList[fromListId];
    if (fromCards != null && fromIndex < fromCards.length) {
      fromCards.removeAt(fromIndex);
    }

    if (cardsByList[toListId] == null) {
      cardsByList[toListId] = [];
    }

    final toCards = cardsByList[toListId]!;
    int insertIndex = toIndex;
    if (insertIndex > toCards.length) {
      insertIndex = toCards.length;
    }

    toCards.insert(insertIndex, card);

    cardsByList.refresh();

    _moveCardToListOnServer(card.id, toListId);
  }

  Future<void> _updateListPositions() async {
    // TODO: Implement API call to update list positions
  }

  Future<void> _updateCardPositions(String listId) async {
    // TODO: Implement API call to update card positions
  }

  Future<void> _moveCardToListOnServer(String cardId, String toListId) async {
    // TODO: Implement API call to move card to different list
  }

  Future<bool> createBoard(String name) async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await BoardService.createBoard(name);

      if (response.success && response.data != null) {
        successMessage.value = 'Board "$name" created successfully!';
        return true;
      } else {
        errorMessage.value = response.message;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to create board: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
    error.value = '';
  }

  Future<void> loadBoards() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await BoardService.getAllBoards();

      if (response.success && response.data != null) {
        final boardsData = response.data!;
        ownerBoards.value = boardsData['ownerBoards'] ?? [];
        invitedBoards.value = boardsData['invitedBoards'] ?? [];
        allBoards.value = [...ownerBoards, ...invitedBoards];

        for (final board in allBoards) {
          if (!boardCountsCache.containsKey(board.id)) {
            _updateBoardCountsCache(board.id, 'lists', 0);
            _updateBoardCountsCache(board.id, 'cards', 0);
          }
        }
      } else {
        errorMessage.value = response.message;
        allBoards.value = [];
        ownerBoards.value = [];
        invitedBoards.value = [];
      }
    } catch (e) {
      errorMessage.value = 'Failed to load boards: ${e.toString()}';
      allBoards.value = [];
      ownerBoards.value = [];
      invitedBoards.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshBoards() async {
    await loadBoards();
  }

  Future<void> loadBoardMemberCounts() async {
    try {
      final futures = allBoards.map((board) => _getBoardMemberCount(board.id));
      final results = await Future.wait(futures);

      for (int i = 0; i < allBoards.length; i++) {
        boardMemberCounts[allBoards[i].id] = results[i];
      }
      boardMemberCounts.refresh();
    } catch (e) {
      print('Error loading board member counts: $e');
    }
  }

  Future<int> _getBoardMemberCount(String boardId) async {
    try {
      final result = await BoardService.getBoardMembers(boardId);
      if (result['success'] == true || result['status'] == 'success') {
        final data = result['data'];
        if (data is List) {
          final acceptedMembers = data.where((member) =>
            member['accepted'] == true || member['status'] == 'accepted' || member['status'] == 'active'
          ).toList();
          return acceptedMembers.length;
        }
        if (data is Map<String, dynamic>) {
          final members = data['members'] ?? data['Users'] ?? data['users'] ?? data['data'];
          if (members is List) {
            final acceptedMembers = members.where((member) =>
              member['accepted'] == true || member['status'] == 'accepted' || member['status'] == 'active'
            ).toList();
            return acceptedMembers.length;
          }
        }
      }
      return 1;
    } catch (e) {
      print('Error getting member count for board $boardId: $e');
      return 1;
    }
  }

  int getMemberCountForBoard(String boardId) {
    return boardMemberCounts[boardId] ?? 1;
  }

  bool isOwnerOfBoard(String boardId) {
    return ownerBoards.any((board) => board.id == boardId);
  }

  static final Map<String, Map<String, int>> boardCountsCache = {};

  int getListCountForBoard(String boardId) {
    if (boardId == this.boardId) {
      final count = lists.length;
      _updateBoardCountsCache(boardId, 'lists', count);
      return count;
    }
    return boardCountsCache[boardId]?['lists'] ?? 0;
  }

  int getCardCountForBoard(String boardId) {
    if (boardId == this.boardId) {
      int totalCards = 0;
      for (var cards in cardsByList.values) {
        totalCards += cards.length;
      }
      _updateBoardCountsCache(boardId, 'cards', totalCards);
      return totalCards;
    }
    return boardCountsCache[boardId]?['cards'] ?? 0;
  }

  static void _updateBoardCountsCache(String boardId, String type, int count) {
    if (boardCountsCache[boardId] == null) {
      boardCountsCache[boardId] = {};
    }
    boardCountsCache[boardId]![type] = count;
  }

  void _notifyHomeController() {
    try {
      final homeController = Get.find<BoardController>(tag: 'home');
      homeController.allBoards.refresh();
      homeController.ownerBoards.refresh();
      homeController.invitedBoards.refresh();
    } catch (e) {
      // Home controller not found, ignore
    }
  }

  Future<void> loadBoardCounts() async {
    return;
  }

  Future<void> toggleCardCompletion(String cardId, bool isCompleted) async {
    try {
      print('BoardController.toggleCardCompletion called: $cardId -> $isCompleted');

      final cardController = CardController();
      final success = await cardController.toggleCompletion(cardId, isCompleted);
      print('API call success: $success');

      if (success) {
        bool updated = false;
        print('Searching for card $cardId in cardsByList...');
        print('cardsByList keys: ${cardsByList.keys.toList()}');

        for (var listId in cardsByList.keys) {
          final cards = cardsByList[listId]!;
          print('Checking list $listId with ${cards.length} cards');

          final cardIds = cards.map((card) => card.id).toList();
          print('Card IDs in list $listId: $cardIds');

          final cardIndex = cards.indexWhere((card) => card.id == cardId);
          if (cardIndex != -1) {
            print('Found card at index $cardIndex, current isCompleted: ${cards[cardIndex].isCompleted}');

            cards[cardIndex] = cards[cardIndex].copyWith(
              isCompleted: isCompleted,
            );

            print('Updated card isCompleted to: ${cards[cardIndex].isCompleted}');
            updated = true;
            break;
          }
        }

        if (updated) {
          print('Calling cardsByList.refresh() and update()');
          cardsByList.refresh();
          update();

          Future.delayed(const Duration(milliseconds: 100), () {
            print('Delayed refresh and update');
            cardsByList.refresh();
            update();
          });

          print('Card completion updated successfully: $isCompleted');
        } else {
          print('Card not found in any list!');
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to update card status',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error toggling card completion: $e');
      Get.snackbar(
        'Error',
        'Failed to update card status: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _setupSyncListeners() {
    try {
      final syncService = SyncService.instance;

      ever(syncService.boardUpdatedEvent, (String event) {
        if (event.isNotEmpty) {
          _handleBoardUpdateEvent(event);
        }
      });

      ever(syncService.homeRefreshNeeded, (bool needRefresh) {
        if (needRefresh && Get.currentRoute.contains('/home')) {
          if (boardId == null) {
            loadBoards();
            syncService.resetHomeRefreshFlag();
          }
        }
      });
    } catch (e) {
      // SyncService not ready yet
    }
  }

  void _handleBoardUpdateEvent(String event) {
    try {
      if (event.startsWith('deleted_')) {
        final deletedBoardId = event.split('_')[1];
        _handleBoardDeleted(deletedBoardId);
      } else {
        final eventBoardId = event.split('_')[0];
        _handleBoardUpdated(eventBoardId);
      }
    } catch (e) {
      // Error parsing event
    }
  }

  void _handleBoardUpdated(String updatedBoardId) {
    if (boardId != updatedBoardId) {
      if (boardId == null) {
        loadBoards();
      }
    } else {
      update();
    }
  }

  void _handleBoardDeleted(String deletedBoardId) {
    allBoards.removeWhere((b) => b.id == deletedBoardId);
    ownerBoards.removeWhere((b) => b.id == deletedBoardId);
    invitedBoards.removeWhere((b) => b.id == deletedBoardId);

    if (boardId == deletedBoardId) {
      currentBoard.value = null;
      lists.clear();
      cardsByList.clear();
    }
  }

  void syncBoardUpdate(String updatedBoardId, Board? updatedBoard) {
    _handleBoardUpdated(updatedBoardId);
  }

  void syncBoardDeleted(String deletedBoardId) {
    _handleBoardDeleted(deletedBoardId);
  }

  void syncCardUpdate(String cardId, String updatedBoardId, TaskCard? updatedCard) {
    if (boardId == updatedBoardId) {
      forceRefresh();
    }
  }

  void syncListUpdate(String listId, String updatedBoardId, TaskList? updatedList) {
    if (boardId == updatedBoardId) {
      forceRefresh();
    }
  }

  void _forceUIUpdate() {
    update();

    Future.delayed(const Duration(milliseconds: 50), () {
      currentBoard.refresh();
      allBoards.refresh();
      update();
    });

    if (currentBoard.value != null) {
      final temp = currentBoard.value;
      currentBoard.value = null;
      currentBoard.value = temp;
    }
  }

  Future<Map<String, dynamic>> getBoardActivities(String boardId, {int page = 1, int limit = 20, String? type}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final queryParams = <String, String>{
        'page': page.toString(),
      };

      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final endpoint = '${ApiEndpoints.boardActivities(boardId)}${queryString.isNotEmpty ? '?$queryString' : ''}';

      return await ApiService.get(endpoint);
    } catch (e) {
      errorMessage.value = 'Connection error: ${e.toString()}';
      return {'success': false, 'message': errorMessage.value};
    } finally {
      isLoading.value = false;
    }
  }
}