import 'package:flutter/material.dart';
import '../config/theme.dart';

class HealthScoreCard extends StatelessWidget {
  final double score;
  final String label;
  final String roomName;
  final int activeIssues;
  final int resolvedIssues;

  const HealthScoreCard({
    super.key,
    required this.score,
    required this.label,
    required this.roomName,
    this.activeIssues = 0,
    this.resolvedIssues = 0,
  });

  Color get _color {
    if (score >= 80) return RumaColors.secondaryGreen;
    if (score >= 60) return RumaColors.warningYellow;
    if (score >= 40) return const Color(0xFFF97316);
    return RumaColors.dangerRed;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Campus Health Score', style: Theme.of(context).textTheme.titleMedium),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(label, style: TextStyle(
                    color: _color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: score / 100,
                          strokeWidth: 8,
                          backgroundColor: RumaColors.slate200,
                          valueColor: AlwaysStoppedAnimation(_color),
                        ),
                      ),
                      Text(
                        '${score.toInt()}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: _color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(roomName, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _statBadge(Icons.warning_amber_rounded, 'Aktif: $activeIssues', RumaColors.warningYellow),
                          const SizedBox(width: 12),
                          _statBadge(Icons.check_circle_outline, 'Selesai: $resolvedIssues', RumaColors.secondaryGreen),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBadge(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: RumaColors.slate600)),
      ],
    );
  }
}
