import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_export.dart';
import 'widgets/user_header_widget.dart';
import 'widgets/emergency_booking_card_widget.dart';
import 'widgets/service_type_grid_widget.dart';
import 'widgets/calendar_strip_widget.dart';
import 'widgets/recent_bookings_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO: Replace with [Riverpod/Bloc] for production
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: isTablet ? _buildTabletLayout(theme) : _buildPhoneLayout(theme),
      ),
    );
  }

  Widget _buildPhoneLayout(ThemeData theme) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: theme.colorScheme.background,
          elevation: 0,
          scrolledUnderElevation: 1,
          floating: true,
          snap: true,
          expandedHeight: 0,
          flexibleSpace: const SizedBox.shrink(),
          title: const UserHeaderWidget(),
          titleSpacing: 0,
          actions: [
            IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomIconWidget(
                    iconName: 'notifications_outlined',
                    color: theme.colorScheme.onSurface,
                    size: 26,
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
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
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),
              EmergencyBookingCardWidget(
                onBook: () => context.push('/booking-status-screen'),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(
                Theme.of(context),
                'Ambulance Types',
                'View all',
              ),
              const SizedBox(height: 12),
              const ServiceTypeGridWidget(),
              const SizedBox(height: 24),
              _buildSectionHeader(Theme.of(context), 'Schedule', null),
              const SizedBox(height: 12),
              CalendarStripWidget(
                selectedDate: _selectedDate,
                onDateSelected: (d) => setState(() => _selectedDate = d),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(
                Theme.of(context),
                'Recent Bookings',
                'View all',
              ),
              const SizedBox(height: 12),
              const RecentBookingsWidget(),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
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
            color: Colors.black.withOpacity(0.06),
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
