import 'package:get/get.dart';
import '../../data/models/player_model.dart';

class ScoreboardController extends GetxController {
  // Reactive list of players
  final players = <PlayerModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Retrieve the arguments passed from GameController
    if (Get.arguments is List<PlayerModel>) {
      List<PlayerModel> rawList = Get.arguments;

      // Sort players by score descending
      rawList.sort((a, b) => b.score.compareTo(a.score));
      players.assignAll(rawList);
    }
  }

  // Helper logic to identify status
  bool isMVP(int index) => index == 0 && players[index].score > 0;

  bool isBiggestChicken(int index) {
    if (players.length < 2) return false;
    // The last person in the sorted list is the chicken
    return index == players.length - 1;
  }

  void playAgain() {
    // Navigate back to home and clear the navigation stack
    Get.offAllNamed('/home');
  }
}
