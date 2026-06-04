import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smart_media_hub/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _navigateToNext();
  }

  void _navigateToNext() async {
    int delay = kIsWeb ? 3400 : 3000;
    await Future.delayed(Duration(milliseconds: delay));
    if (mounted) context.go('/auth');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.splashBG,
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(top: -50, left: -50, child: _circle()),
            Positioned(top: -50, right: -50, child: _circle()),
            Positioned(bottom: -50, left: -50, child: _circle()),
            Positioned(bottom: -50, right: -50, child: _circle()),
            
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with pulse and rotation
                  ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.1).animate(
                      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                    ),
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 44),
                    ).animate(onPlay: (controller) => controller.repeat())
                     .rotate(duration: 12.seconds),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Smart Media Hub",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 30),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),
                  // Badge pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          "AI-Powered Creative Suite",
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 32),
                  // Feature chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _featureChip("Images", 0),
                      _featureChip("Videos", 1),
                      _featureChip("GIFs", 2),
                      _featureChip("AI", 3),
                    ],
                  ),
                ],
              ),
            ),
            
            // Bottom loading
            Positioned(
              bottom: 60,
              left: 40,
              right: 40,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _dot(0),
                      _dot(1),
                      _dot(2),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ).animate().scaleX(
                      duration: 2600.ms,
                      alignment: Alignment.centerLeft,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Loading your creative tools...",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white.withValues(alpha: 0.58)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _featureChip(String label, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    ).animate().fadeIn(delay: (600 + (index * 80)).ms).scale(delay: (600 + (index * 80)).ms);
  }

  Widget _dot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .moveY(begin: 0, end: -10, duration: 600.ms, delay: (index * 200).ms);
  }
}
