import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/list.dart';
import '../../models/card.dart';
import '../../models/board.dart';
import '../../controllers/board_controller.dart';
import 'board_detail_widgets.dart';
import 'board_detail_helpers.dart';
import 'board_members_view.dart';
import 'board_activities_view.dart';

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
  String? _titleOverride; // Tên board tạm thời để hiển thị ngay lập tức

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Listen for controller updates to clear override when needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupTitleOverrideListener();
    });
  }

  void _setupTitleOverrideListener() {
    // Lắng nghe thay đổi từ controller để clear override khi cần
    if (Get.isRegistered<BoardController>(tag: 'board_detail_${widget.boardId}')) {
      final controller = Get.find<BoardController>(tag: 'board_detail_${widget.boardId}');

      // Listen to currentBoard changes
      ever(controller.currentBoard, (Board? board) {
        if (_titleOverride != null && board?.name == _titleOverride) {
          // Controller đã cập nhật đúng tên, có thể clear override
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && _titleOverride == board?.name) {
              setState(() {
                _titleOverride = null;
              });
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Clear title override when leaving
    _titleOverride = null;
    // Clean up controller when leaving the page
    if (Get.isRegistered<BoardController>(tag: 'board_detail_${widget.boardId}')) {
      Get.delete<BoardController>(tag: 'board_detail_${widget.boardId}');
    }
    super.dispose();
  }

  void _handleMenuAction(String action, BoardController controller) {
    switch (action) {
      case 'rename_board':
        _showRenameBoardDialog(controller);
        break;
      case 'board_members':
        _showBoardMembersDialog(controller);
        break;
      case 'board_activities':
        _showBoardActivities(controller);
        break;
      case 'delete_board':
        _showDeleteBoardDialog(controller);
        break;
    }
  }

  void _showRenameBoardDialog(BoardController controller) {
    final TextEditingController nameController = TextEditingController();
    nameController.text = controller.currentBoard.value?.name ?? '';
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.blue),
                    const SizedBox(width: 12),
                    const Text(
                      'Rename Board',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Board Name',
                    hintText: 'Enter new board name...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.dashboard),
                  ),
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Board name cannot be empty';
                    }
                    if (value.trim().length < 3) {
                      return 'Board name must be at least 3 characters';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    if (formKey.currentState!.validate()) {
                      _renameBoardAction(controller, nameController.text.trim());
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          _renameBoardAction(controller, nameController.text.trim());
                        }
                      },
                      child: const Text('Rename'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _renameBoardAction(BoardController controller, String newName) async {
    // Cập nhật UI ngay lập tức
    setState(() {
      _titleOverride = newName;
    });

    final success = await controller.updateBoardName(newName);
    Get.back();

    if (!success) {
      // Chỉ rollback khi API thất bại
      setState(() {
        _titleOverride = null;
      });

      if (controller.error.value.isNotEmpty) {
        Get.snackbar(
          'Error',
          controller.error.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
        );
      }
    }
    // Nếu API thành công, giữ _titleOverride để đảm bảo UI không bị flicker
    // Controller sẽ tự cập nhật trong background
  }

  void _showBoardMembersDialog(BoardController controller) {
    Get.to(() => BoardMembersView(
      boardId: widget.boardId,
      boardName: controller.currentBoard.value?.name ?? widget.boardName,
    ));
  }

  void _showBoardActivities(BoardController controller) {
    Get.to(() => BoardActivitiesView(
      boardId: widget.boardId,
      boardTitle: controller.currentBoard.value?.name ?? widget.boardName ?? 'Board',
    ));
  }

  void _showDeleteBoardDialog(BoardController controller) {
    final boardName = controller.currentBoard.value?.name ?? 'this board';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 12),
            const Text('Delete Board'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "$boardName"?',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone. All lists, cards, and data will be permanently lost.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteBoardAction(controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Board'),
          ),
        ],
      ),
    );
  }

  void _deleteBoardAction(BoardController controller) async {
    final success = await controller.deleteBoard();
    Get.back(); // Close dialog

    if (success) {
      Get.back(); // Go back to home
    } else if (controller.error.value.isNotEmpty) {
      Get.snackbar(
        'Error',
        controller.error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
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
        title: GetBuilder<BoardController>(
          tag: 'board_detail_${widget.boardId}',
          builder: (controller) => Obx(() => Text(
            _titleOverride ??
            controller.currentBoard.value?.name ??
            widget.boardName ??
            'Loading...',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          )),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              _handleMenuAction(value, controller);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'rename_board',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Rename Board'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'board_members',
                child: ListTile(
                  leading: Icon(Icons.people),
                  title: Text('Board Members'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'board_activities',
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Activities'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'delete_board',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete Board', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
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