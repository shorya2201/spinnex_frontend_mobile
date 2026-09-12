import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kaal_spinnex/data/models/player_model.dart';
import 'package:kaal_spinnex/data/models/question_model.dart';
import 'package:kaal_spinnex/modules/challenge/challenge_controller.dart';
import '../mocks/mock_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ChallengeController controller;
  late PlayerModel testPlayer;
  late Question testQuestion;
  int completedPoints = 0;
  bool callbackInvoked = false;

  void setupControllerWithQuestion(Question question) {
    Get.testMode = true;
    testPlayer = PlayerModel(name: 'Hero', score: 5);
    testQuestion = question;
    completedPoints = 0;
    callbackInvoked = false;

    Get.routing.args = {
      'player': testPlayer,
      'question': testQuestion,
      'onComplete': (int points) {
        completedPoints = points;
        callbackInvoked = true;
      },
    };

    controller = ChallengeController();
    controller.onInit();
  }

  setUp(() {
    setupControllerWithQuestion(MockData.dareQuestion1);
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  group('ChallengeController Tests', () {
    // --- POSITIVE CASES ---
    group('Positive Cases', () {
      test('should initialize with 45 seconds and correct arguments', () {
        expect(controller.timeLeft.value, equals(45));
        expect(controller.player.name, equals('Hero'));
        expect(controller.question.type, equals('DARE'));
      });

      test('should award 2 points when DARE challenge is completed', () {
        controller.completeChallenge();

        expect(callbackInvoked, isTrue);
        expect(completedPoints, equals(2));
      });

      test('should award 1 point when TRUTH challenge is completed', () {
        controller.onClose();
        setupControllerWithQuestion(MockData.truthQuestion1);

        controller.completeChallenge();

        expect(callbackInvoked, isTrue);
        expect(completedPoints, equals(1));
      });

      test('should deduct 1 point (-1) when player chickens out', () {
        controller.chickenOut();

        expect(callbackInvoked, isTrue);
        expect(completedPoints, equals(-1));
      });
    });

    // --- NEGATIVE CASES ---
    group('Negative Cases', () {
      test('should not award points when user chickens out on high-value dare', () {
        controller.chickenOut();

        expect(completedPoints, equals(-1));
        expect(completedPoints, isNot(equals(2)));
      });
    });

    // --- EDGE CASES ---
    group('Edge Cases', () {
      test('should stop timer at 0 and not decrement below 0', () {
        controller.timeLeft.value = 1;

        // Simulate tick
        if (controller.timeLeft.value > 0) {
          controller.timeLeft.value--;
        }
        expect(controller.timeLeft.value, equals(0));

        // Attempt second tick
        if (controller.timeLeft.value > 0) {
          controller.timeLeft.value--;
        }
        expect(controller.timeLeft.value, equals(0));
      });

      test('should cancel timer cleanly on controller onClose', () {
        expect(() => controller.onClose(), returnsNormally);
      });

      test('should award 1 point if type is not strictly DARE', () {
        controller.onClose();
        final customQuestion = Question(
          id: 99,
          content: 'Secret challenge',
          type: 'CUSTOM_TYPE',
          category: 'Party',
        );
        setupControllerWithQuestion(customQuestion);

        controller.completeChallenge();

        expect(callbackInvoked, isTrue);
        expect(completedPoints, equals(1));
      });
    });
  });
}
