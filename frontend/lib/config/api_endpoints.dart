import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiEndpoints {
  // Base configuration
  // Automatically select baseUrl based on platform
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    } catch (_) {
      // Platform not available (e.g., in test), fallback localhost
    }
    return 'http://localhost:3000';
  }

  // Auth endpoints
  static const String authLogin = '/v1/auth/login';
  static const String authRegister = '/v1/auth/register';
  static const String authVerification = '/v1/auth/verification';
  static const String authRefreshLogin = '/v1/auth/refresh-login';

  // User endpoints
  static const String userProfile = '/v1/users/my-profiles';
  static const String userChangePassword = '/v1/users/change-password';
  static const String userForgotPassword = '/v1/users/forgot-password';
  static const String userVerifyForgotPassword = '/v1/users/verify-forgot-password';
  static const String userResetPassword = '/v1/users/reset-password';
  static String userInfo(String userId) => '/v1/users/$userId';

  // Board endpoints
  static const String boards = '/v1/boards';
  static const String boardsHomeView = '/v1/boards/home-views';
  static String boardUpdate(String boardId) => '/v1/boards/$boardId';
  static String boardClose(String boardId) => '/v1/boards/$boardId/close';
  static String boardInviteMembers(String boardId) => '/v1/boards/$boardId/invite-members';
  static String boardAcceptInvite(String boardId, String email) => '/v1/boards/$boardId/accept-invites/$email';
  static String boardMembers(String boardId) => '/v1/boards/$boardId/members';
  static String boardMemberRoles(String boardId) => '/v1/boards/$boardId/member-roles';
  static String boardRemoveMember(String boardId, String email) => '/v1/boards/$boardId/members/$email';
  static String boardLeave(String boardId) => '/v1/boards/$boardId/leavings';

  // List endpoints
  static String boardLists(String boardId) => '/v1/boards/$boardId/lists';
  static String listDetail(String listId) => '/v1/lists/$listId';
  static String listUpdate(String listId) => '/v1/lists/$listId';
  static String listDelete(String listId) => '/v1/lists/$listId';
  static String listPosition(String listId) => '/v1/lists/$listId/position';

  // Card endpoints
  static String listCards(String listId) => '/v1/lists/$listId/cards';
  static String cardDetail(String cardId) => '/v1/cards/$cardId';
  static String cardUpdate(String cardId) => '/v1/cards/$cardId';
  static String cardDelete(String cardId) => '/v1/cards/$cardId';
  static String cardPosition(String cardId) => '/v1/cards/$cardId/position';
  static String cardMoveToList(String cardId) => '/v1/cards/$cardId/move-to-list';
  static String cardAssign(String cardId) => '/v1/cards/$cardId/assign';
  static String cardUnassign(String cardId) => '/v1/cards/$cardId/unassign';
  static String cardMembers(String cardId) => '/v1/cards/$cardId/members';
  static String cardAssignMultiple(String cardId) => '/v1/cards/$cardId/assign-multiple';
  static String cardDueDate(String cardId) => '/v1/cards/$cardId/due-date';
  static String cardCompletion(String cardId) => '/v1/cards/$cardId/completion';
  static String cardAttachments(String cardId) => '/v1/cards/$cardId/attachments';
  static String cardRemoveAttachment(String cardId, String attachmentId) => '/v1/cards/$cardId/attachments/$attachmentId';

  // Comment endpoints
  static String cardComments(String cardId) => '/v1/cards/$cardId/comments';
  static String commentDetail(String commentId) => '/v1/comments/$commentId';
  static String commentUpdate(String commentId) => '/v1/comments/$commentId';
  static String commentDelete(String commentId) => '/v1/comments/$commentId';

  // Activity endpoints
  static String boardActivities(String boardId) => '/v1/boards/$boardId/activities';

  // User endpoints
  static const String changePassword = '/v1/users/change-password';
  static const String updateProfile = '/v1/users/my-profiles';
}
