<?php
require_once 'koneksi.php';
if (!isset($_SESSION['admin_id'])) {
    header("Location: login.php");
    exit;
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $id_pengaduan = (int)$_POST['id_pengaduan'];
    $tanggapan_text = $_POST['tanggapan'];
    $status = $_POST['status'];
    $id_petugas = $_SESSION['admin_id'];

    // 1. Update status di tabel pengaduan
    $stmt_status = $koneksi->prepare("UPDATE pengaduan SET status = ? WHERE id_pengaduan = ?");
    $stmt_status->bind_param("si", $status, $id_pengaduan);
    $stmt_status->execute();
    $stmt_status->close();

    // 2. Cek apakah tanggapan sudah ada
    $stmt_cek = $koneksi->prepare("SELECT id_tanggapan FROM tanggapan WHERE id_pengaduan = ?");
    $stmt_cek->bind_param("i", $id_pengaduan);
    $stmt_cek->execute();
    $result_cek = $stmt_cek->get_result();

    if ($result_cek->num_rows > 0) {
        // Jika ada, UPDATE
        $stmt_tanggapan = $koneksi->prepare("UPDATE tanggapan SET tanggapan = ?, id_petugas = ? WHERE id_pengaduan = ?");
        $stmt_tanggapan->bind_param("sii", $tanggapan_text, $id_petugas, $id_pengaduan);
    } else {
        // Jika tidak ada, INSERT
        $stmt_tanggapan = $koneksi->prepare("INSERT INTO tanggapan (id_pengaduan, tanggapan, id_petugas) VALUES (?, ?, ?)");
        $stmt_tanggapan->bind_param("isi", $id_pengaduan, $tanggapan_text, $id_petugas);
    }
    $stmt_tanggapan->execute();
    
    $stmt_cek->close();
    $stmt_tanggapan->close();
    $koneksi->close();

    // Redirect kembali ke halaman detail dengan notifikasi sukses
    header("Location: detail_pengaduan.php?id=$id_pengaduan&success=1");
    exit;
}
?>