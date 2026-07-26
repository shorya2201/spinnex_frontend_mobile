import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.8, end: 1.2),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          builder: (context, double scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          // Pulsing Effect
          onEnd: () {}, // Handled by controller timer
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with Neon Glow effect
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Get.theme.colorScheme.primary.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.wine_bar_rounded, // Bottle alternative
                  size: 100,
                  color: Get.theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "NEON SPIN",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Get.theme.colorScheme.secondary,
                  shadows: [
                    Shadow(
                      color: Get.theme.colorScheme.secondary,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
