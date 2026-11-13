import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Custom painter for real-time EOG waveform rendering.
///
/// Expects normalized values in [0, 1]. Draws a smooth polyline scaled to the
/// available size. Provided as an efficient alternative/complement to fl_chart.
class WaveformPainter extends CustomPainter {
  final List<double> samples;
  final Color lineColor;
  final Color gridColor;
  final double strokeWidth;
  final double? fixedMin;
  final double? fixedMax;

  WaveformPainter({
    required this.samples,
    this.lineColor = AppColors.primary300,
    this.gridColor = const Color(0x1A9A9E9E),
    this.strokeWidth = 2.0,
    this.fixedMin,
    this.fixedMax,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    if (samples.length < 2) return;

    double minY = fixedMin ?? samples.reduce(math.min);
    double maxY = fixedMax ?? samples.reduce(math.max);
    if ((maxY - minY).abs() < 1e-6) {
      minY -= 0.01;
      maxY += 0.01;
    }
    final range = maxY - minY;

    final path = Path();
    for (var i = 0; i < samples.length; i++) {
      final x = (i / (samples.length - 1)) * size.width;
      final norm = (samples[i] - minY) / range;
      final y = size.height - (norm * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    canvas.drawPath(path, paint);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    const rows = 4;
    for (var i = 1; i < rows; i++) {
      final y = size.height * i / rows;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
