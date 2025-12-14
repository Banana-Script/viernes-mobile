import 'dart:async';

import '../models/sse_events.dart';
import '../utils/logger.dart';
import 'sse_service.dart';

/// Callback type for SSE event subscribers
typedef SSEEventCallback = void Function(SSEEvent event);

/// Organization SSE Service
///
/// Singleton service that manages organization-level SSE connection.
/// Handles events like new conversations, agent assignments, and new messages.
///
/// Usage:
/// ```dart
/// final service = OrganizationSSEService.instance;
/// await service.connect(organizationId: 123, currentUserId: 456);
///
/// // Subscribe to specific events
/// final unsubscribe = service.subscribe(SSEEventType.newConversation, (event) {
///   print('New conversation: ${event.conversationId}');
/// });
///
/// // Subscribe to all events
/// service.subscribeAll((event) {
///   print('Event: ${event.type}');
/// });
///
/// // Unsubscribe
/// unsubscribe();
/// ```
class OrganizationSSEService extends SSEService {
  static OrganizationSSEService? _instance;

  int? _organizationId;
  int? _currentUserId;

  // Subscribers map: eventType -> Set<callbacks>
  final Map<SSEEventType, Set<SSEEventCallback>> _subscribers = {};
  final Set<SSEEventCallback> _allSubscribers = {};

  // Stream subscription for internal event handling
  StreamSubscription<SSEEvent>? _eventSubscription;

  OrganizationSSEService._() : super(tag: 'OrganizationSSE');

  /// Get the singleton instance
  static OrganizationSSEService get instance {
    _instance ??= OrganizationSSEService._();
    return _instance!;
  }

  /// Current organization ID
  int? get organizationId => _organizationId;

  /// Current user ID
  int? get currentUserId => _currentUserId;

  @override
  String getEndpoint() {
    if (_organizationId == null) {
      throw StateError('Organization ID not set');
    }
    return '/sse/organization/$_organizationId';
  }

  /// Connect to organization SSE with configuration
  Future<void> connectWithConfig({
    required int organizationId,
    required int currentUserId,
  }) async {
    // Disconnect if already connected to a different organization
    if (_organizationId != null && _organizationId != organizationId) {
      AppLogger.info(
        '[OrganizationSSE] Switching organization from $_organizationId to $organizationId',
        tag: 'OrganizationSSE',
      );
      await disconnect();
    }

    _organizationId = organizationId;
    _currentUserId = currentUserId;

    // Set up internal event handling
    _eventSubscription?.cancel();
    _eventSubscription = events.listen(_handleEvent);

    await connect();
  }

  @override
  Future<void> disconnect() async {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    await super.disconnect();
  }

  /// Handle incoming events and notify subscribers
  void _handleEvent(SSEEvent event) {
    // Filter agent_assigned events for current user only
    if (event is SSEAgentAssignedEvent) {
      if (_currentUserId != null && event.agentId != _currentUserId) {
        AppLogger.debug(
          '[OrganizationSSE] Ignoring agent_assigned for other user: ${event.agentId}',
          tag: 'OrganizationSSE',
        );
        return;
      }
    }

    // Notify specific subscribers
    final typeSubscribers = _subscribers[event.type];
    if (typeSubscribers != null) {
      for (final callback in typeSubscribers) {
        try {
          callback(event);
        } catch (e) {
          AppLogger.error(
            '[OrganizationSSE] Error in subscriber callback: $e',
            tag: 'OrganizationSSE',
          );
        }
      }
    }

    // Notify all-event subscribers
    for (final callback in _allSubscribers) {
      try {
        callback(event);
      } catch (e) {
        AppLogger.error(
          '[OrganizationSSE] Error in all-subscriber callback: $e',
          tag: 'OrganizationSSE',
        );
      }
    }
  }

  /// Subscribe to a specific event type
  ///
  /// Returns a function to unsubscribe
  VoidCallback subscribe(SSEEventType eventType, SSEEventCallback callback) {
    _subscribers.putIfAbsent(eventType, () => {});
    _subscribers[eventType]!.add(callback);

    AppLogger.debug(
      '[OrganizationSSE] Subscribed to ${eventType.value}',
      tag: 'OrganizationSSE',
    );

    // Return unsubscribe function
    return () {
      _subscribers[eventType]?.remove(callback);
      AppLogger.debug(
        '[OrganizationSSE] Unsubscribed from ${eventType.value}',
        tag: 'OrganizationSSE',
      );
    };
  }

  /// Subscribe to all events
  ///
  /// Returns a function to unsubscribe
  VoidCallback subscribeAll(SSEEventCallback callback) {
    _allSubscribers.add(callback);

    AppLogger.debug(
      '[OrganizationSSE] Subscribed to all events',
      tag: 'OrganizationSSE',
    );

    // Return unsubscribe function
    return () {
      _allSubscribers.remove(callback);
      AppLogger.debug(
        '[OrganizationSSE] Unsubscribed from all events',
        tag: 'OrganizationSSE',
      );
    };
  }

  /// Unsubscribe all callbacks
  void unsubscribeAll() {
    _subscribers.clear();
    _allSubscribers.clear();
    AppLogger.debug(
      '[OrganizationSSE] All subscribers removed',
      tag: 'OrganizationSSE',
    );
  }

  @override
  Future<void> dispose() async {
    unsubscribeAll();
    await super.dispose();
    _instance = null;
  }
}

/// Type alias for void callback
typedef VoidCallback = void Function();
