import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class ParkingRealtimeService {
  ParkingRealtimeService({
    required this.onParkingUpdate,
    required this.onConnectionChanged,
  });

  static final Uri _webSocketUri = Uri.parse(
    'wss://smart-parking-system-9mbk.onrender.com/ws/parking',
  );

  final void Function(Map<String, dynamic> data) onParkingUpdate;
  final void Function(bool connected) onConnectionChanged;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;

  bool _disposed = false;
  bool _connecting = false;
  bool _connected = false;
  int _reconnectDelaySeconds = 2;

  bool get isConnected => _connected;

  Future<void> connect() async {
    if (_disposed || _connecting || _connected) {
      return;
    }

    _connecting = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    try {
      final channel = WebSocketChannel.connect(_webSocketUri);

      await channel.ready;

      if (_disposed) {
        await channel.sink.close();
        return;
      }

      _channel = channel;
      _connected = true;
      _reconnectDelaySeconds = 2;
      onConnectionChanged(true);

      _subscription = channel.stream.listen(
        _handleMessage,
        onError: (_, _) => _handleDisconnect(),
        onDone: _handleDisconnect,
        cancelOnError: false,
      );
    } catch (_) {
      _connected = false;
      _channel = null;
      onConnectionChanged(false);
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  void _handleMessage(dynamic message) {
    if (_disposed) {
      return;
    }

    try {
      final decoded = jsonDecode(message.toString());

      if (decoded is! Map) {
        return;
      }

      final data = Map<String, dynamic>.from(decoded);
      final type = data['type']?.toString();

      if (type == 'parking_update') {
        onParkingUpdate(data);
      }
    } catch (_) {
      // Ignore malformed realtime messages.
    }
  }

  void _handleDisconnect() {
    if (_disposed) {
      return;
    }

    _subscription?.cancel();
    _subscription = null;

    _channel = null;

    if (_connected) {
      _connected = false;
      onConnectionChanged(false);
    }

    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnectTimer?.isActive == true) {
      return;
    }

    final delay = Duration(seconds: _reconnectDelaySeconds);

    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;

      if (!_disposed) {
        unawaited(connect());
      }
    });

    _reconnectDelaySeconds =
        (_reconnectDelaySeconds * 2).clamp(2, 30);
  }

  Future<void> disconnect() async {
    await _disconnect(notify: true);
  }

  void dispose() {
    _disposed = true;
    unawaited(_disconnect(notify: false));
  }

  Future<void> _disconnect({required bool notify}) async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _subscription?.cancel();
    _subscription = null;

    final channel = _channel;
    _channel = null;

    final wasConnected = _connected;
    _connected = false;
    _connecting = false;

    if (notify && wasConnected && !_disposed) {
      onConnectionChanged(false);
    }

    if (channel != null) {
      try {
        await channel.sink.close();
      } catch (_) {}
    }
  }
}
