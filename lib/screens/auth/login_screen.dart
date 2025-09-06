import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../main/dashboard_screen.dart';
import 'register_screen.dart';
import '../settings/server_config_screen.dart'; // <-- TAMBAH IMPORT INI
import '../../utils/app_theme.dart';
import '../../config.dart'; // <-- TAMBAH IMPORT INI

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        _showSnackBar('Email atau password salah.');
      }
    } catch (e) {
      _showSnackBar('Gagal terhubung ke server. Periksa koneksi Anda.');
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
      ),
    );
  }

  // TAMBAH METHOD INI untuk buka settings
  void _openServerSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ServerConfigScreen(),
      ),
    );
  }

  // TAMBAH METHOD INI untuk show server info
  void _showServerInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Info Server'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Server saat ini:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('IP: ${AppConfig.ipAddress}'),
            Text('URL: ${AppConfig.baseUrl}'),
            SizedBox(height: 16),
            Text('Jika tidak bisa login:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('• Pastikan XAMPP running'),
            Text('• Cek IP address server'),
            Text('• Klik tombol ⚙️ untuk ubah server'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openServerSettings();
            },
            child: const Text('Atur Server'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      // TAMBAH AppBar dengan tombol settings
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Hilangkan tombol back
        actions: [
          // Tombol info server
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
            tooltip: 'Info Server',
            onPressed: _showServerInfo,
          ),
          // Tombol settings server
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.primaryColor),
            tooltip: 'Konfigurasi Server',
            onPressed: _openServerSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: 'Email',
                    controller: _emailController,
                    hint: 'Masukkan email Anda',
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => (val?.isEmpty ?? true) ? 'Email tidak boleh kosong' : null,
                  ),
                  CustomTextField(
                    label: 'Password',
                    controller: _passwordController,
                    hint: 'Masukkan password Anda',
                    obscureText: _obscurePassword,
                    validator: (val) => (val?.isEmpty ?? true) ? 'Password tidak boleh kosong' : null,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Masuk'),
                  ),
                  const SizedBox(height: 16),
                  _buildRegisterPrompt(),
                  
                  // TAMBAH bagian ini - Server status info
                  const SizedBox(height: 24),
                  _buildServerStatus(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.gavel_rounded, size: 64, color: AppTheme.primaryColor),
        const SizedBox(height: 16),
        const Text(
          'Layanan Pengaduan',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          'Masuk untuk melanjutkan',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildRegisterPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Belum punya akun?"),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
          },
          child: const Text('Daftar di sini'),
        ),
      ],
    );
  }

  // TAMBAH METHOD INI - Server status widget
  Widget _buildServerStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.dns, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Server: ${AppConfig.ipAddress}',
              style: const TextStyle(
                fontSize: 12, 
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _openServerSettings,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.edit, size: 14, color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}