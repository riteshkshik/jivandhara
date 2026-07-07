import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import '../presentation/sign_up_login_screen/sign_up_login_screen.dart' show UserRole;

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
  }

  // Active User Role
  UserRole _currentRole = UserRole.patient;
  UserRole get currentRole => _currentRole;

  // Active Booking state
  BookingStatus _status = BookingStatus.idle;
  BookingStatus get status => _status;

  String? _bookingId;
  String? get bookingId => _bookingId;

  String _patientName = "Priya Sharma";
  String get patientName => _patientName;

  final String _pickupAddress = "14B, MG Road, Bengaluru — 560001";
  String get pickupAddress => _pickupAddress;

  String _serviceType = "Basic Life Support";
  String get serviceType => _serviceType;

  final String _estimatedFare = "₹1,200";
  String get estimatedFare => _estimatedFare;

  // Coordinates
  // Patient Location: Bengaluru MG Road
  final double patientLat = 12.9716;
  final double patientLng = 77.5946;

  // Driver Location (Starts at some offset, moves towards patient)
  double _driverLat = 12.9850;
  double _driverLng = 77.6080;
  double get driverLat => _driverLat;
  double get driverLng => _driverLng;

  // Real route coordinates snapped to roads
  List<List<double>> _routePoints = [];
  List<List<double>> get routePoints => _routePoints;

  // Driver Info
  final String driverName = "Rajesh Kumar";
  final String driverPhone = "+91 98765 43210";
  final String driverRating = "4.8";
  final String vehicleRegNo = "KA 01 AB 2345";
  final String experience = "8+ years experience";

  Timer? _simulationTimer;
  int _simulationStep = 0;

  // Load saved configurations
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

  // Simulated Driver app popup trigger
  bool _showIncomingRequestPopup = false;
  bool get showIncomingRequestPopup => _showIncomingRequestPopup;

  Timer? _ringTimer;

  // Set the current logged in role
  Future<void> setRole(UserRole role) async {
    _currentRole = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role.name);
    notifyListeners();
  }

  // Set patient details
  void setPatientDetails({required String name, required String phone}) {
    _patientName = name;
    notifyListeners();
  }

  // Start booking request (Patient)
  void requestBooking({required String serviceType, bool isEmergency = false}) {
    _status = BookingStatus.searching;
    _serviceType = serviceType;
    final now = DateTime.now();
    _bookingId = "JVN-${now.year}${(now.month).toString().padLeft(2, '0')}${(now.day).toString().padLeft(2, '0')}-${(100 + now.millisecond % 900)}";
    
    // Reset driver location to starting offset
    _driverLat = 12.9850;
    _driverLng = 77.6080;
    _simulationStep = 0;
    _routePoints = [];
    _showIncomingRequestPopup = false;
    _ringTimer?.cancel();
    _stopSimulation();

    // Trigger driver app ringing simulation after 4 seconds
    _ringTimer = Timer(const Duration(seconds: 4), () {
      if (_status == BookingStatus.searching) {
        _showIncomingRequestPopup = true;
        notifyListeners();
      }
    });

    notifyListeners();
  }

  // Accept Booking (Driver)
  void acceptBooking() {
    if (_status == BookingStatus.searching || _status == BookingStatus.idle) {
      _status = BookingStatus.accepted;
      _showIncomingRequestPopup = false;
      _ringTimer?.cancel();
      notifyListeners();

      // Automatically start navigating after 2 seconds
      Timer(const Duration(seconds: 2), () {
        if (_status == BookingStatus.accepted) {
          startEnRoute();
        }
      });
    }
  }

  // Start navigation / En Route (Driver)
  void startEnRoute() async {
    if (_status == BookingStatus.accepted) {
      _status = BookingStatus.enRoute;
      notifyListeners();
      await fetchDirections();
      _startSimulation();
    }
  }

  // Cancel Booking
  void cancelBooking() {
    _status = BookingStatus.idle;
    _bookingId = null;
    _showIncomingRequestPopup = false;
    _ringTimer?.cancel();
    _stopSimulation();
    notifyListeners();
  }

  // Reset booking (to request again)
  void reset() {
    _status = BookingStatus.idle;
    _bookingId = null;
    _showIncomingRequestPopup = false;
    _ringTimer?.cancel();
    _stopSimulation();
    notifyListeners();
  }

  // Open Google Maps navigation (Driver app launcher)
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

  // Fetch route directions from Google Directions API
  Future<void> fetchDirections() async {
    const String apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: 'AIzaSyAVqtwumIuyVmoiTa7yl0A7qOtHV7EEjZs');
    final String url = "https://maps.googleapis.com/maps/api/directions/json"
        "?origin=12.9850,77.6080"
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
            return;
          }
        } else {
          debugPrint("Directions API error status: ${data["status"]}");
        }
      }
    } catch (e) {
      debugPrint("Error fetching directions: $e");
    }
    // Fallback: If API call fails, generate a simple mock route
    _generateFallbackRoute();
  }

  void _generateFallbackRoute() {
    _routePoints = [];
    const double startLat = 12.9850;
    const double startLng = 77.6080;
    const int steps = 15;
    for (int i = 0; i <= steps; i++) {
      final double fraction = i / steps;
      final double lat = startLat + (patientLat - startLat) * fraction;
      final double lng = startLng + (patientLng - startLng) * fraction;
      _routePoints.add([lat, lng]);
    }
    debugPrint("Generated fallback route: ${_routePoints.length} points");
  }

  // Decode Google polyline format into list of coordinates
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

  // Driver Location Simulation
  void _startSimulation() {
    _stopSimulation();
    _simulationStep = 0;

    // Start coordinate simulation en route
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_status != BookingStatus.enRoute) {
        _stopSimulation();
        return;
      }

      if (_routePoints.isEmpty) {
        _generateFallbackRoute();
      }

      _simulationStep++;
      if (_simulationStep >= _routePoints.length) {
        _driverLat = patientLat;
        _driverLng = patientLng;
        _status = BookingStatus.arrived;
        _stopSimulation();
      } else {
        final point = _routePoints[_simulationStep];
        _driverLat = point[0];
        _driverLng = point[1];
      }
      notifyListeners();
    });
  }

  void _stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  void completeBooking() {
    _status = BookingStatus.completed;
    _stopSimulation();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopSimulation();
    super.dispose();
  }
}
