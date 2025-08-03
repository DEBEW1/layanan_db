<?php
require_once 'koneksi.php';
// Cek apakah admin sudah login, jika belum, tendang ke halaman login
if (!isset($_SESSION['admin_id'])) {
    header("Location: login.php");
    exit;
}

// Sertakan header halaman
include 'templates/header.php';

// Ambil semua data pengaduan dan gabungkan (JOIN) dengan data warga untuk mendapatkan nama pelapor
$query = "SELECT p.id_pengaduan, p.tanggal_lapor, p.judul_pengaduan, w.nama AS nama_pelapor, p.kategori, p.status
          FROM pengaduan p
          JOIN warga w ON p.id_warga = w.id_warga
          ORDER BY p.tanggal_lapor DESC";
$result = mysqli_query($koneksi, $query);
?>

<main class="container">
    <h2>Daftar Pengaduan Masuk</h2>
    <p>Berikut adalah daftar semua pengaduan yang telah dikirim oleh pengguna.</p>
    
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
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                <?php if (mysqli_num_rows($result) > 0): ?>
                    <?php while($row = mysqli_fetch_assoc($result)): ?>
                        <tr>
                            <td><?= $row['id_pengaduan'] ?></td>
                            <td><?= date('d M Y, H:i', strtotime($row['tanggal_lapor'])) ?></td>
                            <td><?= htmlspecialchars($row['judul_pengaduan']) ?></td>
                            <td><?= htmlspecialchars($row['nama_pelapor']) ?></td>
                            <td><?= htmlspecialchars(ucfirst($row['kategori'])) ?></td>
                            <td><span class="status status-<?= strtolower($row['status']) ?>"><?= ucfirst($row['status']) ?></span></td>
                            <td>
                                <a href="detail_pengaduan.php?id=<?= $row['id_pengaduan'] ?>" class="btn btn-sm">Detail</a>
                            </td>
                        </tr>
                    <?php endwhile; ?>
                <?php else: ?>
                    <tr>
                        <td colspan="7" style="text-align: center;">Belum ada pengaduan yang masuk.</td>
                    </tr>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</main>

<?php include 'templates/footer.php'; ?>