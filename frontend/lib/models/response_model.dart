class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? meta;
  final List<String>? errors;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      meta: json['meta'],
      errors: json['errors'] != null
          ? List<String>.from(json['errors'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'meta': meta,
      'errors': errors,
    };
  }

  ApiResponse<T> copyWith({
    bool? success,
    String? message,
    T? data,
    Map<String, dynamic>? meta,
    List<String>? errors,
  }) {
    return ApiResponse<T>(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
      meta: meta ?? this.meta,
      errors: errors ?? this.errors,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, data: $data)';
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginatedResponse({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => fromJsonT(item))
          .toList() ?? [],
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items,
      'totalItems': totalItems,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'pageSize': pageSize,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }

  PaginatedResponse<T> copyWith({
    List<T>? items,
    int? totalItems,
    int? totalPages,
    int? currentPage,
    int? pageSize,
    bool? hasNextPage,
    bool? hasPreviousPage,
  }) {
    return PaginatedResponse<T>(
      items: items ?? this.items,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
    );
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  @override
  String toString() {
    return 'PaginatedResponse(totalItems: $totalItems, currentPage: $currentPage, pageSize: $pageSize)';
  }
}

class AuthResponse {
  final String token;
  final Map<String, dynamic> user;
  final DateTime? expiresAt;

  const AuthResponse({
    required this.token,
    required this.user,
    this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      user: json['user'] ?? {},
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AuthResponse(token: ${token.substring(0, 10)}..., user: $user)';
  }
}

class ErrorResponse {
  final String message;
  final int? statusCode;
  final String? error;
  final List<String>? details;

  const ErrorResponse({
    required this.message,
    this.statusCode,
    this.error,
    this.details,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json['message'] ?? 'An error occurred',
      statusCode: json['statusCode'],
      error: json['error'],
      details: json['details'] != null
          ? List<String>.from(json['details'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'error': error,
      'details': details,
    };
  }

  @override
  String toString() {
    return 'ErrorResponse(message: $message, statusCode: $statusCode)';
  }
}
