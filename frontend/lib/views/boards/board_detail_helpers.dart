import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/board_controller.dart';

class BoardDetailHelpers {
  static Timer? _autoScrollTimer;
  static double _lastPointerX = 0.0;

  // Handle pointer move for auto-scrolling
  static void handlePointerMove(
    PointerMoveEvent event,
    ScrollController scrollController,
    bool isDragging,
    bool isAutoScrolling,
    Function(bool) setIsAutoScrolling,
    Function(double) setCurrentScrollSpeed,
  ) {
    if (!isDragging) {
      _stopAutoScroll(setIsAutoScrolling, setCurrentScrollSpeed);
      return;
    }

    // Kiểm tra xem scrollController có được attach không
    if (!scrollController.hasClients) {
      _stopAutoScroll(setIsAutoScrolling, setCurrentScrollSpeed);
      return;
    }


    _lastPointerX = event.position.dx;

    const double maxScrollSpeed = 5.0;
    const double scrollZone = 60.0;

    final screenWidth = Get.width;
    final scrollPosition = scrollController.position.pixels;
    final maxScrollExtent = scrollController.position.maxScrollExtent;

    double scrollSpeed = 0.0;

    // Kiểm tra xem có đang trong vùng edge không
    final isInLeftEdge = event.position.dx < scrollZone && scrollPosition > 0;
    final isInRightEdge = event.position.dx > screenWidth - scrollZone && scrollPosition < maxScrollExtent;
    final isInScrollZone = isInLeftEdge || isInRightEdge;

    // Tính toán scroll speed chỉ khi trong vùng edge
    if (isInLeftEdge) {
      final distanceFromEdge = scrollZone - event.position.dx;
      scrollSpeed = -(distanceFromEdge / scrollZone) * maxScrollSpeed;
    } else if (isInRightEdge) {
      final distanceFromEdge = event.position.dx - (screenWidth - scrollZone);
      scrollSpeed = (distanceFromEdge / scrollZone) * maxScrollSpeed;
    }

    // Dừng scroll ngay lập tức nếu không còn trong vùng edge
    if (!isInScrollZone || !isDragging) {
      _stopAutoScroll(setIsAutoScrolling, setCurrentScrollSpeed);
      return;
    }

    // Apply scrolling chỉ khi trong vùng edge và đang drag
    if (scrollSpeed.abs() > 0.1 && isDragging && isInScrollZone) {
      if (!isAutoScrolling) {
        setIsAutoScrolling(true);
        // Bắt đầu timer-based auto scroll
        _startAutoScroll(scrollController, setIsAutoScrolling, setCurrentScrollSpeed);
      }
      setCurrentScrollSpeed(scrollSpeed);

      final newPosition = (scrollPosition + scrollSpeed).clamp(0.0, maxScrollExtent);

      // Scroll với kiểm tra position change
      if (scrollController.hasClients && (newPosition - scrollPosition).abs() > 0.3) {
        scrollController.jumpTo(newPosition);
      }
    } else {
      // Ngừng auto-scroll ngay lập tức khi không còn trong vùng edge
      _stopAutoScroll(setIsAutoScrolling, setCurrentScrollSpeed);
    }
  }

  // Start timer-based auto scroll
  static void _startAutoScroll(
    ScrollController scrollController,
    Function(bool) setIsAutoScrolling,
    Function(double) setCurrentScrollSpeed,
  ) {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!scrollController.hasClients) {
        _stopAutoScroll(setIsAutoScrolling, setCurrentScrollSpeed);
        return;
      }

      const double maxScrollSpeed = 3.0;
      const double scrollZone = 50.0;
      final screenWidth = Get.width;
      final scrollPosition = scrollController.position.pixels;
      final maxScrollExtent = scrollController.position.maxScrollExtent;

      // Kiểm tra vị trí pointer hiện tại
      final isInLeftEdge = _lastPointerX < scrollZone && scrollPosition > 0;
      final isInRightEdge = _lastPointerX > screenWidth - scrollZone && scrollPosition < maxScrollExtent;

      if (!isInLeftEdge && !isInRightEdge) {
        // Dừng ngay khi ra khỏi vùng edge
        _stopAutoScroll(setIsAutoScrolling, setCurrentScrollSpeed);
        return;
      }

      double scrollSpeed = 0.0;
      if (isInLeftEdge) {
        final distanceFromEdge = scrollZone - _lastPointerX;
        scrollSpeed = -(distanceFromEdge / scrollZone) * maxScrollSpeed;
      } else if (isInRightEdge) {
        final distanceFromEdge = _lastPointerX - (screenWidth - scrollZone);
        scrollSpeed = (distanceFromEdge / scrollZone) * maxScrollSpeed;
      }

      if (scrollSpeed.abs() > 0.1) {
        final newPosition = (scrollPosition + scrollSpeed).clamp(0.0, maxScrollExtent);
        if ((newPosition - scrollPosition).abs() > 0.3) {
          scrollController.jumpTo(newPosition);
        }
      }
    });
  }

  // Stop auto scroll
  static void _stopAutoScroll(
    Function(bool) setIsAutoScrolling,
    Function(double) setCurrentScrollSpeed,
  ) {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    setIsAutoScrolling(false);
    setCurrentScrollSpeed(0.0);
  }

  // Handle drag started
  static void handleDragStarted() {
    // Set dragging state
  }

  // Handle drag end
  static void handleDragEnd() {
    // Clear dragging state and stop auto scroll
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
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

  // Show add list dialog
  static void showAddListDialog(BoardController controller) {
    final TextEditingController nameController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add New List'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'List Name',
            hintText: 'Enter list name...',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Get.back();
                controller.createList(nameController.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Build loading state
  static Widget buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  // Build error state
  static Widget buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            error,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Build empty state
  static Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No lists found',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first list to get started',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Build empty state with add button
  static Widget buildEmptyStateWithAddButton(BoardController controller) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add List Button at the top
          Container(
            width: 320,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
                style: BorderStyle.solid,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => showAddListDialog(controller),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add List',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
