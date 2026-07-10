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
  final String? qrCodeData;
  final String status;

  Room({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.category,
    this.healthScore = 100,
    this.activeIssues = 0,
    this.resolvedIssues = 0,
    this.qrCodeData,
    this.status = 'aktif',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'building': building,
        'floor': floor,
        'category': category,
        'healthScore': healthScore,
        'activeIssues': activeIssues,
        'resolvedIssues': resolvedIssues,
        'qrCodeData': qrCodeData,
        'status': status,
      };

  factory Room.fromMap(Map<String, dynamic> map) => Room(
        id: map['id'] as String,
        name: map['name'] as String,
        building: map['building'] as String,
        floor: (map['floor'] as num).toInt(),
        category: map['category'] as String,
        healthScore: (map['healthScore'] as num).toDouble(),
        activeIssues: (map['activeIssues'] as num?)?.toInt() ?? 0,
        resolvedIssues: (map['resolvedIssues'] as num?)?.toInt() ?? 0,
        qrCodeData: map['qrCodeData'] as String?,
        status: map['status'] as String? ?? 'aktif',
      );

  String get healthLabel {
    if (healthScore >= 80) return 'Sehat';
    if (healthScore >= 60) return 'Cukup';
    if (healthScore >= 40) return 'Kurang';
    return 'Kritis';
  }

  Color get healthColor {
    if (healthScore >= 80) return const Color(0xFF10B981);
    if (healthScore >= 60) return const Color(0xFFF59E0B);
    if (healthScore >= 40) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }
}
