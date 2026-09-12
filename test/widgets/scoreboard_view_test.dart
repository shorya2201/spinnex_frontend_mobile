import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kaal_spinnex/data/models/player_model.dart';
import 'package:kaal_spinnex/modules/scoreboard/scoreboard_controller.dart';
import 'package:kaal_spinnex/modules/scoreboard/scoreboard_view.dart';
import '../mocks/mock_data.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestableWidget(ScoreboardController controller) {
    Get.put<ScoreboardController>(controller);
    return GetMaterialApp(
      initialRoute: '/scoreboard',
      getPages: [
        GetPage(name: '/scoreboard', page: () => const ScoreboardView()),
        GetPage(name: '/home', page: () => const Scaffold(body: Text('Home View'))),
      ],
    );
  }

  group('ScoreboardView Widget Tests', () {
    // --- POSITIVE CASES ---
    testWidgets('should render final scores list with MVP and Chicken badges', (WidgetTester tester) async {
      final controller = ScoreboardController();
      controller.players.assignAll([
        PlayerModel(name: 'Alice', score: 10),
        PlayerModel(name: 'Bob', score: 3),
        PlayerModel(name: 'Charlie', score: -1),
      ]);

      await tester.pumpWidget(buildTestableWidget(controller));
      await tester.pumpAndSettle();

      expect(find.text('FINAL SCORES'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('10 pts'), findsOneWidget);
      expect(find.text('👑 PARTY MVP'), findsOneWidget);

      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('3 pts'), findsOneWidget);

      expect(find.text('Charlie'), findsOneWidget);
      expect(find.text('-1 pts'), findsOneWidget);
      expect(find.text('🐔 CHICKENED OUT'), findsOneWidget);

      expect(find.text('PLAY AGAIN'), findsOneWidget);
    });

    // --- NEGATIVE / EMPTY EDGE CASE ---
    testWidgets('should display empty message when players list is empty', (WidgetTester tester) async {
      final controller = ScoreboardController();
      controller.players.clear();

      await tester.pumpWidget(buildTestableWidget(controller));
      await tester.pumpAndSettle();

      expect(find.text('No game data found.'), findsOneWidget);
      expect(find.text('PLAY AGAIN'), findsOneWidget);
    });

    testWidgets('should trigger playAgain on tapping PLAY AGAIN button', (WidgetTester tester) async {
      final controller = ScoreboardController();
      controller.players.assignAll(MockData.standardTwoPlayers);

      await tester.pumpWidget(buildTestableWidget(controller));
      await tester.pumpAndSettle();

      final newGameBtn = find.text('PLAY AGAIN');
      expect(newGameBtn, findsOneWidget);
      await tester.tap(newGameBtn);
      await tester.pumpAndSettle();
    });
  });
}
