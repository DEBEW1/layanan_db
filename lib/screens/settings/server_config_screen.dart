import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config.dart';
import '../../utils/app_theme.dart';

class ServerConfigScreen extends StatefulWidget {
  const ServerConfigScreen({super.key});

  @override
  State<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends State<ServerConfigScreen> {
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  bool _isLoading = false;
  String? _statusMessage;
  List<String> _foundServers = [];

  @override
  void initState() {
    super.initState();
    _ipController.text = AppConfig.ipAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konfigurasi Server')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input IP
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'IP Address Server',
                hintText: '192.168.1.14',
                prefixIcon: Icon(Icons.computer),
              ),
            ),
            const SizedBox(height: 16),
            
            // Input Port (opsional)
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'Port (opsional)',
                hintText: '8080',
                prefixIcon: Icon(Icons.settings_ethernet),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            
            // Tombol Test
            ElevatedButton.icon(
              icon: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.network_check),
              label: const Text('Test Koneksi'),
              onPressed: _isLoading ? null : _testConnection,
            ),
            
            const SizedBox(height: 16),
            
            // Tombol Auto-Discover
            OutlinedButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('Auto-Discover Server'),
              onPressed: _isLoading ? null : _autoDiscover,
            ),
            
            const SizedBox(height: 16),
            
            // Status Message
            if (_statusMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _statusMessage!.contains('✅') 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _statusMessage!.contains('✅') 
                      ? Colors.green 
                      : Colors.red,
                  ),
                ),
                child: Text(_statusMessage!),
              ),
            
            const SizedBox(height: 24),
            
            // List Server yang Ditemukan
            if (_foundServers.isNotEmpty) ...[
              const Text('Server yang Ditemukan:', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _foundServers.length,
                  itemBuilder: (context, index) {
                    final server = _foundServers[index];
                    return ListTile(
                      leading: const Icon(Icons.dns),
                      title: Text(server),
                      trailing: ElevatedButton(
                        child: const Text('Gunakan'),
                        onPressed: () => _selectServer(server),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final ip = _ipController.text.trim();
      final port = _portController.text.trim();
      
      if (ip.isEmpty) {
        setState(() {
          _statusMessage = '❌ IP Address tidak boleh kosong';
          _isLoading = false;
        });
        return;
      }

      // Test koneksi
      final testUrl = port.isEmpty 
        ? 'http://$ip/layanan/admin/dashboard.php'
        : 'http://$ip:$port/layanan/admin/dashboard.php';

      final response = await http.get(Uri.parse(testUrl))
        .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Simpan konfigurasi jika berhasil
        await AppConfig.setIpAddress(ip, port: port);
        
        setState(() {
          _statusMessage = '✅ Koneksi berhasil!\nServer dapat diakses.';
        });
      } else {
        setState(() {
          _statusMessage = '❌ Server merespons dengan kode: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Tidak dapat terhubung ke server:\n${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _autoDiscover() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '🔍 Mencari server di jaringan...';
      _foundServers.clear();
    });

    try {
      final servers = await AppConfig.scanNetwork();
      
      setState(() {
        _foundServers = servers;
        _statusMessage = servers.isEmpty 
          ? '❌ Tidak ada server yang ditemukan'
          : '✅ Ditemukan ${servers.length} server';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error scanning: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectServer(String serverIp) async {
    await AppConfig.setIpAddress(serverIp);
    _ipController.text = serverIp;
    
    setState(() {
      _statusMessage = '✅ Server $serverIp telah dipilih!';
    });
    
    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Sukses'),
        content: Text('Server berhasil diubah ke:\n$serverIp'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}