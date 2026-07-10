import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/report_model.dart';
import '../services/firestore_provider.dart';
import '../services/auth_provider.dart';
import '../widgets/report_card.dart';
import '../widgets/empty_state.dart';

class MaintenanceHistoryScreen extends StatefulWidget {
  const MaintenanceHistoryScreen({super.key});

  @override
  State<MaintenanceHistoryScreen> createState() =>
      _MaintenanceHistoryScreenState();
}

class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen> {
  String _filter = 'semua';
  final _filters = ['semua', 'Dilaporkan', 'Diproses', 'Selesai', 'Ditolak'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<FirestoreProvider>().loadUserReports(auth.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FirestoreProvider>();
    final allReports = provider.userReports;

    final reports = _filter == 'semua'
        ? allReports
        : allReports.where((r) => r.statusLabel == _filter).toList();

    final stats = <String, int>{
      'Total': allReports.length,
      'Selesai': allReports
          .where((r) => r.status == ReportStatus.resolved)
          .length,
      'Proses': allReports
          .where((r) => r.status == ReportStatus.inProgress)
          .length,
      'Baru':
          allReports.where((r) => r.status == ReportStatus.reported).length,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Maintenance')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: RumaColors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: stats.entries.map((e) {
                Color c;
                switch (e.key) {
                  case 'Selesai':
                    c = RumaColors.secondaryGreen;
                    break;
                  case 'Proses':
                    c = RumaColors.primaryLight;
                    break;
                  case 'Baru':
                    c = RumaColors.warningYellow;
                    break;
                  default:
                    c = RumaColors.slate900;
                }
                return Column(
                  children: [
                    Text(e.value.toString(),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: c)),
                    Text(e.key,
                        style: const TextStyle(
                            fontSize: 11, color: RumaColors.slate500)),
                  ],
                );
              }).toList(),
            ),
          ),
          Container(
            height: 44,
            color: RumaColors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _filters.map((f) {
                final active = _filter == f;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: active
                            ? RumaColors.primaryBlue
                            : RumaColors.slate100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          f == 'semua' ? 'Semua' : f,
                          style: TextStyle(
                            color: active
                                ? RumaColors.white
                                : RumaColors.slate600,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: reports.isEmpty
                ? const EmptyState(
                    icon: Icons.check_circle_outline,
                    title: 'Tidak ada laporan',
                    subtitle: 'Semua laporan sudah selesai',
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: reports.length,
                    itemBuilder: (_, i) => ReportCard(
                      report: reports[i],
                      onTap: () => Navigator.of(context).pushNamed(
                          '/report-detail',
                          arguments: reports[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
