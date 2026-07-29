import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/player_model.dart';
import '../../data/models/question_model.dart';

class ChallengeController extends GetxController {
  late PlayerModel player;
  late Question question;
  late Function(int) onComplete;

  var timeLeft = 45.obs;
  Timer? _timer;

  bool get isLowTime => timeLeft.value <= 10;
  bool get isDare => question.type.toUpperCase() == 'DARE';
  Color get accentColor => isDare ? const Color(0xFFFF007F) : const Color(0xFF00FFFF);
  String get typeLabel => isDare ? 'DARE CHALLENGE' : 'TRUTH QUESTION';
  String get typeIcon => isDare ? '🔥' : '👁️';
  int get rewardPoints => isDare ? 2 : 1;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    player = args['player'];
    question = args['question'];
    onComplete = args['onComplete'];

    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        _timer?.cancel();
      }
    });
  }

  void completeChallenge() {
    onComplete(rewardPoints);
    Get.back();
  }

  void chickenOut() {
    onComplete(-1);
    Get.back();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

