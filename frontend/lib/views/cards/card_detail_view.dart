import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/card_controller.dart';
import '../../controllers/board_controller.dart';
import '../../models/card.dart';
import 'card_detail_widgets.dart';
import 'card_detail_helpers.dart';
import 'widgets/index.dart';

class CardDetailView extends StatefulWidget {
  final String cardId;

  const CardDetailView({
    super.key,
    required this.cardId,
  });

  @override
  State<CardDetailView> createState() => _CardDetailViewState();
}

class _CardDetailViewState extends State<CardDetailView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final CardController _cardController;
  TaskCard? _card;
  bool _isLoading = true;
  String? _error;
  bool _isEditingTitle = false;
  bool _isEditingDescription = false;

  @override
  void initState() {
    super.initState();
    _cardController = Get.put(CardController(), tag: 'card_detail_${widget.cardId}');

    // Force refresh data every time card detail is opened
    // This ensures we get the latest data from the server
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCardData();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    Get.delete<CardController>(tag: 'card_detail_${widget.cardId}');
    super.dispose();
  }

  // Safe setState that checks if widget is still mounted
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  Future<void> _loadCardData() async {
    await CardDetailHelpers.loadCardData(
      widget.cardId,
      _cardController,
      (card) => _safeSetState(() => _card = card),
      (loading) => _safeSetState(() => _isLoading = loading),
      (error) => _safeSetState(() => _error = error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Refresh board detail when closing card detail
        await _refreshBoardDetail();
        return true;
      },
      child: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return CardDetailWidgets.buildLoadingState();
    }

    if (_error != null) {
      return CardDetailWidgets.buildErrorState(_error!, _loadCardData);
    }

    if (_card == null) {
      return CardDetailWidgets.buildErrorState(
        _error ?? 'Card not found',
        _loadCardData,
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header
          CardHeaderWidget(
            card: _card,
            onBack: () => Get.back(),
            onDelete: _deleteCard,
            onToggleComplete: _toggleComplete,
            onEditTitle: _startEditingTitle,
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Title editing (when in edit mode)
                  if (_isEditingTitle) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Edit Title',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              hintText: 'Enter card title',
                              border: OutlineInputBorder(),
                            ),
                            autofocus: true,
                            onSubmitted: (_) => _saveTitle(),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: _cancelEditingTitle,
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _saveTitle,
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else
                    const SizedBox(height: 16),

                  // Description
                  CardDescriptionWidget(
                    card: _card!,
                    descriptionController: _descriptionController,
                    isEditing: _isEditingDescription,
                    onStartEditing: _startEditingDescription,
                    onSave: _saveDescription,
                    onCancel: _cancelEditingDescription,
                  ),

                  const SizedBox(height: 16),

                  // Due Date
                  CardDueDateWidget(
                    card: _card!,
                    onUpdateDueDate: _updateDueDate,
                    onRemoveDueDate: _removeDueDate,
                  ),

                  const SizedBox(height: 16),

                  // Assigned Users
                  CardAssignedUsersWidget(
                    card: _card!,
                    onAssignUser: _assignUser,
                    onUnassignUser: _unassignUser,
                  ),

                  const SizedBox(height: 16),

                  // Attachments
                  CardAttachmentsWidget(
                    card: _card!,
                    onAddAttachment: _addAttachment,
                  ),

                  const SizedBox(height: 16),

                  // Comments
                  CardCommentsWidget(
                    card: _card!,
                    onAddComment: _addComment,
                  ),

                  const SizedBox(height: 24),

                  // Delete Card Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      onPressed: () => _showDeleteConfirmDialog(),
                      icon: const Icon(Icons.delete_outline, color: Colors.white),
                      label: const Text(
                        'Delete Card',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Edit functionality methods
  void _startEditingTitle() {
    _safeSetState(() {
      _isEditingTitle = true;
    });
  }

  void _startEditingDescription() {
    _safeSetState(() {
      _isEditingDescription = true;
    });
  }

  Future<void> _saveTitle() async {
    if (_titleController.text.trim().isEmpty) {
      CardDetailHelpers.showErrorMessage('Title cannot be empty');
      return;
    }

    // Update card locally first for instant UI update
    final newTitle = _titleController.text.trim();
    _safeSetState(() {
      _card = _card?.copyWith(title: newTitle);
      _isEditingTitle = false;
    });

    // Then update on server
    await CardDetailHelpers.updateCardTitle(
      widget.cardId,
      newTitle,
      _cardController,
      (card) => _safeSetState(() => _card = card),
    );

    await _refreshBoardDetail();
    CardDetailHelpers.showSuccessMessage('Title updated successfully');
  }

  Future<void> _saveDescription() async {
    // Update card locally first for instant UI update
    final newDescription = _descriptionController.text.trim();
    _safeSetState(() {
      _card = _card?.copyWith(description: newDescription);
      _isEditingDescription = false;
    });

    // Then update on server
    await CardDetailHelpers.updateCardDescription(
      widget.cardId,
      newDescription,
      _cardController,
      (card) => _safeSetState(() => _card = card),
    );

    await _refreshBoardDetail();
    CardDetailHelpers.showSuccessMessage('Description updated successfully');
  }

  void _cancelEditingTitle() {
    _titleController.text = _card?.title ?? '';
    _safeSetState(() {
      _isEditingTitle = false;
    });
  }

  void _cancelEditingDescription() {
    _descriptionController.text = _card?.description ?? '';
    _safeSetState(() {
      _isEditingDescription = false;
    });
  }

  // Additional methods for widget callbacks
  Future<void> _updateDueDate(DateTime? dateTime) async {
    if (dateTime == null) return;

    // Update card locally first for instant UI update
    _safeSetState(() {
      _card = _card?.copyWith(dueDate: dateTime);
    });

    final success = await _cardController.updateDueDate(
      widget.cardId,
      dateTime.toIso8601String(),
    );

    if (success) {
      await _refreshBoardDetail();
    } else {
      // Revert local change if server update failed
      _safeSetState(() {
        _card = _card?.copyWith(dueDate: _card?.dueDate);
      });
    }
  }

  Future<void> _removeDueDate() async {
    // Store original date for potential revert
    final originalDate = _card?.dueDate;

    // Update card locally first for instant UI update
    _safeSetState(() {
      _card = _card?.copyWith(dueDate: null);
    });

    final success = await _cardController.updateDueDate(
      widget.cardId,
      null,
    );

    if (success) {
      await _refreshBoardDetail();
    } else {
      // Revert local change if server update failed
      _safeSetState(() {
        _card = _card?.copyWith(dueDate: originalDate);
      });
    }
  }

  Future<void> _toggleComplete() async {
    if (_card == null) return;

    // Store original state for potential revert
    final originalState = _card!.isCompleted;
    final newState = !originalState;

    // Update card locally first for instant UI update
    _safeSetState(() {
      _card = _card?.copyWith(isCompleted: newState);
    });

    final success = await _cardController.toggleCompletion(
      widget.cardId,
      newState,
    );

    if (success) {
      await _refreshBoardDetail();
    } else {
      // Revert local change if server update failed
      _safeSetState(() {
        _card = _card?.copyWith(isCompleted: originalState);
      });
    }
  }

  void _showDeleteConfirmDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Card'),
        content: Text(
          'Are you sure you want to delete "${_card?.title ?? 'this card'}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              _deleteCard();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCard() async {
    final success = await _cardController.deleteCard(widget.cardId);

    if (success) {
      await _refreshBoardDetail();
      Get.back();
    }
  }

  void _addAttachment(String filename, String url) {
    // TODO: Call API to save attachment to server
    // For now, just refresh board detail
    _refreshBoardDetail();
  }

  void _addComment(String commentText) {
    // TODO: Call API to save comment to server
    // For now, just refresh board detail
    _refreshBoardDetail();
  }

  Future<void> _assignUser(String userId) async {
    if (_card == null) return;

    if (_card!.assignedUsers.contains(userId)) {
      return;
    }

    final originalUsers = List<String>.from(_card!.assignedUsers);
    final updatedUsers = [..._card!.assignedUsers, userId];
    _safeSetState(() {
      _card = _card?.copyWith(assignedUsers: updatedUsers);
    });

    final ok = await _cardController.assignUser(_card!.id, userId);
    if (ok) {
      await _refreshBoardDetail();
    } else {
      // revert on failure
      _safeSetState(() {
        _card = _card?.copyWith(assignedUsers: originalUsers);
      });
    }
  }

  Future<void> _unassignUser(String userId) async {
    if (_card == null) return;

    final originalUsers = List<String>.from(_card!.assignedUsers);
    final updatedUsers = _card!.assignedUsers.where((id) => id != userId).toList();
    _safeSetState(() {
      _card = _card?.copyWith(assignedUsers: updatedUsers);
    });

    final ok = await _cardController.unassignUser(_card!.id, userId);
    if (ok) {
      await _refreshBoardDetail();
    } else {
      // revert on failure
      _safeSetState(() {
        _card = _card?.copyWith(assignedUsers: originalUsers);
      });
    }
  }

  Future<void> _refreshBoardDetail() async {
    try {
      // Prioritize getting boardId from list embed if available
      String? boardId = _card?.list?.boardId;
      String? listId = _card?.list?.id ?? _card?.listId;

      // Fallback: if no list embed, use listId to call API to get boardId
      if ((boardId == null || boardId.isEmpty) && (listId != null && listId.isNotEmpty)) {
        final listDetail = await _cardController.getListDetail(listId);
        if ((listDetail['status'] == 'success' || listDetail['success'] == true) &&
            listDetail['data'] != null) {
          boardId = listDetail['data']['boardId'];
        }
      }

      if (boardId != null && boardId.isNotEmpty) {
        final boardControllerTag = 'board_detail_$boardId';
        if (Get.isRegistered<BoardController>(tag: boardControllerTag)) {
          final boardController = Get.find<BoardController>(tag: boardControllerTag);

          // Update card in temporary memory if current data exists
          if (_card != null && (listId != null && listId.isNotEmpty)) {
            final cards = boardController.cardsByList[listId];
            if (cards != null) {
              final cardIndex = cards.indexWhere((c) => c.id == _card!.id);
              if (cardIndex != -1) {
                cards[cardIndex] = _card!;
                boardController.cardsByList.refresh();
              }
            }
          }

          // Force refresh to sync data from server
          await boardController.forceRefresh();
        }
      }
    } catch (e) {
      print('Error refreshing board detail: $e');
    }
  }
}
