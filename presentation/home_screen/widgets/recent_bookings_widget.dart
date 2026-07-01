import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_export.dart';
import '../../../widgets/status_badge_widget.dart';

class _BookingItem {
  final String id;
  final String patientName;
  final String serviceType;
  final String date;
  final String time;
  final BookingStatus status;
  final String amount;
  final String imageUrl;
  final String semanticLabel;

  const _BookingItem({
    required this.id,
    required this.patientName,
    required this.serviceType,
    required this.date,
    required this.time,
    required this.status,
    required this.amount,
    required this.imageUrl,
    required this.semanticLabel,
  });
}

final List<Map<String, dynamic>> _bookingMaps = [
  {
    'id': 'JVN-20240628-001',
    'patientName': 'Priya Sharma',
    'serviceType': 'Advanced Life Support',
    'date': '28 Jun 2024',
    'time': '09:41 AM',
    'status': 'completed',
    'amount': '₹1,200',
    'imageUrl':
        'https://images.pixabay.com/photo/2016/11/29/13/14/attractive-1869761_640.jpg',
    'semanticLabel': 'Young Indian woman with dark hair and a warm smile',
  },
  {
    'id': 'JVN-20240627-004',
    'patientName': 'Ramesh Iyer',
    'serviceType': 'Basic Life Support',
    'date': '27 Jun 2024',
    'time': '03:15 PM',
    'status': 'completed',
    'amount': '₹800',
    'imageUrl':
        'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=200',
    'semanticLabel':
        'Middle-aged Indian man with glasses and a professional expression',
  },
  {
    'id': 'JVN-20240626-002',
    'patientName': 'Sunita Devi',
    'serviceType': 'Neonatal Ambulance',
    'date': '26 Jun 2024',
    'time': '11:30 AM',
    'status': 'cancelled',
    'amount': '₹0',
    'imageUrl':
        'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=200',
    'semanticLabel':
        'Elderly Indian woman with grey hair and a kind expression',
  },
  {
    'id': 'JVN-20240625-007',
    'patientName': 'Arjun Mehta',
    'serviceType': 'Advanced Life Support',
    'date': '25 Jun 2024',
    'time': '08:00 AM',
    'status': 'completed',
    'amount': '₹1,500',
    'imageUrl':
        'https://images.pixabay.com/photo/2015/03/04/22/35/head-659651_640.jpg',
    'semanticLabel': 'Young Indian man with short hair and a confident look',
  },
];

BookingStatus _statusFromString(String v) {
  switch (v) {
    case 'pending':
      return BookingStatus.pending;
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

_BookingItem _bookingFromMap(Map<String, dynamic> m) => _BookingItem(
  id: m['id'] as String,
  patientName: m['patientName'] as String,
  serviceType: m['serviceType'] as String,
  date: m['date'] as String,
  time: m['time'] as String,
  status: _statusFromString(m['status'] as String),
  amount: m['amount'] as String,
  imageUrl: m['imageUrl'] as String,
  semanticLabel: m['semanticLabel'] as String,
);

class RecentBookingsWidget extends StatelessWidget {
  const RecentBookingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _bookingMaps.map(_bookingFromMap).toList();
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BookingListItem(item: item),
            ),
          )
          .toList(),
    );
  }
}

class _BookingListItem extends StatelessWidget {
  final _BookingItem item;
  const _BookingListItem({required this.item});

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
                color: Colors.black.withOpacity(0.05),
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
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl: item.imageUrl,
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                    semanticLabel: item.semanticLabel,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.patientName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.serviceType,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.date} · ${item.time}',
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
                  StatusBadgeWidget(status: item.status),
                  const SizedBox(height: 6),
                  Text(
                    item.amount,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
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
