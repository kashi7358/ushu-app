import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  
  const AppLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback just in case the image is missing from the folder
        return Icon(Icons.broken_image, size: size);
      },
    );
  }
}
