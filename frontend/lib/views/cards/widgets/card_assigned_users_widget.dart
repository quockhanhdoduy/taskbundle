import 'package:flutter/material.dart';
import '../../../models/card.dart';

class CardAssignedUsersWidget extends StatelessWidget {
  final TaskCard card;
  final Function(String) onAssignUser;
  final Function(String) onUnassignUser;

  const CardAssignedUsersWidget({
    super.key,
    required this.card,
    required this.onAssignUser,
    required this.onUnassignUser,
  });

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Assigned Users',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAssignUserDialog(context),
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Assign'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Show assigned users or empty state
          if (card.assignedUsers.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.grey[400], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'No users assigned',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: card.assignedUsers.map((userId) => _buildUserChip(userId)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildUserChip(String userId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.blue[100],
            child: Text(
              userId.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'User $userId', // In real app, this would be user name
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => onUnassignUser(userId),
            child: Icon(
              Icons.close,
              size: 14,
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignUserDialog(BuildContext context) {
    final TextEditingController userController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userController,
              decoration: const InputDecoration(
                labelText: 'User Email or ID',
                hintText: 'Enter user email or ID',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: In a real app, this would show a list of available users to select from.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (userController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                onAssignUser(userController.text.trim());
              }
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}
