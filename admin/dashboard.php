<?php
require_once 'koneksi.php';

// Cek apakah admin sudah login
if (!isset($_SESSION['admin_id'])) {
    header("Location: login.php");
    exit;
}

include 'templates/header.php';

// Query untuk mengambil semua pengaduan dengan informasi warga
$query = "SELECT 
    p.id_pengaduan, 
    p.tanggal_lapor, 
    p.judul_pengaduan, 
    w.nama AS nama_pelapor, 
    p.kategori, 
    p.status,
    p.deskripsi,
    p.file_bukti
    FROM pengaduan p
    INNER JOIN warga w ON p.id_warga = w.id_warga
    ORDER BY p.tanggal_lapor DESC";

$result = mysqli_query($koneksi, $query);

if (!$result) {
    die("Query Error: " . mysqli_error($koneksi));
}

// Statistik untuk dashboard
$stats_query = "SELECT 
    COUNT(*) as total,
    SUM(CASE WHEN status = 'menunggu' THEN 1 ELSE 0 END) as menunggu,
    SUM(CASE WHEN status = 'diproses' THEN 1 ELSE 0 END) as diproses,
    SUM(CASE WHEN status = 'selesai' THEN 1 ELSE 0 END) as selesai
    FROM pengaduan";
$stats_result = mysqli_query($koneksi, $stats_query);
$stats = mysqli_fetch_assoc($stats_result);
?>

<main class="container">
    <h2>Dashboard Admin - Layanan Pengaduan</h2>
    <p>Selamat datang, <strong><?= htmlspecialchars($_SESSION['admin_nama']); ?></strong>!</p>
    
    <!-- Statistik Card -->
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-bottom: 2rem;">
        <div class="card" style="text-align: center; background: linear-gradient(135deg, #1976D2, #42A5F5);">
            <h3 style="color: white; margin: 0;"><?= $stats['total'] ?></h3>
            <p style="color: white; margin: 0.5rem 0 0 0;">Total Pengaduan</p>
        </div>
        <div class="card" style="text-align: center; background: linear-gradient(135deg, #FF9800, #FFB74D);">
            <h3 style="color: white; margin: 0;"><?= $stats['menunggu'] ?></h3>
            <p style="color: white; margin: 0.5rem 0 0 0;">Menunggu</p>
        </div>
        <div class="card" style="text-align: center; background: linear-gradient(135deg, #2196F3, #64B5F6);">
            <h3 style="color: white; margin: 0;"><?= $stats['diproses'] ?></h3>
            <p style="color: white; margin: 0.5rem 0 0 0;">Diproses</p>
        </div>
        <div class="card" style="text-align: center; background: linear-gradient(135deg, #4CAF50, #81C784);">
            <h3 style="color: white; margin: 0;"><?= $stats['selesai'] ?></h3>
            <p style="color: white; margin: 0.5rem 0 0 0;">Selesai</p>
        </div>
    </div>

    <h3>Daftar Pengaduan Terbaru</h3>
    
    <div class="table-responsive">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Tanggal</th>
                    <th>Judul Laporan</th>
                    <th>Pelapor</th>
                    <th>Kategori</th>
                    <th>Status</th>
                    <th>Bukti</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                <?php if (mysqli_num_rows($result) > 0): ?>
                    <?php while($row = mysqli_fetch_assoc($result)): ?>
                        <tr>
                            <td><?= $row['id_pengaduan'] ?></td>
                            <td><?= date('d M Y, H:i', strtotime($row['tanggal_lapor'])) ?></td>
                            <td>
                                <strong><?= htmlspecialchars($row['judul_pengaduan']) ?></strong>
                                <br>
                                <small style="color: #666;">
                                    <?= htmlspecialchars(substr($row['deskripsi'], 0, 100)) ?>
                                    <?= strlen($row['deskripsi']) > 100 ? '...' : '' ?>
                                </small>
                            </td>
                            <td><?= htmlspecialchars($row['nama_pelapor']) ?></td>
                            <td>
                                <span style="background: #e3f2fd; color: #1976d2; padding: 0.25rem 0.5rem; border-radius: 0.25rem; font-size: 0.8rem;">
                                    <?= htmlspecialchars(ucfirst($row['kategori'])) ?>
                                </span>
                            </td>
                            <td>
                                <span class="status status-<?= strtolower($row['status']) ?>">
                                    <?= ucfirst($row['status']) ?>
                                </span>
                            </td>
                            <td>
                                <?php if ($row['file_bukti']): ?>
                                    <a href="../uploads/<?= htmlspecialchars($row['file_bukti']) ?>" target="_blank" class="btn btn-sm" style="background: #4caf50;">
                                        📷 Lihat
                                    </a>
                                <?php else: ?>
                                    <span style="color: #999; font-size: 0.8rem;">Tidak ada</span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <a href="detail_pengaduan.php?id=<?= $row['id_pengaduan'] ?>" class="btn btn-sm">
                                    Detail
                                </a>
                            </td>
                        </tr>
                    <?php endwhile; ?>
                <?php else: ?>
                    <tr>
                        <td colspan="8" style="text-align: center; padding: 2rem; color: #666;">
                            <p>📭 Belum ada pengaduan yang masuk.</p>
                            <small>Sistem siap menerima pengaduan dari masyarakat.</small>
                        </td>
                    </tr>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
    
    <!-- Info untuk testing -->
    <div class="card" style="margin-top: 2rem; background: #f8f9fa; border-left: 4px solid #0D47A1;">
        <h4>📱 Testing Aplikasi Mobile</h4>
        <p>Untuk testing aplikasi Flutter:</p>
        <ol>
            <li>Pastikan XAMPP Apache dan MySQL sudah running</li>
            <li>Pastikan IP address di <code>lib/config.dart</code> sudah benar</li>
            <li>Folder <code>uploads</code> harus ada di root proyek</li>
            <li>Database <code>layanan_db</code> sudah dibuat dan terisi</li>
        </ol>
        <p><strong>Login Default Admin:</strong> Username: <code>admin</code>, Password: <code>password</code></p>
    </div>
</main>

<?php include 'templates/footer.php'; ?>