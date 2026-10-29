import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool showIcon;
  const StatusBadge(this.status, {super.key, this.showIcon = false});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(statusIcon(status), size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            statusLabel(status),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
