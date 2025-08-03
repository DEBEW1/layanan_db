import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import '../models/complaint_model.dart';
import '../config.dart';
import 'auth_service.dart';

class ComplaintService {
  final AuthService _authService = AuthService();

  // Mengirim pengaduan baru ke server
  Future<bool> submitComplaint({
    required String title,
    required String description,
    required ComplaintCategory category,
    String? evidencePath,
  }) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return false;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.apiUrl}/create_complaint.php'),
      );

      request.fields['id_warga'] = user.id;
      request.fields['judul_pengaduan'] = title;
      request.fields['deskripsi'] = description;
      request.fields['kategori'] = category.name;

      if (evidencePath != null) {
        final file = await http.MultipartFile.fromPath(
          'file_bukti',
          evidencePath,
          filename: basename(evidencePath),
        );
        request.files.add(file);
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final result = json.decode(responseBody);
        return result['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Error submitting complaint: $e');
      return false;
    }
  }

  // Mengambil daftar pengaduan berdasarkan user yang login
  Future<List<ComplaintModel>> getComplaintsByUser() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return [];

      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/get_complaints.php?user_id=${user.id}'),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success' && result['data'] is List) {
          final List<dynamic> data = result['data'];
          return data.map((json) => ComplaintModel.fromApiJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting complaints: $e');
      throw Exception('Gagal memuat data. Periksa koneksi internet Anda.');
    }
  }

  // Mengambil detail satu pengaduan berdasarkan ID
  Future<ComplaintModel?> getComplaintById(String complaintId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/get_complaint_detail.php?id=$complaintId'),
      );
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          return ComplaintModel.fromApiJson(result['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting complaint by ID: $e');
      return null;
    }
  }
  
    Future<int> getComplaintCountByStatus(ComplaintStatus status) async {
    try {
      final allComplaints = await getComplaintsByUser();
      return allComplaints.where((c) => c.status == status).length;
    } catch (e) {
      return 0;
    }
  }
}