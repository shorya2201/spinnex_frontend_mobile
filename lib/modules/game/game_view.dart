import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';
import '../../data/models/player_model.dart';
import '../../theme/app_theme.dart';
import 'game_controller.dart';
import 'widgets/mode_spinner.dart';
import 'widgets/selector_widgets.dart';
import 'widgets/guest_waiting_overlay.dart';

class GameView extends GetView<GameController> {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitConfirmationDialog(context);
      },
      child: Scaffold(
        backgroundColor: AppTheme.offWhiteBackground,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppTheme.offWhiteGradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      top: -30,
                      left: -30,
                      child: Container(
                        width: 220,
                        height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonPink.withValues(alpha: 0.12),
                          blurRadius: 100,
                          spreadRadius: 30,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 120,
                  right: -40,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonCyan.withValues(alpha: 0.12),
                          blurRadius: 100,
                          spreadRadius: 25,
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Game Stage Column
                Column(
                  children: [
                    const SizedBox(height: 12),

                    // Dynamic Real-time Game Status Guidance Banner
                    _buildGameStatusBanner(),

                    const SizedBox(height: 6),

                    // Central Spin Arena (Players + Mode Bottle Spinner)
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double minDim = min(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          );
                          double radius = minDim * 0.36;
                          double centerX = constraints.maxWidth / 2;
                          double centerY = constraints.maxHeight / 2;

                          return Obx(() {
                            int highestScore = 0;
                            if (controller.players.isNotEmpty) {
                              highestScore = controller.players
                                  .map((p) => p.score)
                                  .reduce(max);
                            }

                            return Stack(
                              children: [
                                Positioned(
                                  left: centerX - radius,
                                  top: centerY - radius,
                                  child: Container(
                                    width: radius * 2,
                                    height: radius * 2,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.surfaceWhite,
                                      border: Border.all(
                                        color: AppTheme.neonCyan.withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.textDarkSlate.withValues(alpha: 0.05),
                                          blurRadius: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Orbiting Player Nodes
                                for (int i = 0; i < controller.players.length; i++)
                                  _buildOrbitingPlayerNode(
                                    context: context,
                                    index: i,
                                    total: controller.players.length,
                                    centerX: centerX,
                                    centerY: centerY,
                                    radius: radius,
                                    highestScore: highestScore,
                                  ),

                                // Central Selector Arena (Bottle, Roulette, Radar, Jackpot)
                                Center(
                                  child: _buildCentralSelectorWidget(context),
                                ),
                              ],
                            );
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Action Deck (TRUTH vs DARE Buttons)
                    _buildActionDeckSection(),

                    const SizedBox(height: 12),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Guest Waiting Overlay – shown on top when pending approval
        Obx(() {
          if (!controller.isPendingApproval.value) return const SizedBox.shrink();
          return GuestWaitingOverlay(
            hostName: 'Host',
            roomCode: controller.roomCode,
            onCancel: () {
              controller.isPendingApproval.value = false;
              Get.back();
            },
          );
        }),
      ],
    ),
  ),
);
}

  // Central Dynamic Selector Widget
  Widget _buildCentralSelectorWidget(BuildContext context) {
    String mode = controller.selectedSelectorMode.value;

    int activeIdx = controller.selectedPlayerIndex.value != -1
        ? controller.selectedPlayerIndex.value
        : controller.highlightedPlayerIndex.value;

    PlayerModel? activePlayer = (activeIdx >= 0 && activeIdx < controller.players.length)
        ? controller.players[activeIdx]
        : null;

    Widget childWidget;

    if (mode == 'Wheel') {
      childWidget = CyberWheelWidget(
        players: controller.players,
        currentAngle: controller.rotationAngle.value,
        isSpinning: controller.isSpinning.value,
      );
    } else if (mode == 'Radar') {
      childWidget = CyberRadarWidget(
        players: controller.players,
        currentAngle: controller.rotationAngle.value,
        isSpinning: controller.isSpinning.value,
        selectedIndex: activeIdx != -1 ? activeIdx : null,
      );
    } else if (mode == 'Jackpot') {
      childWidget = CyberJackpotWidget(
        activePlayer: activePlayer,
        isSpinning: controller.isSpinning.value,
      );
    } else {
      // Default Mode: Bottle Spinner
      childWidget = Transform.rotate(
        angle: controller.rotationAngle.value,
        child: ModeSpinner(
          category: controller.selectedCategory.value,
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.spin,
      child: childWidget,
    );
  }

  // Glassmorphic App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: AppBar(
        backgroundColor: AppTheme.offWhiteBackground.withValues(alpha: 0.85),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.borderLight,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.textDarkSlate.withValues(alpha: 0.05),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.textDarkSlate,
              size: 18,
            ),
          ),
          onPressed: () => _showExitConfirmationDialog(context),
        ),
        title: Obx(
          () => Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.neonPink.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonPink.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.style_rounded,
                  color: AppTheme.neonPink,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  controller.selectedCategory.value.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppTheme.textDarkSlate,
                  ),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          // Quick Standings / Leaderboard HUD Button
          IconButton(
            tooltip: "View Standings",
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.neonAmber.withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonAmber.withValues(alpha: 0.15),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: AppTheme.neonAmber,
                size: 18,
              ),
            ),
            onPressed: () => _showQuickScoreboardModal(context),
          ),
          // End Game & Final Leaderboard Button
          IconButton(
            tooltip: "End Session",
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.borderLight,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppTheme.textDarkSlate,
                size: 18,
              ),
            ),
            onPressed: controller.finishGame,
          ),
        ],
      ),
    );
  }

  // Real-time Guidance Banner
  Widget _buildGameStatusBanner() {
    return Obx(() {
      String text;
      IconData icon;
      Color accentColor;
      String mode = controller.selectedSelectorMode.value;

      if (controller.isSpinning.value) {
        if (mode == 'Radar') {
          text = "SCANNING TARGETS...";
          icon = Icons.radar_rounded;
        } else if (mode == 'Jackpot') {
          text = "SHUFFLING CARDS...";
          icon = Icons.style_rounded;
        } else if (mode == 'Wheel') {
          text = "SPINNING ROULETTE...";
          icon = Icons.motion_photos_on_rounded;
        } else {
          text = "SPINNING THE BOTTLE...";
          icon = Icons.sync_rounded;
        }
        accentColor = AppTheme.neonCyan;
      } else if (controller.selectedPlayerIndex.value != -1) {
        int index = controller.selectedPlayerIndex.value;
        String name = controller.players[index].name;
        text = "HOT SEAT: ${name.toUpperCase()}!";
        icon = Icons.local_fire_department_rounded;
        accentColor = controller.players[index].color;
      } else {
        if (mode == 'Radar') {
          text = "TAP RADAR TO SCAN ⚡";
          icon = Icons.radar_rounded;
        } else if (mode == 'Jackpot') {
          text = "TAP CARD TO DRAW 🃏";
          icon = Icons.style_rounded;
        } else if (mode == 'Wheel') {
          text = "TAP WHEEL TO SPIN 🎡";
          icon = Icons.motion_photos_on_rounded;
        } else {
          text = "TAP BOTTLE TO SPIN 🍾";
          icon = Icons.touch_app_rounded;
        }
        accentColor = AppTheme.neonGreen;
      }

      return GestureDetector(
        onTap: controller.spin,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.15),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: accentColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: AppTheme.textDarkSlate,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Orbital Player Node
  Widget _buildOrbitingPlayerNode({
    required BuildContext context,
    required int index,
    required int total,
    required double centerX,
    required double centerY,
    required double radius,
    required int highestScore,
  }) {
    double angle = (2 * pi / total) * index - (pi / 2);
    double x = centerX + radius * cos(angle);
    double y = centerY + radius * sin(angle);

    bool isWinner = controller.selectedPlayerIndex.value == index;
    PlayerModel player = controller.players[index];
    bool isLeader = player.score > 0 && player.score == highestScore;

    Color themeColor = player.color;
    double avatarRadius = isWinner ? 27.0 : 22.0;
    const double nodeWidth = 80.0;

    return Positioned(
      left: x - (nodeWidth / 2),
      top: y - avatarRadius,
      width: nodeWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Avatar Outer Glow Ring
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isWinner ? 54 : 44,
                height: isWinner ? 54 : 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceWhite,
                  border: Border.all(
                    color: isWinner ? AppTheme.neonPink : themeColor,
                    width: isWinner ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isWinner
                          ? AppTheme.neonPink.withValues(alpha: 0.4)
                          : themeColor.withValues(alpha: 0.2),
                      blurRadius: isWinner ? 16 : 6,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    player.emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),

              // Crown Badge for Current High Scorer
              if (isLeader)
                Positioned(
                  top: -10,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppTheme.neonAmber,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '👑',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),

              // Active Hot Seat Badge
              if (isWinner)
                Positioned(
                  bottom: -6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.neonPink, Color(0xFFFF4500)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'HOT',
                      style: GoogleFonts.orbitron(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),

          // Player Name Label
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 75),
            child: Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                color: isWinner ? AppTheme.neonPink : AppTheme.textDarkSlate,
                fontWeight: isWinner ? FontWeight.w900 : FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),

          // Live Points Badge Chip
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: themeColor.withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: Text(
              "${player.score} pts",
              style: const TextStyle(
                color: AppTheme.textSubtleSlate,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TRUTH & DARE High-Impact Action Deck
  Widget _buildActionDeckSection() {
    return Obx(() {
      bool visible = controller.showActionButtons.value;

      return AnimatedOpacity(
        duration: const Duration(milliseconds: 350),
        opacity: visible ? 1.0 : 0.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          height: visible ? 90 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: visible
              ? Row(
                  children: [
                    // TRUTH Card Button
                    Expanded(
                      child: _buildActionButtonCard(
                        title: "TRUTH",
                        subtitle: "Reveal a Secret",
                        icon: Icons.lightbulb_rounded,
                        gradientColors: const [
                          AppTheme.neonCyan,
                          Color(0xFF0083B0),
                        ],
                        glowColor: AppTheme.neonCyan,
                        onPressed: () => controller.chooseAction('TRUTH'),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // DARE Card Button
                    Expanded(
                      child: _buildActionButtonCard(
                        title: "DARE",
                        subtitle: "Take a Challenge",
                        icon: Icons.local_fire_department_rounded,
                        gradientColors: const [
                          AppTheme.neonPink,
                          Color(0xFFDD2476),
                        ],
                        glowColor: AppTheme.neonPink,
                        onPressed: () => controller.chooseAction('DARE'),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      );
    });
  }

  Widget _buildActionButtonCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required Color glowColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.35),
            blurRadius: 14,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.orbitron(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Quick Scoreboard Standings Modal
  void _showQuickScoreboardModal(BuildContext context) {
    List<PlayerModel> sortedPlayers = List.from(controller.players);
    sortedPlayers.sort((a, b) => b.score.compareTo(a.score));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: AppTheme.neonAmber.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: AppTheme.neonAmber,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "LIVE SCOREBOARD",
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: AppTheme.textDarkSlate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: sortedPlayers.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: AppTheme.borderLight, height: 12),
                    itemBuilder: (context, index) {
                      PlayerModel p = sortedPlayers[index];
                      String rankBadge = index == 0
                          ? "🥇"
                          : index == 1
                              ? "🥈"
                              : index == 2
                                  ? "🥉"
                                  : "#${index + 1}";

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: index == 0
                              ? AppTheme.neonAmber.withValues(alpha: 0.12)
                              : AppTheme.offWhiteBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: index == 0
                                ? AppTheme.neonAmber.withValues(alpha: 0.5)
                                : AppTheme.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              rankBadge,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              p.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                p.name,
                                style: GoogleFonts.orbitron(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDarkSlate,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: p.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: p.color,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                "${p.score} pts",
                                style: GoogleFonts.orbitron(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDarkSlate,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonPink,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "BACK TO GAME",
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Confirmation dialog on Back pressed
  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.neonPink, width: 1.5),
        ),
        title: Text(
          "Exit Game?",
          style: GoogleFonts.orbitron(
            color: AppTheme.textDarkSlate,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you sure you want to leave the current spin game?",
          style: TextStyle(color: AppTheme.textSubtleSlate),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: AppTheme.textSubtleSlate)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonPink,
            ),
            onPressed: () {
              Navigator.pop(context);
              Get.until((route) => route.settings.name == Routes.HOME || route.isFirst);
            },
            child: const Text("EXIT"),
          ),
        ],
      ),
    );
  }
}
