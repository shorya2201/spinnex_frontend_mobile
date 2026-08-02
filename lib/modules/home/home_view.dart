import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhiteBackground,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppTheme.offWhiteGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Stack(
            children: [
              // Ambient background glow effects
              Positioned(
                top: -40,
                left: -40,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonPink.withOpacity(0.12),
                        blurRadius: 100,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 60,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonCyan.withOpacity(0.12),
                        blurRadius: 90,
                        spreadRadius: 25,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 120,
                right: -60,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonGreen.withOpacity(0.08),
                        blurRadius: 100,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // Main Scrollable Content Area
              Obx(
                () => controller.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.neonPink,
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.only(
                          left: 14,
                          right: 14,
                          top: MediaQuery.of(context).padding.top + 60 + 10,
                          bottom: MediaQuery.of(context).padding.bottom + 85,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context),
                            const SizedBox(height: 20),

                            // Category / Deck Selection
                            _buildSectionHeader(
                              title: "SELECT CATEGORY",
                              icon: Icons.style_rounded,
                            ),
                            const SizedBox(height: 10),
                            _buildCategorySelector(),
                            const SizedBox(height: 24),

                            // Player Lobby Section
                            _buildLobbySection(context),
                            const SizedBox(height: 24),

                            // Settings & Utilities
                            _buildSectionHeader(
                              title: "SETTINGS",
                              icon: Icons.tune_rounded,
                            ),
                            const SizedBox(height: 10),
                            _buildSettingsCard(),
                          ],
                        ),
                      ),
              ),

              // Sticky Floating Start Game Button at Bottom Center
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildStickyStartButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Glassmorphic App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: AppBar(
        backgroundColor: AppTheme.offWhiteBackground.withOpacity(0.85),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.neonPink, AppTheme.neonCyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonPink.withOpacity(0.35),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "SPINNEX",
              style: GoogleFonts.orbitron(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.8,
                color: AppTheme.textDarkSlate,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: AppTheme.neonPink.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.neonPink,
                  width: 1,
                ),
              ),
              child: Text(
                "PARTY",
                style: GoogleFonts.orbitron(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.neonPink,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
            actions: [
              // Audio Toggle Button
              Obx(
                () => GestureDetector(
                  onTap: () => controller.isMusicOn.toggle(),
                  child: Tooltip(
                    message: controller.isMusicOn.value
                        ? "Audio Enabled"
                        : "Audio Muted",
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: controller.isMusicOn.value
                              ? AppTheme.neonGreen
                              : AppTheme.borderLight,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.textDarkSlate.withOpacity(0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        controller.isMusicOn.value
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: controller.isMusicOn.value
                            ? AppTheme.neonGreen
                            : AppTheme.textSubtleSlate,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
              // How to Play Info Button
              GestureDetector(
                onTap: () => _showHowToPlayModal(context),
                child: Tooltip(
                  message: "How to Play",
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.neonCyan,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonCyan.withOpacity(0.2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      color: AppTheme.neonCyan,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // Redesigned Top Header Banner Component
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.neonPink.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textDarkSlate.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppTheme.neonPink.withOpacity(0.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Animated Glow Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.neonPink, AppTheme.neonCyan],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonPink.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  "NIGHTLIFE & PARTY EDITION",
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Main Title
          Text(
            "Truth or Dare",
            style: GoogleFonts.righteous(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkSlate,
            ),
          ),
          const SizedBox(height: 4),

          // Catchy Subtitle
          Text(
            "Assemble your squad, spin the bottle & unveil secrets! 🔥",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSubtleSlate,
              letterSpacing: 0.3,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Quick Highlights Chips Row
          _buildQuickHighlightsRow(),
        ],
      ),
    );
  }

  Widget _buildQuickHighlightsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildHighlightChip(
            icon: Icons.groups_rounded,
            color: AppTheme.neonCyan,
            text: "2-12 Squad",
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildHighlightChip(
            icon: Icons.style_rounded,
            color: AppTheme.neonPink,
            text: "3 Decks",
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildHighlightChip(
            icon: Icons.auto_awesome_rounded,
            color: AppTheme.neonGreen,
            text: "Instant Spin",
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightChip({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDarkSlate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section Header
  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    Widget? actionWidget,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppTheme.neonPink.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.neonPink.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: AppTheme.neonPink, size: 16),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.orbitron(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppTheme.textDarkSlate,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (actionWidget != null) actionWidget,
      ],
    );
  }

  // Player Lobby Section (Matching reference UI design)
  Widget _buildLobbySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.borderLight,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textDarkSlate.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: LOBBY (2/12) & READY TO SPIN
          _buildLobbyHeader(),
          const SizedBox(height: 16),

          // Player Chips Wrap
          _buildPlayerChips(context),
          const SizedBox(height: 16),

          // Input Box for adding new players
          _buildAddPlayerInput(),
        ],
      ),
    );
  }

  Widget _buildLobbyHeader() {
    bool isReady = controller.playerControllers.length >= 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "LOBBY (${controller.playerControllers.length}/12)",
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppTheme.textDarkSlate,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: isReady
                ? AppTheme.neonGreen.withOpacity(0.12)
                : AppTheme.neonAmber.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isReady ? AppTheme.neonGreen : AppTheme.neonAmber,
              width: 1.5,
            ),
          ),
          child: Text(
            isReady ? "READY TO SPIN" : "NEED 2+ PLAYERS",
            style: GoogleFonts.orbitron(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: isReady ? AppTheme.neonGreen : AppTheme.neonAmber,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerChips(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(controller.playerControllers.length, (index) {
        Color playerColor = index < controller.playerColorsList.length
            ? controller.playerColorsList[index]
            : AppTheme.neonPink;
        String emoji = index < controller.playerEmojisList.length
            ? controller.playerEmojisList[index]
            : '👾';
        String name = controller.playerControllers[index].text;

        return GestureDetector(
          onTap: () => _showEditPlayerModal(context, index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  playerColor.withOpacity(0.25),
                  playerColor.withOpacity(0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: playerColor,
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: playerColor.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji Badge
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),

                // Player Name Text
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 110),
                    child: Text(
                      name.isEmpty ? "Player ${index + 1}" : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textDarkSlate,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Remove Player Button
                GestureDetector(
                  onTap: () => controller.removePlayerAt(index),
                  child: Tooltip(
                    message: "Remove player",
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: playerColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 13,
                        color: AppTheme.textDarkSlate,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAddPlayerInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rounded Input Field Box matching reference screenshot
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.borderLight,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: controller.newPlayerInputController,
                style: const TextStyle(
                  color: AppTheme.textDarkSlate,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: AppTheme.neonPink,
                onSubmitted: (value) {
                  controller.addPlayerWithInputName(value);
                },
                decoration: const InputDecoration(
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: "Enter player name...",
                  hintStyle: TextStyle(
                    color: AppTheme.textSubtleSlate,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Green + Action Button
          GestureDetector(
            onTap: () {
              controller.addPlayerWithInputName(
                controller.newPlayerInputController.text,
              );
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.neonGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppTheme.neonGreen,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonGreen.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppTheme.neonGreen,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Category / Deck Selection Component
  Widget _buildCategorySelector() {
    final Map<String, Map<String, dynamic>> categoryDetails = {
      'Classic (Family)': {
        'icon': '🏠',
        'tag': 'Clean & Fun',
        'color': AppTheme.neonCyan,
        'secondaryColor': const Color(0xFF0099FF),
      },
      'Party (Friends)': {
        'icon': '🥂',
        'tag': 'Wild & Crazy',
        'color': AppTheme.neonPink,
        'secondaryColor': const Color(0xFFD8006C),
      },
      'Spicy (Couples)': {
        'icon': '🌶️',
        'tag': 'Hot & Bold 18+',
        'color': const Color(0xFFFF4500),
        'secondaryColor': const Color(0xFFCC3700),
      },
    };

    return Row(
      children: controller.categories.map((cat) {
        bool isSelected = controller.selectedCategory.value == cat;
        var details = categoryDetails[cat] ??
            {
              'icon': '⭐',
              'tag': 'Deck',
              'color': AppTheme.neonCyan,
              'secondaryColor': AppTheme.neonCyan,
            };
        Color accentColor = details['color'];
        Color secondaryColor = details['secondaryColor'] ?? accentColor;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => controller.selectedCategory.value = cat,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            accentColor.withOpacity(0.75),
                            secondaryColor.withOpacity(0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : accentColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? accentColor : AppTheme.borderLight,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? accentColor.withOpacity(0.4)
                          : AppTheme.textDarkSlate.withOpacity(0.04),
                      blurRadius: isSelected ? 12 : 6,
                      spreadRadius: isSelected ? 1 : 0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.surfaceWhite
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.surfaceWhite
                              : AppTheme.borderLight,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: details['icon'] is String
                          ? Text(
                              details['icon'] as String,
                              style: const TextStyle(fontSize: 20),
                            )
                          : Icon(
                              details['icon'] as IconData,
                              color: isSelected ? accentColor : AppTheme.textSubtleSlate,
                              size: 20,
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.w700,
                        color: isSelected ? Colors.white : AppTheme.textDarkSlate,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.black.withOpacity(0.15)
                            : accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        details['tag'],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          color: isSelected
                              ? Colors.white
                              : accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Settings Glass Card
  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textDarkSlate.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text(
              "Music & Audio SFX",
              style: TextStyle(
                color: AppTheme.textDarkSlate,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            subtitle: const Text(
              "Enable party beats & sound effects",
              style: TextStyle(
                color: AppTheme.textSubtleSlate,
                fontSize: 11,
              ),
            ),
            secondary: const Icon(Icons.music_note_rounded,
                color: AppTheme.neonGreen, size: 22),
            value: controller.isMusicOn.value,
            activeColor: AppTheme.neonGreen,
            onChanged: (val) => controller.isMusicOn.value = val,
          ),
          const Divider(color: AppTheme.borderLight, height: 1),
          ListTile(
            dense: true,
            leading: const Icon(Icons.star_rate_rounded, color: AppTheme.neonAmber, size: 22),
            title: const Text(
              "Rate Application",
              style: TextStyle(color: AppTheme.textDarkSlate, fontSize: 13),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSubtleSlate,
              size: 20,
            ),
            onTap: () => controller.launchURL("https://play.google.com/store"),
          ),
          const Divider(color: AppTheme.borderLight, height: 1),
          ListTile(
            dense: true,
            leading:
                const Icon(Icons.mail_rounded, color: AppTheme.neonCyan, size: 22),
            title: const Text(
              "Contact Developer",
              style: TextStyle(color: AppTheme.textDarkSlate, fontSize: 13),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSubtleSlate,
              size: 20,
            ),
            onTap: () => controller.launchURL("mailto:proffshorya@gmail.com"),
          ),
        ],
      ),
    );
  }

  // Sticky Bottom Action Bar with Backdrop Blur
  Widget _buildStickyStartButton() {
    return Container(
      padding: const EdgeInsets.only(
        left: 18,
        right: 18,
        top: 12,
        bottom: 14,
      ),
      decoration: BoxDecoration(
        color: AppTheme.offWhiteBackground.withOpacity(0.92),
        border: const Border(
          top: BorderSide(
            color: AppTheme.borderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textDarkSlate.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: controller.startGame,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              elevation: 6,
              shadowColor: AppTheme.neonPink.withOpacity(0.4),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.neonPink,
                    AppTheme.neonCyan,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "START GAME",
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHowToPlayModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: AppTheme.neonCyan.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.textDarkSlate.withOpacity(0.12),
                blurRadius: 25,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.neonCyan.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.help_outline_rounded,
                          color: AppTheme.neonCyan,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "HOW TO PLAY",
                        style: GoogleFonts.orbitron(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: AppTheme.textDarkSlate,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppTheme.textSubtleSlate,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Rules Steps
              _buildRuleStep(
                number: "1",
                color: AppTheme.neonPink,
                title: "Add Squad Players",
                subtitle:
                    "Enter names or tap the dice 🎲 to generate unique avatars & glow colors for your squad.",
              ),
              const SizedBox(height: 14),
              _buildRuleStep(
                number: "2",
                color: AppTheme.neonCyan,
                title: "Pick Your Vibe Deck",
                subtitle:
                    "Choose from Classic (Family), Party (Friends), or Spicy (Couples).",
              ),
              const SizedBox(height: 14),
              _buildRuleStep(
                number: "3",
                color: AppTheme.neonGreen,
                title: "Spin & Challenge",
                subtitle:
                    "Tap START GAME, spin the bottle 🍾 to select a player, and choose Truth or Dare!",
              ),
              const SizedBox(height: 24),

              // Close Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    "GOT IT, LET'S PLAY! 🔥",
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRuleStep({
    required String number,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Text(
            number,
            style: GoogleFonts.orbitron(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textDarkSlate,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSubtleSlate,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditPlayerModal(BuildContext context, int index) {
    if (index < 0 || index >= controller.playerControllers.length) return;

    final String initialName = controller.playerControllers[index].text;
    final String initialEmoji = index < controller.playerEmojisList.length
        ? controller.playerEmojisList[index]
        : '👾';
    final Color initialColor = index < controller.playerColorsList.length
        ? controller.playerColorsList[index]
        : AppTheme.neonPink;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _EditPlayerModalContent(
          controller: controller,
          index: index,
          initialName: initialName,
          initialEmoji: initialEmoji,
          initialColor: initialColor,
        );
      },
    );
  }
}

class _EditPlayerModalContent extends StatefulWidget {
  final HomeController controller;
  final int index;
  final String initialName;
  final String initialEmoji;
  final Color initialColor;

  const _EditPlayerModalContent({
    Key? key,
    required this.controller,
    required this.index,
    required this.initialName,
    required this.initialEmoji,
    required this.initialColor,
  }) : super(key: key);

  @override
  State<_EditPlayerModalContent> createState() => _EditPlayerModalContentState();
}

class _EditPlayerModalContentState extends State<_EditPlayerModalContent> {
  late TextEditingController _nameController;
  late String _selectedEmoji;
  late Color _selectedColor;

  static List<String> get _avatarOptions => HomeController.playerEmojis;

  static const List<Color> _colorOptions = [
    Color(0xFFFF007F), // Neon Pink
    Color(0xFF00D8F6), // Cyber Neon Cyan
    Color(0xFF10B981), // Neon Lime
    Color(0xFFFFB800), // Vivid Amber
    Color(0xFFFF4500), // Fiery Chili Orange
    Color(0xFF8B00FF), // Deep Cyber Violet
    Color(0xFF0070FF), // Royal Cyber Blue
    Color(0xFFFF00A0), // Electric Magenta
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedEmoji = widget.initialEmoji;
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _randomizeName() {
    String newName = widget.controller.getRandomUniqueName(
      currentName: _nameController.text.trim(),
    );
    String matchingEmoji = widget.controller.getMatchingEmojiForName(newName);
    setState(() {
      _nameController.text = newName;
      _selectedEmoji = matchingEmoji;
    });
    if (widget.index < widget.controller.playerEmojisList.length) {
      widget.controller.playerEmojisList[widget.index] = matchingEmoji;
      widget.controller.playerEmojisList.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: AppTheme.borderLight,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.textDarkSlate.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: EDIT PLAYER & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "EDIT PLAYER",
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: AppTheme.textDarkSlate,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppTheme.textSubtleSlate,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Player Name Field with Label Notch & Dice Button
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedColor,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedEmoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  style: const TextStyle(
                                    color: AppTheme.textDarkSlate,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  cursorColor: _selectedColor,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 14,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            color: AppTheme.surfaceWhite,
                            child: Text(
                              "Player Name",
                              style: TextStyle(
                                color: _selectedColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Dice Button Box
                  GestureDetector(
                    onTap: _randomizeName,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FD),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selectedColor,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.casino_rounded,
                        color: AppTheme.textDarkSlate,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // CHOOSE AVATAR Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "CHOOSE AVATAR",
                    style: GoogleFonts.orbitron(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppTheme.textSubtleSlate,
                    ),
                  ),
                  const Text(
                    "🔒 = Taken by player",
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSubtleSlate,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 54,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _avatarOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, i) {
                    final avatar = _avatarOptions[i];
                    final isSelected = _selectedEmoji == avatar;

                    bool isChosenByOther = false;
                    String? takenByPlayerName;
                    for (int k = 0; k < widget.controller.playerEmojisList.length; k++) {
                      if (k != widget.index && widget.controller.playerEmojisList[k] == avatar) {
                        isChosenByOther = true;
                        takenByPlayerName = widget.controller.playerControllers[k].text.trim();
                        if (takenByPlayerName.isEmpty) {
                          takenByPlayerName = "Player ${k + 1}";
                        }
                        break;
                      }
                    }

                    return GestureDetector(
                      onTap: () {
                        if (isChosenByOther) {
                          Get.snackbar(
                            "Avatar Taken",
                            "$avatar is already chosen by $takenByPlayerName.",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.amber.shade900,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                          return;
                        }
                        setState(() => _selectedEmoji = avatar);
                        if (widget.index < widget.controller.playerEmojisList.length) {
                          widget.controller.playerEmojisList[widget.index] = avatar;
                          widget.controller.playerEmojisList.refresh();
                        }
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _selectedColor.withOpacity(0.12)
                                  : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: _selectedColor, width: 2.5)
                                  : Border.all(color: AppTheme.borderLight, width: 1),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: _selectedColor.withOpacity(0.4),
                                        blurRadius: 8,
                                      )
                                    ]
                                  : [],
                            ),
                            child: Opacity(
                              opacity: isChosenByOther ? 0.3 : 1.0,
                              child: Text(
                                avatar,
                                style: TextStyle(fontSize: isSelected ? 26 : 22),
                              ),
                            ),
                          ),
                          if (isChosenByOther)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF1744),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.surfaceWhite, width: 1.5),
                                ),
                                child: const Icon(
                                  Icons.lock_rounded,
                                  size: 9,
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
              const SizedBox(height: 24),

              // CHOOSE GLOW COLOR Section
              Text(
                "CHOOSE GLOW COLOR",
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.textSubtleSlate,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _colorOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, i) {
                    final color = _colorOptions[i];
                    final isSelected = _selectedColor.value == color.value;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedColor = color);
                        if (widget.index < widget.controller.playerColorsList.length) {
                          widget.controller.playerColorsList[widget.index] = color;
                          widget.controller.playerColorsList.refresh();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: AppTheme.textDarkSlate, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.6),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // Action Buttons Row: DELETE PLAYER & SAVE CHANGES
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.controller.removePlayerAt(widget.index);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFFF4D4D),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: Text(
                          "DELETE PLAYER",
                          style: GoogleFonts.orbitron(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: const Color(0xFFFF4D4D),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          String trimmed = _nameController.text.trim();
                          widget.controller.playerControllers[widget.index].text =
                              trimmed.isNotEmpty
                                  ? trimmed
                                  : "Player ${widget.index + 1}";
                          if (widget.index < widget.controller.playerEmojisList.length) {
                            widget.controller.playerEmojisList[widget.index] = _selectedEmoji;
                          }
                          if (widget.index < widget.controller.playerColorsList.length) {
                            widget.controller.playerColorsList[widget.index] = _selectedColor;
                          }
                          widget.controller.playerControllers.refresh();
                          widget.controller.playerEmojisList.refresh();
                          widget.controller.playerColorsList.refresh();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonPink,
                          elevation: 6,
                          shadowColor: AppTheme.neonPink.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: Text(
                          "SAVE CHANGES",
                          style: GoogleFonts.orbitron(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
