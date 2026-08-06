import 'package:get/get.dart';
import '../../data/providers/question_provider.dart';
import '../../data/repositories/question_repository.dart';
import '../../services/stomp_service.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Register StompService as a permanent singleton (survives route changes)
    if (!Get.isRegistered<StompService>()) {
      Get.put(StompService(), permanent: true);
    }

    // Initialize Data Layer
    Get.lazyPut(() => QuestionProvider());
    Get.lazyPut(() => QuestionRepository(provider: Get.find()));

    // Initialize Controller
    Get.lazyPut(() => HomeController(repository: Get.find()), fenix: true);
  }
}

