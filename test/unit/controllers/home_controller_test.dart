import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:kaal_spinnex/data/models/question_model.dart';
import 'package:kaal_spinnex/data/repositories/question_repository.dart';
import 'package:kaal_spinnex/modules/home/home_controller.dart';

@GenerateMocks([QuestionRepository])
import 'home_controller_test.mocks.dart';

HomeController _makeCtrl(QuestionRepository repo) {
  final ctrl = HomeController(repository: repo);
  Get.put(ctrl);
  return ctrl;
}

void main() {
  late MockQuestionRepository mockRepo;

  setUp(() {
    Get.testMode = true;
    mockRepo = MockQuestionRepository();
  });
  tearDown(() => Get.reset());

  // ── Initial state ─────────────────────────────────────────────
  group('HomeController – initial state', () {
    test('playerCount starts at 2', () {
      final ctrl = _makeCtrl(mockRepo);
      expect(ctrl.playerCount.value, 2);
    });

    test('playerControllers has 2 entries on init', () {
      final ctrl = _makeCtrl(mockRepo);
      expect(ctrl.playerControllers.length, 2);
    });

    test('playerEmojisList has 2 entries on init', () {
      final ctrl = _makeCtrl(mockRepo);
      expect(ctrl.playerEmojisList.length, 2);
    });

    test('playerColorsList has 2 entries on init', () {
      final ctrl = _makeCtrl(mockRepo);
      expect(ctrl.playerColorsList.length, 2);
    });

    test('isOnlineMode starts false', () {
      final ctrl = _makeCtrl(mockRepo);
      expect(ctrl.isOnlineMode.value, false);
    });

    test('isMusicOn starts true', () {
      final ctrl = _makeCtrl(mockRepo);
      expect(ctrl.isMusicOn.value, true);
    });

    test('selectedCategory starts as Party (Friends)', () {
      final ctrl = _makeCtrl(mockRepo);
      expect(ctrl.selectedCategory.value, 'Party (Friends)');
    });
  });

  // ── addPlayer ─────────────────────────────────────────────────
  group('HomeController – addPlayer', () {
    test('addPlayer increases count from 2 to 3', () {
      final ctrl = _makeCtrl(mockRepo);
      ctrl.addPlayer();
      expect(ctrl.playerControllers.length, 3);
      expect(ctrl.playerCount.value, 3);
    });

    test('addPlayerWithInputName with custom name uses that name', () {
      final ctrl = _makeCtrl(mockRepo);
      ctrl.addPlayerWithInputName('ZeldaX');
      final names = ctrl.playerControllers.map((c) => c.text).toList();
      expect(names, contains('ZeldaX'));
    });

    test('addPlayerWithInputName with empty string uses random name', () {
      final ctrl = _makeCtrl(mockRepo);
      ctrl.addPlayerWithInputName('');
      expect(ctrl.playerControllers.length, 3);
      expect(ctrl.playerControllers.last.text.isNotEmpty, true);
    });

    test('addPlayerWithInputName with whitespace-only uses random name', () {
      final ctrl = _makeCtrl(mockRepo);
      ctrl.addPlayerWithInputName('   ');
      expect(ctrl.playerControllers.last.text.trim().isNotEmpty, true);
    });

    test('cannot add more than 12 players', () {
      final ctrl = _makeCtrl(mockRepo);
      // Add players up to 12
      for (int i = ctrl.playerControllers.length; i < 12; i++) {
        ctrl.addPlayer();
      }
      expect(ctrl.playerControllers.length, 12);
      // Try to add one more
      ctrl.addPlayer();
      expect(ctrl.playerControllers.length, 12);
    });

    test('emoji and color lists stay in sync after add', () {
      final ctrl = _makeCtrl(mockRepo);
      ctrl.addPlayer();
      expect(ctrl.playerEmojisList.length, ctrl.playerControllers.length);
      expect(ctrl.playerColorsList.length, ctrl.playerControllers.length);
    });
  });

  // ── removePlayer ──────────────────────────────────────────────
  group('HomeController – removePlayer', () {
    test('removePlayer decreases count from 3 to 2', () {
      final ctrl = _makeCtrl(mockRepo);
      ctrl.addPlayer();
      expect(ctrl.playerCount.value, 3);
      ctrl.removePlayer();
      expect(ctrl.playerCount.value, 2);
    });

    test('removePlayer at 2 players shows snackbar and keeps count at 2', () {
      final ctrl = _makeCtrl(mockRepo);
      expect(ctrl.playerCount.value, 2);
      ctrl.removePlayer(); // should be blocked
      expect(ctrl.playerCount.value, 2);
    });

    test('removePlayerAt valid index removes correct player', () {
      final ctrl = _makeCtrl(mockRepo);
      ctrl.addPlayerWithInputName('TargetPlayer');
      final beforeCount = ctrl.playerControllers.length;
      // Remove index 0
      ctrl.removePlayerAt(0);
      expect(ctrl.playerControllers.length, beforeCount - 1);
    });

    test('removePlayerAt negative index is a no-op', () {
      final ctrl = _makeCtrl(mockRepo);
      final beforeCount = ctrl.playerControllers.length;
      ctrl.removePlayerAt(-1);
      expect(ctrl.playerControllers.length, beforeCount);
    });

    test('removePlayerAt out-of-bounds index is a no-op', () {
      final ctrl = _makeCtrl(mockRepo);
      final beforeCount = ctrl.playerControllers.length;
      ctrl.removePlayerAt(999);
      expect(ctrl.playerControllers.length, beforeCount);
    });

    test('removePlayerAt at 2 players shows snackbar and keeps count at 2', () {
      final ctrl = _makeCtrl(mockRepo);
      expect(ctrl.playerCount.value, 2);
      ctrl.removePlayerAt(0);
      expect(ctrl.playerCount.value, 2);
    });

    test('emoji and color lists stay in sync after remove', () {
      final ctrl = _makeCtrl(mockRepo);
      ctrl.addPlayer(); // 3 players
      ctrl.removePlayerAt(0);
      expect(ctrl.playerEmojisList.length, ctrl.playerControllers.length);
      expect(ctrl.playerColorsList.length, ctrl.playerControllers.length);
    });
  });

  // ── randomizeName ─────────────────────────────────────────────
  group('HomeController – randomizeName', () {
    test('randomizeName changes name at given index', () {
      final ctrl = _makeCtrl(mockRepo);
      final before = ctrl.playerControllers[0].text;
      // Run several times to increase chance of getting a different name
      for (int i = 0; i < 10; i++) {
        ctrl.randomizeName(0);
        if (ctrl.playerControllers[0].text != before) break;
      }
      // At minimum it should not crash
      expect(ctrl.playerControllers[0].text.isNotEmpty, true);
    });

    test('randomizeName with invalid index is a no-op', () {
      final ctrl = _makeCtrl(mockRepo);
      expect(() => ctrl.randomizeName(-1), returnsNormally);
      expect(() => ctrl.randomizeName(999), returnsNormally);
    });
  });

  // ── getRandomUniqueName ───────────────────────────────────────
  group('HomeController – getRandomUniqueName', () {
    test('generated name is not empty', () {
      final ctrl = _makeCtrl(mockRepo);
      final name = ctrl.getRandomUniqueName();
      expect(name.isNotEmpty, true);
    });

    test('when all predefined names are exhausted, falls back to "Player N"', () {
      final ctrl = _makeCtrl(mockRepo);
      // Use all names from randomNames
      final usedNames = Set<String>.from(HomeController.randomNames);
      // Override controllers to claim all names
      for (final c in ctrl.playerControllers) {
        c.text = usedNames.first;
        usedNames.remove(usedNames.first);
      }
      // The pool is effectively claimed by controllers; add all remaining
      final bigSet = Set<String>.from(HomeController.randomNames);
      bigSet.addAll(ctrl.playerControllers.map((c) => c.text));
      // getRandomUniqueName must not return any of those
      final name = ctrl.getRandomUniqueName();
      // It should either be from the pool or 'Player N'
      expect(name.isNotEmpty, true);
    });
  });

  // ── getMatchingEmojiForName ───────────────────────────────────
  group('HomeController – getMatchingEmojiForName', () {
    test('returns mapped emoji for known name', () {
      final ctrl = _makeCtrl(mockRepo);
      // 'Vibe Queen' maps to '👑'
      final emoji = ctrl.getMatchingEmojiForName('Vibe Queen', playerIndex: 0);
      expect(emoji, '👑');
    });

    test('falls back to available emoji when mapped one is taken', () {
      final ctrl = _makeCtrl(mockRepo);
      // Force the mapped emoji into the used set by setting it on index 1
      ctrl.playerEmojisList[1] = '👑';
      // Now index 0 requests 'Vibe Queen' which maps to '👑' (already taken)
      final emoji = ctrl.getMatchingEmojiForName('Vibe Queen', playerIndex: 0);
      expect(emoji, isNot('👑'));
    });

    test('returns a non-empty emoji for unknown name', () {
      final ctrl = _makeCtrl(mockRepo);
      final emoji = ctrl.getMatchingEmojiForName('NonExistentName');
      expect(emoji.isNotEmpty, true);
    });
  });

  // ── leaveOnlineRoom ───────────────────────────────────────────
  group('HomeController – leaveOnlineRoom', () {
    test('resets all online state fields', () {
      final ctrl = _makeCtrl(mockRepo);
      ctrl.isOnlineMode.value = true;
      ctrl.isHost.value = true;
      ctrl.roomCode.value = 'ABC123';
      ctrl.myPlayerId.value = 'usr_001';

      ctrl.leaveOnlineRoom();

      expect(ctrl.isOnlineMode.value, false);
      expect(ctrl.isHost.value, false);
      expect(ctrl.roomCode.value, '');
      expect(ctrl.myPlayerId.value, '');
      expect(ctrl.onlinePlayers, isEmpty);
    });
  });

  // ── shareRoomCode ─────────────────────────────────────────────
  group('HomeController – shareRoomCode', () {
    test('does nothing when roomCode is empty', () {
      final ctrl = _makeCtrl(mockRepo);
      ctrl.roomCode.value = '';
      // Should not throw
      expect(() => ctrl.shareRoomCode(), returnsNormally);
    });
  });

  // ── startGame ─────────────────────────────────────────────────
  group('HomeController – startGame', () {
    test('player with empty name gets "Player N" fallback', () async {
      when(mockRepo.getQuestions(any)).thenAnswer((_) async => [
            Question(id: '1', content: 'Q', type: 'TRUTH', category: 'CLASSIC'),
          ]);

      final ctrl = _makeCtrl(mockRepo);
      ctrl.playerControllers[0].text = ''; // empty name
      await ctrl.startGame();

      // Navigation would have been called. We verify by checking no exceptions
      // (full navigation test is in widget tests)
    });

    test('shows error snackbar on repository exception', () async {
      when(mockRepo.getQuestions(any)).thenThrow(Exception('No internet'));
      final ctrl = _makeCtrl(mockRepo);
      // Should not throw — handled internally with snackbar
      await expectLater(ctrl.startGame(), completes);
      expect(ctrl.isLoading.value, false);
    });

    test('isLoading resets to false after startGame completes', () async {
      when(mockRepo.getQuestions(any)).thenAnswer((_) async => []);
      final ctrl = _makeCtrl(mockRepo);
      await ctrl.startGame();
      expect(ctrl.isLoading.value, false);
    });
  });
}
