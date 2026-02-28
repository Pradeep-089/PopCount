import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FloatingBlob> _blobs = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    final random = Random();
    for (int i = 0; i < 6; i++) {
      _blobs.add(_FloatingBlob(
        color: [
          const Color(0xFFE3F2FD).withOpacity(0.15),
          const Color(0xFFF8BBD0).withOpacity(0.15),
          const Color(0xFFFFF59D).withOpacity(0.15),
        ][random.nextInt(3)],
        size: 150.0 + random.nextDouble() * 150.0,
        initialOffset: Offset(random.nextDouble(), random.nextDouble()),
        speed: 0.2 + random.nextDouble() * 0.3,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE3F2FD), // Deeper Pastel Blue
                Color(0xFFF8BBD0), // Deeper Pastel Pink
                Color(0xFFFFF59D), // Deeper Pastel Yellow
              ],
            ),
          ),
          child: Stack(
            children: [
              ..._blobs.map((blob) {
                final x = (blob.initialOffset.dx + _controller.value * blob.speed) % 1.0;
                final y = (blob.initialOffset.dy + sin(_controller.value * pi * 2) * 0.1) % 1.0;
                
                return Positioned(
                  left: x * MediaQuery.of(context).size.width - blob.size / 2,
                  top: y * MediaQuery.of(context).size.height - blob.size / 2,
                  child: Container(
                    width: blob.size,
                    height: blob.size,
                    decoration: BoxDecoration(
                      color: blob.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

class _FloatingBlob {
  final Color color;
  final double size;
  final Offset initialOffset;
  final double speed;

  _FloatingBlob({
    required this.color,
    required this.size,
    required this.initialOffset,
    required this.speed,
  });
}
