import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/card.dart';
import '../../../controllers/card_controller.dart';

class CardCommentsWidget extends StatefulWidget {
  final TaskCard card;
  final Function(String) onAddComment;

  const CardCommentsWidget({
    super.key,
    required this.card,
    required this.onAddComment,
  });

  @override
  State<CardCommentsWidget> createState() => _CardCommentsWidgetState();
}

class _CardCommentsWidgetState extends State<CardCommentsWidget> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [];
  late final CardController _cardController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    print('CardCommentsWidget: Initializing for card ${widget.card.id}');
    _cardController = Get.find<CardController>(tag: 'card_detail_${widget.card.id}');
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _loading = true);
    try {
      final result = await _cardController.getCardComments(widget.card.id);
      print('CardCommentsWidget: Load comments result: $result');

      if ((result['success'] == true || result['status'] == 'success') && result['data'] != null) {
        final data = result['data'];
        List<dynamic> commentsList = [];

        // Handle both array and object responses
        if (data is List) {
          commentsList = data;
        } else if (data is Map && data.containsKey('comments')) {
          // Backend returns { comments: [...], total: X, page: Y, ... }
          commentsList = data['comments'] ?? [];
        } else if (data is Map) {
          // If data is a single comment object, wrap it in array
          commentsList = [data];
        }

        setState(() {
          _comments.clear();
          _comments.addAll(commentsList.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)));
        });
        print('CardCommentsWidget: Loaded ${_comments.length} comments');
      } else {
        setState(() => _comments.clear());
        print('CardCommentsWidget: No comments found or error');
      }
    } catch (e) {
      print('CardCommentsWidget: Error loading comments: $e');
      setState(() => _comments.clear());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Comments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_loading)
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              else
                Text(
                  '${_comments.length} comment${_comments.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Add comment section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Write a comment...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _commentController.clear(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addComment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Comment'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Comments list
          if (_comments.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.comment_outlined, color: Colors.grey[400], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'No comments yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _comments.map((comment) => _buildComment(comment)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildComment(Map<String, dynamic> comment) {
    final author = comment['userId']?['name'] ?? comment['userId']?['email'] ?? 'Unknown User';
    final authorInitial = author.isNotEmpty ? author[0].toUpperCase() : 'U';
    final content = comment['content'] ?? comment['text'] ?? '';
    final createdAt = comment['createdAt'] ?? comment['created_at'];
    final isEdited = comment['isEdited'] == true;
    final editedAt = comment['editedAt'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue[100],
                child: Text(
                  authorInitial,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _formatDateTime(createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (isEdited) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(edited)',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _confirmDeleteComment(comment);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Icon(Icons.more_vert, color: Colors.grey[400], size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final content = _commentController.text.trim();
    print('Creating comment: $content for card: ${widget.card.id}');

    _commentController.clear();

    final success = await _cardController.createComment(widget.card.id, content);
    print('Comment creation result: $success');

    if (success) {
      await _loadComments();
      // Call the parent callback
      widget.onAddComment(content);
    }
  }

  void _confirmDeleteComment(Map<String, dynamic> comment) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final commentId = comment['_id'] ?? comment['id'];
              if (commentId == null) return;

              final success = await _cardController.deleteComment(commentId.toString());
              if (success) {
                await _loadComments();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'Unknown time';

    DateTime dt;
    if (dateTime is String) {
      try {
        dt = DateTime.parse(dateTime);
      } catch (e) {
        return 'Invalid date';
      }
    } else if (dateTime is DateTime) {
      dt = dateTime;
    } else {
      return 'Invalid date';
    }

    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }
}
