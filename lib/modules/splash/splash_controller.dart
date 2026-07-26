import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToHome();
  }

  void _navigateToHome() async {
    // Wait for 3 seconds to show the pulsing logo
    await Future.delayed(const Duration(seconds: 3));
    Get.offNamed(Routes.HOME);
  }
}
