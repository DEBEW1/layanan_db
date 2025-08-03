<?php
require_once 'koneksi.php';

$data = json_decode(file_get_contents('php://input'), true);

$nama = $data['nama'] ?? '';
$email = $data['email'] ?? '';
$telepon = $data['telepon'] ?? '';
$password = $data['password'] ?? '';

if (empty($nama) || empty($email) || empty($telepon) || empty($password)) {
    echo json_encode(['status' => 'error', 'message' => 'Semua kolom harus diisi.']);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(['status' => 'error', 'message' => 'Format email tidak valid.']);
    exit;
}

$stmt = $koneksi->prepare("SELECT id_warga FROM warga WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
if ($stmt->get_result()->num_rows > 0) {
    echo json_encode(['status' => 'error', 'message' => 'Email sudah terdaftar.']);
    exit;
}

$hashed_password = password_hash($password, PASSWORD_BCRYPT);
$stmt = $koneksi->prepare("INSERT INTO warga (nama, email, telepon, password) VALUES (?, ?, ?, ?)");
$stmt->bind_param("ssss", $nama, $email, $telepon, $hashed_password);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'Registrasi berhasil.']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Registrasi gagal.']);
}

$stmt->close();
$koneksi->close();
?>