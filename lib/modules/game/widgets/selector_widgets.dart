import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/player_model.dart';
import '../../../theme/app_theme.dart';

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
            child: CustomPaint(
              painter: _CyberWheelPainter(players: players),
              size: const Size(wheelRadius * 2, wheelRadius * 2),
            ),
          ),

          // Central Hub Button
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceWhite,
              border: Border.all(
                color: AppTheme.neonPink,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonPink.withValues(alpha: 0.35),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                isSpinning ? Icons.sync_rounded : Icons.play_arrow_rounded,
                color: AppTheme.neonPink,
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
            color.withValues(alpha: 0.95),
            color.withValues(alpha: 0.65),
            AppTheme.surfaceWhite,
          ],
          stops: const [0.2, 0.75, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 4),
        startAngle,
        sweepAngle,
        true,
        slicePaint,
      );

      // Slice Border Divider
      final dividerPaint = Paint()
        ..color = AppTheme.surfaceWhite
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final endX = center.dx + (radius - 4) * cos(startAngle);
      final endY = center.dy + (radius - 4) * sin(startAngle);
      canvas.drawLine(center, Offset(endX, endY), dividerPaint);

      // Draw Player Emoji & Name
      _drawSliceContent(canvas, center, radius, startAngle, sweepAngle, player);
    }

    // Outer Rim Glow Ring
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppTheme.neonPink
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius - 2, rimPaint);
  }

  void _drawSliceContent(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    PlayerModel player,
  ) {
    final midAngle = startAngle + (sweepAngle / 2);
    final textRadius = radius * 0.62;

    final labelX = center.dx + textRadius * cos(midAngle);
    final labelY = center.dy + textRadius * sin(midAngle);

    canvas.save();
    canvas.translate(labelX, labelY);
    canvas.rotate(midAngle + (pi / 2));

    final textSpan = TextSpan(
      text: "${player.emoji} ${player.name}",
      style: GoogleFonts.orbitron(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: const [
          Shadow(color: Colors.black87, blurRadius: 4),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
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

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        colors: [AppTheme.neonPink, Color(0xFFFF4500)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppTheme.surfaceWhite
      ..strokeWidth = 1.5;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Cyber Radar Selector Widget (Scanning Beam)
class CyberRadarWidget extends StatelessWidget {
  final List<PlayerModel> players;
  final double currentAngle;
  final bool isSpinning;
  final int? selectedIndex;

  const CyberRadarWidget({
    super.key,
    required this.players,
    required this.currentAngle,
    required this.isSpinning,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radar Scope Background Rings & Sweep
          CustomPaint(
            painter: _RadarScopePainter(
              currentAngle: currentAngle,
              isSpinning: isSpinning,
            ),
            size: const Size(220, 220),
          ),

          // Player Nodes Positioned Orbitally
          for (int i = 0; i < players.length; i++)
            _buildPlayerNode(context, i, players.length),
        ],
      ),
    );
  }

  Widget _buildPlayerNode(BuildContext context, int index, int total) {
    final angle = (2 * pi / total) * index - (pi / 2);
    final distance = 80.0;
    final x = distance * cos(angle);
    final y = distance * sin(angle);

    final isHighlighted = selectedIndex == index;
    final player = players[index];

    return Transform.translate(
      offset: Offset(x, y),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isHighlighted ? 44 : 36,
        height: isHighlighted ? 44 : 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isHighlighted
              ? AppTheme.neonGreen
              : AppTheme.surfaceWhite,
          border: Border.all(
            color: isHighlighted
                ? AppTheme.neonGreen
                : AppTheme.borderLight,
            width: isHighlighted ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isHighlighted
                  ? AppTheme.neonGreen.withValues(alpha: 0.5)
                  : AppTheme.textDarkSlate.withValues(alpha: 0.08),
              blurRadius: isHighlighted ? 12 : 4,
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
    );
  }
}

class _RadarScopePainter extends CustomPainter {
  final double currentAngle;
  final bool isSpinning;

  _RadarScopePainter({
    required this.currentAngle,
    required this.isSpinning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Grid Concentric Rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppTheme.borderLight
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius - 10, ringPaint);
    canvas.drawCircle(center, radius - 45, ringPaint);
    canvas.drawCircle(center, radius - 80, ringPaint);

    // Crosshairs
    canvas.drawLine(
      Offset(10, center.dy),
      Offset(size.width - 10, center.dy),
      ringPaint,
    );
    canvas.drawLine(
      Offset(center.dx, 10),
      Offset(center.dx, size.height - 10),
      ringPaint,
    );

    // Sweep Beam Sector
    final sweepPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: pi / 2,
        colors: [
          Colors.transparent,
          AppTheme.neonGreen.withValues(alpha: 0.05),
          AppTheme.neonGreen.withValues(alpha: 0.2),
          AppTheme.neonGreen.withValues(alpha: 0.4),
        ],
        transform: GradientRotation(currentAngle),
      ).createShader(Rect.fromCircle(center: center, radius: radius - 10));

    canvas.drawCircle(center, radius - 10, sweepPaint);

    // Leading Radar Beam Line
    final beamAngle = currentAngle + (pi / 2);
    final beamEnd = Offset(
      center.dx + (radius - 10) * cos(beamAngle),
      center.dy + (radius - 10) * sin(beamAngle),
    );
    final beamLinePaint = Paint()
      ..color = AppTheme.neonGreen
      ..strokeWidth = 2.0;

    canvas.drawLine(center, beamEnd, beamLinePaint);
  }

  @override
  bool shouldRepaint(covariant _RadarScopePainter oldDelegate) => true;
}

/// Cyber Jackpot Draw Box Widget
class CyberJackpotWidget extends StatelessWidget {
  final PlayerModel? activePlayer;
  final bool isSpinning;

  const CyberJackpotWidget({
    super.key,
    required this.activePlayer,
    required this.isSpinning,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.surfaceWhite,
        border: Border.all(
          color: activePlayer != null
              ? activePlayer!.color
              : const Color(0xFFBF5FFF),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: activePlayer != null
                ? activePlayer!.color.withValues(alpha: 0.4)
                : AppTheme.textDarkSlate.withValues(alpha: 0.08),
            blurRadius: isSpinning ? 20 : 10,
            spreadRadius: isSpinning ? 3 : 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: KeyedSubtree(
                  key: ValueKey(activePlayer?.name ?? "SHUFFLE"),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        activePlayer?.emoji ?? "🃏",
                        style: const TextStyle(
                          fontSize: 34,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(
                          activePlayer != null
                              ? activePlayer!.name.toUpperCase()
                              : (isSpinning ? "SHUFFLING..." : "TAP TO DRAW"),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textDarkSlate,
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
