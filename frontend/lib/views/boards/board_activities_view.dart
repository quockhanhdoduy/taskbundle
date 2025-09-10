import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/board_controller.dart';
import '../../models/activity.dart';

class BoardActivitiesView extends StatefulWidget {
  final String boardId;
  final String boardTitle;

  const BoardActivitiesView({
    super.key,
    required this.boardId,
    required this.boardTitle,
  });

  @override
  State<BoardActivitiesView> createState() => _BoardActivitiesViewState();
}

class _BoardActivitiesViewState extends State<BoardActivitiesView> {
  late final BoardController _boardController;
  List<Activity> _activities = [];
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _boardController = Get.find<BoardController>(tag: 'board_detail_${widget.boardId}');

    // Setup scroll listener for lazy loading
    _scrollController.addListener(_onScroll);

    // Use WidgetsBinding to defer the call until after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActivities();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreActivities();
    }
  }

  Future<void> _loadActivities({bool refresh = false}) async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      if (refresh) {
        _currentPage = 1;
        _activities.clear();
        _hasMore = true;
      }

      final result = await _boardController.getBoardActivities(
        widget.boardId,
        page: _currentPage,
        limit: 10, // Backend uses fixed PAGE_SIZE = 10
      );

      if ((result['success'] == true || result['status'] == 'success') && result['data'] != null) {
        final data = result['data'];
        final List<dynamic> activitiesData = data['activities'] ?? [];
        final pagination = data['pagination'] ?? {};

        final newActivities = activitiesData
            .map<Activity>((json) => Activity.fromJson(json))
            .toList();

        setState(() {
          if (refresh) {
            _activities = newActivities;
          } else {
            _activities.addAll(newActivities);
          }
          _hasMore = pagination['hasNext'] == true;
          _currentPage++;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load activities';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error: ${e.toString()}';
      });
      Get.snackbar('Error', 'Failed to load activities: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadMoreActivities() async {
    if (_loadingMore || !_hasMore || _loading) return;

    setState(() => _loadingMore = true);

    try {
      final result = await _boardController.getBoardActivities(
        widget.boardId,
        page: _currentPage,
        limit: 10,
      );

      if ((result['success'] == true || result['status'] == 'success') && result['data'] != null) {
        final data = result['data'];
        final List<dynamic> activitiesData = data['activities'] ?? [];
        final pagination = data['pagination'] ?? {};

        final newActivities = activitiesData
            .map<Activity>((json) => Activity.fromJson(json))
            .toList();

        setState(() {
          _activities.addAll(newActivities);
          _hasMore = pagination['hasNext'] == true;
          _currentPage++;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load more activities: ${e.toString()}');
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Activities'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadActivities(refresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _activities.isEmpty) {
      return _buildLoadingState();
    }

    if (_errorMessage != null && _activities.isEmpty) {
      return _buildErrorState();
    }

    if (_activities.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _activities.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _activities.length) {
          // Load more indicator
          return _buildLoadMoreIndicator();
        }

        final activity = _activities[index];
        return _buildActivityItem(activity);
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Show 5 skeleton items
      itemBuilder: (context, index) => _buildSkeletonItem(),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 12),
          // Skeleton content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (_loadingMore) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasMore) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Scroll down to load more',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No more activities',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load activities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadActivities(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No activities yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Activities will appear here as team members work on this board',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Activity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(int.parse(activity.activityColor.replaceFirst('#', '0xFF'))).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                activity.activityIcon,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Activity content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User and time
                Row(
                  children: [
                    Text(
                      activity.user?.name ?? 'Unknown User',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      activity.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Activity description
                Text(
                  activity.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // Activity type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(int.parse(activity.activityColor.replaceFirst('#', '0xFF'))).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    activity.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(int.parse(activity.activityColor.replaceFirst('#', '0xFF'))),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
