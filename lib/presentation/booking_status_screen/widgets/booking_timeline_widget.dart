import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _TimelineStep {
  final String status;
  final String label;
  final String description;
  final String time;
  final IconData icon;

  const _TimelineStep({
    required this.status,
    required this.label,
    required this.description,
    required this.time,
    required this.icon,
  });
}

class BookingTimelineWidget extends StatelessWidget {
  final String currentStatus;
  const BookingTimelineWidget({required this.currentStatus, super.key});

  static const List<_TimelineStep> _steps = [
    _TimelineStep(
      status: 'pending',
      label: 'Booking Confirmed',
      description: 'Your request was received',
      time: '09:41 AM',
      icon: Icons.check_circle_rounded,
    ),
    _TimelineStep(
      status: 'accepted',
      label: 'Driver Assigned',
      description: 'Rajesh Kumar accepted your booking',
      time: '09:43 AM',
      icon: Icons.person_rounded,
    ),
    _TimelineStep(
      status: 'enRoute',
      label: 'En Route',
      description: 'Ambulance is heading to your location',
      time: '09:44 AM',
      icon: Icons.local_taxi_rounded,
    ),
    _TimelineStep(
      status: 'arrived',
      label: 'Arrived',
      description: 'Ambulance reached your location',
      time: '—',
      icon: Icons.location_on_rounded,
    ),
    _TimelineStep(
      status: 'completed',
      label: 'Completed',
      description: 'Booking successfully completed',
      time: '—',
      icon: Icons.task_alt_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusOrder = [
      'pending',
      'accepted',
      'enRoute',
      'arrived',
      'completed',
    ];
    final currentIndex = statusOrder.indexOf(currentStatus);

    return Column(
      children: List.generate(_steps.length, (index) {
        final step = _steps[index];
        final stepIndex = statusOrder.indexOf(step.status);
        final isCompleted = stepIndex <= currentIndex;
        final isCurrent = stepIndex == currentIndex;
        final isLast = index == _steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? (isCurrent
                              ? theme.colorScheme.primary
                              : const Color(0xFF2E7D32))
                        : theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(
                            color: theme.colorScheme.primary.withAlpha(77),
                            width: 3,
                          )
                        : null,
                  ),
                  child: Icon(
                    step.icon,
                    size: 18,
                    color: isCompleted
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (!isLast)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 2,
                    height: 48,
                    color: stepIndex < currentIndex
                        ? const Color(0xFF2E7D32)
                        : theme.colorScheme.outline,
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          step.label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: isCompleted
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isCompleted
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (step.time != '—')
                          Text(
                            step.time,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
