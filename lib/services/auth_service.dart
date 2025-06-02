import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000/api/auth';

  /// ✅ Kullanıcı kaydı – artık Map döner
  static Future<Map<String, dynamic>> registerUser({
    required String userName,
    required String gender,
    required String password,
    required int height,
  }) async {
    final uri = Uri.parse('$baseUrl/register');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userName': userName,
        'gender': gender,
        'password': password,
        'height': height,
      }),
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body)['error'] ?? 'Kayıt başarısız';
      throw Exception(error);
    }

    final data = jsonDecode(response.body);

    return {
      'userId': data['userId'],
      'authToken': data['token'],
      'userName': userName,
      'gender': gender,
      'height': height.toString(),
    };
  }

  /// Giriş işlemi (değişmedi)
  static Future<void> loginUser({
    required String userName,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userName': userName,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['error'] ?? 'Giriş başarısız';
      throw Exception(error);
    }

    final data = jsonDecode(response.body);

    await _storeUserData(
      userId: data['userId'],
      token: data['token'],
      userName: userName,
      gender: data['gender'] ?? '',
      height: data['height']?.toString() ?? '',
    );
  }

  /// Local userId, token ve profil bilgilerini kaydet
  static Future<void> _storeUserData({
    required String userId,
    required String token,
    required String userName,
    required String gender,
    required String height,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('authToken', token);
    await prefs.setString('userName', userName);
    await prefs.setString('gender', gender);
    await prefs.setString('height', height);
  }

  /// Çıkış yap
  static Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('authToken');
    await prefs.remove('userName');
    await prefs.remove('gender');
    await prefs.remove('height');
    await prefs.remove('profileImageUrl');
  }

  /// Giriş yapılmış mı?
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userId') && prefs.containsKey('authToken');
  }
}
