import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kaal_spinnex/data/models/player_model.dart';
import 'package:kaal_spinnex/modules/scoreboard/scoreboard_controller.dart';
import '../mocks/mock_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ScoreboardController controller;

  void setupScoreboard(List<PlayerModel>? inputPlayers) {
    Get.testMode = true;
    Get.routing.args = inputPlayers;
    controller = ScoreboardController();
    controller.onInit();
  }

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  group('ScoreboardController Tests', () {
    // --- POSITIVE CASES ---
    group('Positive Cases', () {
      test('should sort players descending by score on initialization', () {
        final unsorted = [
          PlayerModel(name: 'Charlie', score: 2),
          PlayerModel(name: 'Alice', score: 10),
          PlayerModel(name: 'Bob', score: 5),
        ];

        setupScoreboard(unsorted);

        expect(controller.players.length, equals(3));
        expect(controller.players[0].name, equals('Alice'));
        expect(controller.players[0].score, equals(10));
        expect(controller.players[1].name, equals('Bob'));
        expect(controller.players[1].score, equals(5));
        expect(controller.players[2].name, equals('Charlie'));
        expect(controller.players[2].score, equals(2));
      });

      test('should identify top player with score > 0 as MVP', () {
        setupScoreboard(MockData.rankedThreePlayers);

        expect(controller.isMVP(0), isTrue);
        expect(controller.isMVP(1), isFalse);
        expect(controller.isMVP(2), isFalse);
      });

      test('should identify last player as biggest chicken when player count >= 2', () {
        setupScoreboard(MockData.rankedThreePlayers);

        expect(controller.isBiggestChicken(2), isTrue);
        expect(controller.isBiggestChicken(0), isFalse);
        expect(controller.isBiggestChicken(1), isFalse);
      });

      test('should execute playAgain without error', () {
        setupScoreboard(MockData.standardTwoPlayers);
        expect(() => controller.playAgain(), returnsNormally);
      });
    });

    // --- NEGATIVE CASES ---
    group('Negative Cases', () {
      test('should NOT mark player as MVP if top score is zero', () {
        final zeroPlayers = [
          PlayerModel(name: 'Zero1', score: 0),
          PlayerModel(name: 'Zero2', score: 0),
        ];

        setupScoreboard(zeroPlayers);

        expect(controller.isMVP(0), isFalse);
      });

      test('should NOT mark player as MVP if top score is negative', () {
        final negativePlayers = [
          PlayerModel(name: 'Bad1', score: -1),
          PlayerModel(name: 'Bad2', score: -5),
        ];

        setupScoreboard(negativePlayers);

        expect(controller.isMVP(0), isFalse);
      });

      test('should NOT mark anyone as biggest chicken if list has only 1 player', () {
        final singlePlayer = [PlayerModel(name: 'Lone Wolf', score: 5)];

        setupScoreboard(singlePlayer);

        expect(controller.isBiggestChicken(0), isFalse);
      });
    });

    // --- EDGE CASES ---
    group('Edge Cases', () {
      test('should handle null or non-list arguments gracefully onInit', () {
        setupScoreboard(null);

        expect(controller.players, isEmpty);
      });

      test('should handle empty player list gracefully', () {
        setupScoreboard([]);

        expect(controller.players, isEmpty);
        expect(controller.isBiggestChicken(0), isFalse);
      });

      test('should handle tied scores properly (no chicken when all scores equal)', () {
        final tiedPlayers = [
          PlayerModel(name: 'TwinA', score: 7),
          PlayerModel(name: 'TwinB', score: 7),
        ];

        setupScoreboard(tiedPlayers);

        expect(controller.players.length, equals(2));
        expect(controller.isMVP(0), isTrue);
        // When all players have identical scores, no one is the biggest chicken
        expect(controller.isBiggestChicken(1), isFalse);
      });

      test('should handle 12 players ranked correctly from top to bottom', () {
        final twelve = MockData.generate12Players(); // scores 0 to 11
        setupScoreboard(twelve);

        expect(controller.players.first.score, equals(11));
        expect(controller.players.last.score, equals(0));
        expect(controller.isMVP(0), isTrue);
        expect(controller.isBiggestChicken(11), isTrue);
      });
    });
  });
}
