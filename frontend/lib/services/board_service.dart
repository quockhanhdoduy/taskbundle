import '../models/list.dart';
import '../models/card.dart';
import '../models/board.dart';
import '../models/response_model.dart';
import '../config/api_endpoints.dart';
import 'api_service.dart';

class BoardService {
  // Get all boards for home view
  static Future<ApiResponse<Map<String, List<Board>>>> getAllBoards() async {
    try {
      final response = await ApiService.get(ApiEndpoints.boardsHomeView);

      if (response['success'] == true || response['status'] == 'success') {
        final Map<String, dynamic> data = response['data'] ?? {};

        // Parse invited boards
        final List<dynamic> invitedBoardsData = data['invitedBoards'] ?? [];
        final List<Board> invitedBoards = invitedBoardsData
            .map((boardJson) => Board.fromJson(boardJson))
            .toList();

        // Parse owner boards
        final List<dynamic> ownerBoardsData = data['ownerBoards'] ?? [];
        final List<Board> ownerBoards = ownerBoardsData
            .map((boardJson) => Board.fromJson(boardJson))
            .toList();

        return ApiResponse(
          success: true,
          message: 'Success',
          data: {
            'invitedBoards': invitedBoards,
            'ownerBoards': ownerBoards,
          }
        );
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to fetch boards',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
        data: null,
      );
    }
  }

  // Get board counts for all boards (optimized for HomeView)
  static Future<ApiResponse<Map<String, Map<String, int>>>> getAllBoardCounts(List<String> boardIds) async {
    try {
      Map<String, Map<String, int>> allCounts = {};

      // Load counts for each board in parallel
      final futures = boardIds.map((boardId) => _getSingleBoardCounts(boardId));
      final results = await Future.wait(futures);

      for (int i = 0; i < boardIds.length; i++) {
        allCounts[boardIds[i]] = results[i];
      }

      return ApiResponse(
        success: true,
        message: 'Success',
        data: allCounts
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error getting all board counts: ${e.toString()}',
        data: {}
      );
    }
  }

  // Helper method to get counts for a single board
  static Future<Map<String, int>> _getSingleBoardCounts(String boardId) async {
    try {
      final listsResponse = await ApiService.get(ApiEndpoints.boardLists(boardId));

      if (listsResponse['success'] == true) {
        final List<dynamic> listsData = listsResponse['data'] ?? [];
        final int listCount = listsData.length;

        // Count total cards across all lists in parallel
        final cardFutures = listsData.map((listData) async {
          try {
            final cardsResponse = await ApiService.get(ApiEndpoints.listCards(listData['_id']));
            if (cardsResponse['success'] == true) {
              final List<dynamic> cardsData = cardsResponse['data'] ?? [];
              return cardsData.length;
            }
          } catch (e) {
            // Ignore errors for individual lists
          }
          return 0;
        });

        final cardCounts = await Future.wait(cardFutures);
        final totalCards = cardCounts.fold<int>(0, (sum, count) => sum + count);

        return {'lists': listCount, 'cards': totalCards};
      } else {
        return {'lists': 0, 'cards': 0};
      }
    } catch (e) {
      return {'lists': 0, 'cards': 0};
    }
  }

  // Get board counts for a specific board (kept for backward compatibility)
  static Future<ApiResponse<Map<String, int>>> getBoardCounts(String boardId) async {
    try {
      final counts = await _getSingleBoardCounts(boardId);
      return ApiResponse(
        success: true,
        message: 'Success',
        data: counts
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error getting board counts: ${e.toString()}',
        data: {'lists': 0, 'cards': 0}
      );
    }
  }

  // Create a new board
  static Future<ApiResponse<Board>> createBoard(String name) async {
    try {
      final requestData = {
        'name': name,
      };

      final response = await ApiService.post(
        ApiEndpoints.boards,
        requestData,
      );

      if (response['success'] == true || response['status'] == 'success') {
        final Board newBoard = Board.fromJson(response['data']);
        return ApiResponse(success: true, message: 'Success', data: newBoard);
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to create board',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
        data: null,
      );
    }
  }

  // Get all lists for a specific board
  static Future<ApiResponse<List<TaskList>>> getListsByBoard(String boardId) async {
    try {
      final response = await ApiService.get(ApiEndpoints.boardLists(boardId));

      if (response['success'] == true || response['status'] == 'success') {
        final List<dynamic> listsData = response['data'] ?? [];
        final List<TaskList> lists = listsData
            .map((listJson) => TaskList.fromJson(listJson))
            .toList();

        return ApiResponse(success: true, message: 'Success', data: lists);
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to fetch lists',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
        data: null,
      );
    }
  }

  // Create a new list in a board
  static Future<ApiResponse<TaskList>> createList(String boardId, String name) async {
    try {
      // Get current lists to calculate position
      final currentListsResponse = await getListsByBoard(boardId);
      int position = 0;

      if (currentListsResponse.success && currentListsResponse.data != null) {
        position = currentListsResponse.data!.length;
      }

      final requestData = {
        'name': name,
        'position': position,
      };

      final response = await ApiService.post(
        ApiEndpoints.boardLists(boardId),
        requestData,
      );

      if (response['success'] == true || response['status'] == 'success') {
        final TaskList newList = TaskList.fromJson(response['data']);
        return ApiResponse(success: true, message: 'Success', data: newList);
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to create list',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
        data: null,
      );
    }
  }

  // Update list name
  static Future<ApiResponse<TaskList>> updateList(String listId, String name) async {
    try {
      final requestData = {
        'name': name,
      };

      final response = await ApiService.put(
        ApiEndpoints.listUpdate(listId),
        requestData,
      );

      if (response['success'] == true || response['status'] == 'success') {
        final TaskList updatedList = TaskList.fromJson(response['data']);
        return ApiResponse(success: true, message: 'Success', data: updatedList);
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to update list',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
        data: null,
      );
    }
  }

  // Delete a list
  static Future<ApiResponse<bool>> deleteList(String listId) async {
    try {
      final response = await ApiService.delete(ApiEndpoints.listDelete(listId));

      if (response['success'] == true || response['status'] == 'success') {
        return ApiResponse(success: true, message: 'Success', data: true);
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to delete list',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
        data: null,
      );
    }
  }

  // Get all cards for a specific list
  static Future<ApiResponse<List<TaskCard>>> getCardsByList(String listId) async {
    try {
      final response = await ApiService.get(ApiEndpoints.listCards(listId));

      if (response['success'] == true || response['status'] == 'success') {
        final List<dynamic> cardsData = response['data'] ?? [];
        final List<TaskCard> cards = cardsData
            .map((cardJson) => TaskCard.fromJson(cardJson))
            .toList();

        return ApiResponse(success: true, message: 'Success', data: cards);
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to fetch cards',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
        data: null,
      );
    }
  }

  // Create a new card in a list
  static Future<ApiResponse<TaskCard>> createCard(String listId, String title, [String? description]) async {
    try {
      // Get current cards to calculate position
      final currentCardsResponse = await getCardsByList(listId);
      int position = 0;

      if (currentCardsResponse.success && currentCardsResponse.data != null) {
        position = currentCardsResponse.data!.length;
      }

      final requestData = {
        'title': title,
        'position': position,
        if (description != null && description.isNotEmpty) 'description': description,
      };

      final response = await ApiService.post(
        ApiEndpoints.listCards(listId),
        requestData,
      );

      if (response['success'] == true || response['status'] == 'success') {
        final TaskCard newCard = TaskCard.fromJson(response['data']);
        return ApiResponse(success: true, message: 'Success', data: newCard);
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to create card',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
        data: null,
      );
    }
  }
}
