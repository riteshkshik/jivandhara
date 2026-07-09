import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../core/booking_service.dart';
import '../../../widgets/status_badge_widget.dart';

class RecentBookingsWidget extends StatefulWidget {
  const RecentBookingsWidget({super.key});

  @override
  State<RecentBookingsWidget> createState() => _RecentBookingsWidgetState();
}

class _RecentBookingsWidgetState extends State<RecentBookingsWidget> {
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final bookings = await BookingService.instance.getBookings();
      if (mounted) {
        setState(() {
          // Show only the last 4 bookings
          _bookings = bookings.take(4).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[RecentBookingsWidget] Error fetching bookings: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  BookingStatus _statusFromString(String? v) {
    switch (v) {
      case 'pending':
        return BookingStatus.pending;
      case 'searching':
        return BookingStatus.searching;
      case 'accepted':
        return BookingStatus.accepted;
      case 'enRoute':
        return BookingStatus.enRoute;
      case 'arrived':
        return BookingStatus.arrived;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final amPm = hour >= 12 ? 'PM' : 'AM';
      final h12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${h12.toString().padLeft(2, '0')}:$minute $amPm';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (_bookings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No recent bookings',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: _bookings.map((b) {
        final booking = b as Map<String, dynamic>;
        final patientName = booking['patientId'] is Map
            ? (booking['patientId'] as Map)['fullName']?.toString() ?? 'Patient'
            : booking['serviceType']?.toString() ?? 'Booking';
        final serviceType = booking['serviceType']?.toString() ?? '';
        final date = _formatDate(booking['createdAt']?.toString());
        final time = _formatTime(booking['createdAt']?.toString());
        final status = _statusFromString(booking['status']?.toString());
        final amount = '₹${(booking['estimatedFare'] as num?)?.toStringAsFixed(0) ?? '0'}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _BookingListItem(
            patientName: patientName,
            serviceType: serviceType,
            date: date,
            time: time,
            status: status,
            amount: amount,
          ),
        );
      }).toList(),
    );
  }
}

class _BookingListItem extends StatelessWidget {
  final String patientName;
  final String serviceType;
  final String date;
  final String time;
  final BookingStatus status;
  final String amount;

  const _BookingListItem({
    required this.patientName,
    required this.serviceType,
    required this.date,
    required this.time,
    required this.status,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer,
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Icon(Icons.local_hospital_rounded, size: 22, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      serviceType,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$date · $time',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadgeWidget(status: status),
                  const SizedBox(height: 6),
                  Text(
                    amount,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
