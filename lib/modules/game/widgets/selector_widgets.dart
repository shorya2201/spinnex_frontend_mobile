import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/player_model.dart';

/// Cyber Wheel Widget: A glowing roulette wheel split into player slices
class CyberWheelWidget extends StatelessWidget {
  final List<PlayerModel> players;
  final double currentAngle;
  final bool isSpinning;

  const CyberWheelWidget({
    super.key,
    required this.players,
    required this.currentAngle,
    required this.isSpinning,
  });

  static const double wheelRadius = 110.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: wheelRadius * 2,
      height: wheelRadius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating Wheel Canvas
          Transform.rotate(
            angle: currentAngle,
            child: Container(
              width: wheelRadius * 2,
              height: wheelRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFFF).withValues(alpha: isSpinning ? 0.45 : 0.20),
                    blurRadius: isSpinning ? 30 : 15,
                    spreadRadius: isSpinning ? 6 : 2,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _CyberWheelPainter(players: players),
                size: Size(wheelRadius * 2, wheelRadius * 2),
              ),
            ),
          ),

          // Central Hub Button
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF2A004E), Color(0xFF0D0015)],
              ),
              border: Border.all(
                color: const Color(0xFF00FFFF),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF007F).withValues(alpha: 0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                isSpinning ? Icons.sync_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          // Top Neon Laser Pointer (Indicates selected sector)
          Positioned(
            top: -12,
            child: Column(
              children: [
                CustomPaint(
                  painter: _PointerArrowPainter(),
                  size: const Size(22, 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CyberWheelPainter extends CustomPainter {
  final List<PlayerModel> players;

  _CyberWheelPainter({required this.players});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (players.isEmpty) return;

    final sweepAngle = (2 * pi) / players.length;

    for (int i = 0; i < players.length; i++) {
      final startAngle = (i * sweepAngle) - (pi / 2);
      final player = players[i];
      final color = player.color;

      // Slice Fill
      final slicePaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            color.withValues(alpha: 0.9),
            color.withValues(alpha: 0.5),
            const Color(0xFF0D0015),
          ],
          stops: const [0.2, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 4),
        startAngle,
        sweepAngle,
        true,
        slicePaint,
      );

      // Slice Border Divider
      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 4),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      // Draw Player Emoji Icon on Slice
      final labelAngle = startAngle + (sweepAngle / 2);
      final iconRadius = radius * 0.65;
      final iconX = center.dx + iconRadius * cos(labelAngle);
      final iconY = center.dy + iconRadius * sin(labelAngle);

      TextPainter tp = TextPainter(
        text: TextSpan(
          text: player.emoji,
          style: const TextStyle(fontSize: 16),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(iconX - tp.width / 2, iconY - tp.height / 2));
    }

    // Outer Neon Ring
    final outerRingPaint = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius - 4, outerRingPaint);
  }

  @override
  bool shouldRepaint(covariant _CyberWheelPainter oldDelegate) =>
      oldDelegate.players != players;
}

class _PointerArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF007F), Color(0xFFFF4500)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Quantum Radar Pulse Widget: Concentric radar dish target scanner
class QuantumRadarWidget extends StatelessWidget {
  final PlayerModel? activePlayer;
  final bool isSpinning;
  final double currentAngle;

  const QuantumRadarWidget({
    super.key,
    required this.activePlayer,
    required this.isSpinning,
    required this.currentAngle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating Radar Beam Sweep
          Transform.rotate(
            angle: currentAngle,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF39FF14).withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: CustomPaint(
                painter: _RadarBeamPainter(),
              ),
            ),
          ),

          // Central Holographic Energy Core
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activePlayer != null
                  ? activePlayer!.color.withValues(alpha: 0.25)
                  : const Color(0xFF39FF14).withValues(alpha: 0.15),
              border: Border.all(
                color: activePlayer != null
                    ? activePlayer!.color
                    : const Color(0xFF39FF14),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: activePlayer != null
                      ? activePlayer!.color.withValues(alpha: 0.6)
                      : const Color(0xFF39FF14).withValues(alpha: 0.4),
                  blurRadius: isSpinning ? 20 : 10,
                  spreadRadius: isSpinning ? 4 : 1,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    activePlayer?.emoji ?? "⚡",
                    style: TextStyle(fontSize: activePlayer != null ? 26 : 22),
                  ),
                  if (activePlayer != null)
                    Text(
                      activePlayer!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.orbitron(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarBeamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF39FF14).withValues(alpha: 0.05),
          const Color(0xFF39FF14).withValues(alpha: 0.4),
          const Color(0xFF39FF14),
        ],
        stops: const [0.0, 0.7, 0.95, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sweepPaint);

    // Crosshairs
    final linePaint = Paint()
      ..color = const Color(0xFF39FF14).withValues(alpha: 0.25)
      ..strokeWidth = 1;

    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Holographic Jackpot Deck Widget: High-tech slot-card shuffle animation core
class JackpotDeckWidget extends StatelessWidget {
  final PlayerModel? activePlayer;
  final bool isSpinning;

  const JackpotDeckWidget({
    super.key,
    required this.activePlayer,
    required this.isSpinning,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFBF5FFF).withValues(alpha: 0.3),
            const Color(0xFF0D0015),
            const Color(0xFFFF007F).withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: activePlayer != null
              ? activePlayer!.color
              : const Color(0xFFBF5FFF),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: activePlayer != null
                ? activePlayer!.color.withValues(alpha: 0.6)
                : const Color(0xFFBF5FFF).withValues(alpha: 0.35),
            blurRadius: isSpinning ? 20 : 10,
            spreadRadius: isSpinning ? 4 : 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Corner Cyber Grid Lines
          Positioned(
            top: 6,
            left: 10,
            child: Text(
              "JACKPOT CORE",
              style: GoogleFonts.orbitron(
                fontSize: 6.5,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFBF5FFF),
                letterSpacing: 0.8,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: KeyedSubtree(
                  key: ValueKey(activePlayer?.name ?? "SHUFFLE"),
                  child: Column(
                    children: [
                      Text(
                        activePlayer?.emoji ?? "🃏",
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          activePlayer != null
                              ? activePlayer!.name.toUpperCase()
                              : (isSpinning ? "SHUFFLING..." : "TAP TO DRAW"),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.orbitron(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
