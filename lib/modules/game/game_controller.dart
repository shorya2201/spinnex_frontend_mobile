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
  RxDouble get rotationAngle => currentAngle;
  void spin() => triggerSelection();
  void finishGame() => endGame();

  var selectedPlayerIndex = (-1).obs;
  var highlightedPlayerIndex = (-1).obs;
  var showActionButtons = false.obs;
  var isSpinning = false.obs;

  // Shuffle Bag & Boundary Duplicate Protection state
  final List<int> _playerDrawBag = [];
  int _lastSelectedPlayerIndex = -1;

  // Non-repeating Question Draw Decks
  final List<Question> _truthQuestionDeck = [];
  final List<Question> _dareQuestionDeck = [];

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
    });
  }

  void setSelectorMode(String mode) {
    if (isSpinning.value) return;
    selectedSelectorMode.value = mode;
  }

  /// Draws the next player index using a Shuffle Bag (Deck Drawing) algorithm.
  /// Guarantees every player is selected once per round before anyone is picked again.
  /// Boundary Protection prevents the same player from being selected twice in a row,
  /// even across bag reset boundaries.
  int _drawNextPlayerIndex(Random random) {
    if (players.isEmpty) return 0;
    if (players.length == 1) return 0;

    // Refill and shuffle bag when empty
    if (_playerDrawBag.isEmpty) {
      _playerDrawBag.addAll(List<int>.generate(players.length, (index) => index));
      _playerDrawBag.shuffle(random);

      // Boundary Protection: If first player in new bag matches last selected player, swap it!
      if (_playerDrawBag.first == _lastSelectedPlayerIndex && _playerDrawBag.length > 1) {
        int swapIndex = 1 + random.nextInt(_playerDrawBag.length - 1);
        int temp = _playerDrawBag[0];
        _playerDrawBag[0] = _playerDrawBag[swapIndex];
        _playerDrawBag[swapIndex] = temp;
      }
    }

    int nextIndex = _playerDrawBag.removeAt(0);
    _lastSelectedPlayerIndex = nextIndex;
    return nextIndex;
  }

  VoidCallback? _lastAnimationListener;

  void triggerSelection() {
    if (isSpinning.value) return;
    if (players.isEmpty) return;

    isSpinning.value = true;
    showActionButtons.value = false;
    selectedPlayerIndex.value = -1;
    highlightedPlayerIndex.value = -1;

    final random = Random();
    int targetIndex = _drawNextPlayerIndex(random);

    if (selectedSelectorMode.value == 'Jackpot') {
      _runJackpotSelection(random, targetIndex);
    } else {
      _runRotationalSelection(random, targetIndex);
    }
  }

  void _runJackpotSelection(Random random, int targetIndex) async {
    int totalSteps = 25 + random.nextInt(10);
    int currentStep = 0;

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

  void _runRotationalSelection(Random random, int targetIndex) {
    double slice = (2 * pi) / players.length;
    double targetAngleForIndex = targetIndex * slice - (pi / 2);

    double currentModulo = currentAngle.value % (2 * pi);
    double angleDistance = targetAngleForIndex - currentModulo;
    if (angleDistance <= 0) {
      angleDistance += 2 * pi;
    }

    double fullSpins = (5 + random.nextInt(4)) * 2 * pi;
    double endAngle = currentAngle.value + fullSpins + angleDistance;

    if (_lastAnimationListener != null) {
      _animationController.removeListener(_lastAnimationListener!);
    }

    _animation = Tween<double>(
      begin: currentAngle.value,
      end: endAngle,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.decelerate,
      ),
    );

    _animationController.duration = Duration(milliseconds: 3200 + random.nextInt(800));

    void listener() {
      if (_animationController.isAnimating) {
        currentAngle.value = _animation.value;

        double normalized = (currentAngle.value + (slice / 2)) % (2 * pi);
        if (normalized < 0) normalized += 2 * pi;
        int stepIndex = (normalized / slice).floor() % players.length;
        highlightedPlayerIndex.value = stepIndex;
      }
    }

    _lastAnimationListener = listener;
    _animationController.addListener(listener);

    _animationController.forward(from: 0.0).then((_) {
      _onSpinComplete(precalculatedIndex: targetIndex);
    });
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
          players[selectedPlayerIndex.value] = updatedPlayer; // Triggers UI update

          // Reset the board for the next spin
          showActionButtons.value = false;
          selectedPlayerIndex.value = -1;
        },
      },
    );
  }

  Question? getChallenge(String type) {
    final isTruth = type.toUpperCase() == 'TRUTH';
    final deck = isTruth ? _truthQuestionDeck : _dareQuestionDeck;

    if (deck.isEmpty) {
      var available = questions
          .where((q) => q.type.toUpperCase() == type.toUpperCase())
          .toList();
      if (available.isEmpty) return null;

      available.shuffle();
      deck.addAll(available);
    }

    return deck.removeAt(0);
  }

  void endGame() {
    Get.toNamed(Routes.SCOREBOARD, arguments: players.toList());
  }

  @override
  void onClose() {
    _animationController.dispose();
    super.onClose();
  }
}

