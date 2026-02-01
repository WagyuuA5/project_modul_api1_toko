
import 'package:shared_preferences/shared_preferences.dart';

class UserLogin {
  final int? id;
  final String? nama;
  final String? email;
  final String? role;
  final String? token;
  final bool? status;
  final String? message;

  UserLogin({
    this.id,
    this.nama,
    this.email,
    this.role,
    this.token,
    this.status,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'role': role,
      'token': token,
      'status': status,
      'message': message,
    };
  }

  static UserLogin fromJson(Map<String, dynamic> json) {
    return UserLogin(
      id: json['id'] ?? json['user']?['id'] ?? json['data']?['id'] ?? 0,
      nama: json['nama'] ?? 
            json['user']?['nama'] ?? 
            json['user']?['nama_user'] ?? 
            json['user']?['name'] ?? 
            json['data']?['name'] ?? '',
      email: json['email'] ?? json['user']?['email'] ?? json['data']?['email'] ?? '',
      role: json['role'] ?? json['user']?['role'] ?? json['data']?['role'] ?? 'user',
      token: json['token'] ?? json['authorisation']?['token'],
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('user_id', id ?? 0);
    prefs.setString('user_nama', nama ?? '');
    prefs.setString('user_email', email ?? '');
    prefs.setString('user_role', role ?? 'user');
    prefs.setString('user_token', token ?? '');
  }

  static Future<UserLogin?> getFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('user_id') ?? 0;
      final nama = prefs.getString('user_nama');
      final email = prefs.getString('user_email');
      final role = prefs.getString('user_role');
      final token = prefs.getString('user_token');

      if (email == null || email.isEmpty) {
        return null;
      }

      return UserLogin(
        id: id,
        nama: nama,
        email: email,
        role: role,
        token: token,
      );
    } catch (e) {
      print('Error getting user from prefs: $e');
      return null;
    }
  }

  static Future<void> clearPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_nama');
      await prefs.remove('user_email');
      await prefs.remove('user_role');
      await prefs.remove('user_token');
    } catch (e) {
      print('Error clearing prefs: $e');
    }
  }

  bool get isLoggedIn => token != null && token!.isNotEmpty;
}