import 'package:get/get.dart';
import '../../data/providers/question_provider.dart';
import '../../data/repositories/question_repository.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize Data Layer
    Get.lazyPut(() => QuestionProvider());
    Get.lazyPut(() => QuestionRepository(provider: Get.find()));

    // Initialize Controller
    Get.lazyPut(() => HomeController(repository: Get.find()), fenix: true);
  }
}
