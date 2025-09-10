import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/card.dart';
import '../../../controllers/board_controller.dart';
import '../../../controllers/card_controller.dart';
import '../../../services/board_service.dart';

class CardAssignedUsersWidget extends StatelessWidget {
  final TaskCard card;
  final Function(String) onAssignUser;
  final Function(String) onUnassignUser;

  // Cache: boardId -> { userId/email : displayName }
  static final Map<String, Map<String, String>> _memberNameCacheByBoard = {};

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
              children: card.assignedUsers.map((userKey) => _buildUserChip(userKey)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildUserChip(String userKey) {
    final boardId = card.list?.boardId ?? '';
    final cached = _memberNameCacheByBoard[boardId] ?? const {};
    final name = cached[userKey];
    final display = name ?? (userKey.contains('@') ? userKey : '');
    final avatarChar = (display.isNotEmpty ? display[0] : userKey[0]).toUpperCase();

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
              avatarChar,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ),
          if (display.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              display,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => onUnassignUser(userKey),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.person_add, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Assign from Board Members',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchBoardMembers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final members = (snapshot.data ?? [])
                          .where((m) {
                            final email = (m['email'] ?? m['user']?['email'] ?? '').toString();
                            final id = (m['_id'] ?? m['user']?['_id'] ?? '').toString();
                            final key = email.isNotEmpty ? email : id;
                            return !card.assignedUsers.contains(key);
                          })
                          .toList();

                      if (members.isEmpty) {
                        return Center(
                          child: Text(
                            'No available members to assign',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        );
                      }

                      // Update cache: both id and email map to display name
                      final boardId = card.list?.boardId ?? '';
                      _memberNameCacheByBoard[boardId] ??= {};
                      for (final m in members) {
                        final name = (m['name'] ?? m['user']?['name'] ?? 'Unknown').toString();
                        final email = (m['email'] ?? m['user']?['email'] ?? '').toString();
                        final id = (m['_id'] ?? m['user']?['_id'] ?? '').toString();
                        if (email.isNotEmpty) _memberNameCacheByBoard[boardId]![email] = name;
                        if (id.isNotEmpty) _memberNameCacheByBoard[boardId]![id] = name;
                      }

                      return ListView.separated(
                        itemCount: members.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final m = members[index];
                          final name = (m['name'] ?? m['user']?['name'] ?? 'Unknown').toString();
                          final email = (m['email'] ?? m['user']?['email'] ?? '').toString();
                          final id = (m['_id'] ?? m['user']?['_id'] ?? '').toString();
                          final subtitle = email.isNotEmpty ? email : id;

                          return ListTile(
                            leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?')),
                            title: Text(name, overflow: TextOverflow.ellipsis),
                            subtitle: Text(subtitle, overflow: TextOverflow.ellipsis),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                // Always assign by id for backend, cache handles display
                                onAssignUser(id);
                              },
                              child: const Text('Assign'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchBoardMembers() async {
    try {
      // Try boardId from card.list first
      String? boardId = card.list?.boardId;

      // Fallback: get boardId via listId
      if ((boardId == null || boardId.isEmpty) && (card.listId.isNotEmpty)) {
        try {
          final cardController = Get.find<CardController>(tag: 'card_detail_${card.id}');
          final listDetail = await cardController.getListDetail(card.listId);
          if ((listDetail['status'] == 'success' || listDetail['success'] == true) && listDetail['data'] != null) {
            boardId = listDetail['data']['boardId'];
          }
        } catch (_) {}
      }

      if (boardId == null || boardId.isEmpty) {
        return [];
      }

      if (Get.isRegistered<BoardController>(tag: 'board_detail_$boardId')) {
        final controller = Get.find<BoardController>(tag: 'board_detail_$boardId');
        return await controller.getBoardMembers();
      }

      final result = await BoardService.getBoardMembers(boardId);
      if (result['success'] == true || result['status'] == 'success') {
        final data = result['data'];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        if (data is Map<String, dynamic>) {
          final members = data['members'] ?? data['users'] ?? data['data'];
          if (members is List) {
            return List<Map<String, dynamic>>.from(members);
          }
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
