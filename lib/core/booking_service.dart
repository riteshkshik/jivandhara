import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_config.dart';
import 'auth_service.dart';

/// Service for booking-related REST API calls.
class BookingService {
  BookingService._internal();
  static final BookingService instance = BookingService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  /// Helper to build auth header from the current token.
  Map<String, String> get _authHeaders {
    final token = AuthService.instance.token;
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Create a new booking.
  ///
  /// For emergency bookings, the backend will automatically start matchmaking.
  /// Returns the created booking data including the generated booking ID.
  Future<Map<String, dynamic>> createBooking({
    required String serviceType,
    required String pickupAddress,
    required double latitude,
    required double longitude,
    required double estimatedFare,
    bool isEmergency = true,
    DateTime? scheduledTime,
  }) async {
    final body = <String, dynamic>{
      'serviceType': serviceType,
      'pickupAddress': pickupAddress,
      'latitude': latitude,
      'longitude': longitude,
      'estimatedFare': estimatedFare,
      'isEmergency': isEmergency,
      if (scheduledTime != null) 'scheduledTime': scheduledTime.toIso8601String(),
    };

    final response = await _dio.post(
      '/api/bookings',
      data: body,
      options: Options(headers: _authHeaders),
    );

    final data = response.data as Map<String, dynamic>;
    debugPrint('[BookingService] createBooking success: ${data['booking']?['id'] ?? data['booking']?['_id']}');
    return data;
  }

  /// Fetch all bookings for the current user (filtered by role on server).
  Future<List<dynamic>> getBookings() async {
    final response = await _dio.get(
      '/api/bookings',
      options: Options(headers: _authHeaders),
    );

    final data = response.data as Map<String, dynamic>;
    final bookings = data['bookings'] as List<dynamic>? ?? [];
    debugPrint('[BookingService] getBookings returned ${bookings.length} bookings');
    return bookings;
  }

  /// Fetch a single booking by its ID.
  Future<Map<String, dynamic>> getBookingById(String id) async {
    final response = await _dio.get(
      '/api/bookings/$id',
      options: Options(headers: _authHeaders),
    );

    final data = response.data as Map<String, dynamic>;
    debugPrint('[BookingService] getBookingById($id) success');
    return data['booking'] as Map<String, dynamic>;
  }

  /// Cancel a booking by its ID.
  Future<Map<String, dynamic>> cancelBooking(String id) async {
    final response = await _dio.put(
      '/api/bookings/$id/cancel',
      options: Options(headers: _authHeaders),
    );

    final data = response.data as Map<String, dynamic>;
    debugPrint('[BookingService] cancelBooking($id) success');
    return data;
  }
}
