import 'package:flutter/material.dart';
import '../../../models/card.dart';

class CardTitleWidget extends StatelessWidget {
  final TaskCard card;
  final TextEditingController titleController;
  final bool isEditing;
  final VoidCallback onStartEditing;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const CardTitleWidget({
    super.key,
    required this.card,
    required this.titleController,
    required this.isEditing,
    required this.onStartEditing,
    required this.onSave,
    required this.onCancel,
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
          Row(
            children: [
              const Text(
                'Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              if (!isEditing)
                TextButton(
                  onPressed: onStartEditing,
                  child: const Text('Edit'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (isEditing) ...[
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Enter title...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: null,
              autofocus: true,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onSave,
                  child: const Text('Save'),
                ),
              ],
            ),
          ] else ...[
            Text(
              card.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
