import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/environment_config.dart';
import '../models/sse_events.dart';
import '../utils/logger.dart';

/// SSE Service Configuration
class SSEConfig {
  static const int maxReconnectAttempts = 5;
  static const int baseReconnectDelayMs = 2000;
  static const int connectionTimeoutMs = 30000;
}

/// Base SSE Service
///
/// Handles Server-Sent Events connections with automatic reconnection.
/// Uses Dio for HTTP streaming with Firebase token authentication.
abstract class SSEService {
  final String _tag;

  Dio? _dio;
  CancelToken? _cancelToken;
  StreamSubscription<List<int>>? _subscription;

  SSEConnectionState _connectionState = SSEConnectionState.disconnected;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  bool _isConnecting = false; // Prevent concurrent connects
  bool _disposed = false;

  // Stream controllers
  StreamController<SSEEvent>? _eventController;
  StreamController<SSEConnectionState>? _stateController;

  // Buffer overflow protection
  static const int _maxBufferSize = 1024 * 1024; // 1MB

  /// Stream of SSE events
  Stream<SSEEvent> get events {
    _ensureNotDisposed();
    if (_eventController == null || _eventController!.isClosed) {
      _eventController = StreamController<SSEEvent>.broadcast();
    }
    return _eventController!.stream;
  }

  /// Stream of connection state changes
  Stream<SSEConnectionState> get connectionState {
    _ensureNotDisposed();
    if (_stateController == null || _stateController!.isClosed) {
      _stateController = StreamController<SSEConnectionState>.broadcast();
    }
    return _stateController!.stream;
  }

  /// Current connection state
  SSEConnectionState get currentState => _connectionState;

  /// Whether the service is connected
  bool get isConnected => _connectionState == SSEConnectionState.connected;

  SSEService({required String tag}) : _tag = tag;

