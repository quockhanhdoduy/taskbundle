import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/routes.dart';
import '../controllers/board_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final BoardController boardController;
  final TextEditingController _searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  bool _isLoadingCounts = false;

  @override
  void initState() {
    super.initState();
    // Initialize controller with unique tag for home view
    boardController = Get.put(BoardController(), tag: 'home');
    // Load boards when home view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Loading boards
      await boardController.loadBoards();

      // Loading board counts
      setState(() {
        _isLoadingCounts = true;
      });

      await boardController.loadBoardCounts();

      // Completed loading
      setState(() {
        _isLoadingCounts = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh board data when returning to home view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // Trigger rebuild to update counts
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Allow resize when keyboard appears
      appBar: AppBar(
        title: const Text('TaskBundle'),
        automaticallyImplyLeading: false, // Remove back button
        actions: [
          // Loading indicator for counts
          if (_isLoadingCounts)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Notifications
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
          children: [
                // Search section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search boards...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[500],
                      ),
                      suffixIcon: Obx(() => searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey[500],
                              ),
                              onPressed: () {
                                _searchController.clear();
                                searchQuery.value = '';
                              },
                            )
                          : const SizedBox.shrink()),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      searchQuery.value = value;
                    },
              ),
            ),
            const SizedBox(height: 24),

                // Boards section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                      'Boards',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                      onPressed: () => AppRoutes.toCreateBoard(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Board'),
                ),
              ],
            ),
            const SizedBox(height: 16),

                // Boards list (vertical)
                Container(
                  height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          kToolbarHeight -
                          200, // Approximate space for search + header + padding
                  child: Obx(() {
                    if (boardController.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (boardController.errorMessage.value.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              boardController.errorMessage.value,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => boardController.loadBoards(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    // Apply search filter
                    final allBoards = boardController.allBoards;
                    final filteredBoards = searchQuery.value.isEmpty
                        ? allBoards
                        : allBoards.where((board) =>
                            board.name.toLowerCase().contains(searchQuery.value.toLowerCase())
                          ).toList();

                if (allBoards.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.dashboard_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No boards yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first board to get started',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Show "no results" if search returns empty
                if (searchQuery.value.isNotEmpty && filteredBoards.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No boards found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching with different keywords',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
              ),
            ),
          ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => boardController.refreshBoards(),
                  child: ListView.builder(
                    itemCount: filteredBoards.length,
                    itemBuilder: (context, index) {
                      final board = filteredBoards[index];
                      final isOwner = boardController.isOwnerOfBoard(board.id);
                      // Use original index for color consistency
                      final originalIndex = allBoards.indexOf(board);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildBoardCard(context, {
                          'id': board.id,
                          'name': board.name,
                          'memberCount': 1, // Default for now
                          'isOwner': isOwner,
                          'color': _getBoardColor(originalIndex),
                        }),
                      );
                    },
                  ),
                );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBoardCard(BuildContext context, Map<String, dynamic> board) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          AppRoutes.toBoardDetail(board['id'], boardName: board['name']);
        },
        child: Container(
          height: 90, // Fixed height for consistent list appearance
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                board['color'],
                board['color'].withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Left side - Board info
                Expanded(
                  flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Board name
                Text(
                  board['name'],
                  style: const TextStyle(
                    color: Colors.white,
                          fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                        maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                const Spacer(),

                      // Board stats with owner star
                Row(
                  children: [
                    Icon(
                            Icons.people,
                            size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                            '${board['memberCount']} members',
                      style: const TextStyle(
                        color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          if (board['isOwner']) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Right side - Arrow icon
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Get board color based on index
  Color _getBoardColor(int index) {
    final colors = [
      Colors.blue.shade600,
      Colors.purple.shade600,
      Colors.orange.shade600,
      Colors.red.shade600,
      Colors.green.shade600,
      Colors.teal.shade600,
      Colors.indigo.shade600,
      Colors.pink.shade600,
    ];
    return colors[index % colors.length];
  }


}