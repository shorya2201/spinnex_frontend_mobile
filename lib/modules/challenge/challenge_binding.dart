import 'package:get/get.dart';
import 'package:kaal_spinnex/modules/challenge/challenge_controller.dart';

class ChallengeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChallengeController());
  }
}
