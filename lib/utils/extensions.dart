import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/complaint_model.dart';

// Extension untuk memberikan nama, ikon, dan properti lain pada enum Kategori
extension ComplaintCategoryExtension on ComplaintCategory {
  String get displayName {
    switch (this) {
      case ComplaintCategory.infrastruktur:
        return 'Infrastruktur';
      case ComplaintCategory.kebersihan:
        return 'Kebersihan';
      case ComplaintCategory.keamanan:
        return 'Keamanan';
      case ComplaintCategory.pelayanan:
        return 'Pelayanan Publik';
      case ComplaintCategory.lainnya:
        return 'Lainnya';
    }
  }
}

// Extension untuk memberikan nama dan warna pada enum Status
extension ComplaintStatusExtension on ComplaintStatus {
  String get displayName {
    switch (this) {
      case ComplaintStatus.menunggu:
        return 'Menunggu';
      case ComplaintStatus.diproses:
        return 'Diproses';
      case ComplaintStatus.selesai:
        return 'Selesai';
    }
  }

  Color get color {
    switch (this) {
      case ComplaintStatus.menunggu:
        return Colors.orange;
      case ComplaintStatus.diproses:
        return Colors.blue;
      case ComplaintStatus.selesai:
        return Colors.green;
    }
  }
}

// Extension untuk memformat tanggal
extension DateFormatting on DateTime {
  String formatDate() {
    // Menggunakan package intl untuk format tanggal yang bagus
    return DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(this);
  }
}