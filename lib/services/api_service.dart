// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const Duration _timeout = Duration(seconds: 15);

  // ================= TOKEN MANAGEMENT =================

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        data['statusCode'] = response.statusCode;
        return data;
      }
      return {
        'statusCode': response.statusCode,
        'message': 'Invalid response format.',
      };
    } catch (e) {
      return {
        'statusCode': response.statusCode,
        'message': 'Something went wrong. Invalid server response.',
      };
    }
  }

  // ================= AUTH =================

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return {'message': 'Unable to connect to server.'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      )
          .timeout(_timeout);

      final data = _handleResponse(response);
      if (response.statusCode == 200 && data['token'] != null) {
        await saveToken(data['token']);
      }
      return data;
    } catch (e) {
      return {'message': 'Unable to connect to server.'};
    }
  }

  static Future<void> logout() async {
    await clearToken();
  }

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'newPassword': newPassword}),
      )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return {'message': 'Unable to connect to server.'};
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/auth/profile'), headers: await _authHeaders())
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return {'message': 'Unable to connect to server.'};
    }
  }

  // ================= TASKS =================

  static Future<Map<String, dynamic>> getTasks({
    String? status,
    String? priority,
    String? category,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (status != null && status != 'All') queryParams['status'] = status;
    if (priority != null && priority != 'All') queryParams['priority'] = priority;
    if (category != null && category != 'All') queryParams['category'] = category;
    if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();

    final uri = Uri.parse('$baseUrl/tasks').replace(queryParameters: queryParams);

    try {
      final response = await http
          .get(uri, headers: await _authHeaders())
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return {'message': 'Unable to connect to server.'};
    }
  }

  static Future<Map<String, dynamic>> createTask({
    required String title,
    required String priority,
    required String category,
    required String dueDate,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/tasks'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'title': title,
          'priority': priority,
          'category': category,
          'due_date': dueDate,
        }),
      )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return {'message': 'Unable to connect to server.'};
    }
  }

  static Future<Map<String, dynamic>> updateTask({
    required int taskId,
    String? title,
    String? priority,
    String? category,
    String? dueDate,
    int? isCompleted,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (priority != null) body['priority'] = priority;
    if (category != null) body['category'] = category;
    if (dueDate != null) body['due_date'] = dueDate;
    if (isCompleted != null) body['is_completed'] = isCompleted;

    try {
      final response = await http
          .put(
        Uri.parse('$baseUrl/tasks/$taskId'),
        headers: await _authHeaders(),
        body: jsonEncode(body),
      )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return {'message': 'Unable to connect to server.'};
    }
  }

  static Future<Map<String, dynamic>> toggleTask(int taskId) async {
    try {
      final response = await http
          .patch(
        Uri.parse('$baseUrl/tasks/$taskId/toggle'),
        headers: await _authHeaders(),
      )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return {'message': 'Unable to connect to server.'};
    }
  }

  static Future<Map<String, dynamic>> deleteTask(int taskId) async {
    try {
      final response = await http
          .delete(
        Uri.parse('$baseUrl/tasks/$taskId'),
        headers: await _authHeaders(),
      )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return {'message': 'Unable to connect to server.'};
    }
  }

  // ================= CATEGORIES =================

  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/categories'), headers: await _authHeaders())
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return {'message': 'Unable to connect to server.'};
    }
  }

  static Future<Map<String, dynamic>> addCategory(String name) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/categories'),
        headers: await _authHeaders(),
        body: jsonEncode({'name': name}),
      )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return {'message': 'Unable to connect to server.'};
    }
  }

  static Future<Map<String, dynamic>> deleteCategory(int categoryId) async {
    try {
      final response = await http
          .delete(
        Uri.parse('$baseUrl/categories/$categoryId'),
        headers: await _authHeaders(),
      )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return {'message': 'Unable to connect to server.'};
    }
  }

  // ================= NOTIFICATIONS =================

  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/notifications'),
        headers: await _authHeaders(),
      )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return {'message': 'Unable to connect to server.'};
    }
  }

  // ✅ THIS is the method task_data.dart calls
  static Future<Map<String, dynamic>> postNotification({
    required String title,
    required String message,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/notifications'),
        headers: await _authHeaders(),
        body: jsonEncode({'title': title, 'message': message}),
      )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return {'message': 'Unable to connect to server.'};
    }
  }

  static Future<Map<String, dynamic>> markNotificationRead(int notificationId) async {
    try {
      final response = await http
          .patch(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: await _authHeaders(),
      )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return {'message': 'Unable to connect to server.'};
    }
  }

  static Future<Map<String, dynamic>> markAllNotificationsRead() async {
    try {
      final response = await http
          .patch(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: await _authHeaders(),
      )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return {'message': 'Unable to connect to server.'};
    }
  }
}