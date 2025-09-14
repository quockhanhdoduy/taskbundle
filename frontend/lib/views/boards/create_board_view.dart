import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/board_controller.dart';

class CreateBoardView extends StatefulWidget {
  const CreateBoardView({super.key});

  @override
  State<CreateBoardView> createState() => _CreateBoardViewState();
}

class _CreateBoardViewState extends State<CreateBoardView> {
  late final BoardController boardController;
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Use a separate controller instance for create board
    boardController = Get.put(BoardController(), tag: 'create_board');
    // Reset loading state for create board view
    boardController.isLoading.value = false;
  }

  @override
  void dispose() {
    nameController.dispose();
    // Clean up the create board controller
    if (Get.isRegistered<BoardController>(tag: 'create_board')) {
      Get.delete<BoardController>(tag: 'create_board');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Board',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Board Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter board name...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Board name is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Board name must be at least 3 characters';
                  }
                  if (value.trim().length > 150) {
                    return 'Board name must not exceed 150 characters';
                  }
                  return null;
                },
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                onFieldSubmitted: (_) => _handleCreateBoard(),
              ),
              const SizedBox(height: 16),

              // Error message display
              Obx(() {
                if (boardController.errorMessage.value.isNotEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      boardController.errorMessage.value,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              const Spacer(),

              // Create button
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: boardController.isLoading.value
                      ? null
                      : _handleCreateBoard,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: boardController.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Board'),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCreateBoard() async {
    if (!formKey.currentState!.validate()) return;

    boardController.clearMessages();

    final success = await boardController.createBoard(nameController.text.trim());

    if (!mounted) return;

    if (success) {
      // Refresh home controller before going back
      await _refreshHomeController();

      Get.back();
      Get.snackbar(
        'Success',
        boardController.successMessage.value,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _refreshHomeController() async {
    try {
      if (Get.isRegistered<BoardController>(tag: 'home')) {
        final homeController = Get.find<BoardController>(tag: 'home');
        await homeController.loadBoards();
        // Home controller refreshed successfully
      } else {
        // Home controller not found
      }
    } catch (e) {
      // Error refreshing home controller
    }
  }
}
