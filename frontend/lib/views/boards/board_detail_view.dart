import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/list.dart';
import '../../models/card.dart';
import '../../controllers/board_controller.dart';
import 'board_detail_widgets.dart';
import 'board_detail_helpers.dart';

class BoardDetailView extends StatefulWidget {
  final String boardId;
  final String? boardName;

  const BoardDetailView({
    super.key,
    required this.boardId,
    this.boardName,
  });

  @override
  State<BoardDetailView> createState() => _BoardDetailViewState();
}

class _BoardDetailViewState extends State<BoardDetailView> {
  late final ScrollController _scrollController;
  bool _isDragging = false;
  bool _isAutoScrolling = false;
  bool _controllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Clean up controller when leaving the page
    if (Get.isRegistered<BoardController>(tag: 'board_detail_${widget.boardId}')) {
      Get.delete<BoardController>(tag: 'board_detail_${widget.boardId}');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize controller only once
    if (!_controllerInitialized) {
      // Remove existing controller if any to prevent conflicts
      if (Get.isRegistered<BoardController>(tag: 'board_detail_${widget.boardId}')) {
        Get.delete<BoardController>(tag: 'board_detail_${widget.boardId}');
      }

      final controller = Get.put(
        BoardController(),
        tag: 'board_detail_${widget.boardId}',
      );
      controller.setBoardId(widget.boardId);
      _controllerInitialized = true;

      // Force refresh data when controller is first created
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.forceRefresh();
      });
    }

    // Get the controller
    final controller = Get.find<BoardController>(tag: 'board_detail_${widget.boardId}');
    return _buildScaffold(controller);
  }

  Widget _buildScaffold(BoardController controller) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.currentBoard.value?.name ?? widget.boardName ?? 'Loading...',
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return BoardDetailHelpers.buildLoadingState();
        }

        if (controller.error.value.isNotEmpty) {
          return BoardDetailHelpers.buildErrorState(
            controller.error.value,
            () => controller.loadBoardData(),
          );
        }

        if (controller.lists.isEmpty) {
          return BoardDetailHelpers.buildEmptyStateWithAddButton(controller);
        }

        return RefreshIndicator(
          onRefresh: () => controller.forceRefresh(),
          child: _buildScrollableBoard(controller),
        );
      }),
    );
  }

  Widget _buildScrollableBoard(BoardController controller) {
    final listWidgets = controller.lists.asMap().entries.map((entry) {
      final index = entry.key;
      final list = entry.value;
      return _buildDraggableList(controller, list, index);
    }).toList();

    final addListWidget = Container(
      width: 320,
      height: 60,
      child: BoardDetailWidgets.buildAddListColumn(controller),
    );

    return BoardDetailWidgets.buildScrollableBoard(
      controller,
      _scrollController,
      _handlePointerMove,
      listWidgets,
      addListWidget,
    );
  }

  void _handlePointerMove(PointerMoveEvent event) {
    // Giảm tần suất gọi handlePointerMove để giảm giật
    if (!_isDragging) return;

    BoardDetailHelpers.handlePointerMove(
      event,
      _scrollController,
      _isDragging,
      _isAutoScrolling,
      (value) {
        if (_isAutoScrolling != value) {
          _isAutoScrolling = value;
          // Chỉ setState khi giá trị thực sự thay đổi và widget còn mounted
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() {});
            });
          }
        }
      },
      (value) {}, // Không cần setState cho scroll speed
    );
  }


  Widget _buildDraggableList(BoardController controller, TaskList list, int index) {
    return BoardDetailWidgets.buildDraggableList(
      controller,
      list,
      index,
      _buildListColumn(controller, list, index),
    );
  }

  Widget _buildListColumn(BoardController controller, TaskList list, int index) {
    return BoardDetailWidgets.buildListColumn(
      controller,
      list,
      index,
      () {
        if (!_isDragging) {
          _isDragging = true;
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() {});
            });
          }
        }
      },
      () {
        if (_isDragging) {
          _isDragging = false;
          _isAutoScrolling = false; // Reset auto scroll khi kết thúc drag
          BoardDetailHelpers.handleDragEnd(); // Dừng timer
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() {});
            });
          }
        }
      },
      _buildListFeedback,
      () => BoardDetailHelpers.showAddCardDialog(controller, list.id),
      (controller, card, listId, cardIndex) => _buildHybridCardWithScroll(controller, card, listId, cardIndex),
    );
  }

  Widget _buildHybridCardWithScroll(BoardController controller, TaskCard card, String listId, int index) {
    return BoardDetailWidgets.buildHybridCardWithScroll(
      controller,
      card,
      listId,
      index,
      () {
        if (!_isDragging) {
          _isDragging = true;
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() {});
            });
          }
        }
      },
      () {
        if (_isDragging) {
          _isDragging = false;
          _isAutoScrolling = false; // Reset auto scroll khi kết thúc drag
          BoardDetailHelpers.handleDragEnd(); // Dừng timer
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() {});
            });
          }
        }
      },
    );
  }

  Widget _buildListFeedback(TaskList list, int index) {
    return BoardDetailWidgets.buildListFeedback(list, index);
  }
}