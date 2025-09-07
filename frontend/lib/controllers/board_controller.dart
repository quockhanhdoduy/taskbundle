import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/list.dart';
import '../models/card.dart';
import '../models/board.dart';
import '../services/board_service.dart';
import 'auth_controller.dart';
import 'card_controller.dart';

class BoardController extends GetxController {
  // Observable data
  final RxList<TaskList> lists = <TaskList>[].obs;
  final RxMap<String, List<TaskCard>> cardsByList = <String, List<TaskCard>>{}.obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;
  final RxList<Board> allBoards = <Board>[].obs;
  final RxList<Board> ownerBoards = <Board>[].obs;
  final RxList<Board> invitedBoards = <Board>[].obs;

  // Current board details
  final Rx<Board?> currentBoard = Rx<Board?>(null);

  String? boardId;

  @override
  void onInit() {
    super.onInit();
    // Don't load data in onInit, wait for onReady
  }

  @override
  void onReady() {
    super.onReady();
    // Load data when controller is fully ready
    if (boardId != null) {
      loadBoardData();
    }
  }

  void setBoardId(String id) {
    boardId = id;
    // Try to find board in existing data first
    _findCurrentBoard();
    loadBoardData();
  }

  /// Force refresh board data - clear cache and reload everything
  Future<void> forceRefresh() async {
    if (boardId == null) return;

    // Clear existing data
    lists.clear();
    cardsByList.clear();
    currentBoard.value = null;
    error.value = '';

    // Wait for authentication to be ready
    await _waitForAuthentication();

    // Reload data
    await loadBoardData();
  }

