import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../services/mock_data_service.dart';
import '../widgets/health_score_card.dart';
import '../widgets/report_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rooms = MockDataService.mockRooms;
    final reports = MockDataService.mockReports;

    final avgScore = rooms.isEmpty
        ? 0.0
        : rooms.fold(0.0, (sum, r) => sum + r.healthScore) / rooms.length;
    final totalActive = rooms.fold(0, (sum, r) => sum + r.activeIssues);
    final totalResolved = rooms.fold(0, (sum, r) => sum + r.resolvedIssues);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RUMA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            HealthScoreCard(
              score: avgScore,
              label: avgScore >= 80 ? 'Baik' : avgScore >= 60 ? 'Cukup' : 'Kritis',
              roomName: 'Kampus',
              activeIssues: totalActive,
              resolvedIssues: totalResolved,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Laporan Terbaru', style: Theme.of(context).textTheme.titleMedium),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/history'),
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
            ),
            ...reports.take(3).map((r) => ReportCard(
              report: r,
              onTap: () => Navigator.of(context).pushNamed('/report-detail', arguments: r),
            )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text('Ruangan', style: Theme.of(context).textTheme.titleMedium),
            ),
            ...rooms.map((room) => _RoomListTile(room: room)),
          ],
        ),
      ),
    );
  }
}

class _RoomListTile extends StatelessWidget {
  final Room room;
  const _RoomListTile({required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: room.healthColor,
              ),
            ),
          ),
        ),
        title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${room.building} • Lt ${room.floor} • ${room.category}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).pushNamed('/room-detail', arguments: room),
      ),
    );
  }
}
