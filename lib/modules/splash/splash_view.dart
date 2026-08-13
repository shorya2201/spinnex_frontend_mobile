import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: AnimatedBuilder(
        animation: controller.animationController,
        builder: (context, _) {
          final animValue = controller.animationController.value;
          // Dynamic high-frequency sine flicker for realistic fire burning effect
          final fireFlicker = math.sin(animValue * 30);
          final fireSway = math.sin(animValue * 16) * 0.05;

          return Stack(
            alignment: Alignment.center,
            children: [
              // ── 1. Clean Dark Backdrop with Subtle Center Radial Gradient ──
              Positioned.fill(
                child: Opacity(
                  opacity: controller.backgroundFade.value,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.9,
                        colors: [
                          Color(0xFF161F33),
                          Color(0xFF0D121D),
                          Color(0xFF070A10),
                        ],
                        stops: [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // ── 2. Main Content Column (Perfectly Centered) ────────────
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── 2a. Animated Burning Fire Hub with Rising Embers ──
                    Transform.scale(
                      scale: controller.iconScale.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Dynamic Pulsing Flame Ambient Glow (Heatwave effect)
                          Opacity(
                            opacity: controller.glowBloom.value * 0.5,
                            child: Container(
                              width: 170 + fireFlicker * 8,
                              height: 170 + fireFlicker * 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.neonPink.withValues(alpha: 0.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.neonPink.withValues(
                                        alpha: 0.4 + fireFlicker * 0.08),
                                    blurRadius: 65 + fireFlicker * 10,
                                    spreadRadius: 18 + fireFlicker * 4,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFFFF5722).withValues(
                                        alpha: 0.35 + fireFlicker * 0.08),
                                    blurRadius: 45 + fireFlicker * 8,
                                    spreadRadius: 8 + fireFlicker * 3,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Animated Rising Fiery Embers
                          CustomPaint(
                            size: const Size(140, 160),
                            painter: _FieryEmbersPainter(
                              progress: animValue,
                              opacity: controller.glowBloom.value,
                            ),
                          ),

                          // Main Animated Fiery Icon Hub
                          _FieryIconHub(
                            glowOpacity: controller.glowBloom.value,
                            rotation: controller.bottleRotation.value,
                            fireFlicker: fireFlicker,
                            fireSway: fireSway,
                            animProgress: animValue,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── 2b. Clean & Modern App Title ("NEON SPIN") ───────
                    Transform.translate(
                      offset: Offset(
                        0,
                        (1 - controller.titleSlide.value) * 20,
                      ),
                      child: Opacity(
                        opacity: controller.titleFade.value,
                        child: Text(
                          'NEON SPIN',
                          style: GoogleFonts.exo2(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 6,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: AppTheme.neonPink.withValues(alpha: 0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── 2c. Subtitle ─────────────────────────────────────
                    Opacity(
                      opacity: controller.taglineFade.value,
                      child: Text(
                        'TRUTH OR DARE',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 3.0,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 3. Minimal Neon Progress Bar at Bottom ──────────────────
              Positioned(
                left: 60,
                right: 60,
                bottom: 60,
                child: Opacity(
                  opacity: controller.taglineFade.value,
                  child: _SleekProgressBar(
                    progress: controller.progressBar.value,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Fiery Icon Hub Widget with Burning Flame Animation ───────────────────────

class _FieryIconHub extends StatelessWidget {
  final double glowOpacity;
  final double rotation;
  final double fireFlicker;
  final double fireSway;
  final double animProgress;

  const _FieryIconHub({
    required this.glowOpacity,
    required this.rotation,
    required this.fireFlicker,
    required this.fireSway,
    required this.animProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 115,
      height: 115,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF131C2E),
        border: Border.all(
          color: AppTheme.neonPink.withValues(alpha: 0.4 * glowOpacity + 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonPink
                .withValues(alpha: (0.45 + fireFlicker * 0.05) * glowOpacity),
            blurRadius: 30 + fireFlicker * 4,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: const Color(0xFFFF5722)
                .withValues(alpha: (0.35 + fireFlicker * 0.05) * glowOpacity),
            blurRadius: 20 + fireFlicker * 3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Transform.rotate(
          angle: rotation * 4 * math.pi + fireSway,
          child: Transform.scale(
            scale: 1.0 + fireFlicker * 0.04,
            child: ShaderMask(
              shaderCallback: (bounds) => _animatedFireGradientShader(
                bounds,
                animProgress,
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                size: 58,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Shader _animatedFireGradientShader(Rect bounds, double progress) {
    // Dynamic rising gradient offset mimicking rising hot flames
    final shift = math.sin(progress * 10 * math.pi) * 0.08;
    return LinearGradient(
      colors: const [
        Color(0xFFFF007F), // Neon Pink Base
        Color(0xFFFF3D00), // Fiery Red-Orange
        Color(0xFFFF9100), // Hot Orange-Amber
        Color(0xFFFFEA00), // Bright Yellow Tip
      ],
      stops: [
        0.0,
        (0.4 + shift).clamp(0.1, 0.7),
        (0.7 + shift).clamp(0.4, 0.9),
        1.0,
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ).createShader(bounds);
  }
}

// ── Animated Rising Fiery Embers Painter ─────────────────────────────────────

class _FieryEmbersPainter extends CustomPainter {
  final double progress;
  final double opacity;

  _FieryEmbersPainter({required this.progress, required this.opacity});

  static const List<(double, double, double)> _emberSeeds = [
    (-15, 0.1, 2.5),
    (12, 0.3, 3.0),
    (-8, 0.5, 2.0),
    (18, 0.7, 2.8),
    (-22, 0.8, 3.2),
    (5, 0.95, 2.2),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.01) return;

    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < _emberSeeds.length; i++) {
      final (xOffset, speedMult, radius) = _emberSeeds[i];

      // Calculate rising vertical movement for each ember
      final cycle = (progress * 2.5 * speedMult + i * 0.2) % 1.0;
      final yPos = center.dy - 10 - cycle * 55;
      final xPos = center.dx + xOffset + math.sin(cycle * math.pi * 3) * 4;

      // Ember fades out as it rises up
      final emberOpacity = (1.0 - cycle) * opacity * 0.7;

      final Paint emberPaint = Paint()
        ..color = Color.lerp(
          const Color(0xFFFFEA00), // Hot Yellow at bottom
          const Color(0xFFFF3D00), // Fiery Red at top
          cycle,
        )!
            .withValues(alpha: emberOpacity.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(Offset(xPos, yPos), radius * (1.0 - cycle * 0.4), emberPaint);
    }
  }

  @override
  bool shouldRepaint(_FieryEmbersPainter oldDelegate) => true;
}

// ── Minimal Progress Line Widget ─────────────────────────────────────────────

class _SleekProgressBar extends StatelessWidget {
  final double progress;

  const _SleekProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: const Color(0xFF1E293B),
      ),
      child: FractionallySizedBox(
        widthFactor: progress.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              colors: [
                AppTheme.neonPink,
                Color(0xFFFF5722),
                AppTheme.neonCyan,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonPink.withValues(alpha: 0.6),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
