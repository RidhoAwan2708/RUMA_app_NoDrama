import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';
import '../models/report_model.dart';
import '../models/notification_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection('rooms');

  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection('reports');

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  Future<List<Room>> getRooms() async {
    final snap = await _rooms.get();
    return snap.docs.map((d) => Room.fromMap(d.data())).toList();
  }

  Future<Room?> getRoom(String id) async {
    final doc = await _rooms.doc(id).get();
    if (!doc.exists) return null;
    return Room.fromMap(doc.data()!);
  }

  Future<void> addReport(Report report) async {
    await _reports.doc(report.id).set(report.toMap());
  }

  Future<List<Report>> getUserReports(String userId) async {
    final snap = await _reports
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Report.fromMap(d.data())).toList();
  }

  Future<List<Report>> getAllReports() async {
    final snap =
        await _reports.orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => Report.fromMap(d.data())).toList();
  }

  Future<void> updateReportStatus(
      String reportId, ReportStatus status,
      {String? resolution}) async {
    final data = <String, dynamic>{'status': status.name};
    if (resolution != null) data['resolution'] = resolution;
    if (status == ReportStatus.resolved) {
      data['resolvedAt'] = DateTime.now().toIso8601String();
    }
    await _reports.doc(reportId).update(data);
  }

  Future<void> updateReportAssignee(
      String reportId, String teknisiId, String teknisiName) async {
    await _reports.doc(reportId).update({
      'assignedTo': teknisiId,
      'assignedName': teknisiName,
      'status': ReportStatus.inProgress.name,
    });
  }

  Future<List<AppNotification>> getUserNotifications(String userId) async {
    final snap = await _notifications
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => AppNotification.fromMap(d.data()))
        .toList();
  }

  Future<void> addNotification(AppNotification notification) async {
    await _notifications.doc(notification.id).set(notification.toMap());
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _notifications.doc(notificationId).update({'isRead': true});
  }

  Stream<List<Report>> streamAllReports() {
    return _reports
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Report.fromMap(d.data())).toList());
  }

  Stream<List<Report>> streamUserReports(String userId) {
    return _reports
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Report.fromMap(d.data())).toList());
  }
}
