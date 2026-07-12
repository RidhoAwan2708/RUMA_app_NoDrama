import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/theme.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  String _filter = 'semua';
  final _filters = ['semua', 'Belum Dibaca'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FE),
      appBar: AppBar(
        title: const Text('Notifikasi Masuk (Admin)'),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 🔥 Tanpa filter userId, khusus admin agar bisa membaca semua notifikasi yang masuk
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final rawDocs = snapshot.data?.docs ?? [];
          
          // Urutkan secara lokal berdasarkan waktu terbaru (descending)
          final allNotifs = List<QueryDocumentSnapshot>.from(rawDocs);
          allNotifs.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            final timeA = dataA['timestamp'] as Timestamp?;
            final timeB = dataB['timestamp'] as Timestamp?;
            if (timeA == null) return 1;
            if (timeB == null) return -1;
            return timeB.compareTo(timeA);
          });
          
          // Filter data berdasarkan tab aktif
          final notifs = _filter == 'semua'
              ? allNotifs
              : allNotifs.where((n) {
                  final data = n.data() as Map<String, dynamic>;
                  return !(data['isRead'] ?? false);
                }).toList();

          return Column(
            children: [
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
                              f,
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
              Expanded(
                child: notifs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_off_outlined,
                                size: 64, color: RumaColors.slate300),
                            const SizedBox(height: 16),
                            Text('Tidak ada notifikasi masuk',
                                style: TextStyle(color: RumaColors.slate500)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        itemCount: notifs.length,
                        itemBuilder: (_, i) {
                          final doc = notifs[i];
                          final n = doc.data() as Map<String, dynamic>;
                          final bool isRead = n['isRead'] ?? false;
                          final String type = n['type'] ?? 'report';

                          // Parsing tanggal Firebase Timestamp secara aman
                          DateTime createdAt = DateTime.now();
                          if (n['timestamp'] != null && n['timestamp'] is Timestamp) {
                            createdAt = (n['timestamp'] as Timestamp).toDate();
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: RumaColors.slate100),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: (type == 'report' || type == 'report_status')
                                      ? RumaColors.primaryBlue.withOpacity(0.1)
                                      : RumaColors.warningYellow.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  (type == 'report' || type == 'report_status') 
                                      ? Icons.assignment_outlined 
                                      : Icons.info_outline,
                                  color: (type == 'report' || type == 'report_status') 
                                      ? RumaColors.primaryBlue 
                                      : RumaColors.warningYellow,
                                ),
                              ),
                              title: Text(
                                n['title'] ?? 'Pemberitahuan Masuk',
                                style: TextStyle(
                                  fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                                  color: RumaColors.slate800,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    n['message'] ?? (n['body'] ?? ''),
                                    maxLines: 2, 
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: RumaColors.slate600, fontSize: 13),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    DateFormat('dd MMM yyyy, HH:mm').format(createdAt),
                                    style: const TextStyle(fontSize: 11, color: RumaColors.slate400),
                                  ),
                                ],
                              ),
                              trailing: isRead
                                  ? null
                                  : Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: RumaColors.primaryBlue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                              onTap: () {
                                doc.reference.update({'isRead': true});
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}