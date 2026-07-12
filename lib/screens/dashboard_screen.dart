import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room_model.dart';
import '../services/firestore_provider.dart';
import '../services/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FirestoreProvider>().loadRooms();
      context.read<FirestoreProvider>().loadAllReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FirestoreProvider>();
    final auth = context.watch<AuthProvider>();
    
    final rooms = provider.rooms;
    final reports = provider.allReports;
    final userName = auth.user?.name ?? 'User';

    final avgScore = rooms.isEmpty
        ? 0.0
        : rooms.fold(0.0, (sum, r) => sum + r.healthScore) / rooms.length;
    final totalActive = rooms.fold(0, (sum, r) => sum + r.activeIssues);
    final totalHealthy = rooms.where((r) => r.healthScore >= 80).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.grid_view_rounded, color: Color(0xFF004EC4)),
          onPressed: () {},
        ),
        title: const Text(
          'RUMA',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004EC4)),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/profile'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[200],
                backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200'),
              ),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final p = context.read<FirestoreProvider>();
          await p.loadRooms();
          await p.loadAllReports();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            Text(
              'Hi, $userName!',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 4),
            const Text(
              "Here's your facility overview for today.",
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            _buildOverallStatusCard(avgScore),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildGridCard(Icons.business_rounded, const Color(0xFF004EC4), 'Total Rooms', '${rooms.length}'),
                _buildGridCard(Icons.check_circle_outline_rounded, const Color(0xFF10B981), 'Healthy', '$totalHealthy'),
                _buildGridCard(Icons.warning_amber_rounded, const Color(0xFFEF4444), 'Attention', '$totalActive'),
                _buildGridCard(Icons.description_outlined, const Color(0xFF64748B), 'Reports', '${reports.length}'),
              ],
            ),
            const SizedBox(height: 28),

            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildActionButton(Icons.qr_code_scanner_rounded, 'Scan QR', () {})),
                const SizedBox(width: 12),
                Expanded(child: _buildActionButton(Icons.error_outline_rounded, 'Report Issue', () {})),
                const SizedBox(width: 12),
                Expanded(child: _buildActionButton(Icons.door_sliding_outlined, 'View Rooms', () => Navigator.of(context).pushNamed('/history'))),
              ],
            ),
            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/history'),
                  child: const Text('View All', style: TextStyle(color: Color(0xFF004EC4), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            reports.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Belum ada aktivitas laporan terbaru.', style: TextStyle(color: Color(0xFF94A3B8))),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reports.take(3).length,
                    itemBuilder: (context, index) {
                      final r = reports[index];
                      final isLast = index == reports.take(3).length - 1;
                      
                      Color statusColor = const Color(0xFF004EC4);
                      if (r.status == 'pending') statusColor = const Color(0xFFEF4444);
                      if (r.status == 'resolved') statusColor = const Color(0xFF10B981);

                      final String activityTime = "${r.createdAt.hour.toString().padLeft(2, '0')}:${r.createdAt.minute.toString().padLeft(2, '0')}";

                      // 🛠️ FIX AMAN: Menggunakan properti r.category dan r.roomName yang sudah terbukti ada di Report model milikmu
                      return _buildTimelineTile(
                        time: activityTime,
                        title: 'Laporan ${r.category} Baru',
                        subtitle: 'Ditemukan masalah di area ruangan ${r.roomName}',
                        dotColor: statusColor,
                        isLast: isLast,
                        onTap: () => Navigator.of(context).pushNamed('/report-detail', arguments: r),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatusCard(double score) {
    String performanceLabel = score >= 80 ? 'Optimal performance' : score >= 60 ? 'Fair performance' : 'Critical state';
    Color labelBg = score >= 80 ? const Color(0xFFE8EFFF) : score >= 60 ? const Color(0xFFFEF3C7) : const Color(0xFFFEE2E2);
    Color labelText = score >= 80 ? const Color(0xFF004EC4) : score >= 60 ? const Color(0xFFD97706) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('OVERALL STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.8)),
                const SizedBox(height: 6),
                const Text('Campus Health Score', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: labelBg, borderRadius: BorderRadius.circular(12)),
                      child: Text(performanceLabel, style: TextStyle(color: labelText, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(12)),
                      child: const Text('+2% last week', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFF1F5F9),
                  color: const Color(0xFF004EC4),
                ),
              ),
              Text(
                '${score.toInt()}%',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF004EC4)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGridCard(IconData icon, Color color, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1E293B), size: 24),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTile({
    required String time,
    required String title,
    required String subtitle,
    required Color dotColor,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 55,
                  color: const Color(0xFFE2E8F0),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                const SizedBox(height: 2),
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}