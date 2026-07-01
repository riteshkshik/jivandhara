import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingStatusHeroWidget extends StatefulWidget {
  final String status;
  const BookingStatusHeroWidget({required this.status, super.key});

  @override
  State<BookingStatusHeroWidget> createState() =>
      _BookingStatusHeroWidgetState();
}

class _BookingStatusHeroWidgetState extends State<BookingStatusHeroWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _statusConfig(widget.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color.withAlpha(51), width: 1.5),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: config.color.withAlpha(38),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: config.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(config.icon, color: Colors.white, size: 26),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: config.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  config.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: config.color.withAlpha(31),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'ETA: 4 minutes',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: config.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _statusConfig(String s) {
    switch (s) {
      case 'pending':
        return _StatusConfig(
          'Searching…',
          'Finding the nearest available ambulance',
          Icons.search_rounded,
          const Color(0xFFE65100),
          const Color(0xFFFFF3E0),
        );
      case 'accepted':
        return _StatusConfig(
          'Driver Assigned',
          'Ambulance has been assigned to your booking',
          Icons.check_circle_rounded,
          const Color(0xFF1565C0),
          const Color(0xFFE3F2FD),
        );
      case 'enRoute':
        return _StatusConfig(
          'En Route',
          'Ambulance is on the way to your location',
          Icons.local_taxi_rounded,
          const Color(0xFF6A1B9A),
          const Color(0xFFF3E5F5),
        );
      case 'arrived':
        return _StatusConfig(
          'Arrived',
          'Ambulance has reached your location',
          Icons.location_on_rounded,
          const Color(0xFF2E7D32),
          const Color(0xFFE8F5E9),
        );
      default:
        return _StatusConfig(
          'Processing',
          'Your booking is being processed',
          Icons.hourglass_empty_rounded,
          const Color(0xFF9E9E9E),
          const Color(0xFFF5F5F5),
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final Color bg;
  const _StatusConfig(
    this.label,
    this.description,
    this.icon,
    this.color,
    this.bg,
  );
}
