import 'package:flutter/material.dart';

import '../core/yens_theme.dart';

/// Soft wave along the bottom (splash / headers).
class YensBottomWavePainter extends CustomPainter {
  YensBottomWavePainter({this.color = YensTheme.yellowLight});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, size.height * 0.35)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.15,
        size.width * 0.45,
        size.height * 0.42,
      )
      ..quadraticBezierTo(
        size.width * 0.68,
        size.height * 0.72,
        size.width,
        size.height * 0.38,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// White → yellow transition under the top bar (home).
class YensHeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 28)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height,
        size.width * 0.5,
        size.height - 20,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height - 40,
        size.width,
        size.height - 24,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Organic yellow blob behind “Special for you”.
/// Organic liquid yellow blob behind “Special for you”.
class YensSpecialBlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Gradient define karein taaki blob flat na lage
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          YensTheme.yellow,
          YensTheme.yellow.withValues(alpha: 0.85),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // 2. Shape ko thoda aur "asymmetric" banaya hai taaki organic lage
    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.25)
      ..cubicTo(
        size.width * -0.10, size.height * 0.45, // control point 1
        size.width * 0.05, size.height * 0.95,  // control point 2
        size.width * 0.45, size.height * 0.95,  // end point
      )
      ..cubicTo(
        size.width * 0.85, size.height * 0.95, 
        size.width * 1.15, size.height * 0.55, 
        size.width * 0.90, size.height * 0.15,
      )
      ..cubicTo(
        size.width * 0.70, size.height * -0.10, 
        size.width * 0.35, size.height * 0.05, 
        size.width * 0.15, size.height * 0.25,
      )
      ..close();

    // 3. Pehle ek halki si shadow draw karein (Optional)
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.1), 10, true);

    // 4. Main blob draw karein
    canvas.drawPath(path, paint);

    // 5. Glossy highlight ko thoda soft aur angled banaya hai
    final glossPath = Path()
      ..addOval(Rect.fromLTWH(
        size.width * 0.22, 
        size.height * 0.15, 
        size.width * 0.25, 
        size.height * 0.18,
      ));
      
    final glossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8); // Soft edges

    canvas.drawPath(glossPath, glossPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}