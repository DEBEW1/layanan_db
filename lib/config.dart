import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';

class AppConfig {
  static String _ipAddress = '192.168.1.14'; // Default
  static String _port = ''; // Port opsional
  
  // Getter untuk IP saat ini
  static String get ipAddress => _ipAddress;
  static String get port => _port;
  static String get baseUrl => _port.isEmpty 
    ? 'http://$_ipAddress/layanan'
    : 'http://$_ipAddress:$_port/layanan';
  static String get apiUrl => '$baseUrl/api';
  
  // Method untuk mengubah IP
  static Future<void> setIpAddress(String newIp, {String port = ''}) async {
    _ipAddress = newIp.trim();
    _port = port.trim();
    await _saveToStorage();
    print('✅ IP Updated: $_ipAddress${_port.isNotEmpty ? ':$_port' : ''}');
  }
  
  // Method untuk menyimpan ke SharedPreferences
  static Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('server_ip', _ipAddress);
      await prefs.setString('server_port', _port);
      print('💾 Configuration saved to storage');
    } catch (e) {
      print('❌ Error saving to storage: $e');
    }
  }
  
  // Method untuk load dari storage
  static Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _ipAddress = prefs.getString('server_ip') ?? '192.168.1.14';
      _port = prefs.getString('server_port') ?? '';
      print('📖 Configuration loaded from storage');
      printCurrentConfig();
    } catch (e) {
      print('❌ Error loading IP config: $e');
    }
  }
  
  // Method untuk reset ke default
  static Future<void> resetToDefault() async {
    _ipAddress = '192.168.1.14';
    _port = '';
    await _saveToStorage();
    print('🔄 Configuration reset to default');
  }
  
  // Method untuk auto-detect server di jaringan
  static Future<String?> autoDiscoverServer() async {
    print('🔍 Starting auto-discovery...');
    
    List<String> commonIPs = [
      // Router IPs (most likely)
      '192.168.1.1', '192.168.0.1', '10.0.0.1', '172.16.0.1',
      
      // Common server IPs
      '192.168.1.14', '192.168.1.100', '192.168.1.200',
      '192.168.0.14', '192.168.0.100', '192.168.0.200',
      '10.0.0.14', '10.0.0.100', '10.0.0.200',
      '172.16.0.14', '172.16.0.100', '172.16.0.200',
      
      // Localhost variations
      '127.0.0.1', 'localhost',
    ];
    
    for (String ip in commonIPs) {
      print('🔍 Testing IP: $ip');
      if (await _testConnection(ip)) {
        await setIpAddress(ip);
        print('✅ Server found at: $ip');
        return ip;
      }
    }
    
    print('❌ No server found in common IPs');
    return null;
  }
  
  // Method untuk test koneksi dengan multiple endpoints
  static Future<bool> _testConnection(String ip) async {
    // Test multiple endpoints
    List<String> testEndpoints = [
      '/layanan/admin/dashboard.php',
      '/layanan/api/register.php',
      '/layanan/index.php',
      '/layanan/',
    ];
    
    for (String endpoint in testEndpoints) {
      try {
        final url = 'http://$ip$endpoint';
        final response = await http.get(
          Uri.parse(url),
          headers: {'Connection': 'close'},
        ).timeout(const Duration(seconds: 3));
        
        // Consider 200, 302, 403, 405 as valid responses (server exists)
        if ([200, 302, 403, 405].contains(response.statusCode)) {
          print('✅ Server responds at: $url (${response.statusCode})');
          return true;
        }
      } catch (e) {
        // Continue to next endpoint
        continue;
      }
    }
    
    return false;
  }
  
  // Method untuk scan range IP secara cerdas
  static Future<List<String>> scanNetwork() async {
    print('🌐 Starting network scan...');
    List<String> foundServers = [];
    
    // Get local network info first
    String? localNetwork = await _getLocalNetworkRange();
    
    Set<String> ranges = <String>{};
    if (localNetwork != null) {
      ranges.add(localNetwork);
      print('🏠 Scanning local network: $localNetwork');
    }
    
    // Add common ranges
    ranges.addAll(['192.168.1.', '192.168.0.', '10.0.0.', '172.16.0.']);
    
    for (String range in ranges) {
      print('🔍 Scanning range: ${range}x');
      
      // Create a list to hold all scan futures
      List<Future<String?>> scanFutures = [];
      
      // Create scan tasks for each IP in range
      for (int i = 1; i <= 254; i++) {
        String testIP = '$range$i';
        scanFutures.add(_scanSingleIP(testIP));
      }
      
      // Process all scans and collect results
      try {
        final results = await Future.wait(scanFutures, eagerError: false);
        
        // Filter out null results and add to foundServers
        for (String? result in results) {
          if (result != null) {
            foundServers.add(result);
            print('✅ Found server at: $result');
          }
        }
      } catch (e) {
        print('❌ Error during network scan: $e');
      }
    }
    
    print('🎯 Network scan complete. Found ${foundServers.length} servers');
    return foundServers;
  }
  
  // Helper method for scanning a single IP
  static Future<String?> _scanSingleIP(String ip) async {
    try {
      if (await _testConnection(ip)) {
        return ip;
      }
    } catch (e) {
      // Ignore individual IP scan errors
    }
    return null;
  }
  
  // Method untuk mendapatkan range network lokal
  static Future<String?> _getLocalNetworkRange() async {
    try {
      final interfaces = await NetworkInterface.list();
      
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            String ip = addr.address;
            
            // Extract network range (first 3 octets)
            List<String> parts = ip.split('.');
            if (parts.length == 4) {
              String networkRange = '${parts[0]}.${parts[1]}.${parts[2]}.';
              
              // Only return private network ranges
              if (ip.startsWith('192.168.') || 
                  ip.startsWith('10.') ||
                  (ip.startsWith('172.') && _isPrivate172Range(parts[1]))) {
                return networkRange;
              }
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error getting local network: $e');
    }
    return null;
  }
  
  // Helper method to check if 172.x.x.x is in private range (172.16-172.31)
  static bool _isPrivate172Range(String secondOctet) {
    try {
      int octet = int.parse(secondOctet);
      return octet >= 16 && octet <= 31;
    } catch (e) {
      return false;
    }
  }
  
  // Method untuk scan cepat (hanya IP yang paling mungkin)
  static Future<String?> quickScan() async {
    print('⚡ Starting quick scan...');
    
    // Get local network first
    String? localNetwork = await _getLocalNetworkRange();
    
    Set<String> quickIPs = <String>{};
    
    if (localNetwork != null) {
      // Add common IPs in local network
      quickIPs.addAll([
        '${localNetwork}1',   // Router
        '${localNetwork}14',  // Common server IP
        '${localNetwork}100', // Common server IP
        '${localNetwork}200', // Common server IP
      ]);
    }
    
    // Add other common IPs
    quickIPs.addAll([
      '192.168.1.1', '192.168.1.14', '192.168.1.100',
      '192.168.0.1', '192.168.0.14', '192.168.0.100',
      '10.0.0.1', '10.0.0.14', '10.0.0.100',
    ]);
    
    for (String ip in quickIPs) {
      print('⚡ Quick test: $ip');
      if (await _testConnection(ip)) {
        await setIpAddress(ip);
        print('✅ Quick scan found server: $ip');
        return ip;
      }
    }
    
    print('❌ Quick scan found no servers');
    return null;
  }
  
  // Method untuk validasi IP address
  static bool isValidIP(String ip) {
    if (ip.toLowerCase() == 'localhost') return true;
    
    final RegExp ipRegex = RegExp(
      r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    );
    return ipRegex.hasMatch(ip);
  }
  
  // Method untuk validasi port
  static bool isValidPort(String port) {
    if (port.isEmpty) return true;
    
    final int? portNum = int.tryParse(port);
    return portNum != null && portNum > 0 && portNum <= 65535;
  }
  
  // Method untuk test koneksi ke server saat ini
  static Future<bool> testCurrentConnection() async {
    print('🔍 Testing current server: $_ipAddress${_port.isNotEmpty ? ':$_port' : ''}');
    
    String testIP = _port.isEmpty ? _ipAddress : '$_ipAddress:$_port';
    return await _testConnection(testIP);
  }
  
  // Method untuk mendapatkan info lengkap
  static Map<String, dynamic> getConfigInfo() {
    return {
      'ip_address': _ipAddress,
      'port': _port,
      'base_url': baseUrl,
      'api_url': apiUrl,
      'full_address': _port.isEmpty ? _ipAddress : '$_ipAddress:$_port',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  // Method untuk export config sebagai string
  static String exportConfig() {
    final config = getConfigInfo();
    return 'IP: ${config['ip_address']}\n'
           'Port: ${config['port']}\n'
           'Base URL: ${config['base_url']}\n'
           'API URL: ${config['api_url']}\n'
           'Exported: ${config['timestamp']}';
  }
  
  // Method untuk import config dari string
  static Future<bool> importConfig(String configString) async {
    try {
      final lines = configString.split('\n');
      String? newIp;
      String? newPort;
      
      for (String line in lines) {
        if (line.startsWith('IP: ')) {
          newIp = line.substring(4).trim();
        } else if (line.startsWith('Port: ')) {
          newPort = line.substring(6).trim();
        }
      }
      
      if (newIp != null && isValidIP(newIp)) {
        if (newPort != null && newPort.isNotEmpty && !isValidPort(newPort)) {
          print('❌ Invalid port in config: $newPort');
          return false;
        }
        
        await setIpAddress(newIp, port: newPort ?? '');
        print('✅ Configuration imported successfully');
        return true;
      }
      
      print('❌ Invalid IP in config: $newIp');
      return false;
    } catch (e) {
      print('❌ Error importing config: $e');
      return false;
    }
  }
  
  // Debug info
  static void printCurrentConfig() {
    print('🔧 ═══ CURRENT CONFIGURATION ═══');
    print('📍 IP Address: $_ipAddress');
    print('🔌 Port: ${_port.isEmpty ? 'Default (80)' : _port}');
    print('🌐 Base URL: $baseUrl');
    print('🔗 API URL: $apiUrl');
    print('🕒 Last Updated: ${DateTime.now()}');
    print('═══════════════════════════════════');
  }
  
  // Method untuk clear semua config
  static Future<void> clearConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('server_ip');
      await prefs.remove('server_port');
      
      // Reset to default
      _ipAddress = '192.168.1.14';
      _port = '';
      
      print('🗑️ Configuration cleared and reset to default');
    } catch (e) {
      print('❌ Error clearing config: $e');
    }
  }
  
  // Method untuk mendapatkan status koneksi dengan detail
  static Future<Map<String, dynamic>> getConnectionStatus() async {
    final bool isConnected = await testCurrentConnection();
    
    return {
      'connected': isConnected,
      'ip_address': _ipAddress,
      'port': _port,
      'full_address': _port.isEmpty ? _ipAddress : '$_ipAddress:$_port',
      'base_url': baseUrl,
      'api_url': apiUrl,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}