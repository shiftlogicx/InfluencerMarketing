import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PulseLogoMark extends StatelessWidget {
  final double size;
  final bool isBrand;

  const PulseLogoMark({
    super.key,
    this.size = 32,
    this.isBrand = true,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isBrand ? AppTheme.appleBlue : AppTheme.appleGold;
    final secondaryColor = isBrand ? const Color(0xFF0056B3) : const Color(0xFFB8860B);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D12),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.25),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.65, size * 0.55),
          painter: _PulseWavePainter(color: primaryColor, glowColor: secondaryColor),
        ),
      ),
    );
  }
}

class _PulseWavePainter extends CustomPainter {
  final Color color;
  final Color glowColor;

  _PulseWavePainter({required this.color, required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Elegant Apple-style ECG pulse waveform
    path.moveTo(0, h * 0.5);
    path.lineTo(w * 0.25, h * 0.5);
    path.lineTo(w * 0.38, h * 0.15); // sharp peak up
    path.lineTo(w * 0.55, h * 0.95); // sharp drop
    path.lineTo(w * 0.72, h * 0.35); // recovery
    path.lineTo(w * 0.82, h * 0.5);  // baseline
    path.lineTo(w * 0.92, h * 0.5);

    canvas.drawPath(path, strokePaint);

    // Glowing termination pulse dot
    canvas.drawCircle(Offset(w * 0.92, h * 0.5), 2.2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
