import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/booking_state.dart';

class LiveTrackingMapWidget extends StatefulWidget {
  const LiveTrackingMapWidget({super.key});

  @override
  State<LiveTrackingMapWidget> createState() => _LiveTrackingMapWidgetState();
}

class _LiveTrackingMapWidgetState extends State<LiveTrackingMapWidget> with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _pulseController;
  double _lastDriverLat = 0.0;
  double _lastDriverLng = 0.0;
  BookingStatus? _lastStatus;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    BookingState.instance.addListener(_onBookingStateChanged);
  }

  @override
  void dispose() {
    BookingState.instance.removeListener(_onBookingStateChanged);
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onBookingStateChanged() {
    final state = BookingState.instance;
    if (_mapController != null &&
        (state.driverLat != _lastDriverLat ||
         state.driverLng != _lastDriverLng ||
         state.status != _lastStatus)) {
      _lastDriverLat = state.driverLat;
      _lastDriverLng = state.driverLng;
      _lastStatus = state.status;
      _updateCameraPosition();
    }
  }

  LatLngBounds _getBounds(LatLng p1, LatLng p2) {
    final double minLat = min(p1.latitude, p2.latitude);
    final double maxLat = max(p1.latitude, p2.latitude);
    final double minLng = min(p1.longitude, p2.longitude);
    final double maxLng = max(p1.longitude, p2.longitude);
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _updateCameraPosition() {
    final state = BookingState.instance;
    final LatLng driverLatLng = LatLng(state.driverLat, state.driverLng);
    final LatLng patientLatLng = LatLng(state.patientLat, state.patientLng);

    if (state.status == BookingStatus.idle ||
        state.status == BookingStatus.searching ||
        state.status == BookingStatus.arrived) {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(patientLatLng, 15.0));
    } else {
      final bounds = _getBounds(driverLatLng, patientLatLng);
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: BookingState.instance,
      builder: (context, child) {
        final state = BookingState.instance;

        // Coordinates
        final double destLat = state.patientLat;
        final double destLng = state.patientLng;
        final double currentLat = state.driverLat;
        final double currentLng = state.driverLng;

        final LatLng driverLatLng = LatLng(currentLat, currentLng);
        final LatLng patientLatLng = LatLng(destLat, destLng);

        // Build list of polyline points
        final List<LatLng> polylinePoints = state.routePoints
            .map((pt) => LatLng(pt[0], pt[1]))
            .toList();

        // Progress fraction calculation
        double fraction = 0.0;
        final double totalDistance = sqrt(pow(destLat - 12.9850, 2) + pow(destLng - 77.6080, 2));
        if (totalDistance > 0) {
          final double currentDist = sqrt(pow(currentLat - 12.9850, 2) + pow(currentLng - 77.6080, 2));
          fraction = (currentDist / totalDistance).clamp(0.0, 1.0);
        }

        // Markers
        final Set<Marker> markers = {
          Marker(
            markerId: const MarkerId('patient'),
            position: patientLatLng,
            infoWindow: const InfoWindow(title: 'Patient Location (Pickup)'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        };

        // Show nearby available ambulances only during searching/idle phase
        if (state.status == BookingStatus.searching || state.status == BookingStatus.idle) {
          markers.addAll([
            Marker(
              markerId: const MarkerId('nearby_amb_1'),
              position: LatLng(destLat + 0.0035, destLng + 0.0028),
              infoWindow: const InfoWindow(title: 'Available Ambulance (1.2 km away)'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
            Marker(
              markerId: const MarkerId('nearby_amb_2'),
              position: LatLng(destLat - 0.0025, destLng - 0.0032),
              infoWindow: const InfoWindow(title: 'Available Ambulance (0.8 km away)'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
            Marker(
              markerId: const MarkerId('nearby_amb_3'),
              position: LatLng(destLat + 0.0018, destLng - 0.0045),
              infoWindow: const InfoWindow(title: 'Available Ambulance (1.5 km away)'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
          ]);
        }

        // Only add driver marker if booking is accepted, enRoute, or arrived
        if (state.status == BookingStatus.accepted ||
            state.status == BookingStatus.enRoute ||
            state.status == BookingStatus.arrived) {
          markers.add(
            Marker(
              markerId: const MarkerId('driver'),
              position: driverLatLng,
              infoWindow: InfoWindow(title: 'Ambulance - ${state.driverName}'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            ),
          );
        }

        // Polylines (only draw if driver is accepted / en route)
        final Set<Polyline> polylines = {};
        if (state.status != BookingStatus.searching &&
            state.status != BookingStatus.idle &&
            polylinePoints.isNotEmpty) {
          polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: polylinePoints,
              color: theme.colorScheme.primary,
              width: 5,
              geodesic: true,
            ),
          );
        }

        return Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.outline.withAlpha(40)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Real Google Map
              GoogleMap(
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
                initialCameraPosition: CameraPosition(
                  target: patientLatLng,
                  zoom: 14.0,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  _updateCameraPosition();
                },
                markers: markers,
                polylines: polylines,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
              ),

              // Map Floating HUD Overlay
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withAlpha(235),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.radar_rounded,
                          color: Color(0xFF2E7D32),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.status == BookingStatus.enRoute
                                  ? "Ambulance en route"
                                  : state.status == BookingStatus.arrived
                                      ? "Ambulance has arrived!"
                                      : "Awaiting driver accept...",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              state.status == BookingStatus.enRoute
                                  ? "ETA: ~${max(1, (10 - (fraction * 10).toInt()))} mins • ${state.driverName}"
                                  : state.status == BookingStatus.arrived
                                      ? "Please meet paramedic at the gate"
                                      : "Tracking active",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Map Scale and Zoom Controls
              Positioned(
                bottom: 12,
                right: 12,
                child: Column(
                  children: [
                    _mapControlButton(
                      Icons.add_rounded,
                      onTap: () {
                        _mapController?.animateCamera(CameraUpdate.zoomIn());
                      },
                    ),
                    const SizedBox(height: 6),
                    _mapControlButton(
                      Icons.remove_rounded,
                      onTap: () {
                        _mapController?.animateCamera(CameraUpdate.zoomOut());
                      },
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(160),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    state.status == BookingStatus.searching || state.status == BookingStatus.idle
                        ? "SEARCHING NEARBY"
                        : (state.routePoints.isNotEmpty ? "REAL GPS ACTIVE" : "SIMULATED GPS ACTIVE"),
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _mapControlButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: Colors.grey[800], size: 18),
        ),
      ),
    );
  }
}
