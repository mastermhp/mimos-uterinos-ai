import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  final double waveHeight;
  final double waveCount;

  WaveClipper({this.waveHeight = 20, this.waveCount = 4});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - waveHeight);

    final waveWidth = size.width / waveCount;
    
    // Draw waves
    for (int i = 0; i < waveCount; i++) {
      path.quadraticBezierTo(
        waveWidth * (i + 0.5), 
        size.height - (i.isEven ? 0 : waveHeight * 2), 
        waveWidth * (i + 1), 
        size.height - waveHeight
      );
    }
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
