import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter(
      {this.animation,
      required this.seconds,
      this.fillColor,
      this.fillGradient,
      this.ringColor,
      this.ringGradient,
      this.strokeWidth,
      this.strokeCap,
      this.backgroundColor,
      this.backgroundGradient})
      : super(repaint: animation);

  final Animation<double>? animation;
  final int seconds;
  final Color? fillColor, ringColor, backgroundColor;
  final double? strokeWidth;
  final StrokeCap? strokeCap;
  final Gradient? fillGradient, ringGradient, backgroundGradient;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = ringColor!
      ..strokeWidth = strokeWidth!
      ..strokeCap = strokeCap!
      ..style = PaintingStyle.stroke;

    if (ringGradient != null) {
      final rect = Rect.fromCircle(
          center: size.center(Offset.zero), radius: size.width / 2);
      paint..shader = ringGradient!.createShader(rect);
    } else {
      paint..shader = null;
    }

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
    const max = 2 * math.pi;
    double progress = ((animation!.value) * seconds * max) % max;

    if (fillGradient != null) {
      final rect = Rect.fromCircle(
          center: size.center(Offset.zero), radius: size.width / 2);
      paint..shader = fillGradient!.createShader(rect);
    } else {
      paint..shader = null;
      paint.color = fillColor!;
    }

    canvas.drawArc(Offset.zero & size, math.pi * 1.5, progress, false, paint);

    if (backgroundColor != null || backgroundGradient != null) {
      final backgroundPaint = Paint();

      if (backgroundGradient != null) {
        final rect = Rect.fromCircle(
            center: size.center(Offset.zero), radius: size.width / 2.2);
        backgroundPaint..shader = backgroundGradient!.createShader(rect);
      } else {
        backgroundPaint.color = backgroundColor!;
      }
      canvas.drawCircle(
          size.center(Offset.zero), size.width / 2.2, backgroundPaint);
    }
  }

  @override
  bool shouldRepaint(CustomTimerPainter old) {
    return animation!.value != old.animation!.value ||
        ringColor != old.ringColor ||
        fillColor != old.fillColor;
  }
}
