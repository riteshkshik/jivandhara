import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../core/booking_state.dart';
import './widgets/booking_status_hero_widget.dart';
import './widgets/booking_timeline_widget.dart';
import './widgets/cancel_booking_widget.dart';
import './widgets/driver_info_card_widget.dart';
import './widgets/live_tracking_map_widget.dart';

class BookingStatusScreen extends StatefulWidget {
  const BookingStatusScreen({super.key});

  @override
  State<BookingStatusScreen> createState() => _BookingStatusScreenState();
}

class _BookingStatusScreenState extends State<BookingStatusScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: BookingState.instance,
      builder: (context, child) {
        final state = BookingState.instance;

        // Map BookingStatus to hero status strings
        String statusStr = 'pending';
        if (state.status == BookingStatus.accepted) statusStr = 'accepted';
        if (state.status == BookingStatus.enRoute) statusStr = 'enRoute';
        if (state.status == BookingStatus.arrived) statusStr = 'arrived';
        if (state.status == BookingStatus.completed) statusStr = 'arrived';

        final bookingId = state.bookingId ?? 'JVN-20240628-009';

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            scrolledUnderElevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home-screen');
                }
              },
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booking Status', style: theme.textTheme.titleMedium),
                Text(
                  bookingId,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'share_outlined',
                  color: theme.colorScheme.onSurface,
                  size: 22,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BookingStatusHeroWidget(status: statusStr),
                      const SizedBox(height: 20),

                      // Live Tracking Map (Displays animated map while tracking)
                      const LiveTrackingMapWidget(),
                      const SizedBox(height: 20),

                      if (state.status != BookingStatus.searching && state.status != BookingStatus.idle) ...[
                        DriverInfoCardWidget(onCall: _callDriver),
                        const SizedBox(height: 20),
                      ],

                      Text('Booking Progress', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 14),
                      BookingTimelineWidget(currentStatus: statusStr),
                      const SizedBox(height: 20),

                      _buildBookingDetails(theme, state),
                      const SizedBox(height: 20),

                      CancelBookingWidget(
                        onCancel: () {
                          state.cancelBooking();
                          context.go('/home-screen');
                        },
                      ),
                    ],
                  ),
                ),
                if (state.status != BookingStatus.searching && state.status != BookingStatus.idle)
                  Positioned(
                    bottom: 24,
                    left: 16,
                    right: 16,
                    child: _buildCallFab(theme, state),
                  ),

                // Simulated Driver app ringing overlay
                if (state.showIncomingRequestPopup)
                  _buildIncomingRingOverlay(context, theme, state),
              ],
            ),
          ),
        );
      },
    );
  }

  void _callDriver() {
    final state = BookingState.instance;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Calling ${state.driverName}…',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildBookingDetails(ThemeData theme, BookingState state) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking Details', style: theme.textTheme.titleSmall),
          const SizedBox(height: 14),
          _detailRow(theme, 'Service Type', state.serviceType),
          _detailRow(theme, 'Patient Name', state.patientName),
          _detailRow(
            theme,
            'Pickup Address',
            state.pickupAddress,
          ),
          _detailRow(theme, 'Booked On', '28 Jun 2024, 09:41 AM'),
          _detailRow(theme, 'Estimated Fare', state.estimatedFare),
        ],
      ),
    );
  }

  Widget _detailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallFab(ThemeData theme, BookingState state) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withAlpha(102),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _callDriver,
          icon: const Icon(Icons.call_rounded, size: 22),
          label: Text(
            'Call Driver — ${state.driverName}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncomingRingOverlay(BuildContext context, ThemeData theme, BookingState state) {
    return Container(
      color: Colors.black.withAlpha(160),
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withAlpha(100),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.ring_volume_rounded,
                color: Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "INCOMING BOOKING",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.red[800],
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Incoming Booking Request",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "${state.serviceType} — ${state.pickupAddress.isNotEmpty ? state.pickupAddress : 'Pickup location'}\nPatient: ${state.patientName}\nFare: ${state.estimatedFare}",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      state.declineBooking();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "Decline",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      state.acceptBooking();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Booking accepted by ${state.driverName}! Paramedic is starting navigation.',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: const Color(0xFF2E7D32),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "Accept Alert",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
