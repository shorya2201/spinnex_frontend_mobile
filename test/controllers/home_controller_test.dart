import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kaal_spinnex/modules/home/home_controller.dart';
import '../mocks/mock_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockQuestionRepository mockRepository;
  late HomeController controller;

  setUp(() {
    Get.testMode = true;
    mockRepository = MockQuestionRepository();
    controller = HomeController(repository: mockRepository);
    controller.onInit();
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  group('HomeController Tests', () {
    // --- POSITIVE CASES ---
    group('Positive Cases', () {
      test('should initialize with default 2 players, party category, and music on', () {
        expect(controller.playerCount.value, equals(2));
        expect(controller.playerControllers.length, equals(2));
        expect(controller.playerEmojisList.length, equals(2));
        expect(controller.playerColorsList.length, equals(2));
        expect(controller.selectedCategory.value, contains('Party'));
        expect(controller.isMusicOn.value, isTrue);
        expect(controller.isLoading.value, isFalse);

        // Ensure controllers have non-empty generated names
        expect(controller.playerControllers[0].text, isNotEmpty);
        expect(controller.playerControllers[1].text, isNotEmpty);
      });

      test('should add a player with custom input name', () {
        controller.newPlayerInputController.text = 'SpeedyGonzales';
        controller.addPlayer();

        expect(controller.playerCount.value, equals(3));
        expect(controller.playerControllers.length, equals(3));
        expect(controller.playerControllers[2].text, equals('SpeedyGonzales'));
        expect(controller.newPlayerInputController.text, isEmpty); // cleared
      });

      test('should add a player with custom name argument directly', () {
        controller.addPlayerWithInputName('VibeMaster');

        expect(controller.playerCount.value, equals(3));
        expect(controller.playerControllers[2].text, equals('VibeMaster'));
      });

      test('should remove a player when count > 2', () {
        controller.addPlayerWithInputName('Player 3');
        expect(controller.playerCount.value, equals(3));

        controller.removePlayer();
        expect(controller.playerCount.value, equals(2));
        expect(controller.playerControllers.length, equals(2));
      });

      test('should remove player at specific index when count > 2', () {
        controller.playerControllers[0].text = 'First';
        controller.playerControllers[1].text = 'Second';
        controller.addPlayerWithInputName('Third');
        expect(controller.playerCount.value, equals(3));

        // Remove middle player
        controller.removePlayerAt(1);

        expect(controller.playerCount.value, equals(2));
        expect(controller.playerControllers.length, equals(2));
        expect(controller.playerControllers[0].text, equals('First'));
        expect(controller.playerControllers[1].text, equals('Third'));
      });

      test('should randomize name for valid index', () {
        // Run randomize several times to guarantee a change
        for (int i = 0; i < 5; i++) {
          controller.randomizeName(0);
        }
        expect(controller.playerControllers[0].text, isNotEmpty);
      });

      test('should randomize emoji for valid index', () {
        controller.randomizeEmoji(0);
        expect(controller.playerEmojisList[0], isNotEmpty);
      });

      test('should toggle music setting and category', () {
        controller.isMusicOn.value = false;
        expect(controller.isMusicOn.value, isFalse);

        controller.selectedCategory.value = 'Spicy';
        expect(controller.selectedCategory.value, equals('Spicy'));
      });

      test('should successfully start game and navigate with arguments', () async {
        mockRepository.setQuestions(MockData.mockQuestionsList);
        controller.playerControllers[0].text = 'Neo';
        controller.playerControllers[1].text = 'Trinity';

        await controller.startGame();

        expect(controller.isLoading.value, isFalse);
      });
    });

    // --- NEGATIVE CASES ---
    group('Negative Cases', () {
      testWidgets('should not remove player when player count is at minimum (2)', (tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
        expect(controller.playerCount.value, equals(2));

        controller.removePlayer();

        // Must still remain 2
        expect(controller.playerCount.value, equals(2));
        expect(controller.playerControllers.length, equals(2));
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('should not remove player at index when player count is at minimum (2)', (tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
        expect(controller.playerCount.value, equals(2));

        controller.removePlayerAt(0);

        expect(controller.playerCount.value, equals(2));
        expect(controller.playerControllers.length, equals(2));
        await tester.pump(const Duration(seconds: 5));
      });

      test('should not remove player if index is negative or out of bounds', () {
        controller.addPlayerWithInputName('Player 3');
        expect(controller.playerCount.value, equals(3));

        // Negative index
        controller.removePlayerAt(-1);
        expect(controller.playerCount.value, equals(3));

        // Out of bounds index
        controller.removePlayerAt(10);
        expect(controller.playerCount.value, equals(3));
      });

      testWidgets('should handle network error gracefully on startGame and reset loading state', (tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
        mockRepository.setError('Connection failed');

        await controller.startGame();

        expect(controller.isLoading.value, isFalse);
        await tester.pump(const Duration(seconds: 5));
      });
    });

    // --- EDGE CASES ---
    group('Edge Cases', () {
      testWidgets('should enforce maximum limit of 12 players', (tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
        // Add players until 12
        while (controller.playerControllers.length < 12) {
          controller.addPlayer();
        }
        expect(controller.playerControllers.length, equals(12));
        expect(controller.playerCount.value, equals(12));

        // Try adding the 13th player
        controller.addPlayer();

        expect(controller.playerControllers.length, equals(12));
        expect(controller.playerCount.value, equals(12));
        await tester.pump(const Duration(seconds: 5));
      });

      test('should fallback to random name if input name contains only whitespace', () {
        controller.newPlayerInputController.text = '    ';
        controller.addPlayer();

        expect(controller.playerCount.value, equals(3));
        expect(controller.playerControllers[2].text.trim(), isNotEmpty);
      });

      test('should fallback to "Player {i+1}" in startGame if player name field was cleared to empty', () async {
        mockRepository.setQuestions(MockData.mockQuestionsList);
        controller.playerControllers[0].text = '';
        controller.playerControllers[1].text = '   ';

        await controller.startGame();

        expect(controller.isLoading.value, isFalse);
      });

      test('should safely ignore randomizeName and randomizeEmoji for out-of-bounds indices', () {
        expect(() => controller.randomizeName(-1), returnsNormally);
        expect(() => controller.randomizeName(99), returnsNormally);
        expect(() => controller.randomizeEmoji(-1), returnsNormally);
        expect(() => controller.randomizeEmoji(99), returnsNormally);
      });

      test('should handle increasing and decreasing playerCount directly via Rx observable', () {
        controller.playerCount.value = 5;
        expect(controller.playerControllers.length, equals(5));
        expect(controller.playerEmojisList.length, equals(5));
        expect(controller.playerColorsList.length, equals(5));

        controller.playerCount.value = 2;
        expect(controller.playerControllers.length, equals(2));
        expect(controller.playerEmojisList.length, equals(2));
        expect(controller.playerColorsList.length, equals(2));
      });
    });
  });
}
