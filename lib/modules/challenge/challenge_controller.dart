import 'dart:async';
import 'package:get/get.dart';
import '../../data/models/player_model.dart';
import '../../data/models/question_model.dart';

class ChallengeController extends GetxController {
  late PlayerModel player;
  late Question question; // <- FIXED: Changed from QuestionModel to Question
  late Function(int) onComplete;

  var timeLeft = 45.obs;
  Timer? _timer;

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
    int points = question.type == 'DARE' ? 2 : 1;
    onComplete(points);
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
