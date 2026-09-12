import 'package:flutter_test/flutter_test.dart';
import 'package:kaal_spinnex/data/models/question_model.dart';
import 'package:kaal_spinnex/data/models/room_models.dart';

void main() {
  group('Room Models Tests', () {
    // ─── GameCategoryX ────────────────────────────────────────────
    group('GameCategory & GameCategoryX Tests', () {
      // Positive Cases
      test('fromDisplayName should correctly map valid category display names', () {
        expect(GameCategoryX.fromDisplayName('Classic (Family)'), equals(GameCategory.CLASSIC));
        expect(GameCategoryX.fromDisplayName('Spicy (Couples)'), equals(GameCategory.SPICY));
        expect(GameCategoryX.fromDisplayName('Party (Friends)'), equals(GameCategory.PARTY));
      });

      test('serverValue should match enum name in uppercase', () {
        expect(GameCategory.CLASSIC.serverValue, equals('CLASSIC'));
        expect(GameCategory.SPICY.serverValue, equals('SPICY'));
        expect(GameCategory.PARTY.serverValue, equals('PARTY'));
      });

      // Negative Cases
      test('fromDisplayName should fallback to PARTY for unknown category names', () {
        expect(GameCategoryX.fromDisplayName('Unknown Category'), equals(GameCategory.PARTY));
        expect(GameCategoryX.fromDisplayName('Random Mode'), equals(GameCategory.PARTY));
      });

      // Edge Cases
      test('fromDisplayName should fallback to PARTY for empty and whitespace strings', () {
        expect(GameCategoryX.fromDisplayName(''), equals(GameCategory.PARTY));
        expect(GameCategoryX.fromDisplayName('   '), equals(GameCategory.PARTY));
      });

      test('fromDisplayName should fallback to PARTY for wrong casing', () {
        expect(GameCategoryX.fromDisplayName('classic (family)'), equals(GameCategory.PARTY));
        expect(GameCategoryX.fromDisplayName('SPICY (COUPLES)'), equals(GameCategory.PARTY));
      });
    });

    // ─── CreateRoomResponse ───────────────────────────────────────
    group('CreateRoomResponse Tests', () {
      final validJson = {
        'roomCode': 'NEON99',
        'status': 'LOBBY',
        'hostId': 'usr_host_1',
        'maxPlayers': 8,
        'category': 'SPICY',
        'eventType': 'ROOM_CREATED',
        'message': 'Room successfully created',
        'activePlayers': [
          {
            'playerId': 'usr_host_1',
            'name': 'HostMaster',
            'avatar': 'avatar_neon_1',
            'status': 'ACTIVE',
            'host': true,
          }
        ],
      };

      // Positive Cases
      test('fromJson should parse complete valid payload', () {
        final resp = CreateRoomResponse.fromJson(validJson);

        expect(resp.roomCode, equals('NEON99'));
        expect(resp.status, equals('LOBBY'));
        expect(resp.hostId, equals('usr_host_1'));
        expect(resp.maxPlayers, equals(8));
        expect(resp.category, equals('SPICY'));
        expect(resp.eventType, equals('ROOM_CREATED'));
        expect(resp.message, equals('Room successfully created'));
        expect(resp.activePlayers.length, equals(1));
        expect(resp.activePlayers.first['name'], equals('HostMaster'));
      });

      // Negative Cases
      test('fromJson should use defaults when optional or missing fields', () {
        final resp = CreateRoomResponse.fromJson(<String, dynamic>{});

        expect(resp.roomCode, equals(''));
        expect(resp.status, equals('LOBBY'));
        expect(resp.hostId, equals(''));
        expect(resp.maxPlayers, equals(10));
        expect(resp.category, equals('PARTY'));
        expect(resp.eventType, equals('ROOM_CREATED'));
        expect(resp.message, equals(''));
        expect(resp.activePlayers, isEmpty);
      });

      // Edge Cases
      test('fromJson should handle null values inside map safely', () {
        final resp = CreateRoomResponse.fromJson({
          'roomCode': null,
          'status': null,
          'hostId': null,
          'maxPlayers': null,
          'category': null,
          'eventType': null,
          'message': null,
          'activePlayers': null,
        });

        expect(resp.roomCode, equals(''));
        expect(resp.status, equals('LOBBY'));
        expect(resp.maxPlayers, equals(10));
        expect(resp.category, equals('PARTY'));
        expect(resp.activePlayers, isEmpty);
      });

      test('fromJson should ignore extra unknown fields in JSON', () {
        final jsonWithExtras = Map<String, dynamic>.from(validJson)
          ..addAll({'debugInfo': 'test', 'extraTimestamp': 123456});

        final resp = CreateRoomResponse.fromJson(jsonWithExtras);
        expect(resp.roomCode, equals('NEON99'));
      });
    });

    // ─── JoinRoomResponse ─────────────────────────────────────────
    group('JoinRoomResponse Tests', () {
      // Positive Cases
      test('fromJson should parse JOINED status with roomState', () {
        final json = {
          'joinStatus': 'JOINED',
          'roomCode': 'JOIN01',
          'playerId': 'usr_guest_1',
          'message': 'Welcome to the room',
          'roomState': {
            'roomCode': 'JOIN01',
            'status': 'LOBBY',
            'hostId': 'usr_host_1',
            'eventType': 'PLAYER_JOINED',
            'activePlayers': [
              {'playerId': 'usr_host_1', 'name': 'Host'},
              {'playerId': 'usr_guest_1', 'name': 'Guest'},
            ],
            'pendingPlayers': [],
          },
        };

        final resp = JoinRoomResponse.fromJson(json);

        expect(resp.joinStatus, equals('JOINED'));
        expect(resp.roomCode, equals('JOIN01'));
        expect(resp.playerId, equals('usr_guest_1'));
        expect(resp.message, equals('Welcome to the room'));
        expect(resp.roomState, isNotNull);
        expect(resp.roomState!.activePlayers.length, equals(2));
      });

      test('fromJson should parse PENDING_APPROVAL status without roomState', () {
        final json = {
          'joinStatus': 'PENDING_APPROVAL',
          'roomCode': 'PEND01',
          'playerId': 'usr_wait_1',
          'message': 'Waiting for host approval',
          'roomState': null,
        };

        final resp = JoinRoomResponse.fromJson(json);

        expect(resp.joinStatus, equals('PENDING_APPROVAL'));
        expect(resp.roomState, isNull);
      });

      // Negative Cases
      test('fromJson should parse ROOM_NOT_FOUND error status', () {
        final json = {
          'joinStatus': 'ROOM_NOT_FOUND',
          'roomCode': 'BAD99',
          'playerId': '',
          'message': 'Room BAD99 not found',
        };

        final resp = JoinRoomResponse.fromJson(json);

        expect(resp.joinStatus, equals('ROOM_NOT_FOUND'));
        expect(resp.message, equals('Room BAD99 not found'));
        expect(resp.roomState, isNull);
      });

      // Edge Cases
      test('fromJson should handle empty json map safely', () {
        final resp = JoinRoomResponse.fromJson(<String, dynamic>{});

        expect(resp.joinStatus, equals(''));
        expect(resp.roomCode, equals(''));
        expect(resp.playerId, equals(''));
        expect(resp.message, equals(''));
        expect(resp.roomState, isNull);
      });
    });

    // ─── RoomStateUpdate ──────────────────────────────────────────
    group('RoomStateUpdate Tests', () {
      // Positive Cases
      test('fromJson should parse valid update with active and pending players', () {
        final json = {
          'roomCode': 'ROOM42',
          'status': 'PLAYING',
          'hostId': 'usr_h',
          'eventType': 'GAME_STARTED',
          'activePlayers': [
            {'playerId': 'p1', 'name': 'Alice'},
            {'playerId': 'p2', 'name': 'Bob'},
          ],
          'pendingPlayers': [
            {'playerId': 'p3', 'name': 'Charlie'},
          ],
          'message': 'Game is now active!',
        };

        final update = RoomStateUpdate.fromJson(json);

        expect(update.roomCode, equals('ROOM42'));
        expect(update.status, equals('PLAYING'));
        expect(update.hostId, equals('usr_h'));
        expect(update.eventType, equals('GAME_STARTED'));
        expect(update.activePlayers.length, equals(2));
        expect(update.pendingPlayers.length, equals(1));
        expect(update.message, equals('Game is now active!'));
      });

      // Negative Cases
      test('fromJson should handle null activePlayers and pendingPlayers lists', () {
        final json = {
          'roomCode': 'R1',
          'status': null,
          'hostId': null,
          'eventType': null,
          'activePlayers': null,
          'pendingPlayers': null,
          'message': null,
        };

        final update = RoomStateUpdate.fromJson(json);

        expect(update.status, equals('LOBBY'));
        expect(update.activePlayers, isEmpty);
        expect(update.pendingPlayers, isEmpty);
        expect(update.message, isNull);
      });

      // Edge Cases
      test('fromJson should handle completely empty map', () {
        final update = RoomStateUpdate.fromJson(<String, dynamic>{});

        expect(update.roomCode, equals(''));
        expect(update.status, equals('LOBBY'));
        expect(update.hostId, equals(''));
        expect(update.eventType, equals(''));
        expect(update.activePlayers, isEmpty);
        expect(update.pendingPlayers, isEmpty);
        expect(update.message, isNull);
      });
    });

    // ─── SpinResult ───────────────────────────────────────────────
    group('SpinResult Tests', () {
      final validSpinJson = {
        'roomCode': 'SPIN99',
        'spinnerPlayer': {'playerId': 'p1', 'name': 'Spinner'},
        'targetPlayer': {'playerId': 'p2', 'name': 'Target'},
        'targetPlayerIndex': 3,
        'question': {
          'id': 77,
          'content': 'Do a crazy robot dance for 15 seconds',
          'type': 'DARE',
          'category': 'Party',
        },
        'timestamp': 1700005555,
      };

      // Positive Cases
      test('fromJson should parse complete spin result payload with question', () {
        final result = SpinResult.fromJson(validSpinJson);

        expect(result.roomCode, equals('SPIN99'));
        expect(result.spinnerPlayer['name'], equals('Spinner'));
        expect(result.targetPlayer['name'], equals('Target'));
        expect(result.targetPlayerIndex, equals(3));
        expect(result.question.id, equals(77));
        expect(result.question.type, equals('DARE'));
        expect(result.question.category, equals('Party'));
        expect(result.timestamp, equals(1700005555));
      });

      // Negative Cases
      test('fromJson should default timestamp to 0 when missing or null', () {
        final noTimestampJson = Map<String, dynamic>.from(validSpinJson)..remove('timestamp');
        final result = SpinResult.fromJson(noTimestampJson);

        expect(result.timestamp, equals(0));
      });

      // Edge Cases
      test('fromJson should handle targetPlayerIndex of zero and large indices', () {
        final zeroIndexJson = Map<String, dynamic>.from(validSpinJson)..['targetPlayerIndex'] = 0;
        final zeroResult = SpinResult.fromJson(zeroIndexJson);
        expect(zeroResult.targetPlayerIndex, equals(0));

        final maxIndexJson = Map<String, dynamic>.from(validSpinJson)..['targetPlayerIndex'] = 99999;
        final maxResult = SpinResult.fromJson(maxIndexJson);
        expect(maxResult.targetPlayerIndex, equals(99999));
      });
    });

    // ─── HostNotification ─────────────────────────────────────────
    group('HostNotification Tests', () {
      // Positive Cases
      test('fromJson should extract guest info from pendingPlayers list when present', () {
        final json = {
          'eventType': 'JOIN_REQUESTED',
          'pendingPlayers': [
            {'playerId': 'usr_pending_1', 'name': 'GuestPending', 'avatar': 'avatar_neon_7'},
          ],
        };

        final notif = HostNotification.fromJson(json);

        expect(notif.eventType, equals('JOIN_REQUESTED'));
        expect(notif.guestPlayerId, equals('usr_pending_1'));
        expect(notif.guestName, equals('GuestPending'));
        expect(notif.guestAvatar, equals('avatar_neon_7'));
      });

      test('fromJson should extract guest info from root object when pendingPlayers is empty', () {
        final json = {
          'eventType': 'JOIN_REQUESTED',
          'playerId': 'usr_root_1',
          'name': 'RootGuest',
          'avatar': 'avatar_neon_2',
          'pendingPlayers': [],
        };

        final notif = HostNotification.fromJson(json);

        expect(notif.guestPlayerId, equals('usr_root_1'));
        expect(notif.guestName, equals('RootGuest'));
        expect(notif.guestAvatar, equals('avatar_neon_2'));
      });

      // Negative Cases
      test('fromJson should fallback to safe defaults when guest fields are missing', () {
        final json = {
          'eventType': null,
          'pendingPlayers': [
            {'playerId': null, 'name': null, 'avatar': null},
          ],
        };

        final notif = HostNotification.fromJson(json);

        expect(notif.eventType, equals('JOIN_REQUESTED'));
        expect(notif.guestPlayerId, equals(''));
        expect(notif.guestName, equals('Guest'));
        expect(notif.guestAvatar, equals('avatar_neon_3'));
      });

      // Edge Cases
      test('fromJson should handle empty map inside pendingPlayers array', () {
        final json = {
          'eventType': 'JOIN_REQUESTED',
          'pendingPlayers': [<String, dynamic>{}],
        };

        final notif = HostNotification.fromJson(json);

        expect(notif.guestPlayerId, equals(''));
        expect(notif.guestName, equals('Guest'));
        expect(notif.guestAvatar, equals('avatar_neon_3'));
      });

      test('fromJson should handle empty json object', () {
        final notif = HostNotification.fromJson(<String, dynamic>{});

        expect(notif.eventType, equals('JOIN_REQUESTED'));
        expect(notif.guestPlayerId, equals(''));
        expect(notif.guestName, equals('Guest'));
        expect(notif.guestAvatar, equals('avatar_neon_3'));
      });
    });
  });
}
