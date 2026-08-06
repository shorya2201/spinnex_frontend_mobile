import 'dart:convert';
import 'package:get/get.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

// ─────────────────────────────────────────────────────────────────
// StompService – manages a single STOMP WebSocket connection
// Registered as a permanent GetxService so it survives route changes.
// ─────────────────────────────────────────────────────────────────

class StompService extends GetxService {
  static const String _wsUrl = 'wss://spinnex-backend-dev.onrender.com/ws';

  // ── Reactive state ─────────────────────────────────────────────
  final isConnected = false.obs;

  // ── Internal ───────────────────────────────────────────────────
  StompClient? _client;

  // Pending subscriptions to apply once connected.
  final List<_PendingSubscription> _pendingSubscriptions = [];

  // Active STOMP unsubscribe handles keyed by destination.
  final Map<String, StompUnsubscribe> _activeSubs = {};

  // ── Lifecycle ──────────────────────────────────────────────────

  /// Call this once before any room operation. Safe to call multiple times.
  void connect() {
    if (_client != null && isConnected.value) return;

    _client = StompClient(
      config: StompConfig(
        url: _wsUrl,
        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
        onWebSocketError: (dynamic error) {
          print('[STOMP] WebSocket error: $error');
          isConnected.value = false;
        },
        onStompError: (StompFrame frame) {
          print('[STOMP] STOMP error: ${frame.body}');
        },
        onUnhandledFrame: (StompFrame frame) {
          print('[STOMP] Unhandled frame: ${frame.command}');
        },
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _client!.activate();
  }

  void _onConnect(StompFrame frame) {
    print('[STOMP] Connected ✓');
    isConnected.value = true;

    // Flush any subscriptions requested before connection was ready.
    for (final ps in _pendingSubscriptions) {
      _doSubscribe(ps.destination, ps.callback);
    }
    _pendingSubscriptions.clear();
  }

  void _onDisconnect(StompFrame frame) {
    print('[STOMP] Disconnected');
    isConnected.value = false;
  }

  // ── Public API ─────────────────────────────────────────────────

  /// Subscribe to a STOMP topic. If not yet connected the subscription is
  /// queued and applied as soon as the connection is established.
  void subscribe(String destination, void Function(Map<String, dynamic>) callback) {
    if (isConnected.value) {
      _doSubscribe(destination, callback);
    } else {
      _pendingSubscriptions.add(_PendingSubscription(destination, callback));
    }
  }

  void _doSubscribe(String destination, void Function(Map<String, dynamic>) callback) {
    // Unsubscribe existing handle for this destination first (idempotent).
    _activeSubs[destination]?.call();

    final unsub = _client!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        if (frame.body != null && frame.body!.isNotEmpty) {
          try {
            final data = jsonDecode(frame.body!) as Map<String, dynamic>;
            callback(data);
          } catch (e) {
            print('[STOMP] JSON parse error on $destination: $e');
          }
        }
      },
    );
    _activeSubs[destination] = unsub;
    print('[STOMP] Subscribed to $destination');
  }

  /// Unsubscribe from a specific topic.
  void unsubscribe(String destination) {
    _activeSubs[destination]?.call();
    _activeSubs.remove(destination);
  }

  /// Send a message to a STOMP destination.
  void send(String destination, Map<String, dynamic> body) {
    if (_client == null || !isConnected.value) {
      print('[STOMP] Cannot send – not connected');
      return;
    }
    _client!.send(
      destination: destination,
      body: jsonEncode(body),
      headers: {'content-type': 'application/json'},
    );
    print('[STOMP] Sent → $destination: ${jsonEncode(body)}');
  }

  /// ── Convenience send helpers matching the backend spec ─────────

  void sendApproval({
    required String roomCode,
    required String hostId,
    required String guestPlayerId,
    required bool approve,
  }) {
    send('/app/room.approve', {
      'roomCode': roomCode,
      'hostId': hostId,
      'guestPlayerId': guestPlayerId,
      'approve': approve,
    });
  }

  void sendSpin({
    required String roomCode,
    required String playerId,
    required String category,
    required String questionType,
  }) {
    send('/app/room.spin', {
      'roomCode': roomCode,
      'playerId': playerId,
      'category': category,
      'questionType': questionType,
    });
  }

  void sendLeave({required String roomCode, required String playerId}) {
    send('/app/room.leave', {
      'roomCode': roomCode,
      'playerId': playerId,
    });
  }

  void sendStartGame({required String roomCode, required String hostId}) {
    send('/app/room.start', {
      'roomCode': roomCode,
      'hostId': hostId,
    });
  }

  /// Disconnect and clean up all subscriptions.
  void disconnect() {
    for (final unsub in _activeSubs.values) {
      unsub();
    }
    _activeSubs.clear();
    _pendingSubscriptions.clear();
    _client?.deactivate();
    _client = null;
    isConnected.value = false;
    print('[STOMP] Deactivated');
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}

// ─────────────────────────────────────────────────────────────────
// Internal helper
// ─────────────────────────────────────────────────────────────────

class _PendingSubscription {
  final String destination;
  final void Function(Map<String, dynamic>) callback;
  _PendingSubscription(this.destination, this.callback);
}
