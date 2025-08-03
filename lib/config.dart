class AppConfig {
  // =======================================================================
  // PENTING: Ganti dengan alamat IP komputer Anda.
  // Cara cek IP di Windows: Buka CMD, ketik `ipconfig`, cari "IPv4 Address".
  // Cara cek IP di macOS/Linux: Buka Terminal, ketik `ifconfig` atau `ip a`.
  // =======================================================================
  static const String _ipAddress = '192.168.1.14'; // <-- GANTI ALAMAT IP INI

  // Jangan ubah bagian di bawah ini
  static const String baseUrl = 'http://$_ipAddress/layanan';
  static const String apiUrl = '$baseUrl/api';
}