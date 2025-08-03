<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel - Layanan Pengaduan</title>
    <link rel="stylesheet" href="assets/style.css">
</head>
<body>
    <header class="navbar">
        <div class="container-fluid">
            <a href="dashboard.php" class="navbar-brand">Admin Panel</a>
            <nav>
                <span>Halo, <strong><?= htmlspecialchars($_SESSION['admin_nama']); ?></strong>!</span>
                <a href="logout.php" class="btn btn-sm btn-danger">Logout</a>
            </nav>
        </div>
    </header>