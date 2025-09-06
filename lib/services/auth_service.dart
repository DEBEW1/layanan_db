import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../config.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  static const String _userKey = 'current_user';

  // Fungsi untuk registrasi pengguna baru
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Print URL untuk debugging
      const url = '${AppConfig.apiUrl}/register.php';
      print('📡 Calling API: $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: json.encode({
          'nama': name,
          'email': email,
          'telepon': phone,
          'password': password,
        }),
      );

      print('📋 Response Status: ${response.statusCode}');
      print('📋 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        return {
          'status': 'error', 
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('❌ Register Error: $e');
      return {
        'status': 'error', 
        'message': 'Koneksi gagal: ${e.toString()}'
      };
    }
  }

  // Fungsi untuk login
  Future<bool> login(String email, String password) async {
    try {
      const url = '${AppConfig.apiUrl}/login.php';
      print('📡 Calling API: $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email, 
          'password': password
        }),
      );

      print('📋 Response Status: ${response.statusCode}');
      print('📋 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          final user = UserModel.fromJson(data['data']);
          await _saveCurrentUser(user);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ Login Error: $e');
      return false;
    }
  }

  // Fungsi untuk logout
  Future<void> logout() async {
    await _storage.delete(key: _userKey);
  }

  // Menyimpan data user ke secure storage
  Future<void> _saveCurrentUser(UserModel user) async {
    await _storage.write(key: _userKey, value: json.encode(user.toJson()));
  }

  // Mengambil data user yang sedang login
  Future<UserModel?> getCurrentUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson != null) {
        return UserModel.fromJson(json.decode(userJson));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Cek apakah ada sesi login yang aktif
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }
}