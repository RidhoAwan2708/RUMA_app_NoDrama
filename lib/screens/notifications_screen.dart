import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../services/mock_data_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _filter = 'semua';
  final _filters = ['semua', 'Belum Dibaca'];

  @override
  Widget build(BuildContext context) {
    final allNotifs = MockDataService.mockNotifications;
    final notifs = _filter == 'semua'
        ? allNotifs
        : allNotifs.where((n) => !n.isRead).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: Column(
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
                        Icon(Icons.notifications_off_outlined, size: 64, color: RumaColors.slate300),
                        const SizedBox(height: 16),
                        Text('Tidak ada notifikasi', style: TextStyle(color: RumaColors.slate500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: notifs.length,
                    itemBuilder: (_, i) {
                      final n = notifs[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: n.type == 'report'
                                  ? RumaColors.primaryBlue.withValues(alpha: 0.1)
                                  : RumaColors.warningYellow.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              n.type == 'report' ? Icons.assignment : Icons.info_outline,
                              color: n.type == 'report' ? RumaColors.primaryBlue : RumaColors.warningYellow,
                            ),
                          ),
                          title: Text(
                            n.title,
                            style: TextStyle(
                              fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd MMM yyyy, HH:mm').format(n.createdAt),
                                style: const TextStyle(fontSize: 11, color: RumaColors.slate400),
                              ),
                            ],
                          ),
                          trailing: n.isRead
                              ? null
                              : Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: RumaColors.primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
