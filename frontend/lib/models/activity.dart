// Activity Types enum matching backend
enum ActivityType {
  // Board activities
  boardCreated('BOARD_CREATED'),
  boardUpdated('BOARD_UPDATED'),
  boardMemberAdded('BOARD_MEMBER_ADDED'),
  boardMemberRemoved('BOARD_MEMBER_REMOVED'),
  boardMemberRoleChanged('BOARD_MEMBER_ROLE_CHANGED'),

  // List activities
  listCreated('LIST_CREATED'),
  listUpdated('LIST_UPDATED'),
  listDeleted('LIST_DELETED'),
  listMoved('LIST_MOVED'),

  // Card activities
  cardCreated('CARD_CREATED'),
  cardUpdated('CARD_UPDATED'),
  cardDeleted('CARD_DELETED'),
  cardMoved('CARD_MOVED'),
  cardAssigned('CARD_ASSIGNED'),
  cardUnassigned('CARD_UNASSIGNED'),
  cardCompleted('CARD_COMPLETED'),
  cardUncompleted('CARD_UNCOMPLETED'),
  cardDueDateSet('CARD_DUE_DATE_SET'),
  cardDueDateChanged('CARD_DUE_DATE_CHANGED'),
  cardDueDateRemoved('CARD_DUE_DATE_REMOVED'),
  cardAttachmentAdded('CARD_ATTACHMENT_ADDED'),
  cardAttachmentRemoved('CARD_ATTACHMENT_REMOVED'),

  // Comment activities
  commentAdded('COMMENT_ADDED');

  const ActivityType(this.value);
  final String value;

  static ActivityType fromString(String value) {
    for (ActivityType type in ActivityType.values) {
      if (type.value == value) return type;
    }
    return ActivityType.cardCreated; // Default fallback
  }
}

// Entity Types enum matching backend
enum EntityType {
  board('board'),
  list('list'),
  card('card'),
  comment('comment');

  const EntityType(this.value);
  final String value;

  static EntityType fromString(String value) {
    for (EntityType type in EntityType.values) {
      if (type.value == value) return type;
    }
    return EntityType.board; // Default fallback
  }
}

// Activity model matching backend schema
class Activity {
  final String id;
  final ActivityType type;
  final String userId;
  final String boardId;
  final EntityType entityType;
  final String entityId;
  final String description;
  final DateTime createdAt;
  final ActivityUser? user;

  Activity({
    required this.id,
    required this.type,
    required this.userId,
    required this.boardId,
    required this.entityType,
    required this.entityId,
    required this.description,
    required this.createdAt,
    this.user,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['_id'] ?? json['id'] ?? '',
      type: ActivityType.fromString(json['type'] ?? ''),
      userId: json['userId'] is String ? json['userId'] : json['userId']?['_id'] ?? '',
      boardId: json['boardId'] ?? '',
      entityType: EntityType.fromString(json['entityType'] ?? 'board'),
      entityId: json['entityId'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      user: json['userId'] is Map ? ActivityUser.fromJson(json['userId']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'userId': userId,
      'boardId': boardId,
      'entityType': entityType.value,
      'entityId': entityId,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }

  // Activity type helpers
  bool get isBoardActivity => entityType == EntityType.board;
  bool get isListActivity => entityType == EntityType.list;
  bool get isCardActivity => entityType == EntityType.card;
  bool get isCommentActivity => entityType == EntityType.comment;

  // Get activity icon based on type
  String get activityIcon {
    switch (type) {
      case ActivityType.boardCreated:
        return '🏗️';
      case ActivityType.boardUpdated:
        return '✏️';
      case ActivityType.boardMemberAdded:
        return '👥';
      case ActivityType.boardMemberRemoved:
        return '👋';
      case ActivityType.boardMemberRoleChanged:
        return '🔄';
      case ActivityType.listCreated:
        return '📋';
      case ActivityType.listUpdated:
        return '✏️';
      case ActivityType.listDeleted:
        return '🗑️';
      case ActivityType.listMoved:
        return '↔️';
      case ActivityType.cardCreated:
        return '📝';
      case ActivityType.cardUpdated:
        return '✏️';
      case ActivityType.cardDeleted:
        return '🗑️';
      case ActivityType.cardMoved:
        return '↔️';
      case ActivityType.cardAssigned:
        return '👤';
      case ActivityType.cardUnassigned:
        return '👤';
      case ActivityType.cardCompleted:
        return '✅';
      case ActivityType.cardUncompleted:
        return '⏳';
      case ActivityType.cardDueDateSet:
      case ActivityType.cardDueDateChanged:
        return '📅';
      case ActivityType.cardDueDateRemoved:
        return '📅';
      case ActivityType.cardAttachmentAdded:
        return '📎';
      case ActivityType.cardAttachmentRemoved:
        return '📎';
      case ActivityType.commentAdded:
        return '💬';
    }
  }

  // Get activity color based on entity type
  String get activityColor {
    switch (entityType) {
      case EntityType.board:
        return '#4CAF50'; // Green
      case EntityType.list:
        return '#2196F3'; // Blue
      case EntityType.card:
        return '#FF9800'; // Orange
      case EntityType.comment:
        return '#9C27B0'; // Purple
    }
  }

  // Get formatted time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  // Get display name for activity type
  String get displayName {
    switch (type) {
      case ActivityType.boardCreated:
        return 'Board Created';
      case ActivityType.boardUpdated:
        return 'Board Updated';
      case ActivityType.boardMemberAdded:
        return 'Member Added';
      case ActivityType.boardMemberRemoved:
        return 'Member Removed';
      case ActivityType.boardMemberRoleChanged:
        return 'Role Changed';
      case ActivityType.listCreated:
        return 'List Created';
      case ActivityType.listUpdated:
        return 'List Updated';
      case ActivityType.listDeleted:
        return 'List Deleted';
      case ActivityType.listMoved:
        return 'List Moved';
      case ActivityType.cardCreated:
        return 'Card Created';
      case ActivityType.cardUpdated:
        return 'Card Updated';
      case ActivityType.cardDeleted:
        return 'Card Deleted';
      case ActivityType.cardMoved:
        return 'Card Moved';
      case ActivityType.cardAssigned:
        return 'Card Assigned';
      case ActivityType.cardUnassigned:
        return 'Card Unassigned';
      case ActivityType.cardCompleted:
        return 'Card Completed';
      case ActivityType.cardUncompleted:
        return 'Card Uncompleted';
      case ActivityType.cardDueDateSet:
        return 'Due Date Set';
      case ActivityType.cardDueDateChanged:
        return 'Due Date Changed';
      case ActivityType.cardDueDateRemoved:
        return 'Due Date Removed';
      case ActivityType.cardAttachmentAdded:
        return 'Attachment Added';
      case ActivityType.cardAttachmentRemoved:
        return 'Attachment Removed';
      case ActivityType.commentAdded:
        return 'Comment Added';
    }
  }
}

// User model for activity (populated from backend)
class ActivityUser {
  final String id;
  final String name;
  final String email;

  ActivityUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ActivityUser.fromJson(Map<String, dynamic> json) {
    return ActivityUser(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}