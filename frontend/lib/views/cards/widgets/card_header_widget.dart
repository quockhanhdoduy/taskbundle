import 'package:flutter/material.dart';
import '../../../models/card.dart';

class CardHeaderWidget extends StatelessWidget {
  final TaskCard? card;
  final VoidCallback onBack;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;
  final VoidCallback? onEditTitle;

  const CardHeaderWidget({
    super.key,
    required this.card,
    required this.onBack,
    required this.onDelete,
    required this.onToggleComplete,
    this.onEditTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),

          // Complete status indicator - moved to left of title
          if (card != null)
            GestureDetector(
              onTap: onToggleComplete,
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: card!.isCompleted ? Colors.green : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: card!.isCompleted ? Colors.green : Colors.transparent,
                ),
                child: card!.isCompleted
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ),

          // Card title
          Expanded(
            child: Text(
              card?.title ?? 'Card Details',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Edit title button
          if (onEditTitle != null)
            IconButton(
              onPressed: onEditTitle,
              icon: const Icon(Icons.edit, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
        ],
      ),
    );
  }
}