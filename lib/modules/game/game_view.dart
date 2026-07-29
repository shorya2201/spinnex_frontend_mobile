import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';
import '../../data/models/player_model.dart';
import 'game_controller.dart';
import 'widgets/mode_spinner.dart';
import 'widgets/selector_widgets.dart';

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
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0D0015), // Deep dark purple
                Color(0xFF19062B), // Vibrant plum
                Color(0xFF080010), // Midnight black
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Ambient background glow effects
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
                          color: const Color(0xFFFF007F).withValues(alpha: 0.20),
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
                          color: const Color(0xFF00FFFF).withValues(alpha: 0.18),
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

                    // Selector Mode Switcher Bar (Bottle, Roulette, Radar, Jackpot)
                    // _buildSelectorModeSwitcherBar(),

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
                            // Find current highest score for leader badge (crown)
                            int highestScore = 0;
                            if (controller.players.isNotEmpty) {
                              highestScore = controller.players
                                  .map((p) => p.score)
                                  .reduce(max);
                            }

                            return Stack(
                              children: [
                                // Outer Arena Glow Ring
                                Positioned(
                                  left: centerX - radius,
                                  top: centerY - radius,
                                  child: Container(
                                    width: radius * 2,
                                    height: radius * 2,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.08),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF00FFFF)
                                              .withValues(alpha: 0.05),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Radial Player Avatars around the ring
                                ...List.generate(controller.players.length,
                                    (index) {
                                  double angle =
                                      (2 * pi / controller.players.length) *
                                          index;
                                  // Radial offset position calculation
                                  double nodeWidth = 80;
                                  double avatarRadius = 27; // Half of avatar circle height (54)
                                  double x = centerX +
                                      radius * sin(angle) -
                                      (nodeWidth / 2);
                                  double y = centerY -
                                      radius * cos(angle) -
                                      avatarRadius;

                                  bool isWinner = controller
                                          .selectedPlayerIndex.value ==
                                      index;
                                  PlayerModel player =
                                      controller.players[index];
                                  bool isLeader = highestScore > 0 &&
                                      player.score == highestScore;

                                  return Positioned(
                                    left: x,
                                    top: y,
                                    child: _buildPlayerNode(
                                      player: player,
                                      index: index,
                                      isWinner: isWinner,
                                      isLeader: isLeader,
                                    ),
                                  );
                                }),

                                // Dynamic Central Selector Component
                                _buildCentralSelector(centerX, centerY),
                              ],
                            );
                          });
                        },
                      ),
                    ),

                    // Action Buttons Deck (TRUTH or DARE)
                    _buildActionDeckSection(),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Glassmorphic App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: AppBar(
            backgroundColor: const Color(0xFF0D0015).withValues(alpha: 0.7),
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
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
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF007F).withValues(alpha: 0.25),
                      const Color(0xFF00FFFF).withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF007F).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.style_rounded,
                      color: Color(0xFFFF007F),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      controller.selectedCategory.value.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Colors.white,
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
                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFFFD700),
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
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                ),
                onPressed: controller.endGame,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
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
        accentColor = const Color(0xFF00FFFF);
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
        accentColor = const Color(0xFF39FF14);
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.25),
              blurRadius: 12,
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
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    });
  }

  // Interactive Selector Mode Switcher HUD
  Widget _buildSelectorModeSwitcherBar() {
    final modes = [
      // {'id': 'Bottle', 'label': 'Bottle', 'icon': '🍾'}, // Commented out
      // {'id': 'Wheel', 'label': 'Roulette', 'icon': '🎡'}, // Commented out
      // {'id': 'Radar', 'label': 'Radar', 'icon': '⚡'}, // Commented out
      {'id': 'Jackpot', 'label': 'Jackpot', 'icon': '🃏'},
    ];

    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: modes.map((mode) {
            bool isSelected =
                controller.selectedSelectorMode.value == mode['id'];
            return GestureDetector(
              onTap: () => controller.setSelectorMode(mode['id']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFF007F).withValues(alpha: 0.8)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFFFF007F).withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Text(mode['icon']!, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 5),
                    Text(
                      mode['label']!,
                      style: GoogleFonts.orbitron(
                        fontSize: 10.5,
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  // Dynamic Central Selector (Jackpot Deck active; Spin & Radar commented out)
  Widget _buildCentralSelector(double centerX, double centerY) {
    return Obx(() {
      String mode = controller.selectedSelectorMode.value;
      int highlightedIdx = controller.highlightedPlayerIndex.value;
      PlayerModel? activePlayer =
          (highlightedIdx >= 0 && highlightedIdx < controller.players.length)
              ? controller.players[highlightedIdx]
              : null;

      Widget childWidget;
      double width;
      double height;

      switch (mode) {
        /* Commented out spin and radar options:
        case 'Wheel':
          width = CyberWheelWidget.wheelRadius * 2;
          height = CyberWheelWidget.wheelRadius * 2;
          childWidget = CyberWheelWidget(...);
          break;
        case 'Radar':
          width = 170;
          height = 170;
          childWidget = QuantumRadarWidget(...);
          break;
        case 'Bottle':
        */
        case 'Jackpot':
        default:
          width = 110;
          height = 110;
          childWidget = JackpotDeckWidget(
            activePlayer: activePlayer,
            isSpinning: controller.isSpinning.value,
          );
          break;
      }

      return Positioned(
        left: centerX - (width / 2),
        top: centerY - (height / 2),
        child: GestureDetector(
          onTap: controller.triggerSelection,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: controller.isSpinning.value
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00FFFF).withValues(alpha: 0.4),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ]
                  : [],
            ),
            child: childWidget,
          ),
        ),
      );
    });
  }

  // Individual Radial Player Node Card
  Widget _buildPlayerNode({
    required PlayerModel player,
    required int index,
    required bool isWinner,
    required bool isLeader,
  }) {
    Color themeColor = player.color;
    bool isHighlighted =
        isWinner || controller.highlightedPlayerIndex.value == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      transformAlignment: Alignment.topCenter,
      transform: isHighlighted
          ? (Matrix4.identity()..scale(1.22))
          : Matrix4.identity(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Glowing Outer Circle Avatar
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isHighlighted
                        ? [themeColor, themeColor.withValues(alpha: 0.6)]
                        : [
                            Colors.black.withValues(alpha: 0.6),
                            themeColor.withValues(alpha: 0.3),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: isHighlighted ? Colors.white : themeColor,
                    width: isHighlighted ? 2.5 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isHighlighted
                          ? themeColor.withValues(alpha: 0.8)
                          : themeColor.withValues(alpha: 0.25),
                      blurRadius: isHighlighted ? 16 : 8,
                      spreadRadius: isHighlighted ? 3 : 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      player.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),

              // Crown Badge for Current High Scorer
              if (isLeader)
                Positioned(
                  top: -10,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFFD700),
                          blurRadius: 6,
                        ),
                      ],
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
                        colors: [Color(0xFFFF007F), Color(0xFFFF4500)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFFF007F),
                          blurRadius: 8,
                        ),
                      ],
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
                color: isWinner ? Colors.white : Colors.white70,
                fontWeight: isWinner ? FontWeight.w900 : FontWeight.w600,
                fontSize: 11,
                shadows: isWinner
                    ? [
                        Shadow(
                          color: themeColor,
                          blurRadius: 10,
                        ),
                      ]
                    : [],
              ),
            ),
          ),

          // Live Points Badge Chip
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: themeColor.withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: Text(
              "${player.score} pts",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
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
                          Color(0xFF00E5FF),
                          Color(0xFF0083B0),
                        ],
                        glowColor: const Color(0xFF00E5FF),
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
                          Color(0xFFFF007F),
                          Color(0xFFDD2476),
                        ],
                        glowColor: const Color(0xFFFF007F),
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
            color: glowColor.withValues(alpha: 0.4),
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
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
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
                            color: Colors.white.withValues(alpha: 0.85),
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
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF140824).withValues(alpha: 0.92),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
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
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFFFFD700),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "LIVE SCOREBOARD",
                        style: GoogleFonts.orbitron(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: Colors.white,
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
                          const Divider(color: Colors.white10, height: 12),
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
                                ? const Color(0xFFFFD700).withValues(alpha: 0.12)
                                : Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: index == 0
                                  ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                                  : Colors.transparent,
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
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: p.color.withValues(alpha: 0.2),
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
                                    color: Colors.white,
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
                      backgroundColor: const Color(0xFFFF007F),
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
        backgroundColor: const Color(0xFF19062B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFF007F), width: 1.5),
        ),
        title: Text(
          "Exit Game?",
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you sure you want to leave the current spin game?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF007F),
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
