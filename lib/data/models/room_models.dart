
import 'question_model.dart';

// ─────────────────────────────────────────────────────────────────
// Enums matching the backend specification exactly
// ─────────────────────────────────────────────────────────────────

enum RoomStatus { LOBBY, PLAYING, FINISHED }

enum PlayerStatus { ACTIVE, PENDING, DENIED, DISCONNECTED }

enum EventType {
  ROOM_CREATED,
  PLAYER_JOINED,
  JOIN_REQUESTED,
  HOST_DECISION,
  PLAYER_LEFT,
  GAME_STARTED,
  SPIN_RESULT,
  ERROR,
}

enum GameCategory { CLASSIC, PARTY, SPICY }

extension GameCategoryX on GameCategory {
  String get serverValue => name; // "CLASSIC" | "PARTY" | "SPICY"

  /// Map the local UI display name → backend enum string.
  static GameCategory fromDisplayName(String display) {
    switch (display) {
      case 'Classic (Family)':
        return GameCategory.CLASSIC;
      case 'Spicy (Couples)':
        return GameCategory.SPICY;
      default:
        return GameCategory.PARTY;
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// REST – Create Room Response
// ─────────────────────────────────────────────────────────────────

class CreateRoomResponse {
  final String roomCode;
  final String status;
  final String hostId;
  final int maxPlayers;
  final String category;
  final String eventType;
  final String message;
  final List<Map<String, dynamic>> activePlayers;

  const CreateRoomResponse({
    required this.roomCode,
    required this.status,
    required this.hostId,
    required this.maxPlayers,
    required this.category,
    required this.eventType,
    required this.message,
    required this.activePlayers,
  });

  factory CreateRoomResponse.fromJson(Map<String, dynamic> json) {
    return CreateRoomResponse(
      roomCode: json['roomCode'] as String? ?? '',
      status: json['status'] as String? ?? 'LOBBY',
      hostId: json['hostId'] as String? ?? '',
      maxPlayers: json['maxPlayers'] as int? ?? 10,
      category: json['category'] as String? ?? 'PARTY',
      eventType: json['eventType'] as String? ?? 'ROOM_CREATED',
      message: json['message'] as String? ?? '',
      activePlayers: List<Map<String, dynamic>>.from(
        (json['activePlayers'] as List<dynamic>? ?? []).map((e) => e as Map<String, dynamic>),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// REST – Join Room Response
// ─────────────────────────────────────────────────────────────────

class JoinRoomResponse {
  final String joinStatus; // "JOINED" | "PENDING_APPROVAL" | "ROOM_NOT_FOUND"
  final String roomCode;
  final String playerId;
  final String message;
  final RoomStateUpdate? roomState;

  const JoinRoomResponse({
    required this.joinStatus,
    required this.roomCode,
    required this.playerId,
    required this.message,
    this.roomState,
  });

  factory JoinRoomResponse.fromJson(Map<String, dynamic> json) {
    return JoinRoomResponse(
      joinStatus: json['joinStatus'] as String? ?? '',
      roomCode: json['roomCode'] as String? ?? '',
      playerId: json['playerId'] as String? ?? '',
      message: json['message'] as String? ?? '',
      roomState: json['roomState'] != null
          ? RoomStateUpdate.fromJson(json['roomState'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// STOMP – Room State Update (broadcast on /topic/room/{roomCode})
// ─────────────────────────────────────────────────────────────────

class RoomStateUpdate {
  final String roomCode;
  final String status; // RoomStatus string
  final String hostId;
  final String eventType; // EventType string
  final List<Map<String, dynamic>> activePlayers;
  final List<Map<String, dynamic>> pendingPlayers;
  final String? message;

  const RoomStateUpdate({
    required this.roomCode,
    required this.status,
    required this.hostId,
    required this.eventType,
    required this.activePlayers,
    required this.pendingPlayers,
    this.message,
  });

  factory RoomStateUpdate.fromJson(Map<String, dynamic> json) {
    return RoomStateUpdate(
      roomCode: json['roomCode'] as String? ?? '',
      status: json['status'] as String? ?? 'LOBBY',
      hostId: json['hostId'] as String? ?? '',
      eventType: json['eventType'] as String? ?? '',
      activePlayers: List<Map<String, dynamic>>.from(
        (json['activePlayers'] as List<dynamic>? ?? []).map((e) => e as Map<String, dynamic>),
      ),
      pendingPlayers: List<Map<String, dynamic>>.from(
        (json['pendingPlayers'] as List<dynamic>? ?? []).map((e) => e as Map<String, dynamic>),
      ),
      message: json['message'] as String?,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// STOMP – Spin Result (broadcast on /topic/room/{roomCode}/spin)
// ─────────────────────────────────────────────────────────────────

class SpinResult {
  final String roomCode;
  final Map<String, dynamic> spinnerPlayer;
  final Map<String, dynamic> targetPlayer;
  final int targetPlayerIndex;
  final Question question;
  final int timestamp;

  const SpinResult({
    required this.roomCode,
    required this.spinnerPlayer,
    required this.targetPlayer,
    required this.targetPlayerIndex,
    required this.question,
    required this.timestamp,
  });

  factory SpinResult.fromJson(Map<String, dynamic> json) {
    return SpinResult(
      roomCode: json['roomCode'] as String,
      spinnerPlayer: json['spinnerPlayer'] as Map<String, dynamic>,
      targetPlayer: json['targetPlayer'] as Map<String, dynamic>,
      targetPlayerIndex: json['targetPlayerIndex'] as int,
      question: Question.fromJson(json['question'] as Map<String, dynamic>),
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// STOMP – Host Notification (on /topic/room/{roomCode}/host)
// Used for JOIN_REQUESTED events
// ─────────────────────────────────────────────────────────────────

class HostNotification {
  final String eventType; // e.g. "JOIN_REQUESTED"
  final String guestPlayerId;
  final String guestName;
  final String guestAvatar;

  const HostNotification({
    required this.eventType,
    required this.guestPlayerId,
    required this.guestName,
    required this.guestAvatar,
  });

  factory HostNotification.fromJson(Map<String, dynamic> json) {
    // The guest details may be nested under 'pendingPlayers[0]' or flat
    final pending = json['pendingPlayers'] as List<dynamic>?;
    final guest = pending != null && pending.isNotEmpty
        ? pending.first as Map<String, dynamic>
        : json;

    return HostNotification(
      eventType: json['eventType'] as String? ?? 'JOIN_REQUESTED',
      guestPlayerId: guest['playerId'] as String? ?? '',
      guestName: guest['name'] as String? ?? 'Guest',
      guestAvatar: guest['avatar'] as String? ?? 'avatar_neon_3',
    );
  }
}
