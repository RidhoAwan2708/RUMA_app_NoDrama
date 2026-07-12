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

  // 🔥 UPDATE FINAL: Menyimpan Laporan sekaligus Membuat Dokumen Notifikasi Baru di Firebase
  Future<bool> addReport(Report report) async {
    try {
      // 1. Simpan dokumen laporan ke Firestore
      await _firestore.collection('reports').doc(report.id).set(report.toMap());
      
      // 2. Otomatis buat data notifikasi untuk Mahasiswa yang melapor
      final String notifId = _firestore.collection('notifications').doc().id;
      final String namaRuangan = report.roomName ?? 'Ruangan';
      final String kategoriMasalah = report.category ?? 'Masalah';

      await _firestore.collection('notifications').doc(notifId).set({
        'id': notifId,
        'userId': report.userId, 
        'title': 'Laporan Baru: $namaRuangan',
        'message': '$kategoriMasalah berhasil dilaporkan dengan prioritas high.',
        'timestamp': FieldValue.serverTimestamp(), // Menggunakan timestamp server agar dibaca StreamBuilder
        'isRead': false,
        'type': 'report',
      });

      if (!_useMock) {
        if (!_allReports.any((r) => r.id == report.id)) {
          _allReports.insert(0, report);
        }
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Gagal menambah laporan & notifikasi: $e");
      return false;
    }
  }

  // 🔥 FUNGSI TESTING MANDIRI BARU (TANPA LOGIKA LUAR) 🔥
  // Kamu bisa memicu fungsi ini lewat tombol tes apa saja untuk memverifikasi live data di Admin
  Future<void> sendTestNotificationManual() async {
    try {
      // 1. Generate ID dokumen acak untuk notifikasi baru
      final String newNotifId = _firestore.collection('notifications').doc().id;

      // 2. Tulis data mandiri ke koleksi 'notifications'
      await _firestore.collection('notifications').doc(newNotifId).set({
        'id': newNotifId,
        'userId': 'USER_TESTING_123', // ID testing mandiri
        'title': 'Laporan Isu Baru (Tes Mandiri)',
        'message': 'Fasilitas AC di Ruangan Simulator terindikasi mengalami gangguan operasional.',
        'timestamp': FieldValue.serverTimestamp(), // Menggunakan jam server Firebase secara real-time
        'isRead': false,
        'type': 'report_status', 
      });

      debugPrint('Tentara Notif: Data tes berhasil dikirim ke Firebase! ID: $newNotifId');
      notifyListeners();
    } catch (error) {
      debugPrint('Gagal mengirim data tes manual: $error');
    }
  }

  // 🔥 FIXED BUGS: Mengamankan error callback agar tidak mengubah status _useMock ke true saat ditekan kembali
  void listenToAllReportsRealTime() {
    if (_useMock) {
      _allReports = MockDataService.mockReports;
      notifyListeners();
      return;
    }
    
    _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
          _allReports = snap.docs.map((d) => Report.fromMap(d.data())).toList();
          notifyListeners(); 
        }, onError: (e) {
          // Hanya print error ke konsol tanpa merusak state global aplikasi
          debugPrint("Firestore Stream Error: $e");
        });
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

  void listenToNotificationsRealTime(String userId) {
    if (_useMock) {
      _notifications = MockDataService.mockNotifications;
      notifyListeners();
      return;
    }

    _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snap) {
          _notifications = snap.docs.map((d) => AppNotification.fromMap(d.data())).toList();
          notifyListeners();
        }, onError: (_) {});
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