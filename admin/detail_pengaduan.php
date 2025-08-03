<?php
require_once 'koneksi.php';
if (!isset($_SESSION['admin_id'])) {
    header("Location: login.php");
    exit;
}

$id_pengaduan = (int)($_GET['id'] ?? 0);
if ($id_pengaduan === 0) {
    header("Location: dashboard.php");
    exit;
}

include 'templates/header.php';

// Query aman untuk mengambil detail pengaduan dan data pelapor
$stmt = $koneksi->prepare(
    "SELECT p.*, w.nama, w.email, w.telepon FROM pengaduan p 
     JOIN warga w ON p.id_warga = w.id_warga 
     WHERE p.id_pengaduan = ?"
);
$stmt->bind_param("i", $id_pengaduan);
$stmt->execute();
$pengaduan = $stmt->get_result()->fetch_assoc();

// Query aman untuk mengambil tanggapan yang sudah ada
$stmt_tanggapan = $koneksi->prepare(
    "SELECT t.tanggapan FROM tanggapan t WHERE t.id_pengaduan = ?"
);
$stmt_tanggapan->bind_param("i", $id_pengaduan);
$stmt_tanggapan->execute();
$tanggapan = $stmt_tanggapan->get_result()->fetch_assoc();
?>

<main class="container">
    <a href="dashboard.php" class="btn btn-secondary mb-3">&larr; Kembali</a>
    
    <?php if ($pengaduan): ?>
        <h2>Detail Pengaduan #<?= $pengaduan['id_pengaduan'] ?></h2>
        
        <?php if(isset($_GET['success'])): ?>
            <div class="alert alert-success">Status dan tanggapan berhasil diperbarui!</div>
        <?php endif; ?>

        <div class="detail-grid">
            <div class="card">
                <h3>Informasi Laporan</h3>
                <p><strong>Judul:</strong> <?= htmlspecialchars($pengaduan['judul_pengaduan']) ?></p>
                <p><strong>Status:</strong> <span class="status status-<?= strtolower($pengaduan['status']) ?>"><?= ucfirst($pengaduan['status']) ?></span></p>
                <p><strong>Tanggal Lapor:</strong> <?= date('d M Y, H:i', strtotime($pengaduan['tanggal_lapor'])) ?></p>
                <hr>
                <h4>Deskripsi:</h4>
                <p><?= nl2br(htmlspecialchars($pengaduan['deskripsi'])) ?></p>
                <?php if ($pengaduan['file_bukti']): ?>
                    <h4>Bukti Foto:</h4>
                    <a href="../uploads/<?= htmlspecialchars($pengaduan['file_bukti']) ?>" target="_blank">
                        <img src="../uploads/<?= htmlspecialchars($pengaduan['file_bukti']) ?>" alt="Bukti Foto" class="evidence-img">
                    </a>
                <?php endif; ?>
            </div>

            <div class="card">
                <h3>Informasi Pelapor</h3>
                <p><strong>Nama:</strong> <?= htmlspecialchars($pengaduan['nama']) ?></p>
                <p><strong>Email:</strong> <?= htmlspecialchars($pengaduan['email']) ?></p>
                <p><strong>Telepon:</strong> <?= htmlspecialchars($pengaduan['telepon']) ?></p>
                <hr>
                <h3>Tanggapan & Aksi</h3>
                <form action="proses_update.php" method="POST">
                    <input type="hidden" name="id_pengaduan" value="<?= $pengaduan['id_pengaduan'] ?>">
                    <div class="form-group">
                        <label for="tanggapan">Tanggapan Anda</label>
                        <textarea name="tanggapan" id="tanggapan" rows="6" required><?= htmlspecialchars($tanggapan['tanggapan'] ?? '') ?></textarea>
                    </div>
                    <div class="form-group">
                        <label for="status">Ubah Status Laporan</label>
                        <select name="status" id="status">
                            <option value="menunggu" <?= $pengaduan['status'] == 'menunggu' ? 'selected' : '' ?>>Menunggu</option>
                            <option value="diproses" <?= $pengaduan['status'] == 'diproses' ? 'selected' : '' ?>>Diproses</option>
                            <option value="selesai" <?= $pengaduan['status'] == 'selesai' ? 'selected' : '' ?>>Selesai</option>
                        </select>
                    </div>
                    <button type="submit" class="btn">Simpan Perubahan</button>
                </form>
            </div>
        </div>
    <?php else: ?>
        <p class="alert alert-danger">Data pengaduan tidak ditemukan.</p>
    <?php endif; ?>
</main>

<?php include 'templates/footer.php'; ?>