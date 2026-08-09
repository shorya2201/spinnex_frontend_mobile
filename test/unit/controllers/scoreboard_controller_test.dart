import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kaal_spinnex/data/models/player_model.dart';
import 'package:kaal_spinnex/modules/scoreboard/scoreboard_controller.dart';

PlayerModel _p(String name, int score) =>
    PlayerModel(name: name)..score = score;

void main() {
  setUp(() => Get.testMode = true);
  tearDown(() => Get.reset());

  group('ScoreboardController – sorting', () {
    test('sorts players by score descending on init', () {
      final players = [_p('Alice', 1), _p('Bob', 5), _p('Carol', 3)];
      Get.routing.args = players;

      final ctrl = Get.put(ScoreboardController());
      expect(ctrl.players[0].name, 'Bob');
      expect(ctrl.players[1].name, 'Carol');
      expect(ctrl.players[2].name, 'Alice');
    });

    test('handles single player without crash', () {
      Get.routing.args = [_p('Solo', 0)];
      final ctrl = Get.put(ScoreboardController());
      expect(ctrl.players.length, 1);
    });

    test('handles empty player list without crash', () {
      Get.routing.args = <PlayerModel>[];
      final ctrl = Get.put(ScoreboardController());
      expect(ctrl.players, isEmpty);
    });

    test('handles non-List arguments gracefully', () {
      Get.routing.args = 'invalid argument';
      // Should not throw – guard checks type
      expect(() => Get.put(ScoreboardController()), returnsNormally);
    });
  });

  group('ScoreboardController – isMVP', () {
    test('index 0 is MVP when score > 0', () {
      Get.routing.args = [_p('Winner', 5), _p('Loser', 1)];
      final ctrl = Get.put(ScoreboardController());
      expect(ctrl.isMVP(0), true);
    });

    test('index 0 is NOT MVP when score == 0', () {
      Get.routing.args = [_p('NoWin', 0), _p('NoBetter', 0)];
      final ctrl = Get.put(ScoreboardController());
      expect(ctrl.isMVP(0), false);
    });

    test('non-zero index is never MVP', () {
      Get.routing.args = [_p('First', 5), _p('Second', 3)];
      final ctrl = Get.put(ScoreboardController());
      expect(ctrl.isMVP(1), false);
    });
  });

  group('ScoreboardController – isBiggestChicken', () {
    test('last player with lowest unique score is chicken', () {
      Get.routing.args = [_p('A', 5), _p('B', 3), _p('C', 1)];
      final ctrl = Get.put(ScoreboardController());
      expect(ctrl.isBiggestChicken(2), true);
    });

    test('not chicken when all scores are equal (tie)', () {
      Get.routing.args = [_p('A', 0), _p('B', 0), _p('C', 0)];
      final ctrl = Get.put(ScoreboardController());
      expect(ctrl.isBiggestChicken(2), false);
    });

    test('not chicken with only 1 player', () {
      Get.routing.args = [_p('Solo', 3)];
      final ctrl = Get.put(ScoreboardController());
      expect(ctrl.isBiggestChicken(0), false);
    });

    test('middle player is NOT chicken even with lower score', () {
      Get.routing.args = [_p('A', 5), _p('B', 2), _p('C', 1)];
      final ctrl = Get.put(ScoreboardController());
      expect(ctrl.isBiggestChicken(1), false);
    });
  });
}
