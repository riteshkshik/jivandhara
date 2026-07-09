import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

/// Singleton service that handles all authentication REST calls.
///
/// Stores JWT token, user data, and role in SharedPreferences so
/// the app can restore auth state across restarts.
class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  // ─── Cached state (loaded from SharedPreferences) ───
  String? _token;
  String? _userId;
  String? _role;
  String? _email;
  String? _fullName;
  String? _phone;
  String? _profileImageUrl;

  // ─── Public getters ───
  String? get token => _token;
  String? get userId => _userId;
  String? get role => _role;
  String? get email => _email;
  String? get fullName => _fullName;
  String? get phone => _phone;
  String? get profileImageUrl => _profileImageUrl;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  // ─── Initialize (call once on app start) ───
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userId = prefs.getString('auth_user_id');
    _role = prefs.getString('auth_role');
    _email = prefs.getString('auth_email');
    _fullName = prefs.getString('auth_full_name');
    _phone = prefs.getString('auth_phone');
    _profileImageUrl = prefs.getString('auth_profile_image_url');
  }

  // ─── Signup ───
  /// Returns the full response body on success.
  /// Throws [DioException] on network / server errors.
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    required String gender,
    required String address,
    required String pincode,
    String? profileImageUrl,
    // Driver-specific optional fields
    String? vehicleRegNo,
    String? vehicleType,
    String? experience,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'gender': gender,
      'address': address,
      'pincode': pincode,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (vehicleRegNo != null) 'vehicleRegNo': vehicleRegNo,
      if (vehicleType != null) 'vehicleType': vehicleType,
      if (experience != null) 'experience': experience,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };

    final response = await _dio.post('/api/auth/signup', data: body);
    final data = response.data as Map<String, dynamic>;

    debugPrint('[AuthService] signup success for $email');
    return data;
  }

  // ─── Login ───
  /// Returns the full response body including `token` and `user`.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;

    // Extract token + user from response
    final token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;

    await _persistAuth(
      token: token,
      userId: user['id']?.toString() ?? '',
      role: user['role'] as String? ?? 'patient',
      email: user['email'] as String? ?? '',
      fullName: user['fullName'] as String? ?? '',
      phone: user['phone'] as String? ?? '',
      profileImageUrl: user['profileImageUrl'] as String?,
    );

    debugPrint('[AuthService] login success for $email (role: $_role)');
    return data;
  }

  // ─── Logout ───
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _role = null;
    _email = null;
    _fullName = null;
    _phone = null;
    _profileImageUrl = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user_id');
    await prefs.remove('auth_role');
    await prefs.remove('auth_email');
    await prefs.remove('auth_full_name');
    await prefs.remove('auth_phone');
    await prefs.remove('auth_profile_image_url');

    debugPrint('[AuthService] logged out');
  }

  /// Update cached profile fields (called after profile API update).
  Future<void> updateCachedProfile({
    String? fullName,
    String? phone,
    String? profileImageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (fullName != null) {
      _fullName = fullName;
      await prefs.setString('auth_full_name', fullName);
    }
    if (phone != null) {
      _phone = phone;
      await prefs.setString('auth_phone', phone);
    }
    if (profileImageUrl != null) {
      _profileImageUrl = profileImageUrl;
      await prefs.setString('auth_profile_image_url', profileImageUrl);
    }
  }

  // ─── Internal ───
  Future<void> _persistAuth({
    required String token,
    required String userId,
    required String role,
    required String email,
    required String fullName,
    required String phone,
    String? profileImageUrl,
  }) async {
    _token = token;
    _userId = userId;
    _role = role;
    _email = email;
    _fullName = fullName;
    _phone = phone;
    _profileImageUrl = profileImageUrl;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('auth_user_id', userId);
    await prefs.setString('auth_role', role);
    await prefs.setString('auth_email', email);
    await prefs.setString('auth_full_name', fullName);
    await prefs.setString('auth_phone', phone);
    if (profileImageUrl != null) {
      await prefs.setString('auth_profile_image_url', profileImageUrl);
    }
  }
}
