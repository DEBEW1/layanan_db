<?php
require_once 'koneksi.php';

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['status' => 'error', 'message' => 'Method not allowed']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);

$email = $data['email'] ?? '';
$password = $data['password'] ?? '';

if (empty($email) || empty($password)) {
    echo json_encode(['status' => 'error', 'message' => 'Email dan password harus diisi.']);
    exit;
}

$stmt = $koneksi->prepare("SELECT * FROM warga WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($user = $result->fetch_assoc()) {
    if (password_verify($password, $user['password'])) {
        unset($user['password']);
        echo json_encode(['status' => 'success', 'message' => 'Login berhasil', 'data' => $user]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Email atau password salah.']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Email atau password salah.']);
}

$stmt->close();
$koneksi->close();
?>