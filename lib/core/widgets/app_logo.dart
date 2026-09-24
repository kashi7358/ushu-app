import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double? height;
  final double? width;
  final double size;
  
  const AppLogo({
    super.key,
    this.size = 80,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final double h = height ?? size;
    return Image.asset(
      'assets/images/logo.png',
      height: h,
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: h,
          width: width ?? (h * 2.2),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF3B168F),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'USHU BUY',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: h * 0.28,
              letterSpacing: 1.2,
            ),
          ),
        );
      },
    );
  }
}
