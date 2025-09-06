import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../config.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  static const String _userKey = 'current_user';
  static const Duration _timeout = Duration(seconds: 10);

  // Fungsi untuk registrasi pengguna baru dengan dynamic config
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Gunakan dynamic URL dari AppConfig
      final url = '${AppConfig.apiUrl}/register.php';
      print('📡 Calling API: $url');
      print('🔧 Current Server IP: ${AppConfig.ipAddress}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Connection': 'keep-alive',
        },
        body: json.encode({
          'nama': name,
          'email': email,
          'telepon': phone,
          'password': password,
        }),
      ).timeout(_timeout);

      print('📋 Response Status: ${response.statusCode}');
      print('📋 Response Headers: ${response.headers}');
      print('📋 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          return responseData;
        } catch (jsonError) {
          // Jika response bukan JSON valid
          return {
            'status': 'success', 
            'message': 'Registrasi berhasil',
            'raw_response': response.body
          };
        }
      } else {
        return {
          'status': 'error', 
          'message': 'Server error (${response.statusCode}): ${response.body}'
        };
      }
    } on TimeoutException {
      return {
        'status': 'error',
        'message': 'Koneksi timeout ke server ${AppConfig.ipAddress}.\nPastikan XAMPP running dan IP benar.'
      };
    } on SocketException catch (e) {
      return {
        'status': 'error',
        'message': 'Server ${AppConfig.ipAddress} tidak dapat dijangkau.\nError: ${e.message}\n\nSolusi:\n• Pastikan XAMPP Apache running\n• Cek IP address di settings\n• Pastikan HP dan server di jaringan yang sama'
      };
    } on HttpException catch (e) {
      return {
        'status': 'error',
        'message': 'HTTP Error: ${e.message}'
      };
    } on FormatException catch (e) {
      return {
        'status': 'error',
        'message': 'Invalid server response format: ${e.message}'
      };
    } catch (e) {
      print('❌ Register Error: $e');
      return {
        'status': 'error', 
        'message': 'Unexpected error: ${e.toString()}'
      };
    }
  }

  // Fungsi untuk login dengan dynamic config dan better error handling
  Future<bool> login(String email, String password) async {
    try {
      // Gunakan dynamic URL dari AppConfig
      final url = '${AppConfig.apiUrl}/login.php';
      print('📡 Calling API: $url');
      print('🔧 Current Server IP: ${AppConfig.ipAddress}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Connection': 'keep-alive',
        },
        body: json.encode({
          'email': email, 
          'password': password
        }),
      ).timeout(_timeout);

      print('📋 Response Status: ${response.statusCode}');
      print('📋 Response Headers: ${response.headers}');
      print('📋 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          if (data['status'] == 'success' && data['data'] != null) {
            final user = UserModel.fromJson(data['data']);
            await _saveCurrentUser(user);
            print('✅ Login successful for user: ${user.name}');
            return true;
          } else {
            print('❌ Login failed: ${data['message'] ?? 'Invalid credentials'}');
            return false;
          }
        } catch (jsonError) {
          print('❌ JSON parsing error: $jsonError');
          return false;
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return false;
      }
    } on TimeoutException {
      print('❌ Login Timeout to ${AppConfig.ipAddress}');
      return false;
    } on SocketException catch (e) {
      print('❌ Socket Error to ${AppConfig.ipAddress}: ${e.message}');
      return false;
    } on HttpException catch (e) {
      print('❌ HTTP Exception: ${e.message}');
      return false;
    } catch (e) {
      print('❌ Login Error: $e');
      return false;
    }
  }

  // Method untuk test koneksi ke server
  Future<bool> testConnection() async {
    try {
      final url = '${AppConfig.apiUrl}/login.php';
      print('🧪 Testing connection to: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Connection': 'close'},
      ).timeout(Duration(seconds: 5));
      
      print('🧪 Test result: ${response.statusCode}');
      
      // Status 200 (OK) atau 405 (Method Not Allowed) = server ada
      return response.statusCode == 200 || response.statusCode == 405;
    } catch (e) {
      print('🧪 Connection test failed: $e');
      return false;
    }
  }

  // Method untuk mendapatkan info koneksi
  Future<Map<String, dynamic>> getConnectionInfo() async {
    final info = <String, dynamic>{
      'server_ip': AppConfig.ipAddress,
      'base_url': AppConfig.baseUrl,
      'api_url': AppConfig.apiUrl,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Test koneksi
    try {
      final isConnected = await testConnection();
      info['connection_status'] = isConnected ? 'connected' : 'failed';
    } catch (e) {
      info['connection_status'] = 'error';
      info['connection_error'] = e.toString();
    }

    return info;
  }

  // Method untuk login dengan retry otomatis
  Future<Map<String, dynamic>> loginWithRetry(String email, String password, {int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      print('🔄 Login attempt $attempt/$maxRetries');
      
      try {
        final success = await login(email, password);
        
        if (success) {
          return {
            'success': true,
            'message': 'Login berhasil',
            'attempt': attempt,
          };
        }
        
        if (attempt < maxRetries) {
          print('⏳ Waiting before retry...');
          await Future.delayed(Duration(seconds: 2));
        }
        
      } catch (e) {
        print('❌ Attempt $attempt failed: $e');
        
        if (attempt == maxRetries) {
          return {
            'success': false,
            'message': 'Login gagal setelah $maxRetries percobaan: ${e.toString()}',
            'error': e.toString(),
          };
        }
      }
    }
    
    return {
      'success': false,
      'message': 'Login gagal setelah $maxRetries percobaan',
    };
  }

  // Method untuk register dengan retry otomatis
  Future<Map<String, dynamic>> registerWithRetry({
    required String name,
    required String email,
    required String phone,
    required String password,
    int maxRetries = 3,
  }) async {
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      print('🔄 Register attempt $attempt/$maxRetries');
      
      final result = await register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      
      if (result['status'] == 'success') {
        result['attempt'] = attempt;
        return result;
      }
      
      if (attempt < maxRetries) {
        print('⏳ Waiting before retry...');
        await Future.delayed(Duration(seconds: 2));
      }
    }
    
    return {
      'status': 'error',
      'message': 'Registrasi gagal setelah $maxRetries percobaan. Periksa koneksi server.',
    };
  }

  // Fungsi untuk logout
  Future<void> logout() async {
    try {
      await _storage.delete(key: _userKey);
      print('🚪 User logged out successfully');
    } catch (e) {
      print('❌ Logout error: $e');
    }
  }

  // Menyimpan data user ke secure storage
  Future<void> _saveCurrentUser(UserModel user) async {
    try {
      await _storage.write(key: _userKey, value: json.encode(user.toJson()));
      print('💾 User data saved to storage');
    } catch (e) {
      print('❌ Error saving user data: $e');
    }
  }

  // Mengambil data user yang sedang login
  Future<UserModel?> getCurrentUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson != null) {
        final user = UserModel.fromJson(json.decode(userJson));
        print('👤 Retrieved user: ${user.name}');
        return user;
      }
      print('👤 No user data found');
      return null;
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }

  // Cek apakah ada sesi login yang aktif
  Future<bool> isLoggedIn() async {
    try {
      final user = await getCurrentUser();
      final isLoggedIn = user != null;
      print('🔍 User logged in: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      print('❌ Error checking login status: $e');
      return false;
    }
  }

  // Method untuk clear semua data (debugging)
  Future<void> clearAllData() async {
    try {
      await _storage.deleteAll();
      print('🗑️ All user data cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }

  // Method untuk debugging - print semua info
  Future<void> printDebugInfo() async {
    print('🔧 AUTH SERVICE DEBUG INFO:');
    print('Current Server: ${AppConfig.ipAddress}');
    print('Base URL: ${AppConfig.baseUrl}');
    print('API URL: ${AppConfig.apiUrl}');
    
    final user = await getCurrentUser();
    print('Current User: ${user?.name ?? 'None'}');
    
    final connectionInfo = await getConnectionInfo();
    print('Connection Status: ${connectionInfo['connection_status']}');
    
    print('═══════════════════════════════════');
  }
}