import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/board_controller.dart';
import 'package:characters/characters.dart';

class BoardMembersView extends StatefulWidget {
  final String boardId;
  final String? boardName;

  const BoardMembersView({
    super.key,
    required this.boardId,
    this.boardName,
  });

  @override
  State<BoardMembersView> createState() => _BoardMembersViewState();
}

class _BoardMembersViewState extends State<BoardMembersView> {
  final TextEditingController _inviteController = TextEditingController();
  late final BoardController controller;
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = false;
  String _inviteRole = 'MEMBER';

  @override
  void initState() {
    super.initState();
    // Get existing controller or create new one
    if (Get.isRegistered<BoardController>(tag: 'board_detail_${widget.boardId}')) {
      controller = Get.find<BoardController>(tag: 'board_detail_${widget.boardId}');
    } else {
      controller = Get.put(BoardController(), tag: 'board_members_${widget.boardId}');
      controller.setBoardId(widget.boardId);
    }

    // Load board members
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBoardMembers();
    });
  }

  @override
  void dispose() {
    _inviteController.dispose();
    super.dispose();
  }

  Future<void> _loadBoardMembers() async {
    setState(() {
      _isLoading = true;
    });
    final data = await controller.getBoardMembers();
    setState(() {
      _members = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Board Members',
          overflow: TextOverflow.ellipsis,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Invite member section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_add, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Invite New Member',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inviteController,
                        decoration: const InputDecoration(
                          hintText: 'Enter email address...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onSubmitted: (email) {
                          if (email.trim().isNotEmpty) {
                                _inviteMember(email.trim(), _inviteRole);
                          }
                        },
                      ),
                    ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _inviteRole,
                                items: const [
                                  DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                                  DropdownMenuItem(value: 'MEMBER', child: Text('MEMBER')),
                                  DropdownMenuItem(value: 'VIEWER', child: Text('VIEWER')),
                                ],
                                onChanged: (v) {
                                  if (v != null) setState(() => _inviteRole = v);
                                },
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                        ElevatedButton(
                      onPressed: () {
                        if (_inviteController.text.trim().isNotEmpty) {
                              _inviteMember(_inviteController.text.trim(), _inviteRole);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          ),
                          child: const Text('Invite'),
                      ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Members section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.people, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Current Members',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_members.length} members',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Members list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMembersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList() {
    final members = _members;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        final role = _extractRole(member);
        final isOwner = role.toLowerCase() == 'owner';
        final isCurrentUser = false;

        return Card(
          margin: const EdgeInsets.only(bottom: 4),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _getAvatarColor(_extractName(member)),
                  child: Text(
                    _buildAvatarText(member),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Member info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name and "You" tag
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _extractName(member),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'You',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Email
                      Text(
                        _extractEmail(member),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      // Joined date
                      Text(
                        _extractJoinedText(member),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Role and actions
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Role dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getRoleColor(role),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _roleDisplayValue(role),
                        underline: const SizedBox(),
                        dropdownColor: Colors.white,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                        isDense: true,
                        iconSize: 12,
                        items: (isOwner ? ['Owner'] : ['Admin', 'Member', 'Viewer'])
                            .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(
                                    role,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 10,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: isOwner ? null : (newRole) {
                          if (newRole != null) {
                            _changeUserRole(_extractEmail(member), newRole);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Remove button
                    if (!isOwner && !isCurrentUser)
                      InkWell(
                        onTap: () => _showRemoveMemberDialog(_extractName(member), _extractEmail(member)),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red[600],
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _extractName(Map<String, dynamic> member) {
    final user = member['user'];
    if (user is Map<String, dynamic>) {
      return (user['name'] ?? user['fullName'] ?? user['username'] ?? 'Unknown').toString();
    }
    return (member['name'] ?? 'Unknown').toString();
  }

  String _extractEmail(Map<String, dynamic> member) {
    final user = member['user'];
    if (user is Map<String, dynamic>) {
      return (user['email'] ?? '').toString();
    }
    return (member['email'] ?? '').toString();
  }

  String _extractRole(Map<String, dynamic> member) {
    final role = member['role'] ?? member['memberRole'] ?? member['permission'] ?? '';
    return role.toString();
  }

  String _roleDisplayValue(String role) {
    final r = role.toLowerCase();
    if (r == 'owner') return 'Owner';
    if (r == 'admin') return 'Admin';
    if (r == 'viewer') return 'Viewer';
    return 'Member';
  }

  String _toBackendRole(String role) {
    switch (role) {
      case 'Owner':
        return 'ADMIN'; // Owner displays but backend uses ADMIN for owner
      case 'Admin':
        return 'ADMIN';
      case 'Viewer':
        return 'VIEWER';
      case 'Member':
      default:
        return 'MEMBER';
    }
  }

  String _buildAvatarText(Map<String, dynamic> member) {
    final name = _extractName(member);
    if (name.isNotEmpty) {
      return name.trim().characters.first.toUpperCase();
    }
    final email = _extractEmail(member);
    return email.isNotEmpty ? email.characters.first.toUpperCase() : '?';
  }

  String _extractJoinedText(Map<String, dynamic> member) {
    final joined = member['joinedDate'] ?? member['joined_at'] ?? member['createdAt'] ?? '';
    if (joined is String && joined.isNotEmpty) return 'Joined $joined';
    return '';
  }

  Color _getRoleColor(String role) {
    switch (_roleDisplayValue(role)) {
      case 'Owner':
        return Colors.purple.shade100;
      case 'Admin':
        return Colors.blue.shade100;
      case 'Member':
        return Colors.green.shade100;
      case 'Viewer':
        return Colors.grey.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  void _inviteMember(String email, String role) async {
    // Show loading
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    final success = await controller.inviteMemberToBoard(email, role: role);
    Get.back(); // Close loading

    if (success) {
      _inviteController.clear();
      Get.snackbar(
        'Invitation Sent',
        'Invitation sent to $email as $role',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: const Duration(seconds: 2),
      );
      // Reload members list
      _loadBoardMembers();
    } else {
      Get.snackbar(
        'Error',
        controller.error.value.isNotEmpty ? controller.error.value : 'Failed to send invitation',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _changeUserRole(String email, String newRole) async {
    final backendRole = _toBackendRole(newRole);
    final success = await controller.updateMemberRole(email, backendRole);

    if (success) {
      Get.snackbar(
        'Role Updated',
        'User role changed to ${_roleDisplayValue(backendRole)}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue[100],
        colorText: Colors.blue[800],
        duration: const Duration(seconds: 2),
      );
      // Reload members list
      _loadBoardMembers();
    } else {
      Get.snackbar(
        'Error',
        controller.error.value.isNotEmpty ? controller.error.value : 'Failed to update role',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _showRemoveMemberDialog(String name, String email) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove $name from this board?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _removeMember(email);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _removeMember(String email) async {
    final success = await controller.removeMember(email);

    if (success) {
      Get.snackbar(
        'Member Removed',
        'Member has been removed from the board',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 2),
      );
      // Reload members list
      _loadBoardMembers();
    } else {
      Get.snackbar(
        'Error',
        controller.error.value.isNotEmpty ? controller.error.value : 'Failed to remove member',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 2),
      );
    }
  }

  Color _getAvatarColor(String name) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.teal];
    return colors[name.hashCode % colors.length];
  }
}
