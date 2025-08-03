<?php
require_once 'koneksi.php';

// Jika admin sudah login, langsung arahkan ke dashboard
if (isset($_SESSION['admin_id'])) {
    header("Location: dashboard.php");
    exit;
}

$error_message = '';

// Hanya proses jika form dikirim menggunakan metode POST
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';

    // Validasi dasar: pastikan input tidak kosong
    if (empty($username) || empty($password)) {
        $error_message = 'Username dan password tidak boleh kosong!';
    } else {
        // Menggunakan prepared statement untuk keamanan maksimal
        $stmt = $koneksi->prepare("SELECT id_petugas, nama_petugas, password, level FROM admin WHERE username = ?");
        $stmt->bind_param("s", $username);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows === 1) {
            $admin = $result->fetch_assoc();
            
            // Verifikasi password yang diinput dengan hash di database
            if (password_verify($password, $admin['password'])) {
                // Jika password cocok, simpan informasi ke session
                session_regenerate_id(); // Mencegah session fixation
                $_SESSION['admin_id'] = $admin['id_petugas'];
                $_SESSION['admin_nama'] = $admin['nama_petugas'];
                $_SESSION['admin_level'] = $admin['level'];
                
                // Arahkan ke dashboard
                header("Location: dashboard.php");
                exit;
            }
        }
        
        // Jika username tidak ditemukan atau password salah
        $error_message = 'Username atau password yang Anda masukkan salah!';
        $stmt->close();
    }
}
$koneksi->close();
?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Login Admin Panel</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="assets/style.css">
</head>
<body class="login-body">
    <div class="login-container">
        <h2>Admin Panel</h2>
        <p>Silakan masuk untuk mengelola data pengaduan.</p>
        
        <?php if (!empty($error_message)): ?>
            <div class="alert alert-danger"><?= htmlspecialchars($error_message) ?></div>
        <?php endif; ?>

        <form action="login.php" method="POST">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required>
            </div>
            <button type="submit" class="btn">Login</button>
        </form>
    </div>
</body>
</html>