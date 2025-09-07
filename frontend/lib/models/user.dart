class User {
  final String id;
  final String email;
  final String name;
  final bool isVerified;
  final UserVerification verification;
  final DateTime? deletedAt;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.isVerified,
    required this.verification,
    this.deletedAt,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      isVerified: json['isVerified'] ?? false,
      verification: UserVerification.fromJson(json['verification'] ?? {}),
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
      'email': email,
      'name': name,
      'isVerified': isVerified,
      'verification': verification.toJson(),
      'deletedAt': deletedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    bool? isVerified,
    UserVerification? verification,
    DateTime? deletedAt,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isVerified: isVerified ?? this.isVerified,
      verification: verification ?? this.verification,
      deletedAt: deletedAt ?? this.deletedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, isVerified: $isVerified)';
  }
}

class UserVerification {
  final int code;
  final int ttl;

  const UserVerification({
    required this.code,
    required this.ttl,
  });

  factory UserVerification.fromJson(Map<String, dynamic> json) {
    return UserVerification(
      code: json['code'] ?? 0,
      ttl: json['ttl'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'ttl': ttl,
    };
  }

  UserVerification copyWith({
    int? code,
    int? ttl,
  }) {
    return UserVerification(
      code: code ?? this.code,
      ttl: ttl ?? this.ttl,
    );
  }

  bool get isExpired {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now > ttl;
  }

  @override
  String toString() {
    return 'UserVerification(code: $code, ttl: $ttl)';
  }
}

class UserOTP {
  final String id;
  final String userId;
  final int otp;
  final int ttl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserOTP({
    required this.id,
    required this.userId,
    required this.otp,
    required this.ttl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserOTP.fromJson(Map<String, dynamic> json) {
    return UserOTP(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['user'] ?? '',
      otp: json['otp'] ?? 0,
      ttl: json['ttl'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'otp': otp,
      'ttl': ttl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isExpired {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now > ttl;
  }

  @override
  String toString() {
    return 'UserOTP(id: $id, userId: $userId, otp: $otp, ttl: $ttl)';
  }
}