import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_endpoints.dart';

class ApiService {
  static String get baseUrl => ApiEndpoints.baseUrl;
  static String? _token;

  static void setToken(String token) => _token = token;
  static void clearToken() => _token = null;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        return Map<String, dynamic>.from(decoded);
      } else {
        // Try to parse error response body for detailed error message
        try {
          final errorBody = jsonDecode(response.body);
          String errorMessage = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';

          // Extract error message from various possible formats
          if (errorBody is Map<String, dynamic>) {
            if (errorBody['message'] != null) {
              if (errorBody['message'] is String) {
                errorMessage = errorBody['message'];
              } else if (errorBody['message'] is Map<String, dynamic>) {
                // Handle case where message is an object with data array
                var msgObj = errorBody['message'] as Map<String, dynamic>;
                if (msgObj['data'] is List) {
                  List<String> errors = List<String>.from(msgObj['data']);
                  errorMessage = errors.join(', ');
                }
              }
            } else if (errorBody['error'] != null && errorBody['error'] is String) {
              errorMessage = errorBody['error'];
            } else if (errorBody['details'] != null && errorBody['details'] is String) {
              errorMessage = errorBody['details'];
            }
          }

          return {
            'status': 'error',
            'success': false,
            'message': errorMessage,
            'data': errorBody,
            'statusCode': response.statusCode
          };
        } catch (e) {
          // If can't parse error body, return generic error
          return {
            'status': 'error',
            'success': false,
            'message': 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
            'data': null,
            'statusCode': response.statusCode
          };
        }
      }
    } catch (e) {
      return {
        'status': 'error',
        'success': false,
        'message': 'Connection error: ${e.toString()}',
        'data': null
      };
    }
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'), headers: _headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        return Map<String, dynamic>.from(decoded);
      } else {
        // Try to parse error response body for detailed error message
        try {
          final errorBody = jsonDecode(response.body);
          String errorMessage = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';

          // Extract error message from various possible formats
          if (errorBody is Map<String, dynamic>) {
            if (errorBody['message'] != null) {
              if (errorBody['message'] is String) {
                errorMessage = errorBody['message'];
              } else if (errorBody['message'] is Map<String, dynamic>) {
                // Handle case where message is an object with data array
                var msgObj = errorBody['message'] as Map<String, dynamic>;
                if (msgObj['data'] is List) {
                  List<String> errors = List<String>.from(msgObj['data']);
                  errorMessage = errors.join(', ');
                }
              }
            } else if (errorBody['error'] != null && errorBody['error'] is String) {
              errorMessage = errorBody['error'];
            } else if (errorBody['details'] != null && errorBody['details'] is String) {
              errorMessage = errorBody['details'];
            }
          }

          return {
            'status': 'error',
            'success': false,
            'message': errorMessage,
            'data': errorBody,
            'statusCode': response.statusCode
          };
        } catch (e) {
          // If can't parse error body, return generic error
          return {
            'status': 'error',
            'success': false,
            'message': 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
            'data': null,
            'statusCode': response.statusCode
          };
        }
      }
    } catch (e) {
      return {
        'status': 'error',
        'success': false,
        'message': 'Connection error: ${e.toString()}',
        'data': null
      };
    }
  }

  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        return Map<String, dynamic>.from(decoded);
      } else {
        // Try to parse error response body for detailed error message
        try {
          final errorBody = jsonDecode(response.body);
          String errorMessage = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';

          // Extract error message from various possible formats
          if (errorBody is Map<String, dynamic>) {
            if (errorBody['message'] != null) {
              if (errorBody['message'] is String) {
                errorMessage = errorBody['message'];
              } else if (errorBody['message'] is Map<String, dynamic>) {
                // Handle case where message is an object with data array
                var msgObj = errorBody['message'] as Map<String, dynamic>;
                if (msgObj['data'] is List) {
                  List<String> errors = List<String>.from(msgObj['data']);
                  errorMessage = errors.join(', ');
                }
              }
            } else if (errorBody['error'] != null && errorBody['error'] is String) {
              errorMessage = errorBody['error'];
            } else if (errorBody['details'] != null && errorBody['details'] is String) {
              errorMessage = errorBody['details'];
            }
          }

          return {
            'status': 'error',
            'success': false,
            'message': errorMessage,
            'data': errorBody,
            'statusCode': response.statusCode
          };
        } catch (e) {
          // If can't parse error body, return generic error
          return {
            'status': 'error',
            'success': false,
            'message': 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
            'data': null,
            'statusCode': response.statusCode
          };
        }
      }
    } catch (e) {
      return {
        'status': 'error',
        'success': false,
        'message': 'Connection error: ${e.toString()}',
        'data': null
      };
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl$endpoint'), headers: _headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        return Map<String, dynamic>.from(decoded);
      } else {
        // Try to parse error response body for detailed error message
        try {
          final errorBody = jsonDecode(response.body);
          String errorMessage = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';

          // Extract error message from various possible formats
          if (errorBody is Map<String, dynamic>) {
            if (errorBody['message'] != null) {
              if (errorBody['message'] is String) {
                errorMessage = errorBody['message'];
              } else if (errorBody['message'] is Map<String, dynamic>) {
                // Handle case where message is an object with data array
                var msgObj = errorBody['message'] as Map<String, dynamic>;
                if (msgObj['data'] is List) {
                  List<String> errors = List<String>.from(msgObj['data']);
                  errorMessage = errors.join(', ');
                }
              }
            } else if (errorBody['error'] != null && errorBody['error'] is String) {
              errorMessage = errorBody['error'];
            } else if (errorBody['details'] != null && errorBody['details'] is String) {
              errorMessage = errorBody['details'];
            }
          }

          return {
            'status': 'error',
            'success': false,
            'message': errorMessage,
            'data': errorBody,
            'statusCode': response.statusCode
          };
        } catch (e) {
          // If can't parse error body, return generic error
          return {
            'status': 'error',
            'success': false,
            'message': 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
            'data': null,
            'statusCode': response.statusCode
          };
        }
      }
    } catch (e) {
      return {
        'status': 'error',
        'success': false,
        'message': 'Connection error: ${e.toString()}',
        'data': null
      };
    }
  }

  static Future<Map<String, dynamic>> uploadFile(String endpoint, String filePath, Map<String, String>? fields) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));

    // Add headers
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    // Add file
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    // Add fields
    if (fields != null) {
      request.fields.addAll(fields);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }
}
