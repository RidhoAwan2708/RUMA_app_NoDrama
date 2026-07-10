import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/report_model.dart';
import '../widgets/status_badge.dart';

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final report = ModalRoute.of(context)!.settings.arguments as Report;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Laporan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Status', style: Theme.of(context).textTheme.labelLarge),
                      StatusBadge(label: report.statusLabel, color: report.statusColor),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _infoRow('Ruangan', report.roomName),
                  _infoRow('Kategori', report.category),
                  _infoRow('Prioritas', report.priority == 'high' ? 'Tinggi' : report.priority == 'medium' ? 'Sedang' : 'Rendah'),
                  _infoRow('Dilaporkan oleh', report.userName),
                  _infoRow('Tanggal', DateFormat('dd MMM yyyy, HH:mm').format(report.createdAt)),
                  if (report.assignedName != null) _infoRow('Teknisi', report.assignedName!),
                  if (report.resolvedAt != null)
                    _infoRow('Selesai', DateFormat('dd MMM yyyy, HH:mm').format(report.resolvedAt!)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Deskripsi', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(report.description, style: const TextStyle(color: RumaColors.slate700, height: 1.5)),
                ],
              ),
            ),
          ),
          if (report.resolution != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: RumaColors.secondaryGreen, size: 20),
                        const SizedBox(width: 8),
                        Text('Resolusi', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(report.resolution!, style: const TextStyle(color: RumaColors.slate700, height: 1.5)),
                  ],
                ),
              ),
            ),
          ],
          if (report.status == ReportStatus.reported || report.status == ReportStatus.inProgress) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Laporan dibatalkan'),
                      backgroundColor: RumaColors.dangerRed,
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Batalkan Laporan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: RumaColors.dangerRed,
                  side: const BorderSide(color: RumaColors.dangerRed),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: RumaColors.slate500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
