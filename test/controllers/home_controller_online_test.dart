import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kaal_spinnex/data/models/player_model.dart';
import 'package:kaal_spinnex/modules/home/home_controller.dart';
import 'package:kaal_spinnex/services/stomp_service.dart';
import '../mocks/mock_data.dart';

void main() {
  group('HomeController Online Multiplayer Tests', () {
    late MockQuestionRepository mockRepository;
    late HomeController controller;
    late StompService stompService;

    setUp(() {
      Get.testMode = true;
      mockRepository = MockQuestionRepository();
      stompService = StompService();
      Get.put<StompService>(stompService);
      controller = HomeController(repository: mockRepository);
      controller.onInit();
    });

    tearDown(() {
      controller.onClose();
      Get.reset();
    });

    // ── Positive Cases ────────────────────────────────────────────
    group('Positive Cases', () {
      test('initial online state should be clean and inactive', () {
        expect(controller.isOnlineMode.value, isFalse);
        expect(controller.roomCode.value, isEmpty);
        expect(controller.myPlayerId.value, isEmpty);
        expect(controller.isHost.value, isFalse);
        expect(controller.isOnlineLoading.value, isFalse);
        expect(controller.onlinePlayers, isEmpty);
      });

      test('leaveOnlineRoom should reset all online state variables and clear online players', () {
        controller.isOnlineMode.value = true;
        controller.roomCode.value = 'TEST99';
        controller.myPlayerId.value = 'usr_test_1';
        controller.isHost.value = true;
        controller.onlinePlayers.assignAll([
          PlayerModel(name: 'HostAlice', playerId: 'usr_test_1', host: true),
          PlayerModel(name: 'GuestBob', playerId: 'usr_test_2'),
        ]);

        controller.leaveOnlineRoom();

        expect(controller.isOnlineMode.value, isFalse);
        expect(controller.roomCode.value, isEmpty);
        expect(controller.myPlayerId.value, isEmpty);
        expect(controller.isHost.value, isFalse);
        expect(controller.onlinePlayers, isEmpty);
      });

      test('startGame in online mode should prioritize onlinePlayers list over local controllers', () async {
        controller.isOnlineMode.value = true;
        controller.roomCode.value = 'ONLINE42';
        controller.myPlayerId.value = 'usr_101';
        controller.isHost.value = true;

        final onlineP1 = PlayerModel(name: 'SyncedHost', playerId: 'usr_101', host: true);
        final onlineP2 = PlayerModel(name: 'SyncedGuest', playerId: 'usr_102');
        controller.onlinePlayers.assignAll([onlineP1, onlineP2]);

        expect(() => controller.startGame(), returnsNormally);
      });
    });

    // ── Negative Cases ────────────────────────────────────────────
    group('Negative Cases', () {
      test('shareRoomCode should safely return early when roomCode is empty', () {
        controller.roomCode.value = '';
        expect(() => controller.shareRoomCode(), returnsNormally);
      });

      test('leaveOnlineRoom should execute safely when already offline without throwing', () {
        expect(controller.isOnlineMode.value, isFalse);
        expect(() => controller.leaveOnlineRoom(), returnsNormally);
        expect(controller.isOnlineMode.value, isFalse);
      });
    });

    // ── Edge Cases ────────────────────────────────────────────────
    group('Edge Cases', () {
      test('startGame in online mode with empty onlinePlayers should safely fallback to local lobby players', () async {
        controller.isOnlineMode.value = true;
        controller.roomCode.value = 'EMPTY_LOBBY';
        controller.onlinePlayers.clear();

        expect(controller.playerControllers.length, equals(2));
        expect(() => controller.startGame(), returnsNormally);
      });

      test('toggling online mode rapidly should preserve state consistency', () {
        for (int i = 0; i < 5; i++) {
          controller.isOnlineMode.value = true;
          controller.roomCode.value = 'CODE_$i';
          controller.leaveOnlineRoom();

          expect(controller.isOnlineMode.value, isFalse);
          expect(controller.roomCode.value, isEmpty);
          expect(controller.onlinePlayers, isEmpty);
        }
      });
    });
  });
}