  /// Ensure service is not disposed
  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('[$_tag] Service has been disposed');
    }
  }

  /// Get the SSE endpoint URL (to be implemented by subclasses)
  String getEndpoint();

  /// Connect to the SSE stream
  Future<void> connect() async {
    _ensureNotDisposed();

    // Prevent concurrent connection attempts
    if (_isConnecting) {
      AppLogger.warning('[$_tag] Connection already in progress', tag: _tag);
      return;
    }

    if (_connectionState == SSEConnectionState.connected) {
      AppLogger.warning('[$_tag] Already connected', tag: _tag);
      return;
    }

    _isConnecting = true;
    _updateState(SSEConnectionState.connecting);
    AppLogger.info('[$_tag] Connecting to SSE...', tag: _tag);

    try {
      final token = await _getFirebaseToken();
      if (token == null) {
        AppLogger.error('[$_tag] No Firebase token available', tag: _tag);
        _updateState(SSEConnectionState.error);
        _isConnecting = false;
        return;
      }

      final endpoint = getEndpoint();
      final url = '${EnvironmentConfig.apiBaseUrl}$endpoint?token=${Uri.encodeComponent(token)}';

      _dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(hours: 24), // SSE streams stay open
      ));
      _cancelToken = CancelToken();

      final response = await _dio!.get<ResponseBody>(
        url,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
          },
        ),
        cancelToken: _cancelToken,
      );

      _updateState(SSEConnectionState.connected);
      _reconnectAttempts = 0;
      _isConnecting = false;
      AppLogger.info('[$_tag] SSE connected successfully', tag: _tag);

      // Listen to the stream
      _subscription = response.data?.stream.listen(
        _handleData,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: false,
      );
    } catch (e, stackTrace) {
      AppLogger.error('[$_tag] Connection error: $e', tag: _tag);
      AppLogger.error('[$_tag] Stack trace: $stackTrace', tag: _tag);

      // Clean up resources on failure
      _cancelToken?.cancel();
      _cancelToken = null;
      _dio?.close();
      _dio = null;
      _isConnecting = false;

      _handleConnectionError();
    }
  }

  /// Disconnect from the SSE stream
  Future<void> disconnect() async {
    AppLogger.info('[$_tag] Disconnecting...', tag: _tag);

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _cancelToken?.cancel('Manual disconnect');
    _cancelToken = null;

    await _subscription?.cancel();
    _subscription = null;

    _dio?.close();
    _dio = null;

    _reconnectAttempts = 0;
    _isConnecting = false;
    _buffer = '';
    _updateState(SSEConnectionState.disconnected);
  }

  /// Get Firebase ID token
  Future<String?> _getFirebaseToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      return await user.getIdToken();
    } catch (e) {
      AppLogger.error('[$_tag] Error getting Firebase token: $e', tag: _tag);
      return null;
    }
  }

  /// Buffer for incomplete SSE data
  String _buffer = '';

  /// Handle incoming data
  void _handleData(List<int> data) {
    final chunk = utf8.decode(data);

    // Buffer overflow protection
    if (_buffer.length + chunk.length > _maxBufferSize) {
      AppLogger.error(
        '[$_tag] Buffer overflow detected, clearing buffer',
        tag: _tag,
      );
      _buffer = '';
      return;
    }

    _buffer += chunk;

    // Process complete events (separated by double newline)
    while (_buffer.contains('\n\n')) {
      final eventEndIndex = _buffer.indexOf('\n\n');
      final eventData = _buffer.substring(0, eventEndIndex);
      _buffer = _buffer.substring(eventEndIndex + 2);

      _processEvent(eventData);
    }
  }

  /// Process a single SSE event
  void _processEvent(String eventData) {
    if (eventData.trim().isEmpty) return;

    String? eventType;
    String? data;

    // Parse SSE format: "event: type\ndata: {json}"
    for (final line in eventData.split('\n')) {
      if (line.startsWith('event:')) {
        eventType = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        data = line.substring(5).trim();
      }
    }

    // Handle keepalive (just ":" or empty data)
    if (eventData.trim() == ':' || data == null || data.isEmpty) {
      return;
    }

    try {
      final json = jsonDecode(data) as Map<String, dynamic>;

      // Add event type from SSE header if not in JSON
      if (eventType != null && !json.containsKey('type')) {
        json['type'] = eventType;
      }

      final event = SSEEvent.fromJson(json);

      // Skip keepalive events from being broadcast
      if (event.type == SSEEventType.keepalive) {
        return;
      }

      AppLogger.debug('[$_tag] Received event: ${event.type.value}', tag: _tag);
      _eventController?.add(event);
    } catch (e) {
      AppLogger.warning('[$_tag] Error parsing event: $e, data: $data', tag: _tag);
    }
  }

  /// Handle stream error
  void _handleError(Object error) {
    AppLogger.error('[$_tag] Stream error: $error', tag: _tag);
    _handleConnectionError();
  }

  /// Handle stream done (connection closed)
  void _handleDone() {
    AppLogger.warning('[$_tag] Stream closed', tag: _tag);
    if (_connectionState != SSEConnectionState.disconnected) {
      _handleConnectionError();
    }
  }

  /// Handle connection error with reconnection logic
  void _handleConnectionError() {
    if (_connectionState == SSEConnectionState.disconnected) {
      return;
    }

    _subscription?.cancel();
    _subscription = null;
    _dio?.close();
    _dio = null;

    if (_reconnectAttempts >= SSEConfig.maxReconnectAttempts) {
      AppLogger.error('[$_tag] Max reconnection attempts reached', tag: _tag);
      _updateState(SSEConnectionState.error);
      return;
    }

    _updateState(SSEConnectionState.reconnecting);

    // Exponential backoff
    final delay = SSEConfig.baseReconnectDelayMs * (1 << _reconnectAttempts);
    _reconnectAttempts++;

    AppLogger.info(
      '[$_tag] Reconnecting in ${delay}ms (attempt $_reconnectAttempts/${SSEConfig.maxReconnectAttempts})',
      tag: _tag,
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(milliseconds: delay), () async {
      await connect();
    });
  }

  /// Update connection state
  void _updateState(SSEConnectionState state) {
    if (_connectionState == state) return;
    _connectionState = state;
    _stateController?.add(state);
    AppLogger.debug('[$_tag] State changed: $state', tag: _tag);
  }

  /// Dispose the service
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    await disconnect();

    await _eventController?.close();
    _eventController = null;

    await _stateController?.close();
    _stateController = null;
  }
}
