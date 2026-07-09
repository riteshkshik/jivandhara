/// Centralized API configuration for the Jivandhara backend.
///
/// All networking code imports this file for base URLs.
/// When migrating to a live server, update these two constants
/// and every API / socket call will automatically use the new URL.
class ApiConfig {
  /// Base URL for REST API calls (Express server).
  static const String baseUrl = 'http://localhost:5000';

  /// Base URL for Socket.io connections.
  static const String socketUrl = 'http://localhost:5000';
}
