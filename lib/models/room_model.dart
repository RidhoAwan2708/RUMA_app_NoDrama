import 'package:flutter/material.dart';

class Room {
  final String id;
  final String name;
  final String building;
  final int floor;
  final String category;
  final double healthScore;
  final int activeIssues;
  final int resolvedIssues;
  final String status; // Tidak wajib (required) lagi di constructor
  final String qrCodeData;

  Room({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.category,
    required this.healthScore,
    required this.activeIssues,
    required this.resolvedIssues,
    this.status = 'aktif', // <--- JIKA KOSONG DI MOCK DATA, OTOMATIS DIISI 'aktif'
    required this.qrCodeData,
  });

  // Fungsi konversi dari Firebase Firestore ke Objek Dart secara aman
  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Tanpa Nama',
      building: map['building']?.toString() ?? '-',
      floor: (map['floor'] is num) ? (map['floor'] as num).toInt() : 0,
      category: map['category']?.toString() ?? 'Umum',
      healthScore: (map['healthScore'] is num) ? (map['healthScore'] as num).toDouble() : 100.0,
      activeIssues: (map['activeIssues'] is num) ? (map['activeIssues'] as num).toInt() : 0,
      resolvedIssues: (map['resolvedIssues'] is num) ? (map['resolvedIssues'] as num).toInt() : 0,
      status: map['status']?.toString() ?? 'aktif',
      qrCodeData: map['qrCodeData']?.toString() ?? '',
    );
  }

  // Helper warna berdasarkan skor kesehatan ruangan
  Color get healthColor {
    if (healthScore >= 80) return Colors.green;
    if (healthScore >= 50) return Colors.orange;
    return Colors.red;
  }

  String get healthLabel {
    if (healthScore >= 80) return 'Sangat Baik';
    if (healthScore >= 50) return 'Perlu Perbaikan';
    return 'Rusak Parah';
  }
}