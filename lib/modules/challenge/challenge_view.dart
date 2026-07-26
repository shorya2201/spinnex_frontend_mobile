import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'challenge_controller.dart';

class ChallengeView extends GetView<ChallengeController> {
  const ChallengeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${controller.player.name}'s ${controller.question.type}",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: controller.question.type == 'DARE'
                      ? Get.theme.colorScheme.primary
                      : Get.theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Get.theme.colorScheme.tertiary),
                ),
                child: Text(
                  controller.question.content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
              const SizedBox(height: 40),

              Obx(
                () => Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: controller.timeLeft.value / 45,
                        color: controller.timeLeft.value > 10
                            ? Get.theme.colorScheme.secondary
                            : Colors.red,
                        backgroundColor: Colors.grey[800],
                        strokeWidth: 8,
                      ),
                    ),
                    Text(
                      "${controller.timeLeft.value}",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: controller.chickenOut,
                      child: const Text('CHICKEN OUT (-1)'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.tertiary,
                      ),
                      onPressed: controller.completeChallenge,
                      child: Text(
                        'COMPLETED (+${controller.question.type == 'DARE' ? 2 : 1})',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
