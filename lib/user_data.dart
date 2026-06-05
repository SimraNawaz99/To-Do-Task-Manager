// lib/user_data.dart

class UserData {
  static int? id;
  static String name = '';
  static String email = '';

  static bool get isLoggedIn {
    return id != null && id != 0;
  }

  static void setUser({
    required int userId,
    required String userName,
    required String userEmail,
  }) {
    id = userId;
    name = userName;
    email = userEmail;
  }

  static void setUserFromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id'].toString());
    name = json['name']?.toString() ?? '';
    email = json['email']?.toString() ?? '';
  }

  static void clear() {
    id = null;
    name = '';
    email = '';
  }
}