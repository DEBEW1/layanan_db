import 'package:flutter/material.dart';
import '../../models/complaint_model.dart';
import '../../services/complaint_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/extensions.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final String complaintId;
  const ComplaintDetailScreen({super.key, required this.complaintId});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  final ComplaintService _complaintService = ComplaintService();
  late Future<ComplaintModel?> _complaintFuture;

  @override
  void initState() {
    super.initState();
    _loadComplaint();
  }

  void _loadComplaint() {
    setState(() {
      _complaintFuture = _complaintService.getComplaintById(widget.complaintId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengaduan')),
      body: FutureBuilder<ComplaintModel?>(
        future: _complaintFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Gagal memuat detail pengaduan.'));
          }
          final complaint = snapshot.data!;
          return _buildContent(complaint);
        },
      ),
    );
  }

  Widget _buildContent(ComplaintModel complaint) {
    return RefreshIndicator(
      onRefresh: () async => _loadComplaint(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(complaint.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              label: Text(complaint.status.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: complaint.status.color,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(complaint),
          const SizedBox(height: 16),
          _buildSection('Deskripsi Pengaduan', complaint.description),
          if (complaint.response != null && complaint.response!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection('Tanggapan Petugas', complaint.response!),
          ],
          if (complaint.evidencePath != null) ...[
            const SizedBox(height: 16),
            _buildEvidenceImage(complaint.evidencePath!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(ComplaintModel complaint) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(Icons.category, 'Kategori', complaint.category.displayName),
            const Divider(),
            _buildInfoRow(Icons.calendar_today, 'Tanggal Lapor', complaint.createdAt.formatDate()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.secondaryTextColor),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(color: AppTheme.secondaryTextColor)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(content),
      ],
    );
  }
  
  Widget _buildEvidenceImage(String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bukti Foto', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            loadingBuilder: (_, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
            errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 48)),
          ),
        ),
      ],
    );
  }
}