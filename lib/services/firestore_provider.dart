import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';
import '../models/report_model.dart';
import '../models/notification_model.dart';
import '../services/mock_data_service.dart';

class FirestoreProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Room> _rooms = [];
  List<Report> _allReports = [];
  List<Report> _userReports = [];
  List<AppNotification> _notifications = [];
  bool _loading = false;
  String? _error;
  bool _useMock = false;

  List<Room> get rooms => _rooms;
  List<Report> get allReports => _allReports;
  List<Report> get userReports => _userReports;
  List<AppNotification> get notifications => _notifications;
  bool get loading => _loading;
  String? get error => _error;

  FirestoreProvider() {
    _initWithMockFallback();
  }

  Future<void> _initWithMockFallback() async {
    await loadRooms();
    if (_useMock) {
      _rooms = MockDataService.mockRooms;
      _allReports = MockDataService.mockReports;
      _notifications = MockDataService.mockNotifications;
      notifyListeners();
    }
  }

  Future<void> loadRooms() async {
    _loading = true;
    notifyListeners();
    try {
      final snap = await _firestore.collection('rooms').get();
      _rooms = snap.docs.map((d) => Room.fromMap(d.data())).toList();
      _useMock = false;
    } catch (e) {
      _useMock = true;
    }
    _loading = false;
    notifyListeners();
  }

  Future<Room?> getRoomById(String id) async {
    if (_useMock) {
      try {
        return MockDataService.mockRooms.firstWhere((r) => r.id == id);
      } catch (_) {
        return null;
      }
    }
    try {
      final doc = await _firestore.collection('rooms').doc(id).get();
      if (!doc.exists) return null;
      return Room.fromMap(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  Future<bool> addReport(Report report) async {
    try {
      await _firestore.collection('reports').doc(report.id).set(report.toMap());
      if (!_useMock) {
        _allReports.insert(0, report);
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadAllReports() async {
    if (_useMock) {
      _allReports = MockDataService.mockReports;
      notifyListeners();
      return;
    }
    try {
      final snap = await _firestore
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .get();
      _allReports = snap.docs.map((d) => Report.fromMap(d.data())).toList();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> loadUserReports(String userId) async {
    if (_useMock) {
      _userReports =
          MockDataService.mockReports.where((r) => r.userId == userId).toList();
      notifyListeners();
      return;
    }
    try {
      final snap = await _firestore
          .collection('reports')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      _userReports = snap.docs.map((d) => Report.fromMap(d.data())).toList();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> loadNotifications(String userId) async {
    if (_useMock) {
      _notifications = MockDataService.mockNotifications;
      notifyListeners();
      return;
    }
    try {
      final snap = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      _notifications =
          snap.docs.map((d) => AppNotification.fromMap(d.data())).toList();
    } catch (_) {}
    notifyListeners();
  }

  Future<bool> updateReportStatus(String reportId, ReportStatus status,
      {String? resolution}) async {
    try {
      final data = <String, dynamic>{'status': status.name};
      if (resolution != null) data['resolution'] = resolution;
      if (status == ReportStatus.resolved) {
        data['resolvedAt'] = DateTime.now().toIso8601String();
      }
      await _firestore.collection('reports').doc(reportId).update(data);
      return true;
    } catch (_) {
      return false;
    }
  }

  List<Report> reportsForRoom(String roomId) {
    return _allReports.where((r) => r.roomId == roomId).toList();
  }

  Room? roomById(String id) {
    try {
      return _rooms.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Room? roomByQrData(String qrData) {
    try {
      return _rooms.firstWhere((r) => r.qrCodeData == qrData);
    } catch (_) {
      try {
        return MockDataService.mockRooms.firstWhere(
          (r) => r.id == qrData || r.qrCodeData == qrData,
        );
      } catch (_) {
        return null;
      }
    }
  }

  void addNotificationLocal(AppNotification notif) {
    _notifications.insert(0, notif);
    notifyListeners();
  }
}
