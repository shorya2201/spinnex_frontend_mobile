import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import 'scoreboard_controller.dart';

class ScoreboardView extends GetView<ScoreboardController> {
  const ScoreboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhiteBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.borderLight,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.textDarkSlate.withOpacity(0.05),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.textDarkSlate,
              size: 18,
            ),
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'FINAL SCORES',
          style: TextStyle(
            color: AppTheme.textDarkSlate,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(
        () => controller.players.isEmpty
            ? const Center(
                child: Text(
                  "No game data found.",
                  style: TextStyle(color: AppTheme.textSubtleSlate),
                ),
              )
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
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: mvp
                              ? AppTheme.neonCyan.withOpacity(0.2)
                              : AppTheme.textDarkSlate.withOpacity(0.04),
                          blurRadius: mvp ? 12 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: mvp
                            ? [
                                AppTheme.neonCyan.withOpacity(0.12),
                                AppTheme.surfaceWhite,
                              ]
                            : [
                                AppTheme.surfaceWhite,
                                const Color(0xFFF1F5F9),
                              ],
                      ),
                      border: Border.all(
                        color: mvp ? AppTheme.neonCyan : AppTheme.borderLight,
                        width: mvp ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: mvp
                            ? AppTheme.neonCyan
                            : const Color(0xFFE2E8F0),
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(
                            color: mvp ? Colors.white : AppTheme.textDarkSlate,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        player.name,
                        style: TextStyle(
                          color: AppTheme.textDarkSlate,
                          fontWeight: mvp ? FontWeight.bold : FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: mvp
                          ? const Text(
                              "👑 PARTY MVP",
                              style: TextStyle(
                                color: AppTheme.neonCyan,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            )
                          : chicken
                              ? const Text(
                                  "🐔 CHICKENED OUT",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                )
                              : null,
                      trailing: Text(
                        "${player.score} pts",
                        style: TextStyle(
                          color: player.score >= 0
                              ? AppTheme.neonGreen
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
      bottomNavigationBar: Container(
        color: AppTheme.offWhiteBackground,
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          onPressed: controller.playAgain,
          child: const Text("NEW GAME"),
        ),
      ),
    );
  }
}
