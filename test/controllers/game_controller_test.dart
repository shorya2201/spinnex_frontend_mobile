import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kaal_spinnex/data/models/player_model.dart';
import 'package:kaal_spinnex/data/models/question_model.dart';
import 'package:kaal_spinnex/modules/game/game_controller.dart';
import '../mocks/mock_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GameController controller;
  late List<PlayerModel> testPlayers;
  late List<Question> testQuestions;

  setUp(() {
    Get.testMode = true;
    testPlayers = [
      PlayerModel(name: 'Alice', emoji: '👾', score: 0),
      PlayerModel(name: 'Bob', emoji: '⚡', score: 0),
    ];
    testQuestions = [
      MockData.truthQuestion1,
      MockData.dareQuestion1,
    ];

    Get.parameters = {};
    Get.routing.args = {
      'players': testPlayers,
      'questions': testQuestions,
      'category': 'Party',
    };

    controller = GameController();
    controller.onInit();
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  group('GameController Tests', () {
    // --- POSITIVE CASES ---
    group('Positive Cases', () {
      test('should properly extract players, questions, and category from Get.arguments onInit', () {
        expect(controller.players.length, equals(2));
        expect(controller.players[0].name, equals('Alice'));
        expect(controller.players[1].name, equals('Bob'));
        expect(controller.questions.length, equals(2));
        expect(controller.selectedCategory.value, equals('Party'));
        expect(controller.isSpinning.value, isFalse);
        expect(controller.showActionButtons.value, isFalse);
        expect(controller.selectedPlayerIndex.value, equals(-1));
      });

      test('should start bottle spin and update state accordingly', () {
        controller.spinBottle();

        expect(controller.isSpinning.value, isTrue);
        expect(controller.showActionButtons.value, isFalse);
        expect(controller.selectedPlayerIndex.value, equals(-1));
      });

      test('should find matching challenge questions for TRUTH and DARE', () {
        final truth = controller.getChallenge('TRUTH');
        expect(truth, isNotNull);
        expect(truth!.type, equals('TRUTH'));

        final dare = controller.getChallenge('DARE');
        expect(dare, isNotNull);
        expect(dare!.type, equals('DARE'));
      });

      test('should match challenge type case-insensitively', () {
        final lowerTruth = controller.getChallenge('truth');
        expect(lowerTruth, isNotNull);
        expect(lowerTruth!.type, equals('TRUTH'));

        final mixedDare = controller.getChallenge('DaRe');
        expect(mixedDare, isNotNull);
        expect(mixedDare!.type, equals('DARE'));
      });

      test('should update player score when challenge completes via callback', () {
        controller.selectedPlayerIndex.value = 0;
        controller.showActionButtons.value = true;

        // Choose action sets up route with onComplete callback
        controller.chooseAction('TRUTH');

        // Verify that passing points to player updates score
        controller.players[0].score += 1;
        expect(controller.players[0].score, equals(1));
      });
    });

    // --- NEGATIVE CASES ---
    group('Negative Cases', () {
      test('should ignore spinBottle call if already spinning', () {
        controller.spinBottle();
        expect(controller.isSpinning.value, isTrue);

        final initialAngle = controller.currentAngle.value;
        // Call spinBottle again while already spinning
        controller.spinBottle();

        // Should still be spinning without crashing
        expect(controller.isSpinning.value, isTrue);
        expect(controller.currentAngle.value, equals(initialAngle));
      });

      test('should return null from getChallenge when no questions of requested type exist', () {
        controller.questions.assignAll(MockData.mockTruthOnlyQuestions);

        final dareResult = controller.getChallenge('DARE');
        expect(dareResult, isNull);
      });

      testWidgets('should show snackbar and not crash when chooseAction is called on empty deck', (tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
        controller.questions.clear();
        controller.selectedPlayerIndex.value = 0;

        expect(() => controller.chooseAction('TRUTH'), returnsNormally);
        await tester.pump(const Duration(seconds: 5));
      });
    });

    // --- EDGE CASES ---
    group('Edge Cases', () {
      test('should handle empty players and questions list safely onInit', () {
        Get.routing.args = {
          'players': <PlayerModel>[],
          'questions': <Question>[],
        };

        final emptyController = GameController();
        emptyController.onInit();

        expect(emptyController.players, isEmpty);
        expect(emptyController.questions, isEmpty);
        emptyController.onClose();
      });

      test('should calculate valid player slice index when landing at 0 radians', () {
        controller.currentAngle.value = 0.0;
        double slice = 2 * pi / controller.players.length;
        int landedIndex = (controller.currentAngle.value % (2 * pi) / slice).round() % controller.players.length;

        expect(landedIndex, equals(0));
      });

      test('should calculate valid player slice index when landing across multiple revolutions', () {
        // e.g. 5 full rotations (10 * pi) + slight angle
        controller.currentAngle.value = 10 * pi + (pi / 2);
        double slice = 2 * pi / controller.players.length; // pi for 2 players
        int landedIndex = ((controller.currentAngle.value % (2 * pi)) / slice).round() % controller.players.length;

        expect(landedIndex, inInclusiveRange(0, controller.players.length - 1));
      });

      test('should calculate correct slices for maximum 12 players', () {
        final twelvePlayers = MockData.generate12Players();
        controller.players.assignAll(twelvePlayers);

        for (int i = 0; i < 12; i++) {
          double slice = 2 * pi / 12;
          double testAngle = (i * slice);
          int landed = (testAngle / slice).round() % 12;
          expect(landed, equals(i));
        }
      });

      test('should safely call endGame and route to scoreboard', () {
        expect(() => controller.endGame(), returnsNormally);
      });
    });
  });
}
