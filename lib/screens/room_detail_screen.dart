import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/room_model.dart';
import '../services/firestore_provider.dart';
import '../widgets/health_score_card.dart';
import '../widgets/report_card.dart';

class RoomDetailScreen extends StatelessWidget {
  const RoomDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final room = ModalRoute.of(context)!.settings.arguments as Room;
    final provider = context.watch<FirestoreProvider>();
    final reports = provider.reportsForRoom(room.id);

    return Scaffold(
      appBar: AppBar(title: Text(room.name)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          HealthScoreCard(
            score: room.healthScore,
            label: room.healthLabel,
            roomName: room.name,
            activeIssues: room.activeIssues,
            resolvedIssues: room.resolvedIssues,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informasi Ruangan',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _infoRow('Gedung', room.building),
                    _infoRow('Lantai', '${room.floor}'),
                    _infoRow('Kategori', room.category),
                    _infoRow('Status', room.status),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context)
                  .pushNamed('/report-issue', arguments: room),
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('Laporkan Masalah'),
            ),
          ),
          if (reports.isNotEmpty) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Riwayat Laporan',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            ...reports.map((r) => ReportCard(
                  report: r,
                  onTap: () => Navigator.of(context)
                      .pushNamed('/report-detail', arguments: r),
                )),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: RumaColors.slate500)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
