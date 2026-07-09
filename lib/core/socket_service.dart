import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_config.dart';
import 'auth_service.dart';

/// Callback typedefs for socket event handlers.
typedef SocketEventCallback = void Function(Map<String, dynamic> data);

/// Singleton Socket.io client wrapper.
///
/// Manages the WebSocket connection lifecycle and exposes typed
/// emitters and listener registration methods for all booking events.
class SocketService {
  SocketService._internal();
  static final SocketService instance = SocketService._internal();

  io.Socket? _socket;

  /// Whether the socket is currently connected.
  bool get isConnected => _socket?.connected ?? false;

  // ─── Event callbacks (set by BookingState) ───
  SocketEventCallback? onIncomingBookingAlert;
  SocketEventCallback? onBookingAccepted;
  SocketEventCallback? onDriverLocationChanged;
  SocketEventCallback? onBookingStatusChanged;
  SocketEventCallback? onNoDriversAvailable;
  SocketEventCallback? onBookingCancelled;
  SocketEventCallback? onAcceptBookingFailed;
  SocketEventCallback? onErrorResponse;

  /// Connect to the Socket.io server using the stored JWT token.
  ///
  /// If already connected, disconnects first and reconnects.
  void connect({String? token}) {
    final authToken = token ?? AuthService.instance.token;
    if (authToken == null || authToken.isEmpty) {
      debugPrint('[SocketService] Cannot connect: no auth token');
      return;
    }

    // Disconnect any existing connection
    disconnect();

    debugPrint('[SocketService] Connecting to ${ApiConfig.socketUrl}');

    _socket = io.io(
      ApiConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': authToken})
          .build(),
    );

    // Register lifecycle handlers
    _socket!.onConnect((_) {
      debugPrint('[SocketService] Connected (socketId: ${_socket!.id})');
    });

    _socket!.onDisconnect((reason) {
      debugPrint('[SocketService] Disconnected: $reason');
    });

    _socket!.onConnectError((error) {
      debugPrint('[SocketService] Connection error: $error');
    });

    _socket!.onError((error) {
      debugPrint('[SocketService] Error: $error');
    });

    // Register booking event listeners
    _registerListeners();

    // Initiate connection
    _socket!.connect();
  }

  /// Disconnect cleanly from the Socket.io server.
  void disconnect() {
    if (_socket != null) {
      debugPrint('[SocketService] Disconnecting');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }

  // ═══════════════════════════════════════════════════════
  //  EMITTERS — Client → Server
  // ═══════════════════════════════════════════════════════

  /// Driver: send current GPS location to server.
  void emitLocationUpdate({required double latitude, required double longitude}) {
    _socket?.emit('driver-location-update', {
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  /// Driver: accept a booking alert.
  void emitAcceptBooking(String bookingId) {
    debugPrint('[SocketService] Emitting accept-booking: $bookingId');
    _socket?.emit('accept-booking', {'bookingId': bookingId});
  }

  /// Driver: decline a booking alert.
  void emitDeclineBooking(String bookingId) {
    debugPrint('[SocketService] Emitting decline-booking: $bookingId');
    _socket?.emit('decline-booking', {'bookingId': bookingId});
  }

  /// Driver: start transit (enRoute).
  void emitStartTransit(String bookingId) {
    debugPrint('[SocketService] Emitting start-transit: $bookingId');
    _socket?.emit('start-transit', {'bookingId': bookingId});
  }

  /// Driver: arrived at pickup location.
  void emitDriverArrived(String bookingId) {
    debugPrint('[SocketService] Emitting driver-arrived: $bookingId');
    _socket?.emit('driver-arrived', {'bookingId': bookingId});
  }

  /// Driver: complete the trip.
  void emitCompleteTrip(String bookingId) {
    debugPrint('[SocketService] Emitting complete-trip: $bookingId');
    _socket?.emit('complete-trip', {'bookingId': bookingId});
  }

  // ═══════════════════════════════════════════════════════
  //  LISTENERS — Server → Client
  // ═══════════════════════════════════════════════════════

  void _registerListeners() {
    if (_socket == null) return;

    // Driver receives an incoming booking alert from matchmaker
    _socket!.on('incoming-booking-alert', (data) {
      debugPrint('[SocketService] incoming-booking-alert: $data');
      final map = _toMap(data);
      if (map != null) onIncomingBookingAlert?.call(map);
    });

    // Patient: booking accepted by a driver
    _socket!.on('booking-accepted', (data) {
      debugPrint('[SocketService] booking-accepted: $data');
      final map = _toMap(data);
      if (map != null) onBookingAccepted?.call(map);
    });

    // Patient: driver's live location update
    _socket!.on('driver-location-changed', (data) {
      final map = _toMap(data);
      if (map != null) onDriverLocationChanged?.call(map);
    });

    // Both: booking status transition (enRoute, arrived, completed)
    _socket!.on('booking-status-changed', (data) {
      debugPrint('[SocketService] booking-status-changed: $data');
      final map = _toMap(data);
      if (map != null) onBookingStatusChanged?.call(map);
    });

    // Patient: no drivers available in 5km radius
    _socket!.on('no-drivers-available', (data) {
      debugPrint('[SocketService] no-drivers-available: $data');
      final map = _toMap(data);
      if (map != null) onNoDriversAvailable?.call(map);
    });

    // Both: booking cancelled by the other party
    _socket!.on('booking-cancelled', (data) {
      debugPrint('[SocketService] booking-cancelled: $data');
      final map = _toMap(data);
      if (map != null) onBookingCancelled?.call(map);
    });

    // Driver: accept-booking failed
    _socket!.on('accept-booking-failed', (data) {
      debugPrint('[SocketService] accept-booking-failed: $data');
      final map = _toMap(data);
      if (map != null) onAcceptBookingFailed?.call(map);
    });

    // Generic error
    _socket!.on('error-response', (data) {
      debugPrint('[SocketService] error-response: $data');
      final map = _toMap(data);
      if (map != null) onErrorResponse?.call(map);
    });
  }

  /// Safely convert socket event data to a Map.
  Map<String, dynamic>? _toMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    debugPrint('[SocketService] Unexpected data type: ${data.runtimeType}');
    return null;
  }
}
