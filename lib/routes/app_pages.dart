import 'package:get/get.dart';
import '../modules/challenge/challenge_view.dart';
import '../modules/game/game_view.dart';
import '../modules/home/home_view.dart';
import '../modules/scoreboard/scoreboard_view.dart';
import '../modules/splash/splash_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/scoreboard/scoreboard_binding.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/game/game_binding.dart';
import '../modules/challenge/challenge_binding.dart';
import 'app_routes.dart';

// Import your views and bindings here...
class AppPages {
  static const INITIAL = Routes.SPLASH;
  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.GAME,
      page: () => const GameView(),
      binding: GameBinding(),
    ),
    GetPage(
      name: Routes.CHALLENGE,
      page: () => const ChallengeView(),
      binding: ChallengeBinding(),
    ),
    GetPage(
      name: Routes.SCOREBOARD,
      page: () => const ScoreboardView(),
      binding: ScoreboardBinding(),
    ),
  ];
}
