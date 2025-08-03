<?php
// Pengaturan koneksi database
$host = 'localhost';
$user = 'root';
$pass = ''; // Biarkan kosong jika tidak ada password di XAMPP Anda
$db   = 'layanan_db'; // Pastikan nama database ini benar

// Membuat koneksi menggunakan MySQLi
$koneksi = new mysqli($host, $user, $pass, $db);

// Memeriksa koneksi
if ($koneksi->connect_error) {
    // Hentikan eksekusi dan tampilkan pesan error jika koneksi gagal
    die("Koneksi ke database gagal: " . $koneksi->connect_error);
}

// Mengatur charset ke utf8mb4 untuk mendukung karakter yang beragam
$koneksi->set_charset("utf8mb4");

// Memulai sesi PHP untuk manajemen login
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
?>