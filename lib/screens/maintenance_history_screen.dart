import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🛠️ Tambah Firebase Core
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

  // Fungsi helper untuk menerjemahkan status string dari Firebase ke enum/label aplikasi
  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'reported':
      case 'dilaporkan':
        return 'Dilaporkan';
      case 'inprogress':
      case 'diproses':
        return 'Diproses';
      case 'resolved':
      case 'selesai':
        return 'Selesai';
      case 'rejected':
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Dilaporkan';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUid = auth.user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Maintenance')),
      // 🛠️ MENGGUNAKAN STREAMBUILDER REAL-TIME BIAR DIJAMIN MUNCUL OTOMATIS
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .where('userId', isEqualTo: currentUid) // Saringan berdasarkan user login
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Konversi dari dokumen Firebase ke objek list model Report
          final List<Report> allReports = [];
          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              allReports.add(Report.fromMap(data));
            }
          }

          // Filter data berdasarkan tab tombol yang dipilih user
          final reports = _filter == 'semua'
              ? allReports
              : allReports.where((r) => _getStatusLabel(r.status.name) == _filter).toList();

          // Perhitungan Statistik Total Kontainer Atas secara Real-time
          final stats = <String, int>{
            'Total': allReports.length,
            'Selesai': allReports.where((r) => r.status == ReportStatus.resolved).length,
            'Proses': allReports.where((r) => r.status == ReportStatus.inProgress).length,
            'Baru': allReports.where((r) => r.status == ReportStatus.reported).length,
          };

          return Column(
            children: [
              // 1. STATS WIDGET CONTAINER
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
              
              // 2. FILTER HORIZONTAL SCROLL LIST
              Container(
                height: 44,
                color: RumaColors.white,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: _filters.map((f) {
                    final active = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: active ? RumaColors.primaryBlue : RumaColors.slate100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              f == 'semua' ? 'Semua' : f,
                              style: TextStyle(
                                color: active ? RumaColors.white : RumaColors.slate600,
                                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
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
              
              // 3. MAIN CONTENT: REPORT CARD LIST VIEW
              Expanded(
                child: reports.isEmpty
                    ? const EmptyState(
                        icon: Icons.check_circle_outline,
                        title: 'Tidak ada laporan',
                        subtitle: 'Semua laporan sudah selesai',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
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
          );
        },
      ),
    );
  }
}