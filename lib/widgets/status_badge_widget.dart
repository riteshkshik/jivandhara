import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum BookingStatus { idle, pending, searching, accepted, enRoute, arrived, completed, cancelled }

class StatusBadgeWidget extends StatelessWidget {
  final BookingStatus status;
  const StatusBadgeWidget({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        config.label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: config.fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  _StatusConfig _statusConfig(BookingStatus s) {
    switch (s) {
      case BookingStatus.idle:
        return _StatusConfig(
          'Idle',
          const Color(0xFFEEEEEE),
          const Color(0xFF757575),
        );
      case BookingStatus.pending:
        return _StatusConfig(
          'Pending',
          const Color(0xFFFFF3E0),
          const Color(0xFFE65100),
        );
      case BookingStatus.searching:
        return _StatusConfig(
          'Searching',
          const Color(0xFFFFF8E1),
          const Color(0xFFF9A825),
        );
      case BookingStatus.accepted:
        return _StatusConfig(
          'Accepted',
          const Color(0xFFE0FFF8),
          const Color(0xFF00C9A7),
        );
      case BookingStatus.enRoute:
        return _StatusConfig(
          'En Route',
          const Color(0xFFF3E5F5),
          const Color(0xFF6A1B9A),
        );
      case BookingStatus.arrived:
        return _StatusConfig(
          'Arrived',
          const Color(0xFFE0FFF8),
          const Color(0xFF00897B),
        );
      case BookingStatus.completed:
        return _StatusConfig(
          'Completed',
          const Color(0xFFE0FFF8),
          const Color(0xFF00897B),
        );
      case BookingStatus.cancelled:
        return _StatusConfig(
          'Cancelled',
          const Color(0xFFFFEBEE),
          const Color(0xFFD32F2F),
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color bg;
  final Color fg;
  const _StatusConfig(this.label, this.bg, this.fg);
}
