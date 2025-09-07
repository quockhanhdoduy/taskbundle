import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';
import '../../models/list.dart';
import '../../models/card.dart';
import '../../controllers/board_controller.dart';

class BoardDetailWidgets {
  // Build scaffold for board detail
  static Widget buildScaffold(
    BuildContext context,
    BoardController controller,
    String? boardName,
    Widget body,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.currentBoard.value?.name ?? boardName ?? 'Loading...',
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {
              // TODO: Invite members
            },
          ),
        ],
      ),
      body: body,
    );
  }

  // Build scrollable board
  static Widget buildScrollableBoard(
    BoardController controller,
    ScrollController scrollController,
    PointerMoveEventListener onPointerMove,
    List<Widget> listWidgets,
    Widget addListWidget,
  ) {
    return Listener(
      onPointerMove: onPointerMove,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...listWidgets,
            addListWidget,
          ],
        ),
      ),
    );
  }

  // Build draggable list
  static Widget buildDraggableList(
    BoardController controller,
    TaskList list,
    int index,
    Widget listColumn,
  ) {
    return Container(
      width: 296, // 280 + 16 margin để giữ nguyên spacing tổng thể
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) {
          return details.data != index;
        },
        onAcceptWithDetails: (details) {
          controller.reorderLists(details.data, index);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: candidateData.isNotEmpty
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue, width: 3), // Tăng border để dễ thấy
                    color: Colors.blue.withValues(alpha: 0.1), // Thêm background color
                )
              : null,
            child: Container(
              width: 280,
          child: listColumn,
            ),
        );
      },
      ),
    );
  }

  // Build list column
  static Widget buildListColumn(
    BoardController controller,
    TaskList list,
    int index,
    VoidCallback onDragStarted,
    VoidCallback onDragEnd,
    Widget Function(TaskList list, int index) buildListFeedback,
    VoidCallback onShowAddCardDialog,
    Widget Function(BoardController controller, TaskCard card, String listId, int index) buildHybridCard,
  ) {
    // Get list color based on position or name
    final listColors = [
      Colors.blue[50]!,
      Colors.green[50]!,
      Colors.orange[50]!,
      Colors.purple[50]!,
      Colors.red[50]!,
      Colors.teal[50]!,
    ];

    final headerColors = [
      Colors.blue[100]!,
      Colors.green[100]!,
      Colors.orange[100]!,
      Colors.purple[100]!,
      Colors.red[100]!,
      Colors.teal[100]!,
    ];

    final listIndex = controller.lists.indexOf(list);
    final backgroundColor = listColors[listIndex % listColors.length];
    final headerColor = headerColors[listIndex % headerColors.length];

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) => details.data['listId'] != list.id,
      onAcceptWithDetails: (details) {
        // Find the card from the data
        final fromListId = details.data['listId'];
        final fromIndex = details.data['index'];

        // Find the card object
        final fromCards = controller.cardsByList[fromListId];
        if (fromCards != null && fromIndex < fromCards.length) {
          final card = fromCards[fromIndex];
          controller.moveCardToList(card, fromListId, fromIndex, list.id);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty ? Colors.blue[50] : backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.blue[300]! : Colors.grey[300]!,
              width: candidateData.isNotEmpty ? 2 : 1
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildListHeader(
                list,
                index,
                headerColor,
                candidateData,
                onDragStarted,
                onDragEnd,
                buildListFeedback,
              ),
              _buildCardsArea(
                controller,
                list,
                buildHybridCard,
              ),
              _buildAddCardButton(
                candidateData,
                onShowAddCardDialog,
              ),
            ],
          ),
        );
      },
    );
  }

  // Build list header
  static Widget _buildListHeader(
    TaskList list,
    int index,
    Color headerColor,
    List<Map<String, dynamic>?> candidateData,
    VoidCallback onDragStarted,
    VoidCallback onDragEnd,
    Widget Function(TaskList list, int index) buildListFeedback,
  ) {
    return LongPressDraggable<int>(
      data: index,
      onDragStarted: onDragStarted,
      onDragEnd: (details) => onDragEnd(),
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 280,
          child: buildListFeedback(list, index),
        ),
      ),
      childWhenDragging: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          border: Border.all(color: Colors.grey[400]!, width: 2),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                list.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: candidateData.isNotEmpty ? Colors.blue[100] : headerColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                list.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build cards area
  static Widget _buildCardsArea(
    BoardController controller,
    TaskList list,
    Widget Function(BoardController controller, TaskCard card, String listId, int index) buildHybridCard,
  ) {
    return Expanded(
      child: Obx(() {
        final cards = controller.cardsByList[list.id] ?? [];

        if (cards.isEmpty) {
          return const SizedBox(height: 8); // Minimal space when no cards
        }

        return ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          buildDefaultDragHandles: false,
          proxyDecorator: (child, index, animation) => Material(
            color: Colors.transparent,
            child: child,
          ),
          itemCount: cards.length,
          onReorder: (fromIndex, toIndex) {
            controller.reorderCardsInList(list.id, fromIndex, toIndex);
          },
          itemBuilder: (context, index) {
            if (index >= cards.length) return const SizedBox.shrink();
            final card = cards[index];
            return ReorderableDragStartListener(
              key: Key('card_reorder_${card.id}'),
              index: index,
              child: buildHybridCard(controller, card, list.id, index),
            );
          },
        );
      }),
    );
  }

  // Build add card button
  static Widget _buildAddCardButton(
    List<Map<String, dynamic>?> candidateData,
    VoidCallback onShowAddCardDialog,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: candidateData.isNotEmpty ? Colors.blue[100] : Colors.transparent,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: onShowAddCardDialog,
            icon: Icon(Icons.add, size: 16, color: Colors.grey[600]),
            label: Text(
              'Add Card',
              style: TextStyle(color: Colors.grey[600]),
            ),
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(10),
              backgroundColor: Colors.white.withValues(alpha: 0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build hybrid card
  static Widget buildHybridCard(
    BoardController controller,
    TaskCard card,
    String listId,
    int index,
  ) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) => details.data['listId'] != listId,
      onAcceptWithDetails: (details) {
        final fromListId = details.data['listId'];
        final fromIndex = details.data['index'];

        // Find the card from the source list
        final fromCards = controller.cardsByList[fromListId];
        if (fromCards != null && fromIndex < fromCards.length) {
          final draggedCard = fromCards[fromIndex];
          controller.moveCardToListAtPosition(draggedCard, fromListId, fromIndex, listId, index);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Stack(
          children: [
            // Main card with tap and drag functionality
            GestureDetector(
              onTap: () {
                // Open card detail
                if (card.id.isEmpty) {
                  Get.snackbar('Error', 'Card ID is empty');
                  return;
                }
                final route = AppRoutes.cardDetail.replaceAll(':cardId', card.id);
                Get.toNamed(route);
              },
              child: LongPressDraggable<Map<String, dynamic>>(
      key: Key('card_${card.id}'),
      data: {
        'cardId': card.id,
        'listId': listId,
        'index': index,
  },
      onDragStarted: () {
                  // Handle card drag started - could add visual feedback here
      },
      onDragEnd: (details) {
                  // Handle card drag end - clean up any visual states
                },
                feedback: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 256,
                    child: buildCardContentWithoutCheckbox(card),
                  ),
                ),
                childWhenDragging: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[400]!, width: 2),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    card.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                child: Container(
                  decoration: candidateData.isNotEmpty
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue, width: 2),
                        )
                      : null,
                    child: buildCardWithoutCheckbox(card),
                  ),
                ),
              ),
            // Checkbox positioned on top
            Positioned(
              top: 12,
              left: 12,
              child: GestureDetector(
                onTap: () {
                  print('Checkbox tapped directly!');
                  _toggleCardCompletion(card, controller);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 26,
                  height: 26,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: card.isCompleted ? Colors.green : Colors.grey[400]!,
                        width: 2,
                      ),
                      color: card.isCompleted ? Colors.green : Colors.transparent,
                    ),
                    child: card.isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Build hybrid card with scroll
  static Widget buildHybridCardWithScroll(
    BoardController controller,
    TaskCard card,
    String listId,
    int index,
    VoidCallback onDragStarted,
    VoidCallback onDragEnd,
  ) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) => details.data['listId'] != listId,
      onAcceptWithDetails: (details) {
        final fromListId = details.data['listId'];
        final fromIndex = details.data['index'];

        // Find the card from the source list
        final fromCards = controller.cardsByList[fromListId];
        if (fromCards != null && fromIndex < fromCards.length) {
          final draggedCard = fromCards[fromIndex];
          controller.moveCardToListAtPosition(draggedCard, fromListId, fromIndex, listId, index);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: () {
            // Open card detail
            if (card.id.isEmpty) {
              Get.snackbar('Error', 'Card ID is empty');
              return;
            }
            final route = AppRoutes.cardDetail.replaceAll(':cardId', card.id);
            Get.toNamed(route);
          },
          child: LongPressDraggable<Map<String, dynamic>>(
          key: Key('card_${card.id}'),
          data: {
            'cardId': card.id,
            'listId': listId,
            'index': index,
          },
          onDragStarted: onDragStarted,
          onDragEnd: (details) => onDragEnd(),
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 256,
          child: buildCardContent(card, showInkWell: false),
        ),
      ),
      childWhenDragging: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[400]!, width: 2),
        ),
        padding: const EdgeInsets.all(12),
        child: Text(
          card.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ),
          child: Container(
            decoration: candidateData.isNotEmpty
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue, width: 2),
                  )
                : null,
      child: buildCard(card),
            ),
          ),
        );
      },
    );
  }

  // Build card
  static Widget buildCard(TaskCard card, {Key? key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 6),
      child: buildCardContent(card, showInkWell: true),
    );
  }

  // Build card without checkbox (for draggable)
  static Widget buildCardWithoutCheckbox(TaskCard card, {Key? key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 6),
      child: buildCardContentWithoutCheckbox(card),
    );
  }

  // Build card content
  static Widget buildCardContent(TaskCard card, {bool showInkWell = false}) {
    Widget content = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title with completion checkbox
          Row(
            children: [
              // Completion checkbox
              GestureDetector(
                onTap: () => _toggleCardCompletion(card, Get.find<BoardController>()),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 26, // Increased hit area
                  height: 26, // Increased hit area
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: card.isCompleted ? Colors.green : Colors.grey[400]!,
                        width: 2,
                      ),
                      color: card.isCompleted ? Colors.green : Colors.transparent,
                    ),
                    child: card.isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          )
                        : null,
                  ),
                ),
              ),

              // Title
              Expanded(
                child: Text(
                  card.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    decoration: card.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: card.isCompleted
                        ? Colors.grey[600]
                        : Colors.black,
                  ),
                ),
              ),
            ],
          ),

          // Due date (if exists)
          if (card.dueDate != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 12,
                  color: _getDueDateColor(card.dueDate!),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDueDate(card.dueDate!),
                  style: TextStyle(
                    fontSize: 11,
                    color: _getDueDateColor(card.dueDate!),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    // InkWell không cần thiết vì đã có GestureDetector ở level cao hơn
    return content;
  }

  // Build card content without checkbox (for draggable feedback)
  static Widget buildCardContentWithoutCheckbox(TaskCard card) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(40, 12, 12, 12), // Left padding for checkbox space
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title only
          Text(
            card.title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              decoration: card.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: card.isCompleted
                  ? Colors.grey[600]
                  : Colors.black,
            ),
          ),

          // Due date (if exists)
          if (card.dueDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: _getDueDateColor(card.dueDate!),
                ),
                const SizedBox(width: 4),
            Text(
                  _formatDueDate(card.dueDate!),
              style: TextStyle(
                fontSize: 12,
                    color: _getDueDateColor(card.dueDate!),
                    fontWeight: FontWeight.w500,
              ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Toggle card completion
  static void _toggleCardCompletion(TaskCard card, BoardController controller) {
    try {
      print('Attempting to toggle card completion: ${card.id}, current: ${card.isCompleted}');
      print('Using controller: $controller');

      controller.toggleCardCompletion(card.id, !card.isCompleted);
      print('Called toggleCardCompletion');
    } catch (e) {
      print('Error in _toggleCardCompletion: $e');
    }
  }

  // Get due date color based on status
  static Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return Colors.red; // Overdue
    } else if (difference == 0) {
      return Colors.orange; // Due today
    } else if (difference <= 3) {
      return Colors.amber; // Due soon
    } else {
      return Colors.green; // Not urgent
    }
  }

  // Format due date for display
  static String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return '${(-difference)} days ago';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      return '$difference days left';
    }
  }

  // Build add list column
  static Widget buildAddListColumn(BoardController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showAddListDialog(controller),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 15, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text(
                  'Add List',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build list feedback
  static Widget buildListFeedback(TaskList list, int index) {
    final listColors = [
      Colors.blue[50]!,
      Colors.green[50]!,
      Colors.orange[50]!,
      Colors.purple[50]!,
      Colors.red[50]!,
      Colors.teal[50]!,
    ];

    final headerColors = [
      Colors.blue[100]!,
      Colors.green[100]!,
      Colors.orange[100]!,
      Colors.purple[100]!,
      Colors.red[100]!,
      Colors.teal[100]!,
    ];

    final backgroundColor = listColors[index % listColors.length];
    final headerColor = headerColors[index % headerColors.length];

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    list.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 100,
              padding: const EdgeInsets.all(12),
              child: const Center(
                child: Text(
                  'Moving...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show add list dialog
  static void _showAddListDialog(BoardController controller) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: Get.context!,
      barrierDismissible: true,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            body: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New List',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'List Name',
            hintText: 'Enter list name...',
                      border: OutlineInputBorder(),
          ),
          autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        Navigator.of(context).pop();
                        controller.createList(value.trim());
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
          TextButton(
                        onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
                      const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                            Navigator.of(context).pop();
                controller.createList(nameController.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Show add card dialog
  static void showAddCardDialog(BoardController controller, String listId) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    Get.dialog(
      Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.8,
            maxWidth: MediaQuery.of(Get.context!).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Add New Card',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              // Content - Scrollable
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Card Title',
                          hintText: 'Enter card title...',
                          border: OutlineInputBorder(),
                        ),
                        autofocus: true,
                        maxLines: 2,
                        minLines: 1,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Enter card description...',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        minLines: 2,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              // Actions
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (titleController.text.trim().isNotEmpty) {
                          Get.back();
                          final description = descriptionController.text.trim().isEmpty
                              ? null
                              : descriptionController.text.trim();
                          controller.createCard(listId, titleController.text.trim(), description);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
