import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_config.dart';
import 'auth_service.dart';

/// Service for profile-related REST API calls.
class ProfileService {
  ProfileService._internal();
  static final ProfileService instance = ProfileService._internal();

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

  /// Fetch the current user's profile from the server.
  ///
  /// Returns a map with `user` (and optionally `driverProfile` for drivers).
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get(
      '/api/profile',
      options: Options(headers: _authHeaders),
    );
    debugPrint('[ProfileService] getProfile success');
    return response.data as Map<String, dynamic>;
  }

  /// Update the current user's profile fields.
  ///
  /// Only pass the fields you want to update; omitted fields remain unchanged.
  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? phone,
    String? address,
    String? pincode,
    String? gender,
    String? profileImageUrl,
    // Driver-specific
    String? vehicleRegNo,
    String? vehicleType,
    String? experience,
    bool? isOnline,
    bool? isBusy,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      if (fullName != null) 'fullName': fullName,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (pincode != null) 'pincode': pincode,
      if (gender != null) 'gender': gender,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (vehicleRegNo != null) 'vehicleRegNo': vehicleRegNo,
      if (vehicleType != null) 'vehicleType': vehicleType,
      if (experience != null) 'experience': experience,
      if (isOnline != null) 'isOnline': isOnline,
      if (isBusy != null) 'isBusy': isBusy,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };

    final response = await _dio.put(
      '/api/profile',
      data: body,
      options: Options(headers: _authHeaders),
    );

    final data = response.data as Map<String, dynamic>;
    debugPrint('[ProfileService] updateProfile success');

    // Also update the cached auth profile fields
    await AuthService.instance.updateCachedProfile(
      fullName: fullName,
      phone: phone,
      profileImageUrl: profileImageUrl,
    );

    return data;
  }
}
