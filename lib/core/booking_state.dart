import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import '../presentation/sign_up_login_screen/sign_up_login_screen.dart' show UserRole;
import 'socket_service.dart';
import 'booking_service.dart';


enum BookingStatus {
  idle,
  searching,
  accepted,
  enRoute,
  arrived,
  completed,
}

class BookingState extends ChangeNotifier {
  static final BookingState instance = BookingState._internal();
  BookingState._internal() {
    _loadFromPrefs();
    _registerSocketHandlers();
  }

  // ─── Active User Role ───
  UserRole _currentRole = UserRole.patient;
  UserRole get currentRole => _currentRole;

  // ─── Active Booking state ───
  BookingStatus _status = BookingStatus.idle;
  BookingStatus get status => _status;

  String? _bookingId;
  String? get bookingId => _bookingId;

  String _patientName = "User";
  String get patientName => _patientName;

  String _pickupAddress = "";
  String get pickupAddress => _pickupAddress;

  String _serviceType = "Basic Life Support";
  String get serviceType => _serviceType;

  double _estimatedFare = 0;
  String get estimatedFare => '₹${_estimatedFare.toStringAsFixed(0)}';
  double get estimatedFareRaw => _estimatedFare;

  // ─── Coordinates ───
  double _patientLat = 12.9716;
  double _patientLng = 77.5946;
  double get patientLat => _patientLat;
  double get patientLng => _patientLng;

  double _driverLat = 0;
  double _driverLng = 0;
  double get driverLat => _driverLat;
  double get driverLng => _driverLng;

  // Route coordinates (still from Google Directions API)
  List<List<double>> _routePoints = [];
  List<List<double>> get routePoints => _routePoints;

  // ─── Driver Info (populated from server via socket events) ───
  String _driverName = "";
  String _driverPhone = "";
  String _driverRating = "5.0";
  String _vehicleRegNo = "";
  String _experience = "";
  String get driverName => _driverName;
  String get driverPhone => _driverPhone;
  String get driverRating => _driverRating;
  String get vehicleRegNo => _vehicleRegNo;
  String get experience => _experience;

  // ─── Incoming request popup (Driver role) ───
  bool _showIncomingRequestPopup = false;
  bool get showIncomingRequestPopup => _showIncomingRequestPopup;
  Map<String, dynamic>? _incomingAlertData;
  Map<String, dynamic>? get incomingAlertData => _incomingAlertData;

  // ─── No drivers available flag ───
  bool _noDriversAvailable = false;
  bool get noDriversAvailable => _noDriversAvailable;

  // ─── Booking creation time ───
  DateTime? _bookingCreatedAt;
  DateTime? get bookingCreatedAt => _bookingCreatedAt;

