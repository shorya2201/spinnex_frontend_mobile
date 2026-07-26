import 'dart:math';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/player_model.dart';
import '../../data/models/question_model.dart';
import '../../routes/app_routes.dart';

class GameController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Observables bound to GameView
  var players = <PlayerModel>[].obs;
  var questions = <Question>[].obs;
  var selectedCategory = 'Classic'.obs;

  var currentAngle = 0.0.obs;
  var selectedPlayerIndex = (-1).obs;
  var showActionButtons = false.obs;
  var isSpinning = false.obs;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void onInit() {
    super.onInit();

    // 1. Retrieve arguments passed from HomeController
    final args = Get.arguments;
    if (args != null) {
      players.assignAll(args['players'] as List<PlayerModel>);
      questions.assignAll(args['questions'] as List<Question>);
      if (args['category'] != null) {
        selectedCategory.value = args['category'] as String;
      }
    }

    // 2. Initialize Animation Controller for the Bottle Spin
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Spin duration
    );

    _animationController.addListener(() {
      currentAngle.value = _animation.value;
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSpinComplete();
      }
    });
  }

  void spinBottle() {
    if (isSpinning.value) return;

    isSpinning.value = true;
    showActionButtons.value = false;
    selectedPlayerIndex.value = -1;

    // Randomize the spin distance
    final random = Random();
    // Spin randomly between 4 to 7 full circles + an extra random angle
    double extraSpins = (random.nextInt(4) + 4) * 2 * pi;
    double stopAngle =
        currentAngle.value + extraSpins + (random.nextDouble() * 2 * pi);

    _animation = Tween<double>(begin: currentAngle.value, end: stopAngle)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves
                .easeOutCirc, // Creates a realistic friction slowing down effect
          ),
        );

    _animationController.reset();
    _animationController.forward();
  }

  void _onSpinComplete() {
    isSpinning.value = false;

    // Calculate which player it landed on
    double normalizedAngle = currentAngle.value % (2 * pi);
    double slice = 2 * pi / players.length;

    // Round to the nearest "slice" of the circle
    int landedIndex = (normalizedAngle / slice).round() % players.length;

    selectedPlayerIndex.value = landedIndex;
    showActionButtons.value = true;
  }

  void chooseAction(String type) {
    Question? challenge = getChallenge(type);
    if (challenge == null) {
      Get.snackbar(
        "Out of Questions!",
        "No more $type questions left in this deck.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Navigate to Challenge View and wait for the result
    Get.toNamed(
      Routes.CHALLENGE,
      arguments: {
        'player': players[selectedPlayerIndex.value],
        'question': challenge,
        'onComplete': (int points) {
          // Update the player's score safely
          var updatedPlayer = players[selectedPlayerIndex.value];
          updatedPlayer.score += points;
          players[selectedPlayerIndex.value] =
              updatedPlayer; // Triggers UI update

          // Reset the board for the next spin
          showActionButtons.value = false;
          selectedPlayerIndex.value = -1;
        },
      },
    );
  }

  Question? getChallenge(String type) {
    var filtered = questions
        .where((q) => q.type.toUpperCase() == type.toUpperCase())
        .toList();
    if (filtered.isEmpty) return null;

    filtered.shuffle();
    return filtered.first;
  }

  void endGame() {
    // Navigate to scoreboard and pass the players list
    Get.offAllNamed(Routes.SCOREBOARD, arguments: players.toList());
  }

  @override
  void onClose() {
    _animationController.dispose();
    super.onClose();
  }
}
