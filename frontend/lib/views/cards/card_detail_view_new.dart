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

  Future<void> _loadCardData() async {
    await CardDetailHelpers.loadCardData(
      widget.cardId,
      _cardController,
      (card) => setState(() => _card = card),
      (loading) => setState(() => _isLoading = loading),
      (error) => setState(() => _error = error),
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
      return CardDetailWidgets.buildErrorState('Card not found', _loadCardData);
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
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Title
                  CardTitleWidget(
                    card: _card!,
                    titleController: _titleController,
                    isEditing: _isEditingTitle,
                    onStartEditing: _startEditingTitle,
                    onSave: _saveTitle,
                    onCancel: _cancelEditingTitle,
                  ),

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

                  const SizedBox(height: 16),

                  // Actions
                  CardActionsWidget(
                    card: _card!,
                    onToggleComplete: _toggleComplete,
                    onDelete: _deleteCard,
                    onAddAttachment: _addAttachment,
                    onAddComment: _addComment,
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
    setState(() {
      _isEditingTitle = true;
    });
  }

  void _startEditingDescription() {
    setState(() {
      _isEditingDescription = true;
    });
  }

  Future<void> _saveTitle() async {
    if (_titleController.text.trim().isEmpty) {
      CardDetailHelpers.showErrorMessage('Title cannot be empty');
      return;
    }

    await CardDetailHelpers.updateCardTitle(
      widget.cardId,
      _titleController.text.trim(),
      _cardController,
      (card) => setState(() => _card = card),
    );

    setState(() {
      _isEditingTitle = false;
    });

    await _refreshBoardDetail();
    CardDetailHelpers.showSuccessMessage('Title updated successfully');
  }

  Future<void> _saveDescription() async {
    await CardDetailHelpers.updateCardDescription(
      widget.cardId,
      _descriptionController.text.trim(),
      _cardController,
      (card) => setState(() => _card = card),
    );

    setState(() {
      _isEditingDescription = false;
    });
  }

  void _cancelEditingTitle() {
    _titleController.text = _card?.title ?? '';
    setState(() {
      _isEditingTitle = false;
    });
  }

  void _cancelEditingDescription() {
    _descriptionController.text = _card?.description ?? '';
    setState(() {
      _isEditingDescription = false;
    });
  }

  // Additional methods for widget callbacks
  Future<void> _updateDueDate(DateTime? dateTime) async {
    if (dateTime == null) return;

    final success = await _cardController.updateDueDate(
      widget.cardId,
      dateTime.toIso8601String(),
    );

    if (success) {
      setState(() {
        _card = _card?.copyWith(dueDate: dateTime);
      });
      await _refreshBoardDetail();
      Get.snackbar(
        'Success',
        'Due date updated successfully',
        snackPosition: SnackPosition.TOP,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to update due date',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _removeDueDate() async {
    final success = await _cardController.updateDueDate(
      widget.cardId,
      null,
    );

    if (success) {
      setState(() {
        _card = _card?.copyWith(dueDate: null);
      });
      await _refreshBoardDetail();
      Get.snackbar(
        'Success',
        'Due date removed successfully',
        snackPosition: SnackPosition.TOP,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to remove due date',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _toggleComplete() async {
    if (_card == null) return;

    final success = await _cardController.toggleCompletion(
      widget.cardId,
      !_card!.isCompleted,
    );

    if (success) {
      setState(() {
        _card = _card?.copyWith(isCompleted: !_card!.isCompleted);
      });
      await _refreshBoardDetail();
      Get.snackbar(
        'Success',
        _card!.isCompleted ? 'Marked as completed' : 'Marked as incomplete',
        snackPosition: SnackPosition.TOP,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to update status',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _deleteCard() async {
    final success = await _cardController.deleteCard(widget.cardId);

    if (success) {
      await _refreshBoardDetail();
      Get.back();
      Get.snackbar(
        'Success',
        'Card deleted successfully',
        snackPosition: SnackPosition.TOP,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to delete card',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _addAttachment() {
    // TODO: Implement add attachment functionality
    Get.snackbar(
      'Info',
      'Add attachment feature is under development',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _addComment() {
    // TODO: Implement add comment functionality
    Get.snackbar(
      'Info',
      'Add comment feature is under development',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _refreshBoardDetail() async {
    try {
      if (Get.isRegistered<BoardController>(tag: 'board_detail')) {
        final boardController = Get.find<BoardController>(tag: 'board_detail');
        await boardController.loadBoardData();
        print('✅ Board detail refreshed successfully');
      } else {
        print('⚠️ Board detail controller not found');
      }
    } catch (e) {
      print('❌ Error refreshing board detail: $e');
    }
  }
}
