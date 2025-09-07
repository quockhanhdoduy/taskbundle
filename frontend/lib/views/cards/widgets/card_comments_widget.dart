import 'package:flutter/material.dart';
import '../../../models/card.dart';

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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
                    contentPadding: EdgeInsets.zero,
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
                  comment['author'].toString().substring(0, 1).toUpperCase(),
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
                      comment['author'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _formatDateTime(comment['createdAt']),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment['text'],
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': _commentController.text.trim(),
      'author': 'Current User', // In real app, this would be the logged-in user
      'createdAt': DateTime.now(),
    };

    setState(() {
      _comments.insert(0, newComment);
      _commentController.clear();
    });

    // Call the parent callback
    widget.onAddComment(newComment['text'] as String);
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
