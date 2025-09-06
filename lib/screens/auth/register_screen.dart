import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/app_theme.dart';
import '../../config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Print debug info saat screen dibuka
    print('🔧 Debug Info:');
    print('Base URL: ${AppConfig.baseUrl}');
    print('API URL: ${AppConfig.apiUrl}');
    print('Register endpoint: ${AppConfig.apiUrl}/register.php');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('🚀 Starting registration...');
      print('Name: ${_nameController.text.trim()}');
      print('Email: ${_emailController.text.trim()}');
      print('Phone: ${_phoneController.text.trim()}');
      
      final result = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );
      
      print('📨 Registration result: $result');
      
      if (!mounted) return;

      if (result['status'] == 'success') {
        _showSnackBar('Registrasi berhasil! Silakan login.', isError: false);
        Navigator.of(context).pop();
      } else {
        _showSnackBar(result['message'] ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      print('❌ Registration exception: $e');
      _showSnackBar('Gagal terhubung ke server. Periksa koneksi Anda.\nError: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.secondaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5), // Durasi lebih lama untuk error
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
        // Tambah tombol debug
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Debug Info'),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Base URL: ${AppConfig.baseUrl}'),
                      Text('API URL: ${AppConfig.apiUrl}'),
                      Text('Register: ${AppConfig.apiUrl}/register.php'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Nama Lengkap',
                controller: _nameController,
                validator: (val) => (val?.isEmpty ?? true) ? 'Nama tidak boleh kosong' : null,
              ),
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (val) => (val?.isEmpty ?? true) ? 'Email tidak boleh kosong' : null,
              ),
              CustomTextField(
                label: 'Nomor Telepon',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (val) => (val?.isEmpty ?? true) ? 'Telepon tidak boleh kosong' : null,
              ),
              CustomTextField(
                label: 'Password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: (val) => (val?.length ?? 0) < 6 ? 'Password minimal 6 karakter' : null,
                 suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              CustomTextField(
                label: 'Konfirmasi Password',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                validator: (val) => val != _passwordController.text ? 'Password tidak cocok' : null,
                 suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}