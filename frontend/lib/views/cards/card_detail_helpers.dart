import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/card_controller.dart';
import '../../controllers/board_controller.dart';
import '../../models/card.dart';

class CardDetailHelpers {
  // Load card data
  static Future<void> loadCardData(
    String cardId,
    CardController cardController,
    Function(TaskCard?) setCard,
    Function(bool) setIsLoading,
    Function(String?) setError,
  ) async {
    setIsLoading(true);
    setError(null);

    // Debug logging
    if (cardId.isEmpty) {
      setError('Card ID is empty');
      setIsLoading(false);
      return;
    }

    try {
      final result = await cardController.getCardDetail(cardId);

      // Check both 'success' and 'status' fields for API response
      if ((result['success'] == true || result['status'] == 'success') && result['data'] != null) {
        final card = TaskCard.fromJson(result['data']);
        setCard(card);
      } else {
        // API trả về lỗi hoặc không có data
        final message = result['message'] ?? 'Card not found or API error';

        // Tạo mock card data để test UI khi API fail
        // Ensure cardId is valid ObjectId format
        var validCardId = cardId;
        if (cardId.contains(':') || cardId.isEmpty) {
          validCardId = '507f1f77bcf86cd799439011'; // Valid ObjectId for mock
        }

        final mockCard = TaskCard(
          id: validCardId,
          title: 'Test Card (Mock Data)',
          description: 'This is mock data because API failed to load card details. Original cardId: $cardId',
          listId: 'mock-list-id',
          position: 0,
          isCompleted: false,
          assignedUsers: [],
          attachments: [],
          isDeleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        setCard(mockCard);
        // Vẫn set error để user biết đây là mock data
        setError('Using mock data - API error: $message');
      }
    } catch (e) {
      setError('Failed to load card: ${e.toString()}');
    } finally {
      setIsLoading(false);
    }
  }

  // Update card title
  static Future<void> updateCardTitle(
    String cardId,
    String newTitle,
    CardController cardController,
    Function(TaskCard?) setCard,
  ) async {
    try {
      final success = await cardController.updateCard(cardId, newTitle, null);
      if (success) {
        // Reload card data to get updated information
        final result = await cardController.getCardDetail(cardId);
        if ((result['success'] == true || result['status'] == 'success') && result['data'] != null) {
          final updatedCard = TaskCard.fromJson(result['data']);
          setCard(updatedCard);
        } else {
          // If reload fails, keep current card but show error
        }
      }
    } catch (e) {
      // Error updating title
    }
  }

  // Update card description
  static Future<void> updateCardDescription(
    String cardId,
    String newDescription,
    CardController cardController,
    Function(TaskCard?) setCard,
  ) async {
    try {
      final success = await cardController.updateCard(cardId, null, newDescription);
      if (success) {
        // Reload card data to get updated information
        final result = await cardController.getCardDetail(cardId);
        if ((result['success'] == true || result['status'] == 'success') && result['data'] != null) {
          final updatedCard = TaskCard.fromJson(result['data']);
          setCard(updatedCard);
        } else {
          // If reload fails, keep current card but show error
        }
      }
    } catch (e) {
      // Error updating description
    }
  }

  // Refresh board detail after card update
  static Future<void> refreshBoardDetail(String cardId) async {
    try {
      final cardController = Get.find<CardController>(tag: 'card_detail_$cardId');

      // Get the card to find its list
      final result = await cardController.getCardDetail(cardId);
      final card = result['success'] == true ? TaskCard.fromJson(result['data']) : null;
      if (card?.list?.boardId != null) {
        final boardId = card!.list!.boardId;

        // Find and refresh the board controller
        if (Get.isRegistered<BoardController>(tag: 'board_detail_$boardId')) {
          final boardController = Get.find<BoardController>(tag: 'board_detail_$boardId');
          await boardController.forceRefresh();
        }
      } else {
        // Fallback: try to get board ID from list ID
        final boardId = await _getBoardIdFromListId(card?.list?.id ?? '');
        if (boardId != null) {
          if (Get.isRegistered<BoardController>(tag: 'board_detail_$boardId')) {
            final boardController = Get.find<BoardController>(tag: 'board_detail_$boardId');
            await boardController.forceRefresh();
          }
        }
      }
    } catch (e) {
      // Error refreshing board detail
    }
  }

  // Get board ID from list ID
  static Future<String?> _getBoardIdFromListId(String listId) async {
    try {
      final cardController = Get.find<CardController>();
      final result = await cardController.getListDetail(listId);
      if (result['status'] == 'success' && result['data'] != null) {
        return result['data']['boardId'];
      } else if (result['success'] == true && result['data'] != null) {
        return result['data']['boardId'];
      }
    } catch (e) {
      // Error getting board ID from list
    }
    return null;
  }

  // Show success message
  static void showSuccessMessage(String message) {
    // Success messages removed as requested
  }

  // Show error message
  static void showErrorMessage(String message) {
    // Error messages removed as requested
  }

  // Validate title
  static bool validateTitle(String title) {
    return title.trim().isNotEmpty;
  }

  // Validate description
  static bool validateDescription(String description) {
    return true; // Description is optional
  }

  // Format date
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Format time
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Get relative time
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }
}

