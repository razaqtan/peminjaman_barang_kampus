import 'package:flutter/material.dart';

// ──── App Info ────
const String appName = 'Sarana Kampus';
const String appVersion = '1.0.0';
const String appDescription =
    'Aplikasi peminjaman sarana kampus berbasis Flutter '
    'dengan implementasi QR Code dan SQLite.';

// ──── Status Helpers ────
Color statusColor(String status) {
  switch (status) {
    case 'APPROVED':
      return Colors.green;
    case 'REJECTED':
      return Colors.red;
    case 'CHECKED_OUT':
      return Colors.deepOrange;
    case 'RETURNED':
      return Colors.blue;
    case 'SUBMITTED':
      return Colors.amber.shade800;
    case 'CANCELLED':
      return Colors.grey.shade600;
    case 'OVERDUE':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

String statusLabel(String status) {
  switch (status) {
    case 'SUBMITTED':
      return 'Menunggu persetujuan';
    case 'APPROVED':
      return 'Disetujui';
    case 'REJECTED':
      return 'Ditolak';
    case 'CHECKED_OUT':
      return 'Sedang dipinjam';
    case 'RETURNED':
      return 'Dikembalikan';
    case 'OVERDUE':
      return 'Terlambat';
    case 'CANCELLED':
      return 'Dibatalkan';
    default:
      return status;
  }
}

IconData statusIcon(String status) {
  switch (status) {
    case 'SUBMITTED':
      return Icons.hourglass_top;
    case 'APPROVED':
      return Icons.check_circle_outline;
    case 'REJECTED':
      return Icons.cancel_outlined;
    case 'CHECKED_OUT':
      return Icons.outbox;
    case 'RETURNED':
      return Icons.assignment_return;
    case 'CANCELLED':
      return Icons.block;
    default:
      return Icons.info_outline;
  }
}

// ──── Date Formatting ────
String formatDate(String isoDate) {
  try {
    final dt = DateTime.parse(isoDate);
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  } catch (_) {
    return isoDate;
  }
}

String formatDateTime(String isoDate) {
  try {
    final dt = DateTime.parse(isoDate);
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return isoDate;
  }
}
