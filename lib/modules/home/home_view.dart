import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        color: const Color(0xFFFF007F).withOpacity(0.25),
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
                        color: const Color(0xFF00FFFF).withOpacity(0.20),
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
                        color: const Color(0xFF00FFFF).withOpacity(0.12),
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
                          color: Color(0xFFFF007F),
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

                             // Player Lobby Section
                             _buildLobbySection(context),
                             const SizedBox(height: 24),

                            // Category / Deck Selection
                            _buildSectionHeader(
                              title: "SELECT DECK",
                              icon: Icons.style_rounded,
                            ),
                            const SizedBox(height: 10),
                            _buildCategorySelector(),
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
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: AppBar(
            backgroundColor: const Color(0xFF0D0015).withOpacity(0.65),
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
                      colors: [Color(0xFFFF007F), Color(0xFF00FFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF007F).withOpacity(0.5),
                        blurRadius: 10,
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
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00FFFF), Color(0xFFFF007F), Color(0xFF39FF14)],
                  ).createShader(bounds),
                  child: Text(
                    "SPINNEX",
                    style: GoogleFonts.orbitron(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.8,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF007F).withOpacity(0.3),
                        const Color(0xFF00FFFF).withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFF007F).withOpacity(0.7),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    "PARTY",
                    style: GoogleFonts.orbitron(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFF007F),
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
                        color: controller.isMusicOn.value
                            ? const Color(0xFF39FF14).withOpacity(0.15)
                            : Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: controller.isMusicOn.value
                              ? const Color(0xFF39FF14)
                              : Colors.white.withOpacity(0.2),
                          width: 1.2,
                        ),
                        boxShadow: controller.isMusicOn.value
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF39FF14).withOpacity(0.4),
                                  blurRadius: 8,
                                )
                              ]
                            : [],
                      ),
                      child: Icon(
                        controller.isMusicOn.value
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: controller.isMusicOn.value
                            ? const Color(0xFF39FF14)
                            : Colors.white54,
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
                      color: const Color(0xFF00FFFF).withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00FFFF).withOpacity(0.6),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FFFF).withOpacity(0.3),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      color: Color(0xFF00FFFF),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Redesigned Top Header Banner Component
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF007F).withOpacity(0.15),
            const Color(0xFF8B00FF).withOpacity(0.12),
            const Color(0xFF00FFFF).withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFF007F).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF007F).withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
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
                colors: [Color(0xFFFF007F), Color(0xFF9D4EDD), Color(0xFF00FFFF)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF007F).withOpacity(0.6),
                  blurRadius: 16,
                  spreadRadius: 1,
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

          // Glowing Main Title
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFF00FFFF),
                Color(0xFFFF007F),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: Text(
              "Truth or Dare",
              style: GoogleFonts.righteous(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: const Color(0xFF00FFFF).withOpacity(0.9),
                    blurRadius: 16,
                  ),
                  Shadow(
                    color: const Color(0xFFFF007F).withOpacity(0.7),
                    blurRadius: 24,
                  ),
                ],
              ),
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
              color: Colors.white.withOpacity(0.85),
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
            color: const Color(0xFF00FFFF),
            text: "2-12 Squad",
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildHighlightChip(
            icon: Icons.style_rounded,
            color: const Color(0xFFFF007F),
            text: "3 Decks",
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildHighlightChip(
            icon: Icons.auto_awesome_rounded,
            color: const Color(0xFF39FF14),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.35),
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
                color: Colors.white,
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
                  color: const Color(0xFFFF007F).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFF007F).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: const Color(0xFF00FFFF), size: 16),
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
                    color: Colors.white,
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
        color: const Color(0xFF140824).withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
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
            color: Colors.white,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: isReady
                ? const Color(0xFF39FF14).withOpacity(0.12)
                : Colors.amber.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isReady ? const Color(0xFF39FF14) : Colors.amber,
              width: 1.5,
            ),
          ),
          child: Text(
            isReady ? "READY TO SPIN" : "NEED 2+ PLAYERS",
            style: GoogleFonts.orbitron(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: isReady ? const Color(0xFF39FF14) : Colors.amber,
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
        Color borderColor = index < controller.playerColorsList.length
            ? controller.playerColorsList[index]
            : const Color(0xFFFF007F);
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
                  borderColor.withOpacity(0.28),
                  borderColor.withOpacity(0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: borderColor,
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.42),
                  blurRadius: 10,
                  spreadRadius: 1,
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
                    color: Colors.black.withOpacity(0.35),
                    shape: BoxShape.circle,
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
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
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
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 13,
                        color: Colors.white,
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
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
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
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: controller.newPlayerInputController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: const Color(0xFF39FF14),
                onSubmitted: (value) {
                  controller.addPlayerWithInputName(value);
                },
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: "Enter player name...",
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.45),
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
                color: const Color(0xFF39FF14).withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF39FF14),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF39FF14).withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Color(0xFF39FF14),
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
        'icon': Icons.family_restroom_rounded,
        'tag': 'Clean & Fun',
        'color': const Color(0xFF00FFFF),
      },
      'Party (Friends)': {
        'icon': '🥂',
        'tag': 'Wild & Crazy',
        'color': const Color(0xFFFF007F),
      },
      'Spicy (Couples)': {
        'icon': Icons.local_fire_department_rounded,
        'tag': 'Hot & Bold 18+',
        'color': const Color(0xFFFF4500),
      },
    };

    return Row(
      children: controller.categories.map((cat) {
        bool isSelected = controller.selectedCategory.value == cat;
        var details = categoryDetails[cat] ??
            {
              'icon': Icons.star,
              'tag': 'Deck',
              'color': const Color(0xFF00FFFF),
            };
        Color accentColor = details['color'];

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => controller.selectedCategory.value = cat,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor.withOpacity(0.2)
                      : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? accentColor
                        : Colors.white.withOpacity(0.1),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: accentColor.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (details['icon'] is String)
                      Text(
                        details['icon'] as String,
                        style: const TextStyle(fontSize: 22),
                      )
                    else
                      Icon(
                        details['icon'] as IconData,
                        color: isSelected ? accentColor : Colors.white60,
                        size: 22,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      cat,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      details['tag'],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: isSelected
                            ? accentColor
                            : Colors.white.withOpacity(0.4),
                        fontWeight: FontWeight.bold,
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              "Music & Audio SFX",
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            subtitle: Text(
              "Enable party beats & sound effects",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
            secondary: const Icon(Icons.music_note_rounded,
                color: Color(0xFF39FF14), size: 22),
            value: controller.isMusicOn.value,
            activeColor: const Color(0xFF39FF14),
            onChanged: (val) => controller.isMusicOn.value = val,
          ),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          ListTile(
            dense: true,
            leading: const Icon(Icons.star_rate_rounded, color: Colors.amber, size: 22),
            title: const Text(
              "Rate Application",
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.4),
              size: 20,
            ),
            onTap: () => controller.launchURL("https://play.google.com/store"),
          ),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          ListTile(
            dense: true,
            leading:
                const Icon(Icons.mail_rounded, color: Color(0xFF00FFFF), size: 22),
            title: const Text(
              "Contact Developer",
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.4),
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
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.only(
            left: 18,
            right: 18,
            top: 12,
            bottom: 14,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0015).withOpacity(0.85),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFFF007F).withOpacity(0.3),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 18,
                offset: const Offset(0, -5),
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
                  elevation: 10,
                  shadowColor: const Color(0xFFFF007F).withOpacity(0.6),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF007F), // Neon Pink
                        Color(0xFF9D4EDD), // Bright Purple
                        Color(0xFF00FFFF), // Neon Cyan
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
            color: const Color(0xFF0D031A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: const Color(0xFF00FFFF).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.8),
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
                          color: const Color(0xFF00FFFF).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.help_outline_rounded,
                          color: Color(0xFF00FFFF),
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
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
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
                color: const Color(0xFFFF007F),
                title: "Add Squad Players",
                subtitle:
                    "Enter names or tap the dice 🎲 to generate unique avatars & glow colors for your squad.",
              ),
              const SizedBox(height: 14),
              _buildRuleStep(
                number: "2",
                color: const Color(0xFF00FFFF),
                title: "Pick Your Vibe Deck",
                subtitle:
                    "Choose from Classic (Family), Party (Friends), or Spicy (Couples).",
              ),
              const SizedBox(height: 14),
              _buildRuleStep(
                number: "3",
                color: const Color(0xFF39FF14),
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
                    backgroundColor: const Color(0xFF00FFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    "GOT IT, LET'S PLAY! 🔥",
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
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
            color: color.withOpacity(0.2),
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
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
        : const Color(0xFFB026FF);

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
    Color(0xFFFF0055), // Hot Crimson
    Color(0xFF8B00FF), // Deep Cyber Violet
    Color(0xFF39FF14), // Electric Neon Lime
    Color(0xFF00FFFF), // Neon Cyan
    Color(0xFFFF4500), // Fiery Chili Orange
    Color(0xFFFFEA00), // Electric Voltage Yellow
    Color(0xFF0070FF), // Royal Cyber Blue
    Color(0xFFFF6B00), // Spicy Tangerine
    Color(0xFF00FF66), // Toxic Acid Mint
    Color(0xFFE60039), // Rich Ruby Red
    Color(0xFFB026FF), // Electric Purple
    Color(0xFF00E5FF), // Bright Aqua Blue
    Color(0xFFFFB700), // Sunset Amber Gold
    Color(0xFFFF00A0), // Neon Electric Magenta
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
          color: const Color(0xFF0D031A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
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
                      color: const Color(0xFF00FFFF),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
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
                            color: Colors.white.withOpacity(0.04),
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
                                    color: Colors.white,
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
                            color: const Color(0xFF0D031A),
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
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selectedColor,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.casino_rounded,
                        color: Colors.white,
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
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    "🔒 = Taken by player",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.4),
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
                            backgroundColor: Colors.amber.shade900.withOpacity(0.9),
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
                                  ? _selectedColor.withOpacity(0.2)
                                  : isChosenByOther
                                      ? Colors.white.withOpacity(0.02)
                                      : Colors.white.withOpacity(0.06),
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: _selectedColor, width: 2.5)
                                  : isChosenByOther
                                      ? Border.all(color: Colors.white.withOpacity(0.08), width: 1)
                                      : Border.all(color: Colors.white.withOpacity(0.12), width: 1),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: _selectedColor.withOpacity(0.5),
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
                                  border: Border.all(color: const Color(0xFF0D031A), width: 1.5),
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
                  color: Colors.white.withOpacity(0.7),
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
                              ? Border.all(color: Colors.white, width: 3.5)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.8),
                                    blurRadius: 12,
                                    spreadRadius: 2,
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
                          backgroundColor: const Color(0xFFB026FF),
                          elevation: 8,
                          shadowColor: const Color(0xFFB026FF).withOpacity(0.6),
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
                            color: Colors.black,
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
