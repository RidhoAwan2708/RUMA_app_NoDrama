import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/report_model.dart';
import '../services/mock_data_service.dart';
import '../widgets/report_card.dart';

class AdminConsoleScreen extends StatefulWidget {
  const AdminConsoleScreen({super.key});

  @override
  State<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends State<AdminConsoleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allReports = MockDataService.mockReports;
    final rooms = MockDataService.mockRooms;

    final totalReports = allReports.length;
    final resolvedCount = allReports.where((r) => r.status == ReportStatus.resolved).length;
    final activeCount = allReports.where((r) => r.status == ReportStatus.reported || r.status == ReportStatus.inProgress).length;
    final avgHealth = rooms.fold(0.0, (s, r) => s + r.healthScore) / rooms.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: RumaColors.primaryBlue,
          labelColor: RumaColors.primaryBlue,
          unselectedLabelColor: RumaColors.slate500,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Laporan'),
            Tab(text: 'Ruangan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _OverviewTab(
            totalReports: totalReports,
            resolvedCount: resolvedCount,
            activeCount: activeCount,
            avgHealth: avgHealth,
            rooms: rooms,
          ),
          _ReportsTab(reports: allReports),
          _RoomsTab(rooms: rooms),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final int totalReports;
  final int resolvedCount;
  final int activeCount;
  final double avgHealth;
  final List<dynamic> rooms;

  const _OverviewTab({
    required this.totalReports,
    required this.resolvedCount,
    required this.activeCount,
    required this.avgHealth,
    required this.rooms,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(
              icon: Icons.assignment,
              label: 'Total Laporan',
              value: '$totalReports',
              color: RumaColors.primaryBlue,
            )),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(
              icon: Icons.check_circle,
              label: 'Selesai',
              value: '$resolvedCount',
              color: RumaColors.secondaryGreen,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard(
              icon: Icons.warning_amber,
              label: 'Aktif',
              value: '$activeCount',
              color: RumaColors.warningYellow,
            )),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(
              icon: Icons.favorite,
              label: 'Health Score',
              value: '${avgHealth.toInt()}',
              color: avgHealth >= 80 ? RumaColors.secondaryGreen : RumaColors.warningYellow,
            )),
          ],
        ),
        const SizedBox(height: 20),
        Text('Distribusi Kategori', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ..._categoryDistribution().entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(width: 100, child: Text(e.key, style: const TextStyle(color: RumaColors.slate600))),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: e.value / totalReports,
                    backgroundColor: RumaColors.slate200,
                    valueColor: AlwaysStoppedAnimation(_catColor(e.key)),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(width: 30, child: Text('${e.value}', textAlign: TextAlign.right)),
            ],
          ),
        )),
      ],
    );
  }

  Color _catColor(String cat) {
    final colors = [RumaColors.primaryBlue, RumaColors.secondaryGreen, RumaColors.warningYellow, RumaColors.dangerRed, RumaColors.primaryLight, Colors.purple, Colors.teal];
    return colors[cat.hashCode % colors.length];
  }

  Map<String, int> _categoryDistribution() {
    final map = <String, int>{};
    for (final r in MockDataService.mockReports) {
      map[r.category] = (map[r.category] ?? 0) + 1;
    }
    return map;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: const TextStyle(color: RumaColors.slate500, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  final List<Report> reports;
  const _ReportsTab({required this.reports});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: reports.length,
      itemBuilder: (_, i) => ReportCard(
        report: reports[i],
        onTap: () => Navigator.of(context).pushNamed('/report-detail', arguments: reports[i]),
      ),
    );
  }
}

class _RoomsTab extends StatelessWidget {
  final List<dynamic> rooms;
  const _RoomsTab({required this.rooms});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rooms.length,
      itemBuilder: (_, i) {
        final room = rooms[i] as dynamic;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: room.healthColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${room.healthScore.toInt()}',
                  style: TextStyle(fontWeight: FontWeight.w700, color: room.healthColor),
                ),
              ),
            ),
            title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${room.building} • Lt ${room.floor}'),
            trailing: Text('Aktif: ${room.activeIssues}', style: const TextStyle(color: RumaColors.warningYellow, fontWeight: FontWeight.w500)),
            onTap: () => Navigator.of(context).pushNamed('/room-detail', arguments: room),
          ),
        );
      },
    );
  }
}
