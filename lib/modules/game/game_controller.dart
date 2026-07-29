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
  var selectedCategory = 'Classic (Family)'.obs;
  var selectedSelectorMode = 'Jackpot'.obs; // Active mode: 'Jackpot' (Options commented out: 'Bottle', 'Wheel', 'Radar')

  var currentAngle = 0.0.obs;
  var selectedPlayerIndex = (-1).obs;
  var highlightedPlayerIndex = (-1).obs;
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

    // 2. Initialize Animation Controller for selector animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Default dummy animation to prevent LateInitializationError
    _animation = Tween<double>(begin: 0.0, end: 0.0).animate(_animationController);

    _animationController.addListener(() {
      if (_animationController.isAnimating) {
        currentAngle.value = _animation.value;
      }
      /* Commented out spin angle listener:
      if (players.isNotEmpty && (selectedSelectorMode.value == 'Bottle' || selectedSelectorMode.value == 'Wheel')) {
        double normalizedAngle = currentAngle.value % (2 * pi);
        double slice = 2 * pi / players.length;
        highlightedPlayerIndex.value = (normalizedAngle / slice).round() % players.length;
      }
      */
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSpinComplete();
      }
    });
  }

  void setSelectorMode(String mode) {
    if (isSpinning.value) return;
    selectedSelectorMode.value = mode;
  }

  void triggerSelection() {
    if (isSpinning.value) return;
    if (players.isEmpty) return;

    isSpinning.value = true;
    showActionButtons.value = false;
    selectedPlayerIndex.value = -1;
    highlightedPlayerIndex.value = -1;

    final random = Random();

    /* Commented out spin/radar angular options:
    if (selectedSelectorMode.value == 'Bottle' || selectedSelectorMode.value == 'Wheel') {
      _runAngularSpin(random);
    } else if (selectedSelectorMode.value == 'Radar') {
      _runRadarPulseSelection(random);
    } else {
    */
    _runJackpotSelection(random);
  }

  /* Commented out spin option:
  void _runAngularSpin(Random random) {
    double extraSpins = (random.nextInt(4) + 4) * 2 * pi;
    double stopAngle = currentAngle.value + extraSpins + (random.nextDouble() * 2 * pi);

    _animation = Tween<double>(begin: currentAngle.value, end: stopAngle).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCirc),
    );

    _animationController.reset();
    _animationController.forward();
  }
  */

  /* Commented out radar pulse option:
  void _runRadarPulseSelection(Random random) async {
    int targetIndex = random.nextInt(players.length);
    int totalSteps = 25 + random.nextInt(10);
    int currentStep = 0;

    _animation = Tween<double>(begin: currentAngle.value, end: currentAngle.value + 6 * pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.reset();
    _animationController.forward();

    while (currentStep < totalSteps) {
      currentStep++;
      if (currentStep == totalSteps) {
        highlightedPlayerIndex.value = targetIndex;
      } else {
        highlightedPlayerIndex.value = (currentStep) % players.length;
      }

      int delay = 50 + ((currentStep * currentStep * 15) ~/ totalSteps);
      await Future.delayed(Duration(milliseconds: delay));
      if (!isSpinning.value) return;
    }

    _onSpinComplete(precalculatedIndex: targetIndex);
  }
  */

  void _runJackpotSelection(Random random) async {
    int targetIndex = random.nextInt(players.length);
    int totalSteps = 25 + random.nextInt(10);
    int currentStep = 0;

    _animation = Tween<double>(begin: currentAngle.value, end: currentAngle.value + 6 * pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.reset();
    _animationController.forward();

    while (currentStep < totalSteps) {
      currentStep++;
      if (currentStep == totalSteps) {
        highlightedPlayerIndex.value = targetIndex;
      } else {
        highlightedPlayerIndex.value = (currentStep) % players.length;
      }

      int delay = 40 + ((currentStep * currentStep * 12) ~/ totalSteps);
      await Future.delayed(Duration(milliseconds: delay));
      if (!isSpinning.value) return;
    }

    _onSpinComplete(precalculatedIndex: targetIndex);
  }

  void spinBottle() {
    triggerSelection();
  }

  void _onSpinComplete({int? precalculatedIndex}) {
    isSpinning.value = false;

    if (precalculatedIndex != null) {
      selectedPlayerIndex.value = precalculatedIndex;
      highlightedPlayerIndex.value = precalculatedIndex;
    } else {
      // Calculate which player it landed on from currentAngle
      double normalizedAngle = currentAngle.value % (2 * pi);
      double slice = 2 * pi / players.length;

      int landedIndex = (normalizedAngle / slice).round() % players.length;
      selectedPlayerIndex.value = landedIndex;
      highlightedPlayerIndex.value = landedIndex;
    }

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
