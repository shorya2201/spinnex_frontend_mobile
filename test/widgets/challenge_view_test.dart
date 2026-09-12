import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kaal_spinnex/data/models/player_model.dart';
import 'package:kaal_spinnex/modules/challenge/challenge_controller.dart';
import 'package:kaal_spinnex/modules/challenge/challenge_view.dart';
import '../mocks/mock_data.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestableWidget(ChallengeController controller) {
    Get.put<ChallengeController>(controller);
    return GetMaterialApp(
      initialRoute: '/challenge',
      getPages: [
        GetPage(name: '/challenge', page: () => const ChallengeView()),
        GetPage(name: '/game', page: () => const Scaffold(body: Text('Game View'))),
      ],
    );
  }

  group('ChallengeView Widget Tests', () {
    testWidgets('should render DARE challenge with 2 points reward and action buttons', (WidgetTester tester) async {
      int awardedPoints = 0;
      Get.routing.args = {
        'player': PlayerModel(name: 'Sam', score: 3),
        'question': MockData.dareQuestion1,
        'onComplete': (int points) {
          awardedPoints = points;
        },
      };

      final controller = ChallengeController();

      await tester.pumpWidget(buildTestableWidget(controller));
      await tester.pump();

      expect(find.text('Sam'), findsOneWidget);
      expect(find.text('DARE CHALLENGE'), findsOneWidget);
      expect(find.text(MockData.dareQuestion1.content), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
      expect(find.text('CHICKEN OUT'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('+2 PTS'), findsOneWidget);

      // Tap complete challenge
      await tester.tap(find.text('COMPLETED'));
      await tester.pump();

      expect(awardedPoints, equals(2));

      controller.onClose();
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });

    testWidgets('should render TRUTH challenge with 1 point reward button and handle chicken out', (WidgetTester tester) async {
      int awardedPoints = 0;
      Get.routing.args = {
        'player': PlayerModel(name: 'Mia', score: 2),
        'question': MockData.truthQuestion1,
        'onComplete': (int points) {
          awardedPoints = points;
        },
      };

      final controller = ChallengeController();

      await tester.pumpWidget(buildTestableWidget(controller));
      await tester.pump();

      expect(find.text('Mia'), findsOneWidget);
      expect(find.text('TRUTH QUESTION'), findsOneWidget);
      expect(find.text(MockData.truthQuestion1.content), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('+1 PTS'), findsOneWidget);

      // Tap chicken out
      await tester.tap(find.text('CHICKEN OUT'));
      await tester.pump();

      expect(awardedPoints, equals(-1));

      controller.onClose();
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });
}
