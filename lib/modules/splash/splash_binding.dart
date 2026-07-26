import 'package:get/get.dart';
import 'package:kaal_spinnex/modules/splash/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SplashController());
  }
}