  /// Wait for authentication to be properly set up
  Future<void> _waitForAuthentication() async {
    // Try to get AuthController
    try {
      final authController = Get.find<AuthController>();

      // Wait up to 3 seconds for authentication to be ready
      for (int i = 0; i < 30; i++) {
        if (authController.isAuthenticated.value) {
          return;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      // Fallback to simple delay
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  void _findCurrentBoard() {
    if (boardId != null) {
      // Try to find in allBoards first
      final board = allBoards.firstWhereOrNull((b) => b.id == boardId);
      if (board != null) {
        currentBoard.value = board;
      } else {
        // Try to find in ownerBoards + invitedBoards
        final allBoardsList = [...ownerBoards, ...invitedBoards];
        final foundBoard = allBoardsList.firstWhereOrNull((b) => b.id == boardId);
        if (foundBoard != null) {
          currentBoard.value = foundBoard;
        } else {
          currentBoard.value = null;
          // If not found, try to load boards first
          _loadBoardsIfEmpty();
        }
      }
    }
  }

  Future<void> _loadBoardsIfEmpty() async {
    if (allBoards.isEmpty && ownerBoards.isEmpty && invitedBoards.isEmpty) {
      await loadBoards();
      // Try to find board again after loading
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
      // Load lists for the board
      final listsResponse = await BoardService.getListsByBoard(boardId!);

      if (listsResponse.success && listsResponse.data != null) {
        lists.value = listsResponse.data!;

        // Load cards for each list
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
        // Update cardsByList properly to maintain reactivity
        cardsByList.clear();
        for (var entry in tempCardsByList.entries) {
          cardsByList[entry.key] = entry.value;
        }
        cardsByList.refresh();

        // Update cache with loaded data
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
        _notifyHomeController(); // Update home view

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
        cardsByList.refresh(); // Notify observers
        _notifyHomeController(); // Update home view

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

  // Drag and Drop Logic
  void reorderLists(int fromIndex, int toIndex) {
    if (fromIndex == toIndex || fromIndex >= lists.length || toIndex < 0) {
      // Invalid reorder parameters
      return;
    }

    // Clamp toIndex to valid range
    toIndex = toIndex.clamp(0, lists.length - 1);

    // Reordering lists với logic thông minh theo hướng kéo
    final TaskList item = lists.removeAt(fromIndex);

    int finalIndex;

    if (fromIndex < toIndex) {
      // Kéo từ trái sang phải → chèn vào sau target (bên phải)
      finalIndex = toIndex; // Sau khi removeAt, toIndex đã tự động adjust
    } else {
      // Kéo từ phải sang trái → chèn vào trước target (bên trái)
      finalIndex = toIndex;
    }

    lists.insert(finalIndex, item);

    // Force UI update multiple ways để đảm bảo
    lists.refresh();
    update(); // Trigger GetBuilder updates if any

    // Delay để đảm bảo UI đã update
    Future.delayed(const Duration(milliseconds: 50), () {
      lists.refresh();
    });

    // TODO: Call API to update list positions on server
    _updateListPositions();
  }

  void moveCardToList(TaskCard card, String fromListId, int fromIndex, String toListId) {
    // Remove card from source list
    if (cardsByList[fromListId] != null) {
      cardsByList[fromListId]!.removeAt(fromIndex);
    }

    // Add card to target list
    if (cardsByList[toListId] == null) {
      cardsByList[toListId] = [];
    }
    cardsByList[toListId]!.add(card);

    cardsByList.refresh(); // Notify observers
    _notifyHomeController(); // Update home view

    // TODO: Call API to move card to different list
    _moveCardToListOnServer(card.id, toListId);
  }

  void reorderCardsInList(String listId, int fromIndex, int toIndex) {
    final cards = cardsByList[listId];
    if (cards == null || fromIndex >= cards.length || toIndex < 0) {
      return;
    }

    // Adjust toIndex if it's beyond the list
    if (toIndex > cards.length) {
      toIndex = cards.length;
    }

    // Remove card from original position
    final TaskCard item = cards.removeAt(fromIndex);

    // Adjust target index after removal
    int insertIndex = toIndex;
    if (toIndex > fromIndex) {
      insertIndex = toIndex - 1;
    }

    // Insert at new position
    cards.insert(insertIndex, item);

    cardsByList.refresh(); // Notify observers
    _notifyHomeController(); // Update home view

    // TODO: Call API to update card positions
    _updateCardPositions(listId);
  }

  void moveCardToListAtPosition(TaskCard card, String fromListId, int fromIndex, String toListId, int toIndex) {
    // Remove card from source list
    final fromCards = cardsByList[fromListId];
    if (fromCards != null && fromIndex < fromCards.length) {
      fromCards.removeAt(fromIndex);
    }

    // Add card to target list at specific position
    if (cardsByList[toListId] == null) {
      cardsByList[toListId] = [];
    }

    final toCards = cardsByList[toListId]!;
    int insertIndex = toIndex;
    if (insertIndex > toCards.length) {
      insertIndex = toCards.length;
    }

    toCards.insert(insertIndex, card);

    cardsByList.refresh(); // Notify observers

    // TODO: Call API to move card to different list at position
    _moveCardToListOnServer(card.id, toListId);
  }

  // Private API methods (placeholder implementations)
  Future<void> _updateListPositions() async {
    // TODO: Implement API call to update list positions
  }

  Future<void> _updateCardPositions(String listId) async {
    // TODO: Implement API call to update card positions
  }

  Future<void> _moveCardToListOnServer(String cardId, String toListId) async {
    // TODO: Implement API call to move card to different list
  }

  // Board creation methods
  Future<bool> createBoard(String name) async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await BoardService.createBoard(name);

      if (response.success && response.data != null) {
        successMessage.value = 'Board "$name" created successfully!';
        // Don't call loadBoards() here - let the calling view handle refresh
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

  // Board list management methods
  Future<void> loadBoards() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await BoardService.getAllBoards();

      if (response.success && response.data != null) {
        final boardsData = response.data!;
        ownerBoards.value = boardsData['ownerBoards'] ?? [];
        invitedBoards.value = boardsData['invitedBoards'] ?? [];

        // Combine all boards for the main list
        allBoards.value = [...ownerBoards, ...invitedBoards];

        // Loaded boards successfully

        // Initialize cache with default counts for all boards
        for (final board in allBoards) {
          if (!boardCountsCache.containsKey(board.id)) {
            _updateBoardCountsCache(board.id, 'lists', 0);
            _updateBoardCountsCache(board.id, 'cards', 0);
            // Initialized cache for board
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

  bool isOwnerOfBoard(String boardId) {
    // Check if board is in the owner boards list
    return ownerBoards.any((board) => board.id == boardId);
  }

  // Static cache for board counts
  static final Map<String, Map<String, int>> boardCountsCache = {};

  // Get counts for a specific board
  int getListCountForBoard(String boardId) {
    if (boardId == this.boardId) {
      final count = lists.length;
      _updateBoardCountsCache(boardId, 'lists', count);
      return count;
    }
    // Return cached value or 0
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
    // Return cached value or 0
    return boardCountsCache[boardId]?['cards'] ?? 0;
  }

  // Update cache when data changes
  static void _updateBoardCountsCache(String boardId, String type, int count) {
    if (boardCountsCache[boardId] == null) {
      boardCountsCache[boardId] = {};
    }
    boardCountsCache[boardId]![type] = count;
    // Updated cache for board
  }

  // Update home controller when counts change
  void _notifyHomeController() {
    try {
      final homeController = Get.find<BoardController>(tag: 'home');
      // Trigger refresh in home view
      homeController.allBoards.refresh();
      homeController.ownerBoards.refresh();
      homeController.invitedBoards.refresh();
    } catch (e) {
      // Home controller not found, ignore
    }
  }

  // Load real counts for all boards from API (optimized for HomeView)
  // DISABLED: No longer needed since we don't display counts
  Future<void> loadBoardCounts() async {
    // No longer needed - counts are not displayed
    return;
  }

  // Toggle card completion status
  Future<void> toggleCardCompletion(String cardId, bool isCompleted) async {
    try {
      print('BoardController.toggleCardCompletion called: $cardId -> $isCompleted');

      // Create a new CardController instance for this operation
      final cardController = CardController();
      final success = await cardController.toggleCompletion(cardId, isCompleted);
      print('API call success: $success');

      if (success) {
        // Update the card in cardsByList
        bool updated = false;
        print('Searching for card $cardId in cardsByList...');
        print('cardsByList keys: ${cardsByList.keys.toList()}');

        for (var listId in cardsByList.keys) {
          final cards = cardsByList[listId]!;
          print('Checking list $listId with ${cards.length} cards');

          // Print all card IDs in this list
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
          update(); // Force controller update

          // Also trigger a slight delay to ensure UI updates
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
          'Lỗi',
          'Không thể cập nhật trạng thái thẻ',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error toggling card completion: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật trạng thái thẻ: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}