import 'package:flutter_test/flutter_test.dart';
import 'package:kaal_spinnex/data/models/room_models.dart';
import 'package:kaal_spinnex/data/models/question_model.dart';

void main() {
  // ─── GameCategoryX ──────────────────────────────────────────────
  group('GameCategoryX.fromDisplayName', () {
    test('"Classic (Family)" maps to CLASSIC', () {
      expect(GameCategoryX.fromDisplayName('Classic (Family)'), GameCategory.CLASSIC);
    });

    test('"Spicy (Couples)" maps to SPICY', () {
      expect(GameCategoryX.fromDisplayName('Spicy (Couples)'), GameCategory.SPICY);
    });

    test('"Party (Friends)" maps to PARTY', () {
      expect(GameCategoryX.fromDisplayName('Party (Friends)'), GameCategory.PARTY);
    });

    test('unknown display name defaults to PARTY', () {
      expect(GameCategoryX.fromDisplayName('something_random'), GameCategory.PARTY);
    });

    test('serverValue matches the enum name string', () {
      expect(GameCategory.CLASSIC.serverValue, 'CLASSIC');
      expect(GameCategory.PARTY.serverValue, 'PARTY');
      expect(GameCategory.SPICY.serverValue, 'SPICY');
    });
  });

  // ─── CreateRoomResponse ─────────────────────────────────────────
  group('CreateRoomResponse.fromJson', () {
    test('parses complete response', () {
      final json = {
        'roomCode': 'ABC123',
        'status': 'LOBBY',
        'hostId': 'usr_001',
        'maxPlayers': 8,
        'category': 'PARTY',
        'eventType': 'ROOM_CREATED',
        'message': 'Room created',
        'activePlayers': [
          {'playerId': 'usr_001', 'name': 'Host', 'avatar': 'avatar_neon_1', 'status': 'ACTIVE', 'host': true}
        ],
      };
      final resp = CreateRoomResponse.fromJson(json);

      expect(resp.roomCode, 'ABC123');
      expect(resp.hostId, 'usr_001');
      expect(resp.maxPlayers, 8);
      expect(resp.activePlayers.length, 1);
      expect(resp.activePlayers[0]['name'], 'Host');
    });

    test('handles empty activePlayers list', () {
      final json = {
        'roomCode': 'XYZ',
        'status': 'LOBBY',
        'hostId': 'usr_002',
        'maxPlayers': 10,
        'category': 'CLASSIC',
        'eventType': 'ROOM_CREATED',
        'message': '',
        'activePlayers': [],
      };
      final resp = CreateRoomResponse.fromJson(json);
      expect(resp.activePlayers, isEmpty);
    });

    test('defaults missing fields gracefully', () {
      final json = <String, dynamic>{};
      final resp = CreateRoomResponse.fromJson(json);
      expect(resp.roomCode, '');
      expect(resp.status, 'LOBBY');
      expect(resp.maxPlayers, 10);
      expect(resp.activePlayers, isEmpty);
    });
  });

  // ─── JoinRoomResponse ───────────────────────────────────────────
  group('JoinRoomResponse.fromJson', () {
    test('parses JOINED status', () {
      final json = {
        'joinStatus': 'JOINED',
        'roomCode': 'ABC123',
        'playerId': 'usr_999',
        'message': 'Welcome!',
        'roomState': null,
      };
      final resp = JoinRoomResponse.fromJson(json);
      expect(resp.joinStatus, 'JOINED');
      expect(resp.playerId, 'usr_999');
      expect(resp.roomState, isNull);
    });

    test('parses PENDING_APPROVAL status', () {
      final json = {
        'joinStatus': 'PENDING_APPROVAL',
        'roomCode': 'ABC123',
        'playerId': 'usr_888',
        'message': 'Awaiting host...',
      };
      final resp = JoinRoomResponse.fromJson(json);
      expect(resp.joinStatus, 'PENDING_APPROVAL');
    });

    test('parses ROOM_NOT_FOUND status', () {
      final json = {
        'joinStatus': 'ROOM_NOT_FOUND',
        'roomCode': '',
        'playerId': '',
        'message': 'Room not found',
      };
      final resp = JoinRoomResponse.fromJson(json);
      expect(resp.joinStatus, 'ROOM_NOT_FOUND');
      expect(resp.message, 'Room not found');
    });

    test('parses roomState when present', () {
      final json = {
        'joinStatus': 'JOINED',
        'roomCode': 'ABC123',
        'playerId': 'usr_777',
        'message': 'ok',
        'roomState': {
          'roomCode': 'ABC123',
          'status': 'LOBBY',
          'hostId': 'usr_001',
          'eventType': 'PLAYER_JOINED',
          'activePlayers': [],
          'pendingPlayers': [],
        },
      };
      final resp = JoinRoomResponse.fromJson(json);
      expect(resp.roomState, isNotNull);
      expect(resp.roomState!.roomCode, 'ABC123');
    });
  });

  // ─── RoomStateUpdate ────────────────────────────────────────────
  group('RoomStateUpdate.fromJson', () {
    test('parses full update', () {
      final json = {
        'roomCode': 'ROOM1',
        'status': 'PLAYING',
        'hostId': 'usr_001',
        'eventType': 'GAME_STARTED',
        'activePlayers': [
          {'playerId': 'usr_001', 'name': 'Alice', 'status': 'ACTIVE', 'host': true},
        ],
        'pendingPlayers': [],
        'message': 'Game has started',
      };
      final update = RoomStateUpdate.fromJson(json);
      expect(update.status, 'PLAYING');
      expect(update.eventType, 'GAME_STARTED');
      expect(update.activePlayers.length, 1);
      expect(update.message, 'Game has started');
    });

    test('defaults null activePlayers to empty list', () {
      final json = <String, dynamic>{
        'roomCode': 'R1',
        'status': 'LOBBY',
        'hostId': 'h1',
        'eventType': '',
        'activePlayers': null,
        'pendingPlayers': null,
      };
      final update = RoomStateUpdate.fromJson(json);
      expect(update.activePlayers, isEmpty);
      expect(update.pendingPlayers, isEmpty);
    });

    test('message is null when not in JSON', () {
      final json = {
        'roomCode': 'R2',
        'status': 'LOBBY',
        'hostId': 'h2',
        'eventType': '',
        'activePlayers': [],
        'pendingPlayers': [],
      };
      final update = RoomStateUpdate.fromJson(json);
      expect(update.message, isNull);
    });
  });

  // ─── SpinResult ─────────────────────────────────────────────────
  group('SpinResult.fromJson', () {
    final validJson = {
      'roomCode': 'SPIN1',
      'spinnerPlayer': {'playerId': 'p1', 'name': 'Alice'},
      'targetPlayer': {'playerId': 'p2', 'name': 'Bob'},
      'targetPlayerIndex': 1,
      'question': {
        'id': 10,
        'content': 'Do a dare!',
        'type': 'DARE',
        'category': 'PARTY',
      },
      'timestamp': 1700000000,
    };

    test('parses complete SpinResult', () {
      final result = SpinResult.fromJson(validJson);
      expect(result.roomCode, 'SPIN1');
      expect(result.targetPlayerIndex, 1);
      expect(result.question.type, 'DARE');
      expect(result.timestamp, 1700000000);
    });

    test('defaults timestamp to 0 when missing', () {
      final json = Map<String, dynamic>.from(validJson)..remove('timestamp');
      final result = SpinResult.fromJson(json);
      expect(result.timestamp, 0);
    });

    test('parses embedded question correctly', () {
      final result = SpinResult.fromJson(validJson);
      expect(result.question, isA<Question>());
      expect(result.question.content, 'Do a dare!');
    });
  });

  // ─── HostNotification ───────────────────────────────────────────
  group('HostNotification.fromJson', () {
    test('reads guest from pendingPlayers[0] when present', () {
      final json = {
        'eventType': 'JOIN_REQUESTED',
        'pendingPlayers': [
          {'playerId': 'usr_guest1', 'name': 'GuestA', 'avatar': 'avatar_neon_5'},
        ],
      };
      final notif = HostNotification.fromJson(json);
      expect(notif.guestPlayerId, 'usr_guest1');
      expect(notif.guestName, 'GuestA');
    });

    test('reads guest from root when pendingPlayers is empty', () {
      final json = {
        'eventType': 'JOIN_REQUESTED',
        'playerId': 'usr_flat',
        'name': 'FlatGuest',
        'avatar': 'avatar_neon_2',
        'pendingPlayers': [],
      };
      final notif = HostNotification.fromJson(json);
      expect(notif.guestPlayerId, 'usr_flat');
      expect(notif.guestName, 'FlatGuest');
    });

    test('defaults guestName to "Guest" when missing', () {
      final json = {
        'eventType': 'JOIN_REQUESTED',
        'pendingPlayers': [{}],
      };
      final notif = HostNotification.fromJson(json);
      expect(notif.guestName, 'Guest');
    });

    test('defaults eventType to JOIN_REQUESTED when missing', () {
      final json = <String, dynamic>{'pendingPlayers': []};
      final notif = HostNotification.fromJson(json);
      expect(notif.eventType, 'JOIN_REQUESTED');
    });
  });
}
