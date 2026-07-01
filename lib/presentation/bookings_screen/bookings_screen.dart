import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/status_badge_widget.dart';
import '../../widgets/custom_image_widget.dart';

class _BookingHistoryItem {
  final String id;
  final String serviceType;
  final String date;
  final String time;
  final BookingStatus status;
  final String amount;
  final String pickupAddress;

  const _BookingHistoryItem({
    required this.id,
    required this.serviceType,
    required this.date,
    required this.time,
    required this.status,
    required this.amount,
    required this.pickupAddress,
  });
}

// Last 5 bookings made by the currently logged-in customer: Ravi Sharma
final List<_BookingHistoryItem> _last5Bookings = [
  _BookingHistoryItem(
    id: 'JVN-20240628-009',
    serviceType: 'Advanced Life Support',
    date: '28 Jun 2024',
    time: '09:41 AM',
    status: BookingStatus.completed,
    amount: '₹1,200',
    pickupAddress: '14B, MG Road, Bengaluru — 560001',
  ),
  _BookingHistoryItem(
    id: 'JVN-20240627-004',
    serviceType: 'Basic Life Support',
    date: '27 Jun 2024',
    time: '03:15 PM',
    status: BookingStatus.completed,
    amount: '₹800',
    pickupAddress: '22, Koramangala 5th Block, Bengaluru — 560095',
  ),
  _BookingHistoryItem(
    id: 'JVN-20240626-002',
    serviceType: 'Neonatal Ambulance',
    date: '26 Jun 2024',
    time: '11:30 AM',
    status: BookingStatus.cancelled,
    amount: '₹0',
    pickupAddress: '7, Indiranagar 100ft Road, Bengaluru — 560038',
  ),
  _BookingHistoryItem(
    id: 'JVN-20240625-007',
    serviceType: 'Advanced Life Support',
    date: '25 Jun 2024',
    time: '08:00 AM',
    status: BookingStatus.completed,
    amount: '₹1,500',
    pickupAddress: '3, Whitefield Main Road, Bengaluru — 560066',
  ),
  _BookingHistoryItem(
    id: 'JVN-20240623-011',
    serviceType: 'Patient Transport',
    date: '23 Jun 2024',
    time: '06:20 PM',
    status: BookingStatus.completed,
    amount: '₹650',
    pickupAddress: '9, Jayanagar 4th Block, Bengaluru — 560041',
  ),
];

// Current logged-in profile user
const _currentUserName = 'Ravi Sharma';
const _currentUserImageUrl =
    'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg';
const _currentUserSemanticLabel =
    'Indian man in his thirties with short dark hair and a confident expression';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          'Booking History',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile user info banner
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withAlpha(80),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: CustomImageWidget(
                        imageUrl: _currentUserImageUrl,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        semanticLabel: _currentUserSemanticLabel,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentUserName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Last 5 bookings',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: _last5Bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _BookingHistoryCard(item: _last5Bookings[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingHistoryCard extends StatelessWidget {
  final _BookingHistoryItem item;
  const _BookingHistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      imageUrl: _currentUserImageUrl,
                      width: 46,
                      height: 46,
                      fit: BoxFit.cover,
                      semanticLabel: _currentUserSemanticLabel,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentUserName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.serviceType,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outline.withAlpha(60),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.pickupAddress,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.date} · ${item.time}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text(
                  item.id,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
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
