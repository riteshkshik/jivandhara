import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_export.dart';

class _ServiceType {
  final String name;
  final String subtitle;
  final String iconName;
  final Color color;
  const _ServiceType(this.name, this.subtitle, this.iconName, this.color);
}

class ServiceTypeGridWidget extends StatelessWidget {
  const ServiceTypeGridWidget({super.key});

  static const List<_ServiceType> _services = [
    _ServiceType(
      'Advanced\nLife Support',
      'ICU-equipped',
      'monitor_heart',
      Color(0xFFC62828),
    ),
    _ServiceType(
      'Basic\nLife Support',
      'First aid ready',
      'medical_services',
      Color(0xFF1565C0),
    ),
    _ServiceType(
      'Neonatal\nAmbulance',
      'Newborn care',
      'child_care',
      Color(0xFF6A1B9A),
    ),
    _ServiceType(
      'Air\nAmbulance',
      'Critical transport',
      'flight',
      Color(0xFF00695C),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: _services.map((s) => _ServiceCard(service: s)).toList(),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final _ServiceType service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        splashColor: service.color.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(14),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: service.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: service.iconName,
                    color: service.color,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                service.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                service.subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
