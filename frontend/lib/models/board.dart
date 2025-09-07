import 'user.dart';
import '../utils/constants.dart';

class Board {
  final String id;
  final String name;
  final DateTime? deletedAt;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Board({
    required this.id,
    required this.name,
    this.deletedAt,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'deletedAt': deletedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Board copyWith({
    String? id,
    String? name,
    DateTime? deletedAt,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Board(
      id: id ?? this.id,
      name: name ?? this.name,
      deletedAt: deletedAt ?? this.deletedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Board && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Board(id: $id, name: $name)';
  }
}

class UserBoard {
  final String id;
  final String userId;
  final String boardId;
  final DateTime? invitedAt;
  final BoardRole role;
  final bool accepted;
  final User? user;
  final Board? board;

  const UserBoard({
    required this.id,
    required this.userId,
    required this.boardId,
    this.invitedAt,
    required this.role,
    required this.accepted,
    this.user,
    this.board,
  });

  factory UserBoard.fromJson(Map<String, dynamic> json) {
    return UserBoard(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      boardId: json['boardId'] ?? '',
      invitedAt: json['invitedAt'] != null
          ? DateTime.parse(json['invitedAt'])
          : null,
      role: BoardRole.fromString(json['role'] ?? 'VIEWER'),
      accepted: json['accepted'] ?? false,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      board: json['board'] != null ? Board.fromJson(json['board']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'boardId': boardId,
      'invitedAt': invitedAt?.toIso8601String(),
      'role': role.value,
      'accepted': accepted,
      'user': user?.toJson(),
      'board': board?.toJson(),
    };
  }

  UserBoard copyWith({
    String? id,
    String? userId,
    String? boardId,
    DateTime? invitedAt,
    BoardRole? role,
    bool? accepted,
    User? user,
    Board? board,
  }) {
    return UserBoard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      boardId: boardId ?? this.boardId,
      invitedAt: invitedAt ?? this.invitedAt,
      role: role ?? this.role,
      accepted: accepted ?? this.accepted,
      user: user ?? this.user,
      board: board ?? this.board,
    );
  }

  bool get canEdit {
    return role == BoardRole.admin || role == BoardRole.member;
  }

  bool get canDelete {
    return role == BoardRole.admin;
  }

  bool get canInvite {
    return role == BoardRole.admin;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserBoard && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserBoard(id: $id, userId: $userId, boardId: $boardId, role: ${role.value}, accepted: $accepted)';
  }
}
