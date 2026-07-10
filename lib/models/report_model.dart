import 'package:flutter/material.dart';

enum ReportStatus { reported, inProgress, resolved, rejected }

class Report {
  final String id;
  final String userId;
  final String userName;
  final String roomId;
  final String roomName;
  final String category;
  final String description;
  final String priority;
  final ReportStatus status;
  final String? assignedTo;
  final String? assignedName;
  final String? resolution;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  Report({
    required this.id,
    required this.userId,
    required this.userName,
    required this.roomId,
    required this.roomName,
    required this.category,
    required this.description,
    this.priority = 'medium',
    this.status = ReportStatus.reported,
    this.assignedTo,
    this.assignedName,
    this.resolution,
    this.imageUrls = const [],
    DateTime? createdAt,
    this.resolvedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'roomId': roomId,
        'roomName': roomName,
        'category': category,
        'description': description,
        'priority': priority,
        'status': status.name,
        'assignedTo': assignedTo,
        'assignedName': assignedName,
        'resolution': resolution,
        'imageUrls': imageUrls,
        'createdAt': createdAt.toIso8601String(),
        'resolvedAt': resolvedAt?.toIso8601String(),
      };

  factory Report.fromMap(Map<String, dynamic> map) => Report(
        id: map['id'] as String,
        userId: map['userId'] as String,
        userName: map['userName'] as String,
        roomId: map['roomId'] as String,
        roomName: map['roomName'] as String,
        category: map['category'] as String,
        description: map['description'] as String,
        priority: map['priority'] as String? ?? 'medium',
        status: ReportStatus.values.firstWhere(
          (s) => s.name == map['status'],
          orElse: () => ReportStatus.reported,
        ),
        assignedTo: map['assignedTo'] as String?,
        assignedName: map['assignedName'] as String?,
        resolution: map['resolution'] as String?,
        imageUrls: (map['imageUrls'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : null,
        resolvedAt: map['resolvedAt'] != null
            ? DateTime.parse(map['resolvedAt'] as String)
            : null,
      );

  String get statusLabel {
    switch (status) {
      case ReportStatus.reported:
        return 'Dilaporkan';
      case ReportStatus.inProgress:
        return 'Diproses';
      case ReportStatus.resolved:
        return 'Selesai';
      case ReportStatus.rejected:
        return 'Ditolak';
    }
  }

  Color get statusColor {
    switch (status) {
      case ReportStatus.reported:
        return const Color(0xFFF59E0B);
      case ReportStatus.inProgress:
        return const Color(0xFF3B82F6);
      case ReportStatus.resolved:
        return const Color(0xFF10B981);
      case ReportStatus.rejected:
        return const Color(0xFFEF4444);
    }
  }
}
