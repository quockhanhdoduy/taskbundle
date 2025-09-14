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
        try {
          final errorBody = jsonDecode(response.body);
          String errorMessage = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';

          if (errorBody is Map<String, dynamic>) {
            if (errorBody['message'] != null) {
              if (errorBody['message'] is String) {
                errorMessage = errorBody['message'];
              } else if (errorBody['message'] is Map<String, dynamic>) {
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
        try {
          final errorBody = jsonDecode(response.body);
          String errorMessage = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';

          if (errorBody is Map<String, dynamic>) {
            if (errorBody['message'] != null) {
              if (errorBody['message'] is String) {
                errorMessage = errorBody['message'];
              } else if (errorBody['message'] is Map<String, dynamic>) {
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
        try {
          final errorBody = jsonDecode(response.body);
          String errorMessage = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';

          if (errorBody is Map<String, dynamic>) {
            if (errorBody['message'] != null) {
              if (errorBody['message'] is String) {
                errorMessage = errorBody['message'];
              } else if (errorBody['message'] is Map<String, dynamic>) {
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
        try {
          final errorBody = jsonDecode(response.body);
          String errorMessage = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';

          if (errorBody is Map<String, dynamic>) {
            if (errorBody['message'] != null) {
              if (errorBody['message'] is String) {
                errorMessage = errorBody['message'];
              } else if (errorBody['message'] is Map<String, dynamic>) {
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

  static Future<Map<String, dynamic>> deleteWithBody(String endpoint, Map<String, dynamic> data) async {
    try {
      final request = http.Request('DELETE', Uri.parse('$baseUrl$endpoint'))
        ..headers.addAll(_headers)
        ..body = jsonEncode(data);
      final response = await http.Client().send(request);
      final resp = await http.Response.fromStream(response);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = jsonDecode(resp.body);
        return Map<String, dynamic>.from(decoded);
      } else {
        try {
          final errorBody = jsonDecode(resp.body);
          String errorMessage = 'HTTP ${resp.statusCode}: ${resp.reasonPhrase}';
          if (errorBody is Map<String, dynamic>) {
            if (errorBody['message'] != null) {
              if (errorBody['message'] is String) {
                errorMessage = errorBody['message'];
              } else if (errorBody['message'] is Map<String, dynamic>) {
                var msgObj = errorBody['message'] as Map<String, dynamic>;
                if (msgObj['data'] is List) {
                  List<String> errors = List<String>.from(msgObj['data']);
                  errorMessage = errors.join(', ');
                }
              }
            } else if (errorBody['error'] is String) {
              errorMessage = errorBody['error'];
            } else if (errorBody['details'] is String) {
              errorMessage = errorBody['details'];
            }
          }
          return {
            'status': 'error',
            'success': false,
            'message': errorMessage,
            'data': errorBody,
            'statusCode': resp.statusCode
          };
        } catch (_) {
          return {
            'status': 'error',
            'success': false,
            'message': 'HTTP ${resp.statusCode}: ${resp.reasonPhrase}',
            'data': null,
            'statusCode': resp.statusCode
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

    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    if (fields != null) {
      request.fields.addAll(fields);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }
}
