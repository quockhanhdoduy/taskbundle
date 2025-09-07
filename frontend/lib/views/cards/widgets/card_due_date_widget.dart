import 'package:flutter/material.dart';
import '../../../models/card.dart';

class CardDueDateWidget extends StatelessWidget {
  final TaskCard card;
  final Function(DateTime?) onUpdateDueDate;
  final Function() onRemoveDueDate;

  const CardDueDateWidget({
    super.key,
    required this.card,
    required this.onUpdateDueDate,
    required this.onRemoveDueDate,
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
                'Due Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showDatePicker(context),
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (card.dueDate != null) ...[
            Row(
              children: [
                Text(
                  '📅',
                  style: TextStyle(
                    fontSize: 16,
                    color: _getDueDateColor(),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDueDate(),
                  style: TextStyle(
                    fontSize: 16,
                    color: _getDueDateColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onRemoveDueDate,
                  child: const Text(
                    'Remove',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ] else ...[
            const Text(
              'No due date',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getDueDateColor() {
    if (card.dueDate == null) return Colors.grey;

    final now = DateTime.now();
    final dueDate = card.dueDate!;
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return Colors.red; // Overdue
    } else if (difference == 0) {
      return Colors.orange; // Due today
    } else if (difference <= 3) {
      return Colors.amber; // Due soon
    } else {
      return Colors.green; // Not urgent
    }
  }

  String _formatDueDate() {
    if (card.dueDate == null) return '';

    final now = DateTime.now();
    final dueDate = card.dueDate!;
    final difference = dueDate.difference(now).inDays;

    final dateStr = '${dueDate.day}/${dueDate.month}/${dueDate.year}';

    if (difference < 0) {
      return '$dateStr (Overdue ${-difference} days)';
    } else if (difference == 0) {
      return '$dateStr (Today)';
    } else if (difference == 1) {
      return '$dateStr (Tomorrow)';
    } else if (difference <= 7) {
      return '$dateStr ($difference days left)';
    } else {
      return dateStr;
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: card.dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: card.dueDate != null
            ? TimeOfDay.fromDateTime(card.dueDate!)
            : const TimeOfDay(hour: 9, minute: 0),
      );

      if (time != null) {
        final DateTime finalDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
        onUpdateDueDate(finalDateTime);
      }
    }
  }
}
