// App Constants
class AppConstants {
  static const String baseUrl = 'http://localhost:3000';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  static const int minPasswordLength = 6;
  static const int maxListsPerBoard = 10;
  static const int maxCardsPerList = 50;
  static const int maxCommentsPerCard = 100;
  static const int maxAttachmentsPerCard = 20;

  static const int pageSize = 10;
}

enum BoardRole {
  admin('ADMIN'),
  member('MEMBER'),
  viewer('VIEWER');

  const BoardRole(this.value);
  final String value;

  static BoardRole fromString(String value) {
    return values.firstWhere(
      (role) => role.value == value,
      orElse: () => BoardRole.viewer,
    );
  }
}

enum ActivityType {
  boardCreated('BOARD_CREATED'),
  boardUpdated('BOARD_UPDATED'),
  boardMemberAdded('BOARD_MEMBER_ADDED'),
  boardMemberRemoved('BOARD_MEMBER_REMOVED'),
  boardMemberRoleChanged('BOARD_MEMBER_ROLE_CHANGED'),

  listCreated('LIST_CREATED'),
  listUpdated('LIST_UPDATED'),
  listDeleted('LIST_DELETED'),
  listMoved('LIST_MOVED'),

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

  commentAdded('COMMENT_ADDED');

  const ActivityType(this.value);
  final String value;

  static ActivityType fromString(String value) {
    return values.firstWhere(
      (type) => type.value == value,
      orElse: () => ActivityType.boardCreated,
    );
  }
}

enum EntityType {
  board('board'),
  list('list'),
  card('card'),
  comment('comment');

  const EntityType(this.value);
  final String value;

  static EntityType fromString(String value) {
    return values.firstWhere(
      (type) => type.value == value,
      orElse: () => EntityType.board,
    );
  }
}
