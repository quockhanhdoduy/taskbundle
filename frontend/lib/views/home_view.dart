import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/routes.dart';
import '../controllers/board_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/notification_controller.dart';
import '../services/sync_service.dart';
import 'profile/profile_view.dart';

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
    boardController = Get.put(BoardController(), tag: 'home');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await boardController.loadBoards();

      setState(() {
        _isLoadingCounts = true;
      });

      await boardController.loadBoardCounts();
      await boardController.loadBoardMemberCounts();

      setState(() {
        _isLoadingCounts = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForSyncUpdates();
      setState(() {
        // Trigger rebuild to update counts
      });
    });
  }

  void _checkForSyncUpdates() {
    try {
      final syncService = SyncService.instance;
      if (syncService.homeRefreshNeeded.value) {
        boardController.loadBoards();
        syncService.resetHomeRefreshFlag();
      }
    } catch (e) {
      // SyncService not available
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'profile':
        _showProfile();
        break;
      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  void _showProfile() {
    Get.to(() => const ProfileView())?.then((_) {
      setState(() {
        // Trigger a rebuild to refresh any cached data
      });
    });
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to logout?'),
            SizedBox(height: 8),
            Text(
              'You will need to login again to access your boards.',
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
            onPressed: () => _logout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    try {
      final authController = Get.find<AuthController>();
      await authController.logout();

      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
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
        title: const Text(
          'TaskBundle',
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
        automaticallyImplyLeading: false,
        actions: [
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
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                Obx(() {
                  final unreadCount = Get.find<NotificationController>().unreadCount;
                  if (unreadCount > 0) {
                    return Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
            onPressed: () {
              AppRoutes.toNotifications();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              _handleMenuAction(value);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
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
                Container(
                  height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          kToolbarHeight -
                          200,
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
                  onRefresh: () async {
                    await boardController.refreshBoards();
                    await boardController.loadBoardMemberCounts();
                  },
                  child: ListView.builder(
                    itemCount: filteredBoards.length,
                    itemBuilder: (context, index) {
                      final board = filteredBoards[index];
                      final isOwner = boardController.isOwnerOfBoard(board.id);
                      final originalIndex = allBoards.indexOf(board);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildBoardCard(context, {
                          'id': board.id,
                          'name': board.name,
                          'memberCount': boardController.getMemberCountForBoard(board.id),
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
                Expanded(
                  flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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