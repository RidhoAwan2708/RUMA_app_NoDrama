import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/theme.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  String _filter = 'semua';
  final _filters = ['semua', 'Belum Dibaca'];

  List<QueryDocumentSnapshot> _fallbackDocs = [];
  bool _fallbackLoading = true;
  String? _fallbackError;

  @override
  void initState() {
    super.initState();
    _fetchFallback();
  }

  Future<void> _fetchFallback() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('notifications')
          .get();
      if (mounted) {
        setState(() {
          _fallbackDocs = snap.docs;
          _fallbackLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _fallbackError = e.toString();
          _fallbackLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FE),
      appBar: AppBar(
        title: const Text('Notifikasi Masuk (Admin)'),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _fallbackLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorView(snapshot.error.toString());
          }

          // Gunakan data stream + fallback untuk redundancy
          final streamDocs = snapshot.data?.docs ?? [];
          final docs = streamDocs.isNotEmpty ? streamDocs : _fallbackDocs;

          if (docs.isEmpty) {
            if (_fallbackError != null) {
              return _buildErrorView(_fallbackError!);
            }
            return _buildEmptyView();
          }

          // Urutkan secara lokal dengan safe parsing
          final allNotifs = List<QueryDocumentSnapshot>.from(docs);
          try {
            allNotifs.sort(_safeCompareByTimestamp);
          } catch (_) {
            // Jika sort gagal, tampilkan apa adanya
          }

          final notifs = _filter == 'semua'
              ? allNotifs
              : allNotifs.where((n) {
                  final data = n.data() as Map<String, dynamic>;
                  return !(data['isRead'] ?? false);
                }).toList();

          if (notifs.isEmpty && _filter != 'semua') {
            return _buildFilteredEmptyView();
          }

          return Column(
            children: [
              _buildFilterBar(),
              Expanded(child: _buildNotificationList(notifs)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: RumaColors.dangerRed),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat notifikasi',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: RumaColors.slate700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 12, color: RumaColors.slate500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _fallbackLoading = true;
                  _fallbackError = null;
                });
                _fetchFallback();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 64, color: RumaColors.slate300),
          const SizedBox(height: 16),
          const Text('Tidak ada notifikasi masuk',
              style: TextStyle(color: RumaColors.slate500)),
        ],
      ),
    );
  }

  Widget _buildFilteredEmptyView() {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.done_all, size: 48, color: RumaColors.slate300),
                const SizedBox(height: 12),
                const Text('Semua notifikasi sudah dibaca',
                    style: TextStyle(color: RumaColors.slate500)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
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
                  color:
                      active ? RumaColors.primaryBlue : RumaColors.slate100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    f,
                    style: TextStyle(
                      color: active ? RumaColors.white : RumaColors.slate600,
                      fontWeight:
                          active ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationList(List<QueryDocumentSnapshot> notifs) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: notifs.length,
      itemBuilder: (_, i) {
        final doc = notifs[i];
        final n = doc.data() as Map<String, dynamic>;
        final bool isRead = n['isRead'] ?? false;
        final String type = n['type'] ?? 'report';

        DateTime createdAt = DateTime.now();
        final ts = n['timestamp'];
        if (ts is Timestamp) {
          createdAt = ts.toDate();
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: RumaColors.slate100),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  style:
                      TextStyle(color: RumaColors.slate600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(createdAt),
                  style: const TextStyle(
                      fontSize: 11, color: RumaColors.slate400),
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
    );
  }

  int _safeCompareByTimestamp(
      QueryDocumentSnapshot a, QueryDocumentSnapshot b) {
    try {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;

      final Timestamp? timeA =
          dataA['timestamp'] is Timestamp ? dataA['timestamp'] as Timestamp? : null;
      final Timestamp? timeB =
          dataB['timestamp'] is Timestamp ? dataB['timestamp'] as Timestamp? : null;

      if (timeA == null && timeB == null) return 0;
      if (timeA == null) return 1;
      if (timeB == null) return -1;
      return timeB.compareTo(timeA);
    } catch (_) {
      return 0;
    }
  }
}
