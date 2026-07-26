import 'package:flutter/material.dart';

/// Mode-specific spinner visuals that rotate around the center of [spinnerSize].
class ModeSpinner extends StatelessWidget {
  final String category;

  const ModeSpinner({super.key, required this.category});

  static const Size spinnerSize = Size(64, 172);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: spinnerSize.width,
      height: spinnerSize.height,
      child: CustomPaint(
        painter: _painterFor(category),
        size: spinnerSize,
      ),
    );
  }

  CustomPainter _painterFor(String category) {
    if (category.contains('Party')) {
      return const _DiscoBallPainter();
    } else if (category.contains('Spicy')) {
      return const _ChiliPepperPainter();
    } else {
      return const _FamilyBottlePainter();
    }
  }
}

class _FamilyBottlePainter extends CustomPainter {
  const _FamilyBottlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    _drawGroundShadow(canvas, cx, size.height - 6, 22, const Color(0xFF00FFFF));

    final bottle = _bottlePath(size);
    final glassGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFF1B5E20).withOpacity(0.95),
        const Color(0xFF4CAF50),
        const Color(0xFF81C784),
        const Color(0xFF2E7D32),
      ],
      stops: const [0.0, 0.35, 0.65, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(
      bottle,
      Paint()
        ..shader = glassGradient
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      bottle,
      Paint()
        ..color = const Color(0xFF00FFFF).withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Glass highlight
    canvas.drawPath(
      Path()
        ..moveTo(cx - 10, size.height * 0.42)
        ..quadraticBezierTo(cx - 14, size.height * 0.62, cx - 8, size.height * 0.78),
      Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Paper label
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, size.height * 0.58),
        width: 34,
        height: 28,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      labelRect,
      Paint()..color = const Color(0xFFF5F0E1).withOpacity(0.92),
    );
    _drawLabelText(canvas, cx, size.height * 0.58);

    // Cork cap — the pointer end
    final corkRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, 10), width: 16, height: 18),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      corkRect,
      Paint()..color = const Color(0xFFD4A574),
    );
    canvas.drawRRect(
      corkRect,
      Paint()
        ..color = const Color(0xFF8D6E63)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Neck ring
    canvas.drawLine(
      Offset(cx - 9, 30),
      Offset(cx + 9, 30),
      Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..strokeWidth = 1.5,
    );
  }

  Path _bottlePath(Size size) {
    final cx = size.width / 2;
    return Path()
      ..moveTo(cx - 7, 20)
      ..lineTo(cx - 7, 34)
      ..quadraticBezierTo(cx - 26, 52, cx - 24, 72)
      ..lineTo(cx - 24, size.height - 18)
      ..quadraticBezierTo(cx - 24, size.height - 4, cx, size.height - 4)
      ..quadraticBezierTo(cx + 24, size.height - 4, cx + 24, size.height - 18)
      ..lineTo(cx + 24, 72)
      ..quadraticBezierTo(cx + 26, 52, cx + 7, 34)
      ..lineTo(cx + 7, 20)
      ..close();
  }

  void _drawLabelText(Canvas canvas, double cx, double cy) {
    const style = TextStyle(
      color: Color(0xFF1B5E20),
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.5,
    );
    for (final entry in [
      ('T', -7.0),
      ('/', 0.0),
      ('D', 7.0),
    ]) {
      final tp = TextPainter(
        text: TextSpan(text: entry.$1, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx + entry.$2 - tp.width / 2, cy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DiscoBallPainter extends CustomPainter {
  const _DiscoBallPainter();

  static const _tileColors = [
    Color(0xFFFF007F),
    Color(0xFF00FFFF),
    Color(0xFF39FF14),
    Color(0xFFFFD700),
    Color(0xFFBF5FFF),
    Colors.white,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    const ballRadius = 27.0;
    final ballCenter = Offset(cx, size.height - ballRadius - 14);

    _drawGroundShadow(canvas, cx, size.height - 6, 24, const Color(0xFFFF007F));

    // Neon pointer arrow
    final arrow = Path()
      ..moveTo(cx, 2)
      ..lineTo(cx - 10, 22)
      ..lineTo(cx + 10, 22)
      ..close();
    canvas.drawPath(
      arrow,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF007F), Color(0xFFBF5FFF)],
        ).createShader(Rect.fromLTWH(cx - 10, 2, 20, 20)),
    );

    // Hanging rod
    canvas.drawLine(
      Offset(cx, 22),
      Offset(ballCenter.dx, ballCenter.dy - ballRadius),
      Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..strokeWidth = 2.5,
    );

    // Ball base glow
    canvas.drawCircle(
      ballCenter,
      ballRadius + 6,
      Paint()
        ..color = const Color(0xFFFF007F).withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    canvas.drawCircle(
      ballCenter,
      ballRadius,
      Paint()..color = const Color(0xFF2A1040),
    );

    // Mirror tiles
    final tileSize = 7.0;
    final cols = (ballRadius * 2 / tileSize).ceil();
    for (var row = 0; row < cols; row++) {
      for (var col = 0; col < cols; col++) {
        final x = ballCenter.dx - ballRadius + col * tileSize;
        final y = ballCenter.dy - ballRadius + row * tileSize;
        final tileCenter = Offset(x + tileSize / 2, y + tileSize / 2);
        if ((tileCenter - ballCenter).distance > ballRadius - 1) continue;

        final color = _tileColors[(row + col) % _tileColors.length];
        canvas.drawRect(
          Rect.fromLTWH(x + 0.5, y + 0.5, tileSize - 1, tileSize - 1),
          Paint()..color = color.withOpacity(0.85),
        );
      }
    }

    canvas.drawCircle(
      ballCenter,
      ballRadius,
      Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Confetti sparkles
    _drawSparkle(canvas, Offset(cx - 22, 48), const Color(0xFF39FF14));
    _drawSparkle(canvas, Offset(cx + 24, 62), const Color(0xFF00FFFF));
    _drawSparkle(canvas, Offset(cx - 18, 88), const Color(0xFFFFD700));
    _drawSparkle(canvas, Offset(cx + 20, 102), const Color(0xFFFF007F));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChiliPepperPainter extends CustomPainter {
  const _ChiliPepperPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    _drawGroundShadow(canvas, cx, size.height - 6, 20, const Color(0xFFFF4500));

    // Flame aura behind the tip
    final flameGlow = Path()
      ..moveTo(cx, 6)
      ..quadraticBezierTo(cx - 18, 28, cx - 10, 46)
      ..quadraticBezierTo(cx, 36, cx + 10, 46)
      ..quadraticBezierTo(cx + 18, 28, cx, 6)
      ..close();
    canvas.drawPath(
      flameGlow,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.topCenter,
          radius: 1.2,
          colors: [
            const Color(0xFFFFD54F).withOpacity(0.7),
            const Color(0xFFFF4500).withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, 60)),
    );

    final pepper = _pepperPath(size);
    canvas.drawPath(
      pepper,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF6D00),
            Color(0xFFFF1744),
            Color(0xFFB71C1C),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      pepper,
      Paint()
        ..color = const Color(0xFFFFAB40).withOpacity(0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Pepper shine
    canvas.drawPath(
      Path()
        ..moveTo(cx - 6, size.height * 0.35)
        ..quadraticBezierTo(cx - 10, size.height * 0.55, cx - 4, size.height * 0.72),
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Seeds
    for (final y in [0.48, 0.58, 0.68, 0.78]) {
      canvas.drawCircle(
        Offset(cx + (y > 0.6 ? 2 : -2), size.height * y),
        1.8,
        Paint()..color = const Color(0xFFFFF8E1).withOpacity(0.55),
      );
    }

    // Green stem at the tip (pointer)
    final stem = Path()
      ..moveTo(cx - 5, 14)
      ..quadraticBezierTo(cx - 8, 4, cx - 2, 2)
      ..quadraticBezierTo(cx + 4, 0, cx + 6, 10)
      ..quadraticBezierTo(cx + 2, 16, cx - 5, 14)
      ..close();
    canvas.drawPath(stem, Paint()..color = const Color(0xFF2E7D32));
    canvas.drawPath(
      stem,
      Paint()
        ..color = const Color(0xFF1B5E20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Small flame tongues at tip
    _drawFlame(canvas, Offset(cx - 8, 18), 10);
    _drawFlame(canvas, Offset(cx + 6, 16), 8);
  }

  Path _pepperPath(Size size) {
    final cx = size.width / 2;
    return Path()
      ..moveTo(cx, 18)
      ..quadraticBezierTo(cx - 14, 36, cx - 18, size.height * 0.45)
      ..quadraticBezierTo(cx - 20, size.height * 0.72, cx - 10, size.height - 12)
      ..quadraticBezierTo(cx, size.height - 2, cx + 10, size.height - 12)
      ..quadraticBezierTo(cx + 20, size.height * 0.72, cx + 18, size.height * 0.45)
      ..quadraticBezierTo(cx + 14, 36, cx, 18)
      ..close();
  }

  void _drawFlame(Canvas canvas, Offset origin, double height) {
    final flame = Path()
      ..moveTo(origin.dx, origin.dy)
      ..quadraticBezierTo(origin.dx - 4, origin.dy - height * 0.5, origin.dx, origin.dy - height)
      ..quadraticBezierTo(origin.dx + 4, origin.dy - height * 0.5, origin.dx, origin.dy)
      ..close();
    canvas.drawPath(
      flame,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFFFF4500), Color(0xFFFFD54F)],
        ).createShader(Rect.fromLTWH(origin.dx - 6, origin.dy - height, 12, height)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _drawGroundShadow(Canvas canvas, double cx, double cy, double rx, Color color) {
  canvas.drawOval(
    Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: 8),
    Paint()
      ..color = color.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
  );
}

void _drawSparkle(Canvas canvas, Offset center, Color color) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = 1.5
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
    Offset(center.dx - 4, center.dy),
    Offset(center.dx + 4, center.dy),
    paint,
  );
  canvas.drawLine(
    Offset(center.dx, center.dy - 4),
    Offset(center.dx, center.dy + 4),
    paint,
  );
}
