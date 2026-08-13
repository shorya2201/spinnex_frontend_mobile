import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final AnimationController animationController;

  // ── Animation intervals for 2.5s cinematic splash sequence ──

  /// Background & mesh fade-in
  late final Animation<double> backgroundFade;

  /// Ambient neon orb pulsing scale & opacity
  late final Animation<double> orbPulse;

  /// Outer dial ring rotation (0 -> 1.5 turns)
  late final Animation<double> ringRotation;

  /// Main bottle icon scale (elastic pop)
  late final Animation<double> iconScale;

  /// Bottle spin rotation (0 -> 2 turns)
  late final Animation<double> bottleRotation;

  /// Neon glow intensity bloom
  late final Animation<double> glowBloom;

  /// Title slide up + fade
  late final Animation<double> titleSlide;
  late final Animation<double> titleFade;

  /// Truth or Dare Pill Badge scale pop
  late final Animation<double> badgeScale;
  late final Animation<double> badgeFade;

  /// Tagline fade
  late final Animation<double> taglineFade;

  /// Progress bar fill
  late final Animation<double> progressBar;

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _initAnimations();
    animationController.forward();
    _navigateToHome();
  }

  void _initAnimations() {
    backgroundFade = CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
    );

    orbPulse = CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.1, 0.9, curve: Curves.easeInOut),
    );

    iconScale = CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.05, 0.3, curve: Curves.elasticOut),
    );

    ringRotation = CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.1, 0.6, curve: Curves.easeOutCubic),
    );

    bottleRotation = CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.15, 0.65, curve: Curves.easeOutQuart),
    );

    glowBloom = CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
    );

    badgeScale = CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.35, 0.55, curve: Curves.elasticOut),
    );

    badgeFade = CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.35, 0.5, curve: Curves.easeIn),
    );

    titleSlide = CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.45, 0.7, curve: Curves.easeOutCubic),
    );

    titleFade = CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.45, 0.65, curve: Curves.easeIn),
    );

    taglineFade = CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.6, 0.8, curve: Curves.easeIn),
    );

    progressBar = CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.5, 0.95, curve: Curves.easeInOutCubic),
    );
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2750));
    Get.offNamed(Routes.HOME);
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
