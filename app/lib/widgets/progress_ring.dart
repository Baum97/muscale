import 'dart:math';

import 'package:flutter/material.dart';

/// Fortschrittsring mit runden Enden. [colors] mit zwei Farben ergibt einen Verlauf entlang des Rings.
/// Über 100 % läuft eine zweite, dunklere Runde mit, damit „zu viel“ sichtbar bleibt.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    required this.colors,
    required this.size,
    this.strokeWidth = 12,
    this.child,
  });

  /// 0 = leer, 1 = voll, >1 = überschritten.
  final double progress;
  final List<Color> colors;
  final double size;
  final double strokeWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final track = Theme.of(context).colorScheme.surfaceContainerHighest;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: progress.isFinite ? max(0, progress) : 0),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => CustomPaint(
        size: Size.square(size),
        painter: _RingPainter(value, colors, track, strokeWidth),
        child: SizedBox.square(
          dimension: size,
          child: Center(child: child),
        ),
      ),
      child: child,
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.colors, this.track, this.strokeWidth);

  final double progress;
  final List<Color> colors;
  final Color track;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset(strokeWidth / 2, strokeWidth / 2) & Size(size.width - strokeWidth, size.height - strokeWidth);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * pi, false, base..color = track);
    if (progress <= 0) return;

    const start = -pi / 2;
    final first = min(progress, 1.0);
    // Die runde Kappe am Anfang ragt um diesen Winkel vor den Bogen – der Verlauf beginnt entsprechend früher,
    // sonst bekäme die Kappe die Endfarbe.
    final cap = strokeWidth / 2 / (rect.width / 2);
    final gradient = SweepGradient(
      // Verlauf über den gefüllten Bogen strecken, nicht über den ganzen Kreis.
      startAngle: 0,
      endAngle: 2 * pi * max(first, 0.05) + cap,
      colors: colors.length == 1 ? [colors.first, colors.first] : colors,
      transform: GradientRotation(start - cap),
    );
    canvas.drawArc(rect, start, 2 * pi * first, false, base..shader = gradient.createShader(rect));

    // Überschreitung: zweite Runde in kräftigerer Farbe darüber.
    if (progress > 1) {
      final over = min(progress - 1, 1.0);
      final dark = Color.lerp(colors.last, Colors.black, 0.35)!;
      canvas.drawArc(
        rect,
        start,
        2 * pi * over,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = dark,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.track != track || old.strokeWidth != strokeWidth || old.colors != colors;
}
