import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import 'game_controller.dart';
import 'widgets/mode_spinner.dart';

class GameView extends GetView<GameController> {
  const GameView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.offAllNamed(Routes.HOME);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SPIN!'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.offAllNamed(Routes.HOME),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.leaderboard, color: Colors.white),
              onPressed: controller.endGame,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double radius =
                        min(constraints.maxWidth, constraints.maxHeight) / 2.5;
                    double centerX = constraints.maxWidth / 2;
                    double centerY = constraints.maxHeight / 2;

                    return Obx(
                      () => Stack(
                        children: [
                          // Players
                          ...List.generate(controller.players.length, (index) {
                            double angle =
                                (2 * pi / controller.players.length) * index;
                            double x =
                                centerX +
                                radius * sin(angle) -
                                40; // center offset
                            double y = centerY - radius * cos(angle) - 40;

                            bool isWinner =
                                controller.selectedPlayerIndex.value == index;

                            return Positioned(
                              left: x,
                              top: y,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                transform: isWinner
                                    ? (Matrix4.identity()..scale(1.2))
                                    : Matrix4.identity(),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: isWinner
                                          ? Get.theme.colorScheme.secondary
                                          : Colors.grey[850],
                                      radius: 28,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            controller.players[index].emoji,
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                          Text(
                                            "${controller.players[index].score}",
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.8),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      controller.players[index].name,
                                      style: TextStyle(
                                        color: isWinner
                                            ? Get.theme.colorScheme.tertiary
                                            : Colors.white70,
                                        fontWeight: isWinner
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          // Mode-specific spinner
                          Positioned(
                            left: centerX - ModeSpinner.spinnerSize.width / 2,
                            top: centerY - ModeSpinner.spinnerSize.height / 2,
                            child: GestureDetector(
                              onTap: controller.spinBottle,
                              child: Transform.rotate(
                                angle: controller.currentAngle.value,
                                child: ModeSpinner(
                                  category: controller.selectedCategory.value,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Action Buttons
              Obx(
                () => controller.showActionButtons.value
                    ? Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Get.theme.colorScheme.secondary,
                              ),
                              onPressed: () => controller.chooseAction('TRUTH'),
                              child: const Text('TRUTH'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Get.theme.colorScheme.primary,
                              ),
                              onPressed: () => controller.chooseAction('DARE'),
                              child: const Text('DARE'),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(height: 80),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
