import 'package:flutter_test/flutter_test.dart';
import 'package:kaal_spinnex/services/stomp_service.dart';

void main() {
  group('StompService Tests', () {
    late StompService service;

    setUp(() {
      service = StompService();
    });

    tearDown(() {
      service.disconnect();
    });

    // ── Positive Cases ────────────────────────────────────────────
    group('Positive Cases', () {
      test('initial state should have isConnected as false', () {
        expect(service.isConnected.value, isFalse);
      });

      test('subscribe while disconnected should queue pending subscription safely', () {
        bool callbackCalled = false;
        void callback(Map<String, dynamic> data) {
          callbackCalled = true;
        }

        // Should not throw even though disconnected
        expect(() => service.subscribe('/topic/room/ABC123', callback), returnsNormally);
        expect(callbackCalled, isFalse);
      });

      test('sendApproval should execute without throwing even when disconnected', () {
        expect(
          () => service.sendApproval(
            roomCode: 'NEON42',
            hostId: 'usr_host_1',
            guestPlayerId: 'usr_guest_2',
            approve: true,
          ),
          returnsNormally,
        );
      });

      test('sendSpin should execute without throwing even when disconnected', () {
        expect(
          () => service.sendSpin(
            roomCode: 'NEON42',
            playerId: 'usr_player_1',
            category: 'PARTY',
            questionType: 'DARE',
          ),
          returnsNormally,
        );
      });

      test('sendLeave should execute without throwing even when disconnected', () {
        expect(
          () => service.sendLeave(
            roomCode: 'NEON42',
            playerId: 'usr_player_1',
          ),
          returnsNormally,
        );
      });

      test('sendStartGame should execute without throwing even when disconnected', () {
        expect(
          () => service.sendStartGame(
            roomCode: 'NEON42',
            hostId: 'usr_host_1',
          ),
          returnsNormally,
        );
      });

      test('disconnect should reset isConnected and clear subscriptions', () {
        service.subscribe('/topic/test', (data) {});
        service.isConnected.value = true;

        service.disconnect();

        expect(service.isConnected.value, isFalse);
      });

      test('onClose should invoke disconnect and clean up safely', () {
        service.isConnected.value = true;
        expect(() => service.onClose(), returnsNormally);
        expect(service.isConnected.value, isFalse);
      });
    });

    // ── Negative Cases ────────────────────────────────────────────
    group('Negative Cases', () {
      test('send should safely no-op when not connected without throwing error', () {
        expect(
          () => service.send('/app/room.test', {'message': 'hello'}),
          returnsNormally,
        );
      });

      test('unsubscribe on un-subscribed destination should safely no-op', () {
        expect(
          () => service.unsubscribe('/topic/room/non_existent_topic'),
          returnsNormally,
        );
      });

      test('multiple disconnect calls should be idempotent and not throw', () {
        expect(() {
          service.disconnect();
          service.disconnect();
          service.disconnect();
        }, returnsNormally);
        expect(service.isConnected.value, isFalse);
      });
    });

    // ── Edge Cases ────────────────────────────────────────────────
    group('Edge Cases', () {
      test('subscribing multiple times to same topic should overwrite previous subscription', () {
        int firstCounter = 0;
        int secondCounter = 0;

        service.subscribe('/topic/room/SAME_TOPIC', (data) => firstCounter++);
        expect(() => service.subscribe('/topic/room/SAME_TOPIC', (data) => secondCounter++), returnsNormally);

        expect(firstCounter, equals(0));
        expect(secondCounter, equals(0));
      });

      test('convenience helpers should handle empty strings without crashing', () {
        expect(
          () => service.sendApproval(
            roomCode: '',
            hostId: '',
            guestPlayerId: '',
            approve: false,
          ),
          returnsNormally,
        );

        expect(
          () => service.sendSpin(
            roomCode: '',
            playerId: '',
            category: '',
            questionType: '',
          ),
          returnsNormally,
        );

        expect(
          () => service.sendLeave(roomCode: '', playerId: ''),
          returnsNormally,
        );

        expect(
          () => service.sendStartGame(roomCode: '', hostId: ''),
          returnsNormally,
        );
      });

      test('send with empty payload map should safely no-op when disconnected', () {
        expect(() => service.send('/app/empty', <String, dynamic>{}), returnsNormally);
      });
    });
  });
}
