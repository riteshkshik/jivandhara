import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../core/booking_state.dart';
import '../../core/auth_service.dart';
import '../../core/socket_service.dart';
import './widgets/calendar_strip_widget.dart';
import './widgets/emergency_booking_card_widget.dart';
import './widgets/service_type_grid_widget.dart';
import './widgets/user_header_widget.dart';
import './widgets/nearby_ambulances_widget.dart';
import './widgets/driver_dashboard_widget.dart';
import '../sign_up_login_screen/sign_up_login_screen.dart' show UserRole;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  int _selectedHour = TimeOfDay.now().hour;
  int _selectedMinute = TimeOfDay.now().minute;
  bool _showEtaPopup = false;

  String get _formattedTime {
    final h = _selectedHour.toString().padLeft(2, '0');
    final m = _selectedMinute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedHour = picked.hour;
        _selectedMinute = picked.minute;
      });
    }
  }

  void _confirmScheduledBooking() {
    final theme = Theme.of(context);
    final dateStr =
        '${_selectedDate.day.toString().padLeft(2, '0')}/'
        '${_selectedDate.month.toString().padLeft(2, '0')}/'
        '${_selectedDate.year}';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.schedule_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Confirm Booking'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your ambulance will be scheduled for:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            _infoRow(theme, Icons.calendar_today_rounded, 'Date', dateStr),
            const SizedBox(height: 8),
            _infoRow(
              theme,
              Icons.access_time_rounded,
              'Time',
              '$_formattedTime (24-hr)',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push(
                '/booking-confirmation-screen',
                extra: {
                  'serviceType': 'Basic Life Support',
                  'scheduledDate': dateStr,
                  'scheduledTime': _formattedTime,
                  'isEmergency': false,
                },
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return ListenableBuilder(
      listenable: BookingState.instance,
      builder: (context, child) {
        final state = BookingState.instance;
        final isDriver = state.currentRole == UserRole.driver;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: isDriver
              ? AppBar(
                  backgroundColor: theme.colorScheme.surface,
                  elevation: 0,
                  scrolledUnderElevation: 1,
                  title: Row(
                    children: [
                      Icon(Icons.drive_eta_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        "Driver Companion Hub",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout_rounded),
                      onPressed: () async {
                        state.reset();
                        SocketService.instance.disconnect();
                        await AuthService.instance.logout();
                        if (context.mounted) {
                          context.go('/');
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                )
              : null,
          body: SafeArea(
            child: Stack(
              children: [
                isDriver
                    ? const DriverDashboardWidget()
                    : (isTablet ? _buildTabletLayout(theme) : _buildPhoneLayout(theme)),
                if (!isDriver && _showEtaPopup) _buildEtaOverlay(theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEtaOverlay(ThemeData theme) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showEtaPopup = false),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              top: 120,
              right: 12,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 260,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: theme.colorScheme.outline.withAlpha(60),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_hospital_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Active Booking',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(50),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'LIVE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ETA Section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.timer_rounded,
                                    color: Color(0xFF2E7D32),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Estimated Arrival',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      '~8 minutes',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 1,
                              color: theme.colorScheme.outline.withAlpha(40),
                            ),
                            const SizedBox(height: 12),
                            _etaDetailRow(
                              theme,
                              Icons.directions_car_rounded,
                              'Ambulance',
                              'BLS Unit #A-204',
                            ),
                            const SizedBox(height: 8),
                            _etaDetailRow(
                              theme,
                              Icons.person_rounded,
                              'Paramedic',
                              'Rajesh Kumar',
                            ),
                            const SizedBox(height: 8),
                            _etaDetailRow(
                              theme,
                              Icons.location_on_rounded,
                              'Distance',
                              '3.2 km away',
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() => _showEtaPopup = false);
                                  context.push('/booking-status-screen');
                                },
                                icon: const Icon(Icons.map_rounded, size: 16),
                                label: Text(
                                  'Track Live',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _etaDetailRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 15, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneLayout(ThemeData theme) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 1,
          floating: true,
          snap: true,
          expandedHeight: 0,
          flexibleSpace: const SizedBox.shrink(),
          title: const UserHeaderWidget(),
          titleSpacing: 0,
          actions: const [],
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),
              EmergencyBookingCardWidget(
                onBook: () {
                  BookingState.instance.requestBooking(
                    serviceType: 'Basic Life Support',
                    isEmergency: true,
                  );
                  context.push('/booking-status-screen');
                },
              ),
              const SizedBox(height: 24),
              const NearbyAmbulancesWidget(),
              const SizedBox(height: 24),
              _buildAmbulanceTypesHeader(Theme.of(context)),
              const SizedBox(height: 12),
              const ServiceTypeGridWidget(),
              const SizedBox(height: 24),
              _buildSectionHeader(
                Theme.of(context),
                'Schedule Advance Booking',
                null,
              ),
              const SizedBox(height: 12),
              CalendarStripWidget(
                selectedDate: _selectedDate,
                onDateSelected: (d) => setState(() => _selectedDate = d),
              ),
              const SizedBox(height: 16),
              _buildTimePickerRow(theme),
              const SizedBox(height: 16),
              _buildBookInAdvanceButton(theme),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickerRow(ThemeData theme) {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withAlpha(80),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.access_time_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Time (24-hour)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formattedTime,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookInAdvanceButton(ThemeData theme) {
    final dateStr =
        '${_selectedDate.day.toString().padLeft(2, '0')}/'
        '${_selectedDate.month.toString().padLeft(2, '0')}/'
        '${_selectedDate.year}';
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _confirmScheduledBooking,
        icon: const Icon(Icons.schedule_rounded, size: 20),
        label: Text('Book for $dateStr at $_formattedTime'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(ThemeData theme) {
    return Row(
      children: [
        Expanded(flex: 6, child: _buildPhoneLayout(theme)),
        Container(width: 1, color: theme.colorScheme.outline),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text('Quick Stats', style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),
                _buildStatCard(
                  theme,
                  'Total Bookings',
                  '24',
                  Icons.local_taxi_rounded,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  theme,
                  'Completed',
                  '21',
                  Icons.check_circle_rounded,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  theme,
                  'Avg Response',
                  '4.2 min',
                  Icons.timer_rounded,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmbulanceTypesHeader(ThemeData theme) {
    return Row(
      children: [
        Text(
          'Ambulance Types',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() => _showEtaPopup = !_showEtaPopup),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'notifications_outlined',
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {},
          child: Text(
            'View all',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    String title,
    String? actionLabel,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: () {},
            child: Text(
              actionLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}