import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'scoreboard_controller.dart';

class ScoreboardView extends GetView<ScoreboardController> {
  const ScoreboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FINAL SCORES'),
        automaticallyImplyLeading:
            false, // Prevent going back to a finished game
      ),
      body: Obx(
        () => controller.players.isEmpty
            ? const Center(child: Text("No game data found."))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                itemCount: controller.players.length,
                itemBuilder: (context, index) {
                  final player = controller.players[index];
                  final mvp = controller.isMVP(index);
                  final chicken = controller.isBiggestChicken(index);

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: mvp
                            ? [
                                const Color(0xFF00FFFF).withOpacity(0.3),
                                Colors.transparent,
                              ]
                            : [
                                Colors.white.withOpacity(0.05),
                                Colors.transparent,
                              ],
                      ),
                      border: Border.all(
                        color: mvp ? const Color(0xFF00FFFF) : Colors.white10,
                        width: mvp ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: mvp
                            ? const Color(0xFF00FFFF)
                            : Colors.grey[900],
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        player.name,
                        style: TextStyle(
                          fontWeight: mvp ? FontWeight.bold : FontWeight.normal,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: mvp
                          ? const Text(
                              "👑 PARTY MVP",
                              style: TextStyle(
                                color: Color(0xFF00FFFF),
                                fontSize: 12,
                              ),
                            )
                          : chicken
                          ? const Text(
                              "🐔 CHICKENED OUT",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            )
                          : null,
                      trailing: Text(
                        "${player.score} pts",
                        style: TextStyle(
                          color: player.score >= 0
                              ? const Color(0xFF39FF14)
                              : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          onPressed: controller.playAgain,
          child: const Text("NEW GAME"),
        ),
      ),
    );
  }
}
