import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kaal_spinnex/data/models/player_model.dart';
import 'package:kaal_spinnex/data/models/question_model.dart';
import 'package:kaal_spinnex/modules/challenge/challenge_controller.dart';

Question _q(String type) => Question(
      id: 1,
      content: 'Test question',
      type: type,
      category: 'CLASSIC',
    );

PlayerModel _player() => PlayerModel(name: 'Alice');

void main() {
  setUp(() {
    Get.testMode = true;
  });
  tearDown(() => Get.reset());

  ChallengeController _buildCtrl(String type, {Function(int)? onComplete}) {
    Get.routing.args = {
      'player': _player(),
      'question': _q(type),
      'onComplete': onComplete ?? (_) {},
    };
    return Get.put(ChallengeController());
  }

  group('ChallengeController – type detection', () {
    test('isDare is true for DARE type', () {
      final ctrl = _buildCtrl('DARE');
      expect(ctrl.isDare, true);
    });

    test('isDare is true for lowercase dare', () {
      final ctrl = _buildCtrl('dare');
      expect(ctrl.isDare, true);
    });

    test('isDare is false for TRUTH type', () {
      final ctrl = _buildCtrl('TRUTH');
      expect(ctrl.isDare, false);
    });

    test('typeLabel returns DARE CHALLENGE for dare', () {
      expect(_buildCtrl('DARE').typeLabel, 'DARE CHALLENGE');
    });

    test('typeLabel returns TRUTH QUESTION for truth', () {
      expect(_buildCtrl('TRUTH').typeLabel, 'TRUTH QUESTION');
    });

    test('typeIcon is 🔥 for dare', () {
      expect(_buildCtrl('DARE').typeIcon, '🔥');
    });

    test('typeIcon is 👁️ for truth', () {
      expect(_buildCtrl('TRUTH').typeIcon, '👁️');
    });
  });

  group('ChallengeController – rewardPoints', () {
    test('dare rewards 2 points', () {
      expect(_buildCtrl('DARE').rewardPoints, 2);
    });

    test('truth rewards 1 point', () {
      expect(_buildCtrl('TRUTH').rewardPoints, 1);
    });
  });

  group('ChallengeController – isLowTime', () {
    test('isLowTime is false when timeLeft > 10', () {
      final ctrl = _buildCtrl('TRUTH');
      ctrl.timeLeft.value = 11;
      expect(ctrl.isLowTime, false);
    });

    test('isLowTime is true at exactly 10 (boundary inclusive)', () {
      final ctrl = _buildCtrl('TRUTH');
      ctrl.timeLeft.value = 10;
      expect(ctrl.isLowTime, true);
    });

    test('isLowTime is true at 5', () {
      final ctrl = _buildCtrl('TRUTH');
      ctrl.timeLeft.value = 5;
      expect(ctrl.isLowTime, true);
    });

    test('isLowTime is true at 0', () {
      final ctrl = _buildCtrl('TRUTH');
      ctrl.timeLeft.value = 0;
      expect(ctrl.isLowTime, true);
    });
  });

  group('ChallengeController – completeChallenge', () {
    test('calls onComplete with rewardPoints for DARE (2)', () {
      int receivedPoints = -999;
      final ctrl = _buildCtrl('DARE', onComplete: (p) => receivedPoints = p);
      ctrl.completeChallenge();
      expect(receivedPoints, 2);
    });

    test('calls onComplete with rewardPoints for TRUTH (1)', () {
      int receivedPoints = -999;
      final ctrl = _buildCtrl('TRUTH', onComplete: (p) => receivedPoints = p);
      ctrl.completeChallenge();
      expect(receivedPoints, 1);
    });
  });

  group('ChallengeController – chickenOut', () {
    test('calls onComplete with -1 penalty', () {
      int receivedPoints = 0;
      final ctrl = _buildCtrl('DARE', onComplete: (p) => receivedPoints = p);
      ctrl.chickenOut();
      expect(receivedPoints, -1);
    });

    test('chickenOut on TRUTH also passes -1', () {
      int receivedPoints = 0;
      final ctrl = _buildCtrl('TRUTH', onComplete: (p) => receivedPoints = p);
      ctrl.chickenOut();
      expect(receivedPoints, -1);
    });
  });

  group('ChallengeController – timer', () {
    test('initial timeLeft is 45', () {
      final ctrl = _buildCtrl('TRUTH');
      expect(ctrl.timeLeft.value, 45);
    });

    test('timeLeft decrements after 1 second', () async {
      final ctrl = _buildCtrl('TRUTH');
      await Future.delayed(const Duration(seconds: 2));
      expect(ctrl.timeLeft.value, lessThan(45));
    });
  });
}
