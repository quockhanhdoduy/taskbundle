import 'package:flutter/material.dart';
import '../../models/card.dart';

class CardDetailWidgets {
  // Build scaffold for card detail
  static Widget buildScaffold(
    BuildContext context,
    TaskCard? card,
    bool isLoading,
    String? error,
    Widget body,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          card?.title ?? 'Card Detail',
          style: const TextStyle(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // TODO: Card options menu
            },
          ),
        ],
      ),
      body: body,
    );
  }

  // Build loading state
  static Widget buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  // Build error state
  static Widget buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            error,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Build card content
  static Widget buildCardContent(
    TaskCard card,
    TextEditingController titleController,
    TextEditingController descriptionController,
    bool isEditingTitle,
    bool isEditingDescription,
    VoidCallback onTitleEdit,
    VoidCallback onDescriptionEdit,
    VoidCallback onTitleSave,
    VoidCallback onDescriptionSave,
    VoidCallback onTitleCancel,
    VoidCallback onDescriptionCancel,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section
          _buildTitleSection(
            card,
            titleController,
            isEditingTitle,
            onTitleEdit,
            onTitleSave,
            onTitleCancel,
          ),
          const SizedBox(height: 24),

          // Description section
          _buildDescriptionSection(
            card,
            descriptionController,
            isEditingDescription,
            onDescriptionEdit,
            onDescriptionSave,
            onDescriptionCancel,
          ),
          const SizedBox(height: 24),

          // Due date section
          _buildDueDateSection(card),
          const SizedBox(height: 24),

          // Assigned users section
          _buildAssignedUsersSection(card),
          const SizedBox(height: 24),

          // Comments section
          _buildCommentsSection(card),
        ],
      ),
    );
  }

  // Build title section
  static Widget _buildTitleSection(
    TaskCard card,
    TextEditingController titleController,
    bool isEditingTitle,
    VoidCallback onTitleEdit,
    VoidCallback onTitleSave,
    VoidCallback onTitleCancel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.title, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            const Text(
              'Title',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            if (!isEditingTitle)
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: onTitleEdit,
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (isEditingTitle)
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter card title...',
            ),
            autofocus: true,
            maxLines: 2,
            minLines: 1,
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              card.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (isEditingTitle) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onTitleCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onTitleSave,
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // Build description section
  static Widget _buildDescriptionSection(
    TaskCard card,
    TextEditingController descriptionController,
    bool isEditingDescription,
    VoidCallback onDescriptionEdit,
    VoidCallback onDescriptionSave,
    VoidCallback onDescriptionCancel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.description, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            if (!isEditingDescription)
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: onDescriptionEdit,
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (isEditingDescription)
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter card description...',
              alignLabelWithHint: true,
            ),
            maxLines: 6,
            minLines: 3,
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              card.description.isEmpty ? 'No description' : card.description,
              style: TextStyle(
                fontSize: 14,
                color: card.description.isEmpty ? Colors.grey[500] : Colors.black87,
                fontStyle: card.description.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        if (isEditingDescription) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onDescriptionCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onDescriptionSave,
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // Build due date section
  static Widget _buildDueDateSection(TaskCard card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.schedule, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            const Text(
              'Due Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: () {
                // TODO: Add due date
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            card.dueDate != null
                ? '${card.dueDate!.day}/${card.dueDate!.month}/${card.dueDate!.year}'
                : 'No due date set',
            style: TextStyle(
              fontSize: 14,
              color: card.dueDate != null ? Colors.black87 : Colors.grey[500],
              fontStyle: card.dueDate == null ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }

  // Build assigned users section
  static Widget _buildAssignedUsersSection(TaskCard card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            const Text(
              'Assigned Users',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: () {
                // TODO: Add assigned user
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            card.assignedUsers.isEmpty
                ? 'No users assigned'
                : '${card.assignedUsers.length} user(s) assigned',
            style: TextStyle(
              fontSize: 14,
              color: card.assignedUsers.isEmpty ? Colors.grey[500] : Colors.black87,
              fontStyle: card.assignedUsers.isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }

  // Build comments section
  static Widget _buildCommentsSection(TaskCard card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.comment, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            const Text(
              'Comments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: () {
                // TODO: Add comment
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Text(
            'No comments yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

