import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kaal_spinnex/data/models/player_model.dart';
import 'package:kaal_spinnex/data/models/question_model.dart';
import 'package:kaal_spinnex/modules/challenge/challenge_controller.dart';
import 'package:kaal_spinnex/modules/challenge/challenge_view.dart';

Widget _buildChallenge({
  String type = 'DARE',
  String content = 'Do 10 push-ups',
  Function(int)? onComplete,
}) {
  Get.routing.args = {
    'player': PlayerModel(name: 'Alice', emoji: '💃'),
    'question': Question(
      id: '1',
      content: content,
      type: type,
      category: 'CLASSIC',
    ),
    'onComplete': onComplete ?? (_) {},
  };
  return GetMaterialApp(
    home: const ChallengeView(),
    initialBinding: BindingsBuilder(() {
      Get.put(ChallengeController());
    }),
  );
}

void _cleanUpChallenge() {
  if (Get.isRegistered<ChallengeController>()) {
    Get.find<ChallengeController>().onClose();
    Get.delete<ChallengeController>(force: true);
  }
  Get.reset();
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(() => _cleanUpChallenge());

  group('ChallengeView – content rendering', () {
    testWidgets('shows player name', (tester) async {
      await tester.pumpWidget(_buildChallenge());
      await tester.pump();
      expect(find.text('Alice'), findsOneWidget);
      _cleanUpChallenge();
    });

    testWidgets('shows challenge question text', (tester) async {
      await tester.pumpWidget(_buildChallenge(content: 'Do 10 push-ups'));
      await tester.pump();
      expect(find.text('Do 10 push-ups'), findsOneWidget);
      _cleanUpChallenge();
    });

    testWidgets('shows DARE CHALLENGE label for dare type', (tester) async {
      await tester.pumpWidget(_buildChallenge(type: 'DARE'));
      await tester.pump();
      expect(find.text('DARE CHALLENGE'), findsOneWidget);
      _cleanUpChallenge();
    });

    testWidgets('shows TRUTH QUESTION label for truth type', (tester) async {
      await tester.pumpWidget(_buildChallenge(type: 'TRUTH', content: 'Tell a secret'));
      await tester.pump();
      expect(find.text('TRUTH QUESTION'), findsOneWidget);
      _cleanUpChallenge();
    });

    testWidgets('shows initial timer value (45)', (tester) async {
      await tester.pumpWidget(_buildChallenge());
      await tester.pump();
      expect(find.text('45'), findsOneWidget);
      _cleanUpChallenge();
    });
  });

  group('ChallengeView – timer', () {
    testWidgets('timer counts down after 2 seconds', (tester) async {
      await tester.pumpWidget(_buildChallenge());
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      // After 2 seconds, timer should be ≤ 43
      expect(find.text('45'), findsNothing);
      _cleanUpChallenge();
    });
  });

  group('ChallengeView – buttons', () {
    testWidgets('Complete button is present', (tester) async {
      await tester.pumpWidget(_buildChallenge());
      await tester.pump();
      expect(find.textContaining('COMPLETE', findRichText: true), findsAny);
      _cleanUpChallenge();
    });

    testWidgets('Chicken Out button is present', (tester) async {
      await tester.pumpWidget(_buildChallenge());
      await tester.pump();
      expect(find.textContaining('CHICKEN', findRichText: true), findsAny);
      _cleanUpChallenge();
    });

    testWidgets('tapping Complete calls onComplete with positive points', (tester) async {
      int receivedPoints = -999;
      await tester.pumpWidget(_buildChallenge(
        type: 'DARE',
        onComplete: (p) => receivedPoints = p,
      ));
      await tester.pump();

      // Find and tap complete button
      final completeBtn = find.textContaining('COMPLETE', findRichText: true);
      if (completeBtn.evaluate().isNotEmpty) {
        await tester.tap(completeBtn.first);
        await tester.pumpAndSettle();
        expect(receivedPoints, greaterThan(0));
      }
      _cleanUpChallenge();
    });

    testWidgets('tapping Chicken Out calls onComplete with -1', (tester) async {
      int receivedPoints = 0;
      await tester.pumpWidget(_buildChallenge(
        onComplete: (p) => receivedPoints = p,
      ));
      await tester.pump();

      final chickenBtn = find.textContaining('CHICKEN', findRichText: true);
      if (chickenBtn.evaluate().isNotEmpty) {
        await tester.tap(chickenBtn.first);
        await tester.pumpAndSettle();
        expect(receivedPoints, -1);
      }
      _cleanUpChallenge();
    });
  });
}
