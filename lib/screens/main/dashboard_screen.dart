import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/complaint_service.dart';
import '../../models/complaint_model.dart';
import '../auth/login_screen.dart';
import '../complaint/create_complaint_screen.dart';
import '../complaint/complaint_list_screen.dart';
import '../../utils/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final ComplaintService _complaintService = ComplaintService();

  // Fungsi untuk handle logout
  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // Fungsi untuk memuat ulang semua data di dashboard
  Future<void> _refreshData() async {
    setState(() {
      // Cukup refresh state, FutureBuilder akan otomatis memuat ulang data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 24),
              Text('Statistik Pengaduan Anda', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              Text('Menu Utama', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _buildActionCard(
                'Buat Pengaduan Baru',
                'Laporkan masalah atau berikan masukan Anda di sini.',
                Icons.add_comment_rounded,
                AppTheme.primaryColor,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateComplaintScreen())).then((_) => _refreshData()),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                'Lihat Riwayat Pengaduan',
                'Lacak status dan lihat semua pengaduan yang pernah Anda buat.',
                Icons.history_rounded,
                AppTheme.secondaryColor,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintListScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return FutureBuilder<UserModel?>(
      future: _authService.getCurrentUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(child: ListTile(title: Text('Memuat data pengguna...')));
        }
        final user = snapshot.data!;
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 24, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selamat Datang,', style: TextStyle(color: AppTheme.secondaryTextColor)),
                      Text(user.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard('Menunggu', _complaintService.getComplaintCountByStatus(ComplaintStatus.menunggu), Colors.orange, Icons.pending_actions),
        _buildStatCard('Diproses', _complaintService.getComplaintCountByStatus(ComplaintStatus.diproses), Colors.blue, Icons.sync),
        _buildStatCard('Selesai', _complaintService.getComplaintCountByStatus(ComplaintStatus.selesai), Colors.green, Icons.check_circle),
      ],
    );
  }
  
  Widget _buildStatCard(String title, Future<int> futureCount, Color color, IconData icon) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      child: FutureBuilder<int>(
          future: futureCount,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)));
            }
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Text(
                        (snapshot.data ?? 0).toString(),
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
                    ),
                    const SizedBox(height: 4),
                    Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
                ],
            );
          },
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 40, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}