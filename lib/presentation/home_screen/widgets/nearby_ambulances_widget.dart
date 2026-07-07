import 'package:flutter/material.dart';
import '../../../core/booking_state.dart';
import '../../../core/app_export.dart';

class NearbyAmbulanceModel {
  final String providerName;
  final String type;
  final String distance;
  final String eta;
  final String fare;
  final String rating;
  final String regNo;
  final IconData icon;

  NearbyAmbulanceModel({
    required this.providerName,
    required this.type,
    required this.distance,
    required this.eta,
    required this.fare,
    required this.rating,
    required this.regNo,
    required this.icon,
  });
}

class NearbyAmbulancesWidget extends StatelessWidget {
  const NearbyAmbulancesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<NearbyAmbulanceModel> providers = [
      NearbyAmbulanceModel(
        providerName: "Lifeline Care Service",
        type: "Basic Life Support (BLS)",
        distance: "0.8 km away",
        eta: "4 mins",
        fare: "₹800",
        rating: "4.8",
        regNo: "KA 01 AB 2345",
        icon: Icons.local_hospital_rounded,
      ),
      NearbyAmbulanceModel(
        providerName: "Medilife Critical Care",
        type: "Advanced Life Support (ALS)",
        distance: "1.5 km away",
        eta: "7 mins",
        fare: "₹1,200",
        rating: "4.9",
        regNo: "KA 03 XY 7890",
        icon: Icons.emergency_rounded,
      ),
      NearbyAmbulanceModel(
        providerName: "Apex Cardiac Rescue",
        type: "Cardiac Care Unit (CCU)",
        distance: "2.4 km away",
        eta: "11 mins",
        fare: "₹1,900",
        rating: "4.7",
        regNo: "KA 05 MN 4567",
        icon: Icons.heart_broken_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Nearby Ambulances",
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "3 Active",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: providers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final provider = providers[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withAlpha(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Service Icon Circle
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      provider.icon,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Provider Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.providerName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          provider.type,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 13,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              provider.distance,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 3),
                            Text(
                              provider.rating,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Fare & Book Action
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        provider.fare,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        "ETA: ${provider.eta}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            BookingState.instance.requestBooking(
                              serviceType: provider.type,
                              isEmergency: true,
                            );
                            context.push('/booking-status-screen');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Book",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
