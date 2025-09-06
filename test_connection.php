<?php
// File untuk testing koneksi database dan API
header('Content-Type: application/json; charset=UTF-8');

// Test koneksi database
$host = 'localhost';
$user = 'root';
$pass = '';
$db = 'layanan_db';

try {
    $koneksi = new mysqli($host, $user, $pass, $db);
    
    if ($koneksi->connect_error) {
        throw new Exception("Koneksi gagal: " . $koneksi->connect_error);
    }
    
    // Test query
    $result = $koneksi->query("SELECT COUNT(*) as total FROM warga");
    $warga_count = $result->fetch_assoc()['total'];
    
    $result = $koneksi->query("SELECT COUNT(*) as total FROM pengaduan");
    $pengaduan_count = $result->fetch_assoc()['total'];
    
    $result = $koneksi->query("SELECT COUNT(*) as total FROM admin");
    $admin_count = $result->fetch_assoc()['total'];
    
    // Cek apakah folder uploads ada
    $uploads_exists = is_dir('./uploads');
    $uploads_writable = is_writable('./uploads');
    
    echo json_encode([
        'status' => 'success',
        'message' => 'Koneksi database berhasil!',
        'data' => [
            'database' => $db,
            'warga_count' => $warga_count,
            'pengaduan_count' => $pengaduan_count,
            'admin_count' => $admin_count,
            'uploads_folder' => [
                'exists' => $uploads_exists,
                'writable' => $uploads_writable
            ],
            'server_time' => date('Y-m-d H:i:s'),
            'php_version' => phpversion()
        ]
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage(),
        'suggestions' => [
            'Pastikan XAMPP sudah running',
            'Pastikan database "layanan_db" sudah dibuat',
            'Jalankan script SQL untuk membuat tabel',
            'Periksa username/password database'
        ]
    ]);
}
?>