import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';

class OrbitPainter extends CustomPainter {
  const OrbitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final angle in [-.5, .5]) {
      canvas.save();
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 140, height: 62),
        paint..color = AppColors.violet.withValues(alpha: .55),
      );
      canvas.restore();
    }
    canvas.drawCircle(Offset.zero, 9, Paint()..color = AppColors.mint);
    canvas.drawCircle(
      const Offset(57, -30),
      4,
      Paint()..color = AppColors.violet,
    );
  }

  @override
  bool shouldRepaint(covariant OrbitPainter oldDelegate) => false;
}

class SkyPainter extends CustomPainter {
  const SkyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment.topRight,
          radius: 1.2,
          colors: [Color(0xFF192746), AppColors.background],
        ).createShader(bounds),
    );
    final paint = Paint()..color = AppColors.muted.withValues(alpha: .12);
    for (double x = 24; x < size.width; x += 40) {
      for (double y = 24; y < size.height; y += 40) {
        canvas.drawCircle(Offset(x, y), .7, paint);
      }
    }
    canvas.drawCircle(
      Offset(size.width - 40, 100),
      220,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = AppColors.violet.withValues(alpha: .06),
    );
  }

  @override
  bool shouldRepaint(covariant SkyPainter oldDelegate) => false;
}
