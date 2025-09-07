import 'user.dart';
import 'list.dart';

class TaskCard {
  final String id;
  final String title;
  final String description;
  final String listId;
  final int position;
  final DateTime? dueDate;
  final DateTime? completedDate;
  final bool isCompleted;
  final List<String> assignedUsers;
  final List<CardAttachment> attachments;
  final DateTime? deletedAt;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TaskList? list;
  final List<User>? assignedUserDetails;

  const TaskCard({
    required this.id,
    required this.title,
    required this.description,
    required this.listId,
    required this.position,
    this.dueDate,
    this.completedDate,
    required this.isCompleted,
    required this.assignedUsers,
    required this.attachments,
    this.deletedAt,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.list,
    this.assignedUserDetails,
  });

  factory TaskCard.fromJson(Map<String, dynamic> json) {
    // Parse card ID với fallback cho invalid IDs
    var cardId = json['_id'] ?? json['id'] ?? '';

    // Fix invalid IDs (chỉ khi thực sự cần)
    if (cardId.contains(':') || cardId.isEmpty) {
      // Generate a unique ObjectId-like string based on title hash
      final title = json['title'] ?? 'untitled';
      final hash = title.hashCode.abs().toString().padLeft(12, '0');
      cardId = '507f1f77bcf86cd7${hash.substring(0, 8)}'; // Valid ObjectId format
    }

    return TaskCard(
      id: cardId,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      listId: _extractListId(json['listId']),
      position: json['position'] ?? 0,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : null,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
      assignedUsers: _extractAssignedUsers(json['assignedUsers']),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((attachment) => CardAttachment.fromJson(attachment))
          .toList() ?? [],
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      list: json['list'] != null ? TaskList.fromJson(json['list']) : null,
      assignedUserDetails: (json['assignedUserDetails'] as List<dynamic>?)
          ?.map((user) => User.fromJson(user))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'listId': listId,
      'position': position,
      'dueDate': dueDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'assignedUsers': assignedUsers,
      'attachments': attachments.map((attachment) => attachment.toJson()).toList(),
      'deletedAt': deletedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'list': list?.toJson(),
      'assignedUserDetails': assignedUserDetails?.map((user) => user.toJson()).toList(),
    };
  }

  TaskCard copyWith({
    String? id,
    String? title,
    String? description,
    String? listId,
    int? position,
    DateTime? dueDate,
    DateTime? completedDate,
    bool? isCompleted,
    List<String>? assignedUsers,
    List<CardAttachment>? attachments,
    DateTime? deletedAt,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    TaskList? list,
    List<User>? assignedUserDetails,
  }) {
    return TaskCard(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      listId: listId ?? this.listId,
      position: position ?? this.position,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      isCompleted: isCompleted ?? this.isCompleted,
      assignedUsers: assignedUsers ?? this.assignedUsers,
      attachments: attachments ?? this.attachments,
      deletedAt: deletedAt ?? this.deletedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      list: list ?? this.list,
      assignedUserDetails: assignedUserDetails ?? this.assignedUserDetails,
    );
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueSoon {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    return dueDate!.isBefore(tomorrow) && dueDate!.isAfter(now);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskCard && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TaskCard(id: $id, title: $title, description: $description, listId: $listId, position: $position, isCompleted: $isCompleted)';
  }

  // Helper methods for safe JSON parsing
  static String _extractListId(dynamic listId) {
    if (listId == null) return '';
    if (listId is String) return listId;
    if (listId is Map<String, dynamic>) {
      return listId['_id'] ?? listId['id'] ?? '';
    }
    return listId.toString();
  }

  static List<String> _extractAssignedUsers(dynamic assignedUsers) {
    if (assignedUsers == null) return [];
    if (assignedUsers is List) {
      return assignedUsers.map<String>((user) {
        if (user is String) return user;
        if (user is Map<String, dynamic>) {
          return user['_id'] ?? user['id'] ?? user.toString();
        }
        return user.toString();
      }).toList();
    }
    return [];
  }
}

class CardAttachment {
  final String url;
  final String uploadedBy;
  final DateTime uploadedAt;
  final User? uploadedByUser;

  const CardAttachment({
    required this.url,
    required this.uploadedBy,
    required this.uploadedAt,
    this.uploadedByUser,
  });

  factory CardAttachment.fromJson(Map<String, dynamic> json) {
    return CardAttachment(
      url: json['url'] ?? '',
      uploadedBy: json['uploadedBy'] ?? '',
      uploadedAt: DateTime.parse(json['uploadedAt'] ?? DateTime.now().toIso8601String()),
      uploadedByUser: json['uploadedByUser'] != null
          ? User.fromJson(json['uploadedByUser'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploadedByUser': uploadedByUser?.toJson(),
    };
  }

  CardAttachment copyWith({
    String? url,
    String? uploadedBy,
    DateTime? uploadedAt,
    User? uploadedByUser,
  }) {
    return CardAttachment(
      url: url ?? this.url,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      uploadedByUser: uploadedByUser ?? this.uploadedByUser,
    );
  }

  String get fileName {
    return url.split('/').last.split('?').first;
  }

  String get fileExtension {
    final name = fileName;
    final lastDotIndex = name.lastIndexOf('.');
    if (lastDotIndex != -1 && lastDotIndex < name.length - 1) {
      return name.substring(lastDotIndex + 1).toLowerCase();
    }
    return '';
  }

  bool get isImage {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(fileExtension);
  }

  @override
  String toString() {
    return 'CardAttachment(url: $url, uploadedBy: $uploadedBy, uploadedAt: $uploadedAt)';
  }
}
