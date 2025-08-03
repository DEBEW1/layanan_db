import 'package:flutter/material.dart';
import '../../models/complaint_model.dart';
import '../../services/complaint_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/complaint_card.dart';
import 'complaint_detail_screen.dart';

class ComplaintListScreen extends StatefulWidget {
  const ComplaintListScreen({super.key});

  @override
  State<ComplaintListScreen> createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen> {
  final ComplaintService _complaintService = ComplaintService();
  late Future<List<ComplaintModel>> _complaintsFuture;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() {
      _complaintsFuture = _complaintService.getComplaintsByUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pengaduan Saya')),
      body: RefreshIndicator(
        onRefresh: _loadComplaints,
        child: FutureBuilder<List<ComplaintModel>>(
          future: _complaintsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _buildErrorView(snapshot.error);
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyView();
            }
            return _buildListView(snapshot.data!);
          },
        ),
      ),
    );
  }

  Widget _buildListView(List<ComplaintModel> complaints) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        return InkWell(
          onTap: () async {
            // Navigasi ke detail dan tunggu hasilnya (apakah perlu refresh)
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => ComplaintDetailScreen(complaintId: complaint.id),
              ),
            );
            // Jika `true` dikembalikan, refresh daftar
            if (result == true) {
              _loadComplaints();
            }
          },
          child: ComplaintCard(complaint: complaint),
        );
      },
    );
  }
  
  Widget _buildEmptyView() {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('Belum Ada Pengaduan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Tarik ke bawah untuk memuat ulang.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    });
  }
  
  Widget _buildErrorView(Object? error) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    const Icon(Icons.error_outline, size: 80, color: AppTheme.errorColor),
                    const SizedBox(height: 16),
                    const Text('Gagal Memuat Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Terjadi kesalahan: ${error.toString()}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                ],
            ),
        ),
    );
  }
}