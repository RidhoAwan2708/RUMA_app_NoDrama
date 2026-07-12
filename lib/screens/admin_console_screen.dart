import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/report_model.dart';
import '../services/firestore_provider.dart';
import 'admin_notifications_screen.dart'; // 🔥 IMPORT FILE BARU KHUSUS NOTIFIKASI ADMIN

class AdminConsoleScreen extends StatefulWidget {
  const AdminConsoleScreen({super.key});

  @override
  State<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends State<AdminConsoleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FirestoreProvider>().listenToAllReportsRealTime();
      context.read<FirestoreProvider>().loadRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FirestoreProvider>();
    var allReports = provider.allReports;

    if (allReports.isEmpty) {
      allReports = [
        Report(id: '1', userId: 'dummy_user_1', userName: 'Sarah J.', roomId: 'room_1', category: 'Broken light fixture', roomName: 'Main Plaza', status: ReportStatus.reported, description: 'Sarah J. • 2m ago'),
        Report(id: '2', userId: 'dummy_user_2', userName: 'Mike R.', roomId: 'room_2', category: 'HVAC leak observed', roomName: 'West Wing', status: ReportStatus.inProgress, description: 'Mike R. • 15m ago'),
        Report(id: '3', userId: 'dummy_user_3', userName: 'Auto-Bot', roomId: 'room_3', category: 'Elevator noise', roomName: 'Main Plaza', status: ReportStatus.resolved, description: 'Auto-Bot • 45m ago'),
        Report(id: '4', userId: 'dummy_user_4', userName: 'Janitorial', roomId: 'room_4', category: 'Spill in Lobby', roomName: 'Innovation Hub', status: ReportStatus.resolved, description: 'Janitorial • 1h ago'),
        Report(id: '5', userId: 'dummy_user_5', userName: 'Admin', roomId: 'room_5', category: 'Door handle loose', roomName: 'The Dock', status: ReportStatus.resolved, description: 'Admin • 2h ago'),
      ];
    }

    // Kalkulasi Statistik Real-Time
    int totalReports = allReports.length;
    int resolvedCount = allReports.where((r) => r.status == ReportStatus.resolved).length;
    int pendingCount = allReports.where((r) => r.status == ReportStatus.reported || r.status == ReportStatus.inProgress).length;

    // Distribusi Gedung
    final Map<String, int> buildingMap = {};
    for (var report in allReports) {
      buildingMap[report.roomName] = (buildingMap[report.roomName] ?? 0) + 1;
    }

    // Distribusi Kategori
    final Map<String, int> categoryCountMap = {};
    for (var report in allReports) {
      String cat = report.category;
      if (cat.contains('light') || cat.contains('HVAC') || cat.contains('Elevator') || cat.contains('handle')) {
        cat = 'Maintenance';
      } else if (cat.contains('Spill') || cat.contains('Bersih')) {
        cat = 'Cleaning';
      } else {
        cat = 'Security';
      }
      categoryCountMap[cat] = (categoryCountMap[cat] ?? 0) + 1;
    }

    final Map<String, int> categoryPercentageMap = {};
    if (totalReports > 0) {
      categoryCountMap.forEach((key, value) {
        categoryPercentageMap[key] = ((value / totalReports) * 100).round();
      });
    }

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
          'Admin Console',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004EC4), fontSize: 20),
        ),
        centerTitle: false,
        actions: [
          // 🔥 NAVIGASI KE HALAMAN NOTIFIKASI ADMIN BARU
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF64748B)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminNotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[200],
              backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200'),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<FirestoreProvider>().listenToAllReportsRealTime();
        },
        child: allReports.isEmpty
            ? _buildEmptyState()
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildWideStatCard('TOTAL REPORTS', '$totalReports', const Color(0xFF004EC4), Icons.bar_chart_rounded),
                  const SizedBox(height: 12),
                  _buildWideStatCard('RESOLVED', '$resolvedCount', const Color(0xFF10B981), Icons.check_circle_outline_rounded),
                  const SizedBox(height: 12),
                  _buildWideStatCard('PENDING', '$pendingCount', const Color(0xFFDC2626), Icons.assignment_late_outlined, hasLeftBorder: true),
                  const SizedBox(height: 24),

                  if (buildingMap.isNotEmpty) ...[
                    _buildBuildingDistributionCard(buildingMap),
                    const SizedBox(height: 24),
                  ],

                  if (categoryPercentageMap.isNotEmpty) ...[
                    _buildCategoryDonutCard(categoryPercentageMap),
                    const SizedBox(height: 24),
                  ],

                  _buildRecentActivityTable(allReports),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        const Center(
          child: Column(
            children: [
              Icon(Icons.assignment_turned_in_outlined, size: 72, color: Color(0xFF94A3B8)),
              SizedBox(height: 16),
              Text(
                'Belum Ada Laporan Masuk',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              ),
              SizedBox(height: 8),
              Text(
                'Laporan isu dari mahasiswa akan muncul di sini.',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWideStatCard(String title, String value, Color color, IconData icon, {bool hasLeftBorder = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: hasLeftBorder ? const Border(left: BorderSide(color: Color(0xFFDC2626), width: 4)) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
        ),
      ),
    );
  }

  Widget _buildBuildingDistributionCard(Map<String, int> buildingMap) {
    int maxVal = buildingMap.values.isEmpty ? 1 : buildingMap.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reports by Building', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          Column(
            children: buildingMap.entries.map((e) {
              double progress = e.value / maxVal;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1E293B), fontSize: 12)),
                        Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF004EC4)),
                        minHeight: 6,
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryDonutCard(Map<String, int> categoryMap) {
    List<Color> palette = [const Color(0xFF004EC4), const Color(0xFF475569), const Color(0xFF94A3B8)];
    int index = 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reports by Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: 0.75,
                      strokeWidth: 12,
                      backgroundColor: const Color(0xFFF1F5F9),
                      color: const Color(0xFF004EC4),
                    ),
                  ),
                  const Text('CAT', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 12))
                ],
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: dataEntries(categoryMap, palette),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  List<Widget> dataEntries(Map<String, int> categoryMap, List<Color> palette) {
    int index = 0;
    return categoryMap.entries.map((e) {
      Color currentColor = palette[index % palette.length];
      index++;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: currentColor, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${e.key} (${e.value}%)',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildRecentActivityTable(List<Report> reports) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              TextButton(
                onPressed: () {}, 
                child: const Text('View All', style: TextStyle(color: Color(0xFF004EC4), fontWeight: FontWeight.bold, fontSize: 13))
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(flex: 4, child: Text('SUBJECT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))),
              Expanded(flex: 3, child: Text('BUILDING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))),
              Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))))),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reports.length,
            separatorBuilder: (_, __) => const Divider(height: 20, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, i) {
              final r = reports[i];

              String statusLabel = 'Pending';
              Color bgStatus = const Color(0xFFFEE2E2);
              Color textStatus = const Color(0xFFDC2626);

              if (r.status == ReportStatus.resolved) {
                statusLabel = 'Resolved';
                bgStatus = const Color(0xFFD1FAE5);
                textStatus = const Color(0xFF10B981);
              } else if (r.status == ReportStatus.inProgress) {
                statusLabel = 'In Review';
                bgStatus = const Color(0xFFE8EFFF);
                textStatus = const Color(0xFF004EC4);
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.category, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 13, height: 1.2)),
                        const SizedBox(height: 2),
                        Text(r.description ?? 'Oleh Mahasiswa', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(r.roomName, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF475569), fontSize: 12)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: bgStatus, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          statusLabel, 
                          style: TextStyle(color: textStatus, fontSize: 11, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}