import 'user.dart';
import 'card.dart';

class Comment {
  final String id;
  final String content;
  final String cardId;
  final String userId;
  final bool isEdited;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final TaskCard? card;

  const Comment({
    required this.id,
    required this.content,
    required this.cardId,
    required this.userId,
    required this.isEdited,
    this.editedAt,
    this.deletedAt,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.card,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] ?? json['id'] ?? '',
      content: json['content'] ?? '',
      cardId: json['cardId'] ?? '',
      userId: json['userId'] ?? '',
      isEdited: json['isEdited'] ?? false,
      editedAt: json['editedAt'] != null
          ? DateTime.parse(json['editedAt'])
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      card: json['card'] != null ? TaskCard.fromJson(json['card']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'content': content,
      'cardId': cardId,
      'userId': userId,
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user?.toJson(),
      'card': card?.toJson(),
    };
  }

  Comment copyWith({
    String? id,
    String? content,
    String? cardId,
    String? userId,
    bool? isEdited,
    DateTime? editedAt,
    DateTime? deletedAt,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    TaskCard? card,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      cardId: cardId ?? this.cardId,
      userId: userId ?? this.userId,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      card: card ?? this.card,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String get editedTimeAgo {
    if (editedAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(editedAt!);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Comment(id: $id, content: $content, cardId: $cardId, userId: $userId, isEdited: $isEdited)';
  }
}