  // ─── Load saved configurations ───
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final roleStr = prefs.getString('user_role');
    if (roleStr == 'driver') {
      _currentRole = UserRole.driver;
    } else {
      _currentRole = UserRole.patient;
    }
    notifyListeners();
  }

  // ─── Register socket event handlers ───
  void _registerSocketHandlers() {
    final socket = SocketService.instance;

    // Patient: a driver accepted our booking
    socket.onBookingAccepted = (data) {
      debugPrint('[BookingState] booking-accepted: $data');
      _status = BookingStatus.accepted;
      _showIncomingRequestPopup = false;

      // Extract driver info from the booking response
      final booking = data['booking'];
      if (booking != null && booking is Map) {
        // The booking response contains driver info
        // The populated driverId field contains driver user details
        if (booking['driverId'] is Map) {
          final driverData = booking['driverId'] as Map;
          _driverName = driverData['fullName']?.toString() ?? 'Driver';
          _driverPhone = driverData['phone']?.toString() ?? '';
        }
      }

      notifyListeners();

      // Fetch route directions for live tracking
      fetchDirections();
    };

    // Patient: real-time driver location updates
    socket.onDriverLocationChanged = (data) {
      _driverLat = (data['latitude'] as num?)?.toDouble() ?? _driverLat;
      _driverLng = (data['longitude'] as num?)?.toDouble() ?? _driverLng;
      notifyListeners();
    };

    // Both: booking status transitions (enRoute, arrived, completed)
    socket.onBookingStatusChanged = (data) {
      final statusStr = data['status']?.toString();
      debugPrint('[BookingState] booking-status-changed: $statusStr');
      switch (statusStr) {
        case 'enRoute':
          _status = BookingStatus.enRoute;
          break;
        case 'arrived':
          _status = BookingStatus.arrived;
          break;
        case 'completed':
          _status = BookingStatus.completed;
          break;
      }
      notifyListeners();
    };

    // Driver: incoming booking alert from matchmaker
    socket.onIncomingBookingAlert = (data) {
      debugPrint('[BookingState] incoming-booking-alert: $data');
      _incomingAlertData = data;
      _showIncomingRequestPopup = true;
      _bookingId = data['bookingId']?.toString();
      _serviceType = data['serviceType']?.toString() ?? 'Basic Life Support';
      _pickupAddress = data['pickupAddress']?.toString() ?? '';
      _estimatedFare = (data['estimatedFare'] as num?)?.toDouble() ?? 0;
      _patientName = data['patientName']?.toString() ?? 'Patient';
      notifyListeners();
    };

    // Patient: no drivers available
    socket.onNoDriversAvailable = (data) {
      debugPrint('[BookingState] no-drivers-available');
      _noDriversAvailable = true;
      _status = BookingStatus.idle;
      notifyListeners();
    };

    // Both: booking cancelled by the other party
    socket.onBookingCancelled = (data) {
      debugPrint('[BookingState] booking-cancelled: $data');
      _status = BookingStatus.idle;
      _bookingId = null;
      _showIncomingRequestPopup = false;
      notifyListeners();
    };

    // Driver: accept booking failed
    socket.onAcceptBookingFailed = (data) {
      debugPrint('[BookingState] accept-booking-failed: ${data['message']}');
      _showIncomingRequestPopup = false;
      notifyListeners();
    };
  }

  // ─── Set the current logged in role ───
  Future<void> setRole(UserRole role) async {
    _currentRole = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role.name);
    notifyListeners();
  }

  // ─── Set patient details ───
  void setPatientDetails({required String name, required String phone}) {
    _patientName = name;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════
  //  PATIENT ACTIONS
  // ═══════════════════════════════════════════════════════

  /// Create a booking request via the REST API.
  /// For emergency bookings, the backend triggers matchmaking automatically.
  Future<void> requestBooking({
    required String serviceType,
    bool isEmergency = true,
    String? pickupAddress,
    double? latitude,
    double? longitude,
    double? estimatedFare,
    DateTime? scheduledTime,
  }) async {
    _status = BookingStatus.searching;
    _serviceType = serviceType;
    _noDriversAvailable = false;
    _pickupAddress = pickupAddress ?? '';
    _patientLat = latitude ?? _patientLat;
    _patientLng = longitude ?? _patientLng;
    _estimatedFare = estimatedFare ?? 1200;
    _driverName = "";
    _driverPhone = "";
    _routePoints = [];
    notifyListeners();

    try {
      final result = await BookingService.instance.createBooking(
        serviceType: serviceType,
        pickupAddress: _pickupAddress.isNotEmpty
            ? _pickupAddress
            : '${_patientLat.toStringAsFixed(4)}, ${_patientLng.toStringAsFixed(4)}',
        latitude: _patientLat,
        longitude: _patientLng,
        estimatedFare: _estimatedFare,
        isEmergency: isEmergency,
        scheduledTime: scheduledTime,
      );

      final booking = result['booking'] as Map<String, dynamic>?;
      _bookingId = booking?['id']?.toString() ?? booking?['_id']?.toString();
      _bookingCreatedAt = DateTime.now();
      debugPrint('[BookingState] Booking created: $_bookingId');
      notifyListeners();
    } on DioException catch (e) {
      debugPrint('[BookingState] Error creating booking: ${e.response?.data}');
      _status = BookingStatus.idle;
      notifyListeners();
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════
  //  DRIVER ACTIONS
  // ═══════════════════════════════════════════════════════

  /// Driver accepts the incoming booking alert.
  void acceptBooking() {
    if (_bookingId != null) {
      SocketService.instance.emitAcceptBooking(_bookingId!);
      _showIncomingRequestPopup = false;
      // Status will be updated by the server via 'booking-accepted' event
      notifyListeners();
    }
  }

  /// Driver declines the incoming booking alert.
  void declineBooking() {
    if (_bookingId != null) {
      SocketService.instance.emitDeclineBooking(_bookingId!);
      _showIncomingRequestPopup = false;
      _incomingAlertData = null;
      notifyListeners();
    }
  }

  /// Driver starts transit (enRoute).
  void startEnRoute() {
    if (_bookingId != null) {
      SocketService.instance.emitStartTransit(_bookingId!);
      // Status will be updated by the server via 'booking-status-changed' event
    }
  }

  /// Driver marks arrival.
  void markArrived() {
    if (_bookingId != null) {
      SocketService.instance.emitDriverArrived(_bookingId!);
    }
  }

  /// Driver completes the trip.
  void completeBooking() {
    if (_bookingId != null) {
      SocketService.instance.emitCompleteTrip(_bookingId!);
    }
  }

  // ═══════════════════════════════════════════════════════
  //  SHARED ACTIONS
  // ═══════════════════════════════════════════════════════

  /// Cancel booking via REST API.
  Future<void> cancelBooking() async {
    if (_bookingId != null) {
      try {
        await BookingService.instance.cancelBooking(_bookingId!);
      } catch (e) {
        debugPrint('[BookingState] Error cancelling: $e');
      }
    }
    _status = BookingStatus.idle;
    _bookingId = null;
    _showIncomingRequestPopup = false;
    _incomingAlertData = null;
    notifyListeners();
  }

  /// Reset booking state.
  void reset() {
    _status = BookingStatus.idle;
    _bookingId = null;
    _showIncomingRequestPopup = false;
    _incomingAlertData = null;
    _noDriversAvailable = false;
    notifyListeners();
  }

  /// Clear the "no drivers" flag.
  void clearNoDriversFlag() {
    _noDriversAvailable = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════
  //  MAPS & DIRECTIONS
  // ═══════════════════════════════════════════════════════

  /// Open Google Maps navigation (Driver).
  Future<void> launchGoogleMaps() async {
    final String googleMapsUrl = "google.navigation:q=$patientLat,$patientLng";
    final Uri googleMapsUri = Uri.parse(googleMapsUrl);
    final String fallbackUrl = "https://www.google.com/maps/search/?api=1&query=$patientLat,$patientLng";
    final Uri fallbackUri = Uri.parse(fallbackUrl);

    try {
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri);
      } else if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch Google Maps");
      }
    } catch (e) {
      debugPrint("Error launching maps: $e");
    }
  }

  /// Fetch route directions from Google Directions API.
  Future<void> fetchDirections() async {
    if (_driverLat == 0 && _driverLng == 0) return;

    const String apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: 'AIzaSyAVqtwumIuyVmoiTa7yl0A7qOtHV7EEjZs');
    final String url = "https://maps.googleapis.com/maps/api/directions/json"
        "?origin=$_driverLat,$_driverLng"
        "&destination=$patientLat,$patientLng"
        "&key=$apiKey";

    try {
      final dio = Dio();
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data["status"] == "OK") {
          final routes = data["routes"] as List;
          if (routes.isNotEmpty) {
            final overviewPolyline = routes[0]["overview_polyline"];
            final pointsStr = overviewPolyline["points"] as String;
            _routePoints = decodePolyline(pointsStr);
            debugPrint("Successfully fetched Directions API route: ${_routePoints.length} points");
            notifyListeners();
            return;
          }
        } else {
          debugPrint("Directions API error status: ${data["status"]}");
        }
      }
    } catch (e) {
      debugPrint("Error fetching directions: $e");
    }
  }

  /// Decode Google polyline format into list of coordinates.
  List<List<double>> decodePolyline(String encoded) {
    List<List<double>> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add([lat / 1E5, lng / 1E5]);
    }
    return points;
  }

}
