import 'dart:math';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/player_model.dart';
import '../../data/models/question_model.dart';
import '../../data/models/room_models.dart';
import '../../routes/app_routes.dart';
import '../../services/stomp_service.dart';
import '../../theme/app_theme.dart';

class GameController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Observables bound to GameView
  var players = <PlayerModel>[].obs;
  var questions = <Question>[].obs;
  var selectedCategory = 'Classic (Family)'.obs;
  var selectedSelectorMode = 'Jackpot'.obs; // Active mode: 'Jackpot' (Options commented out: 'Bottle', 'Wheel', 'Radar')

  var currentAngle = 0.0.obs;
  RxDouble get rotationAngle => currentAngle;
  void spin() => isOnlineMode ? _sendOnlineSpin() : triggerSelection();
  void finishGame() => endGame();

  var selectedPlayerIndex = (-1).obs;
  var highlightedPlayerIndex = (-1).obs;
  var showActionButtons = false.obs;
  var isSpinning = false.obs;

  // ── Online multiplayer state ───────────────────────────────────
  bool isOnlineMode = false;
  String roomCode = '';
  String myPlayerId = '';
  bool isHostPlayer = false;
  final isPendingApproval = false.obs; // guest awaiting host decision

  // Incoming server question (overrides local deck in online mode)
  final Rx<Question?> serverQuestion = Rx<Question?>(null);

  StompService? get _stomp => Get.isRegistered<StompService>() ? Get.find<StompService>() : null;

  // Shuffle Bag & Boundary Duplicate Protection state
  final List<int> _playerDrawBag = [];
  int _lastSelectedPlayerIndex = -1;

  // Non-repeating Question Draw Decks
  final List<Question> _truthQuestionDeck = [];
  final List<Question> _dareQuestionDeck = [];

  // Question ID history tracking (MongoDB String ObjectId)
  final Set<String> answeredQuestionIds = <String>{};

  void markQuestionAnswered(String questionId) {
    if (questionId.isNotEmpty) {
      answeredQuestionIds.add(questionId);
    }
  }

  bool isQuestionAnswered(String questionId) {
    return answeredQuestionIds.contains(questionId);
  }

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
      // Online mode arguments
      if (args['isOnlineMode'] == true) {
        isOnlineMode = true;
        roomCode = args['roomCode'] as String? ?? '';
        myPlayerId = args['myPlayerId'] as String? ?? '';
        isHostPlayer = args['isHost'] as bool? ?? false;
        isPendingApproval.value = args['pendingApproval'] as bool? ?? false;
        _setupOnlineSubscriptions();
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

  // ── Online STOMP subscriptions ─────────────────────────────────

  void _setupOnlineSubscriptions() {
    final stomp = _stomp;
    if (stomp == null || roomCode.isEmpty) return;

    // Room roster & lifecycle updates
    stomp.subscribe('/topic/room/$roomCode', _handleRoomUpdate);

    // Synchronized spin outcome
    stomp.subscribe('/topic/room/$roomCode/spin', _handleSpinResult);

    // Host-only: pending guest join alerts
    if (isHostPlayer) {
      stomp.subscribe('/topic/room/$roomCode/host', _handleHostNotification);
    }

    // Private notifications for this player
    if (myPlayerId.isNotEmpty) {
      stomp.subscribe('/topic/user/$myPlayerId/notifications', _handlePrivateNotification);
    }
  }

  void _handleRoomUpdate(Map<String, dynamic> json) {
    try {
      final update = RoomStateUpdate.fromJson(json);
      // Sync active player list — preserve local score & emoji
      _syncServerPlayers(update.activePlayers);
    } catch (e) {
      print('[GameController] RoomStateUpdate error: $e');
    }
  }

  void _handleSpinResult(Map<String, dynamic> json) {
    try {
      final result = SpinResult.fromJson(json);

      // Cache the server question for ChallengeView
      serverQuestion.value = result.question;

      // Drive the spin animation toward the server-determined target index
      _triggerSyncedSpin(result.targetPlayerIndex);
    } catch (e) {
      print('[GameController] SpinResult error: $e');
    }
  }

  void _handleHostNotification(Map<String, dynamic> json) {
    try {
      final notification = HostNotification.fromJson(json);
      if (notification.eventType == 'JOIN_REQUESTED') {
        _showApprovalDialog(notification);
      }
    } catch (e) {
      print('[GameController] HostNotification error: $e');
    }
  }

  void _handlePrivateNotification(Map<String, dynamic> json) {
    final eventType = json['eventType'] as String? ?? '';
    if (eventType == 'HOST_DECISION') {
      final approved = json['approve'] as bool? ?? false;
      isPendingApproval.value = false;
      if (!approved) {
        Get.snackbar('Rejected', 'The host rejected your join request.',
            snackPosition: SnackPosition.BOTTOM);
        Get.back();
      }
    }
  }

  /// Show the neon approval dialog on the host's screen.
  void _showApprovalDialog(HostNotification notification) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.neonAmber.withOpacity(0.7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonAmber.withOpacity(0.25),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🚪', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(
                  'JOIN REQUEST',
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    color: AppTheme.textDarkSlate,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${notification.guestName} wants to join the game!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSubtleSlate,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.back();
                          _stomp?.sendApproval(
                            roomCode: roomCode,
                            hostId: myPlayerId,
                            guestPlayerId: notification.guestPlayerId,
                            approve: false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.neonPink,
                          side: const BorderSide(color: AppTheme.neonPink),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Deny'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          _stomp?.sendApproval(
                            roomCode: roomCode,
                            hostId: myPlayerId,
                            guestPlayerId: notification.guestPlayerId,
                            approve: true,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 4,
                          shadowColor: AppTheme.neonGreen.withOpacity(0.4),
                        ),
                        child: const Text('Approve'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Sync the active player list from server frames, preserving local score/emoji.
  void _syncServerPlayers(List<Map<String, dynamic>> serverPlayers) {
    final updated = <PlayerModel>[];
    for (int i = 0; i < serverPlayers.length; i++) {
      final pid = serverPlayers[i]['playerId'] as String? ?? '';
      final existing = players.firstWhereOrNull((p) => p.playerId == pid);
      final color = existing?.color ?? const Color(0xFFFF007F);
      final emoji = existing?.emoji ?? '👾';
      final p = PlayerModel.fromJson(serverPlayers[i], color: color, emoji: emoji);
      p.score = existing?.score ?? 0; // preserve local score
      updated.add(p);
    }
    players.assignAll(updated);
  }

  // ── Online Spin ───────────────────────────────────────────────

  /// Send spin request to server (any active player may initiate).
  void _sendOnlineSpin() {
    if (isSpinning.value || players.isEmpty) return;

    // Pick questionType from the current UI selection context (default TRUTH).
    // The server will supply the actual question via SpinResult.
    final questionType = 'TRUTH'; // overridden per game flow; server selects
    final category = _mapCategory(selectedCategory.value);

    _stomp?.sendSpin(
      roomCode: roomCode,
      playerId: myPlayerId,
      category: category,
      questionType: questionType,
    );
  }

  /// Drive animation to server-chosen targetIndex (called after SpinResult arrives).
  void _triggerSyncedSpin(int targetIndex) {
    if (players.isEmpty) return;
    if (targetIndex < 0 || targetIndex >= players.length) return;

    isSpinning.value = true;
    showActionButtons.value = false;
    selectedPlayerIndex.value = -1;
    highlightedPlayerIndex.value = -1;

    final random = Random();
    _runJackpotSelection(random, 0, overrideTarget: targetIndex);
  }

  String _mapCategory(String displayName) {
    switch (displayName) {
      case 'Classic (Family)':
        return 'CLASSIC';
      case 'Spicy (Couples)':
        return 'SPICY';
      default:
        return 'PARTY';
    }
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

  void _runJackpotSelection(Random random, int targetIndex, {int? overrideTarget}) async {
    final finalTarget = overrideTarget ?? targetIndex;
    int totalSteps = 25 + random.nextInt(10);
    int currentStep = 0;

    while (currentStep < totalSteps) {
      currentStep++;
      if (currentStep == totalSteps) {
        highlightedPlayerIndex.value = finalTarget;
      } else {
        highlightedPlayerIndex.value = (currentStep) % players.length;
      }

      int delay = 40 + ((currentStep * currentStep * 12) ~/ totalSteps);
      await Future.delayed(Duration(milliseconds: delay));
      if (!isSpinning.value) return;
    }

    _onSpinComplete(precalculatedIndex: finalTarget);
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
    // In online mode the question comes from the server (via SpinResult).
    // In offline mode we pull from the local deck.
    Question? challenge;
    if (isOnlineMode && serverQuestion.value != null) {
      challenge = serverQuestion.value;
      serverQuestion.value = null; // consume it
    } else {
      challenge = getChallenge(type);
    }

    if (challenge == null) {
      Get.snackbar(
        "Out of Questions!",
        "No more $type questions left in this deck.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Mark question as answered in state history
    markQuestionAnswered(challenge.id);

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

