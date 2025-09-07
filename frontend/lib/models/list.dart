import 'board.dart';

class TaskList {
  final String id;
  final String name;
  final String boardId;
  final int position;
  final DateTime? deletedAt;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Board? board;

  const TaskList({
    required this.id,
    required this.name,
    required this.boardId,
    required this.position,
    this.deletedAt,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.board,
  });

  factory TaskList.fromJson(Map<String, dynamic> json) {
    return TaskList(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      boardId: json['boardId'] ?? '',
      position: json['position'] ?? 0,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      board: json['board'] != null ? Board.fromJson(json['board']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'boardId': boardId,
      'position': position,
      'deletedAt': deletedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'board': board?.toJson(),
    };
  }

  TaskList copyWith({
    String? id,
    String? name,
    String? boardId,
    int? position,
    DateTime? deletedAt,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Board? board,
  }) {
    return TaskList(
      id: id ?? this.id,
      name: name ?? this.name,
      boardId: boardId ?? this.boardId,
      position: position ?? this.position,
      deletedAt: deletedAt ?? this.deletedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      board: board ?? this.board,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskList && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TaskList(id: $id, name: $name, boardId: $boardId, position: $position)';
  }
}
