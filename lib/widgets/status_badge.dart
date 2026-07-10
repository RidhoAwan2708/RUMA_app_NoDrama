import 'package:flutter/material.dart';
import '../config/theme.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Color colorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'dilaporkan':
      case 'reported':
        return RumaColors.warningYellow;
      case 'diproses':
      case 'inprogress':
      case 'in_progress':
        return RumaColors.primaryLight;
      case 'selesai':
      case 'resolved':
        return RumaColors.secondaryGreen;
      case 'ditolak':
      case 'rejected':
        return RumaColors.dangerRed;
      default:
        return RumaColors.slate400;
    }
  }
}
