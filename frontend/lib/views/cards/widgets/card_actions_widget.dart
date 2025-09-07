import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/card.dart';

class CardActionsWidget extends StatelessWidget {
  final TaskCard card;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final VoidCallback onAddAttachment;
  final VoidCallback onAddComment;

  const CardActionsWidget({
    super.key,
    required this.card,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onAddAttachment,
    required this.onAddComment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Toggle complete button
              Expanded(
                child: ElevatedButton(
                  onPressed: onToggleComplete,
                  child: Text(
                    card.isCompleted ? 'Completed' : 'Mark Complete',
                    style: TextStyle(
                      color: card.isCompleted ? Colors.green : Colors.grey,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: card.isCompleted ? Colors.green[50] : Colors.grey[50],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Add attachment button
              Expanded(
                child: OutlinedButton(
                  onPressed: onAddAttachment,
                  child: const Text('Attach'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Add comment button
              Expanded(
                child: OutlinedButton(
                  onPressed: onAddComment,
                  child: const Text('Comment'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Delete button
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showDeleteConfirmation(context),
                  child: const Text(
                    'Delete Card',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this card? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onDelete();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
