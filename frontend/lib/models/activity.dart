import 'user.dart';
import 'board.dart';
import '../utils/constants.dart';

class Activity {
  final String id;
  final ActivityType type;
  final String userId;
  final String boardId;
  final EntityType entityType;
  final String entityId;
  final String description;
  final DateTime createdAt;
  final User? user;
  final Board? board;
  final String? entityName;

  const Activity({
    required this.id,
    required this.type,
    required this.userId,
    required this.boardId,
    required this.entityType,
    required this.entityId,
    required this.description,
    required this.createdAt,
    this.user,
    this.board,
    this.entityName,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['_id'] ?? json['id'] ?? '',
      type: ActivityType.fromString(json['type'] ?? ''),
      userId: json['userId'] ?? '',
      boardId: json['boardId'] ?? '',
      entityType: EntityType.fromString(json['entityType'] ?? ''),
      entityId: json['entityId'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      board: json['board'] != null ? Board.fromJson(json['board']) : null,
      entityName: json['entityName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type.value,
      'userId': userId,
      'boardId': boardId,
      'entityType': entityType.value,
      'entityId': entityId,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'user': user?.toJson(),
      'board': board?.toJson(),
      'entityName': entityName,
    };
  }

  Activity copyWith({
    String? id,
    ActivityType? type,
    String? userId,
    String? boardId,
    EntityType? entityType,
    String? entityId,
    String? description,
    DateTime? createdAt,
    User? user,
    Board? board,
    String? entityName,
  }) {
    return Activity(
      id: id ?? this.id,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      boardId: boardId ?? this.boardId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      board: board ?? this.board,
      entityName: entityName ?? this.entityName,
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

    String get formattedDescription {
    final userName = user?.name ?? 'Someone';
    final entityNameDisplay = entityName != null ? '"$entityName"' : entityType.value;

    switch (type) {
      // Board activities
      case ActivityType.boardCreated:
        return '$userName created board $entityNameDisplay';
      case ActivityType.boardUpdated:
        return '$userName updated board $entityNameDisplay';
      case ActivityType.boardMemberAdded:
        return '$userName added member to board $entityNameDisplay';
      case ActivityType.boardMemberRemoved:
        return '$userName removed member from board $entityNameDisplay';
      case ActivityType.boardMemberRoleChanged:
        return '$userName changed member role in board $entityNameDisplay';

      // List activities
      case ActivityType.listCreated:
        return '$userName created list $entityNameDisplay';
      case ActivityType.listUpdated:
        return '$userName updated list $entityNameDisplay';
      case ActivityType.listDeleted:
        return '$userName deleted list $entityNameDisplay';
      case ActivityType.listMoved:
        return '$userName moved list $entityNameDisplay';

      // Card activities
      case ActivityType.cardCreated:
        return '$userName created card $entityNameDisplay';
      case ActivityType.cardUpdated:
        return '$userName updated card $entityNameDisplay';
      case ActivityType.cardDeleted:
        return '$userName deleted card $entityNameDisplay';
      case ActivityType.cardMoved:
        return '$userName moved card $entityNameDisplay';
      case ActivityType.cardAssigned:
        return '$userName assigned card $entityNameDisplay';
      case ActivityType.cardUnassigned:
        return '$userName unassigned card $entityNameDisplay';
      case ActivityType.cardCompleted:
        return '$userName completed card $entityNameDisplay';
      case ActivityType.cardUncompleted:
        return '$userName marked card $entityNameDisplay as incomplete';
      case ActivityType.cardDueDateSet:
        return '$userName set due date for card $entityNameDisplay';
      case ActivityType.cardDueDateChanged:
        return '$userName changed due date for card $entityNameDisplay';
      case ActivityType.cardDueDateRemoved:
        return '$userName removed due date from card $entityNameDisplay';
      case ActivityType.cardAttachmentAdded:
        return '$userName added attachment to card $entityNameDisplay';
      case ActivityType.cardAttachmentRemoved:
        return '$userName removed attachment from card $entityNameDisplay';

      // Comment activities
      case ActivityType.commentAdded:
        return '$userName added comment to card $entityNameDisplay';
    }
  }

  bool get isBoardActivity {
    return type == ActivityType.boardCreated ||
           type == ActivityType.boardUpdated ||
           type == ActivityType.boardMemberAdded ||
           type == ActivityType.boardMemberRemoved ||
           type == ActivityType.boardMemberRoleChanged;
  }

  bool get isListActivity {
    return type == ActivityType.listCreated ||
           type == ActivityType.listUpdated ||
           type == ActivityType.listDeleted ||
           type == ActivityType.listMoved;
  }

  bool get isCardActivity {
    return type == ActivityType.cardCreated ||
           type == ActivityType.cardUpdated ||
           type == ActivityType.cardDeleted ||
           type == ActivityType.cardMoved ||
           type == ActivityType.cardAssigned ||
           type == ActivityType.cardUnassigned ||
           type == ActivityType.cardCompleted ||
           type == ActivityType.cardUncompleted ||
           type == ActivityType.cardDueDateSet ||
           type == ActivityType.cardDueDateChanged ||
           type == ActivityType.cardDueDateRemoved ||
           type == ActivityType.cardAttachmentAdded ||
           type == ActivityType.cardAttachmentRemoved;
  }

  bool get isCommentActivity {
    return type == ActivityType.commentAdded;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Activity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Activity(id: $id, type: ${type.value}, userId: $userId, boardId: $boardId, entityType: ${entityType.value}, entityName: $entityName)';
  }
}
