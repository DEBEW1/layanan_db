import '../config.dart';
// Untuk mendapatkan displayName dari enum

// Enum untuk kategori pengaduan
enum ComplaintCategory {
  infrastruktur,
  kebersihan,
  keamanan,
  pelayanan,
  lainnya,
}

// Enum untuk status pengaduan
enum ComplaintStatus {
  menunggu,
  diproses,
  selesai,
}

class ComplaintModel {
  final String id;
  final String title;
  final String description;
  final ComplaintCategory category;
  final ComplaintStatus status;
  final String? evidencePath;
  final DateTime createdAt;
  final String? response;
  final String userId;

  ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    this.evidencePath,
    required this.createdAt,
    this.response,
    required this.userId,
  });

  factory ComplaintModel.fromApiJson(Map<String, dynamic> json) {
    // Fungsi helper untuk parsing kategori
    ComplaintCategory parseCategory(String? categoryName) {
      return ComplaintCategory.values.firstWhere(
        (e) => e.name.toLowerCase() == categoryName?.toLowerCase(),
        orElse: () => ComplaintCategory.lainnya,
      );
    }

    // Fungsi helper untuk parsing status
    ComplaintStatus parseStatus(String? statusName) {
      return ComplaintStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == statusName?.toLowerCase(),
        orElse: () => ComplaintStatus.menunggu,
      );
    }

    // Membangun URL bukti jika ada
    String? evidenceUrl;
    if (json['file_bukti'] != null && json['file_bukti'].isNotEmpty) {
      evidenceUrl = '${AppConfig.baseUrl}/uploads/${json['file_bukti']}';
    }

    return ComplaintModel(
      id: json['id_pengaduan']?.toString() ?? '',
      title: json['judul_pengaduan'] ?? 'Tanpa Judul',
      description: json['deskripsi'] ?? '',
      category: parseCategory(json['kategori']),
      status: parseStatus(json['status']),
      evidencePath: evidenceUrl,
      createdAt: DateTime.tryParse(json['tanggal_lapor'] ?? '') ?? DateTime.now(),
      response: json['tanggapan'],
      userId: json['id_warga']?.toString() ?? '',
    );
  }
}