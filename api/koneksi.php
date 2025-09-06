<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$host = 'localhost';
$user = 'root';
$pass = ''; // Kosongkan jika password root XAMPP Anda kosong
$db   = 'layanan_db'; // Nama database

$koneksi = mysqli_connect($host, $user, $pass, $db);

if (!$koneksi) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Koneksi ke database gagal: ' . mysqli_connect_error()]);
    die();
}

mysqli_set_charset($koneksi, "utf8");

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
?>