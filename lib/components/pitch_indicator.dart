import 'dart:math';
import 'package:flutter/material.dart';

class PitchIndicatorPainter extends CustomPainter {
  final double cents;
  final String note;
  PitchIndicatorPainter(this.cents, this.note);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2 - 16, size.height / 2 - 16);

    final textPainter = TextPainter(
      text: TextSpan(
        text: note,
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );

    final arrowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = (cents.abs() < 7) ? Colors.green : Colors.red;

    const arrowSize = 20.0;

    canvas.drawPath(
      Path()
        ..moveTo(center.dx - radius - 10, center.dy)
        ..lineTo(center.dx - radius + arrowSize, center.dy - arrowSize)
        ..lineTo(center.dx - radius + arrowSize, center.dy + arrowSize)
        ..close(),
      arrowPaint..color = (cents < -7) ? Colors.red : Colors.white24,
    );

    canvas.drawPath(
      Path()
        ..moveTo(center.dx + radius + 10, center.dy)
        ..lineTo(center.dx + radius - arrowSize, center.dy - arrowSize)
        ..lineTo(center.dx + radius - arrowSize, center.dy + arrowSize)
        ..close(),
      arrowPaint..color = (cents > 7) ? Colors.red : Colors.white24,
    );
  }

  @override
  bool shouldRepaint(covariant PitchIndicatorPainter old) =>
      old.cents != cents || old.note != note;
}
