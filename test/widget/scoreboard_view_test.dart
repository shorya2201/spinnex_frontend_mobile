import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kaal_spinnex/data/models/player_model.dart';
import 'package:kaal_spinnex/modules/scoreboard/scoreboard_controller.dart';
import 'package:kaal_spinnex/modules/scoreboard/scoreboard_view.dart';

PlayerModel _p(String name, int score) => PlayerModel(name: name)..score = score;

Widget _buildScoreboard(List<PlayerModel> players) {
  Get.routing.args = players;
  return GetMaterialApp(
    home: const ScoreboardView(),
    initialBinding: BindingsBuilder(() {
      Get.put(ScoreboardController());
    }),
  );
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(() => Get.reset());

  group('ScoreboardView – rendering', () {
    testWidgets('shows all player names', (tester) async {
      await tester.pumpWidget(_buildScoreboard([
        _p('Alice', 5),
        _p('Bob', 3),
      ]));
      await tester.pump();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('shows scores for each player', (tester) async {
      await tester.pumpWidget(_buildScoreboard([
        _p('Alice', 7),
        _p('Bob', 2),
      ]));
      await tester.pump();

      expect(find.textContaining('7'), findsOneWidget);
    });

    testWidgets('top player is ranked first (sorted)', (tester) async {
      await tester.pumpWidget(_buildScoreboard([
        _p('Loser', 1),
        _p('Winner', 9),
      ]));
      await tester.pump();

      final ctrl = Get.find<ScoreboardController>();
      expect(ctrl.players[0].name, 'Winner');
    });

    testWidgets('shows Play Again button', (tester) async {
      await tester.pumpWidget(_buildScoreboard([_p('Solo', 0)]));
      await tester.pump();
      expect(find.textContaining('PLAY', findRichText: true), findsAny);
    });

    testWidgets('handles empty player list without crash', (tester) async {
      await tester.pumpWidget(_buildScoreboard([]));
      await tester.pump();
      // Should render without throwing
    });

    testWidgets('single player – no chicken badge shown', (tester) async {
      await tester.pumpWidget(_buildScoreboard([_p('Solo', 3)]));
      await tester.pump();
      final ctrl = Get.find<ScoreboardController>();
      expect(ctrl.isBiggestChicken(0), false);
    });
  });
}
