import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'challenge_controller.dart';

class ChallengeView extends GetView<ChallengeController> {
  const ChallengeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D0015), // Deep dark purple
              Color(0xFF1B052A), // Cyberpunk plum
              Color(0xFF080010), // Midnight black
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Ambient Glowing Background Spheres
            _buildAmbientGlows(),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  children: [
                    // Top Bar / Navigation Header
                    _buildTopHeader(),

                    const SizedBox(height: 16),

                    // Player & Challenge Type Header Card
                    _buildPlayerHeaderCard(),

                    const SizedBox(height: 20),

                    // Central Challenge Card (Glassmorphic Container)
                    Expanded(
                      child: _buildChallengeCard(),
                    ),

                    const SizedBox(height: 20),

                    // Futuristic Animated Timer Countdown Ring
                    _buildTimerSection(),

                    const SizedBox(height: 24),

                    // High-Impact Action Deck (Chicken Out vs Completed)
                    _buildActionDeck(),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ambient glowing background spheres for dynamic lighting
  Widget _buildAmbientGlows() {
    final accentColor = controller.accentColor;
    return Stack(
      children: [
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.28),
                  blurRadius: 120,
                  spreadRadius: 40,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -50,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (controller.isDare ? const Color(0xFF00FFFF) : const Color(0xFFFF007F))
                      .withValues(alpha: 0.20),
                  blurRadius: 110,
                  spreadRadius: 30,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Top navigation header bar
  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button in Frosted Glass Chip
        GestureDetector(
          onTap: () => Get.back(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),

        // Screen Title Header
        Text(
          "SPINNEX ARENA",
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            color: const Color(0xFF00FFFF),
            shadows: [
              const Shadow(
                color: Color(0xFF00FFFF),
                blurRadius: 12,
              ),
            ],
          ),
        ),

        // Placeholder spacer for symmetry
        const SizedBox(width: 42),
      ],
    );
  }

  /// Player Header Card with glowing ring avatar and challenge type tag
  Widget _buildPlayerHeaderCard() {
    final accent = controller.accentColor;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accent.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.12),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              // Glowing Player Avatar Ring
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.player.color.withValues(alpha: 0.25),
                  border: Border.all(color: accent, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    controller.player.emoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Player Name & Current Score
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.player.name,
                      style: GoogleFonts.orbitron(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.military_tech_rounded,
                          color: Colors.amberAccent[200],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Current Score: ${controller.player.score} pts",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Challenge Type Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: accent, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.typeIcon,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      controller.question.type.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accent,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Central Frosted Glass Challenge Card
  Widget _buildChallengeCard() {
    final accent = controller.accentColor;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      tween: Tween<double>(begin: 0.9, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Tag: Question Category
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        controller.question.category.toUpperCase(),
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.format_quote_rounded,
                      color: accent.withValues(alpha: 0.6),
                      size: 32,
                    ),
                  ],
                ),

                const Spacer(),

                // Question Prompt Content Text
                Text(
                  controller.question.content,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.45,
                    shadows: [
                      const Shadow(
                        color: Colors.black54,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Subtext / Challenge Prompt Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: accent,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Read aloud & complete before the timer expires!",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white60,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Animated Futuristic Timer Section
  Widget _buildTimerSection() {
    return Obx(() {
      final secondsLeft = controller.timeLeft.value;
      final isLow = controller.isLowTime;

      // Dynamic timer progress color shift
      Color timerColor;
      if (secondsLeft > 15) {
        timerColor = controller.accentColor;
      } else if (secondsLeft > 5) {
        timerColor = const Color(0xFFFFB703); // Amber
      } else {
        timerColor = const Color(0xFFFF0055); // Neon Red Warning
      }

      return Column(
        children: [
          // Low Time Alert Banner (when <= 10s)
          if (isLow)
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween<double>(begin: 0.8, end: 1.0),
              builder: (context, val, child) {
                return Transform.scale(scale: val, child: child);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0055).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF0055), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_sharp, color: Color(0xFFFF0055), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "HURRY UP! TIME IS TICKING",
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF0055),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Central Circular Progress Timer Ring
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glowing Aura Ring
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: timerColor.withValues(alpha: isLow ? 0.6 : 0.25),
                      blurRadius: isLow ? 24 : 16,
                      spreadRadius: isLow ? 4 : 1,
                    ),
                  ],
                ),
              ),

              // Progress Indicator Ring
              SizedBox(
                width: 96,
                height: 96,
                child: CircularProgressIndicator(
                  value: secondsLeft / 45,
                  color: timerColor,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  strokeWidth: 9,
                  strokeCap: StrokeCap.round,
                ),
              ),

              // Countdown Digits
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$secondsLeft",
                    style: GoogleFonts.orbitron(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: timerColor,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "SEC",
                    style: GoogleFonts.orbitron(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white60,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    });
  }

  /// High-Impact Action Deck (Chicken Out vs Challenge Completed)
  Widget _buildActionDeck() {
    final accent = controller.accentColor;
    return Row(
      children: [
        // CHICKEN OUT (-1 PT) BUTTON
        Expanded(
          flex: 4,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.chickenOut,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0055).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF0055).withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF0055).withValues(alpha: 0.15),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.sentiment_very_dissatisfied_rounded,
                          color: Color(0xFFFF0055),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "CHICKEN OUT",
                          style: GoogleFonts.orbitron(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF0055),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0055).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "-1 PT",
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF0055),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // COMPLETED (+1 / +2 PTS) BUTTON
        Expanded(
          flex: 6,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.completeChallenge,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: controller.isDare
                        ? [const Color(0xFFFF007F), const Color(0xFFFF5E00)]
                        : [const Color(0xFF00FFFF), const Color(0xFF0088FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "COMPLETED",
                          style: GoogleFonts.orbitron(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "+${controller.rewardPoints} PTS",
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

