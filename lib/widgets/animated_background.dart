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
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    for (int i = 0; i < 25; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 4 + 1,
        speed: _random.nextDouble() * 0.3 + 0.1,
        opacity: _random.nextDouble() * 0.3 + 0.1,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Color.lerp(
                        const Color(0xFF0D0D1A),
                        accent.withOpacity(0.15),
                        _controller.value,
                      )!,
                      Color.lerp(
                        const Color(0xFF1A0D2E),
                        accent.withOpacity(0.08),
                        (_controller.value + 0.5) % 1.0,
                      )!,
                    ]
                  : [
                      Color.lerp(
                        const Color(0xFFF0F0F5),
                        accent.withOpacity(0.12),
                        _controller.value,
                      )!,
                      Color.lerp(
                        const Color(0xFFE8E8F0),
                        accent.withOpacity(0.06),
                        (_controller.value + 0.5) % 1.0,
                      )!,
                    ],
            ),
          ),
          child: CustomPaint(
            painter: ParticlePainter(
              particles: _particles,
              animationValue: _controller.value,
              accentColor: accent,
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  final Color accentColor;

  ParticlePainter({
    required this.particles,
    required this.animationValue,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final x = (particle.x + animationValue * particle.speed) % 1.0 * size.width;
      final y = (particle.y + animationValue * particle.speed * 0.5) % 1.0 * size.height;

      paint.color = accentColor.withOpacity(particle.opacity);
      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
