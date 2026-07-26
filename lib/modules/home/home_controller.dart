import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/player_model.dart';
import '../../data/repositories/question_repository.dart';
import '../../routes/app_routes.dart';

class HomeController extends GetxController {
  final QuestionRepository repository;
  HomeController({required this.repository});

  var playerCount = 2.obs;
  var playerControllers = <TextEditingController>[].obs;
  var playerEmojisList = <String>[].obs;
  var playerColorsList = <Color>[].obs;
  var selectedCategory = 'Party'.obs;
  var isMusicOn = true.obs;
  var isLoading = false.obs;

  final List<String> categories = ['Classic', 'Party', 'Spicy'];

  static const List<Color> glowColors = [
    Color(0xFFFF007F), // Neon Pink
    Color(0xFF00FFFF), // Cyan
    Color(0xFF39FF14), // Neon Lime
    Color(0xFFFFEA00), // Yellow
    Color(0xFFFF5722), // Orange
    Color(0xFFB026FF), // Purple
    Color(0xFF00E676), // Teal
  ];

  static const List<String> playerEmojis = [
    '👾', '⚡', '👑', '🍕', '🦄', '🛸', '💎', '🔥', '🎸', '🎲',
    '🦊', '🐼', '🚀', '🌟', '🎧', '🔮', '🎨', '👻', '🍭', '🍀',
    '🐯', '🦁', '🦖', '🍿', '🧁', '🍦', '🎈', '🎉', '🍩', '🎮'
  ];

  static const List<String> randomNames = [
    'Neon Ninja', 'Spin Master', 'Daring Devil', 'Truth Seeker', 'Vibe Lord',
    'Disco King', 'Glitch Star', 'Whiskey Wizard', 'Cyber Punk', 'Cosmic Cow',
    'Party Animal', 'Salty McSalt', 'Sassy Queen', 'Joker', 'Golden Spin',
    'Rule Breaker', 'Mystery Guest', 'Wild Card', 'Llama Drama', 'Drama Queen',
    'Meme Lord', 'Couch Potato', 'Speedy', 'Pancake', 'Noodle', 'Pickle',
    'Gummy Bear', 'Pixel Hero', 'Ghost Rider', 'Space Cadet'
  ];

  final Random _random = Random();

  @override
  void onInit() {
    super.onInit();
    _updateControllers();
    ever(playerCount, (_) => _updateControllers());
  }

  void _updateControllers() {
    int current = playerControllers.length;
    if (playerCount.value > current) {
      for (int i = current; i < playerCount.value; i++) {
        String newName = randomNames[_random.nextInt(randomNames.length)];
        int attempts = 0;
        while (playerControllers.any((c) => c.text == newName) && attempts < 15) {
          newName = randomNames[_random.nextInt(randomNames.length)];
          attempts++;
        }
        playerControllers.add(TextEditingController(text: newName));

        // Assign unique emoji & color
        String newEmoji = playerEmojis[i % playerEmojis.length];
        playerEmojisList.add(newEmoji);
        Color newColor = glowColors[i % glowColors.length];
        playerColorsList.add(newColor);
      }
    } else if (playerCount.value < current) {
      for (int i = current - 1; i >= playerCount.value; i--) {
        playerControllers[i].dispose();
        playerControllers.removeAt(i);
        if (i < playerEmojisList.length) {
          playerEmojisList.removeAt(i);
        }
        if (i < playerColorsList.length) {
          playerColorsList.removeAt(i);
        }
      }
    }
  }

  final TextEditingController newPlayerInputController = TextEditingController();

  void addPlayer() {
    addPlayerWithInputName();
  }

  void addPlayerWithInputName([String? customName]) {
    if (playerControllers.length >= 12) {
      Get.snackbar(
        "Limit Reached",
        "Maximum of 12 players allowed.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber,
        colorText: Colors.black,
      );
      return;
    }

    String textToUse = customName ?? newPlayerInputController.text;
    String trimmed = textToUse.trim();
    String finalName = trimmed.isNotEmpty
        ? trimmed
        : randomNames[_random.nextInt(randomNames.length)];

    playerControllers.add(TextEditingController(text: finalName));
    String newEmoji = playerEmojis[playerEmojisList.length % playerEmojis.length];
    playerEmojisList.add(newEmoji);
    Color newColor = glowColors[playerColorsList.length % glowColors.length];
    playerColorsList.add(newColor);
    playerCount.value = playerControllers.length;

    newPlayerInputController.clear();
  }

  void removePlayer() {
    if (playerCount.value > 2) {
      playerCount.value--;
    } else {
      Get.snackbar(
        "Minimum Players",
        "At least 2 players are required to spin the bottle!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber,
        colorText: Colors.black,
      );
    }
  }

  void removePlayerAt(int index) {
    if (playerCount.value > 2 && index >= 0 && index < playerControllers.length) {
      playerControllers[index].dispose();
      playerControllers.removeAt(index);
      if (index < playerEmojisList.length) {
        playerEmojisList.removeAt(index);
      }
      if (index < playerColorsList.length) {
        playerColorsList.removeAt(index);
      }
      playerCount.value = playerControllers.length;
    } else if (playerCount.value <= 2) {
      Get.snackbar(
        "Minimum Players",
        "At least 2 players are required to spin the bottle!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber,
        colorText: Colors.black,
      );
    }
  }

  void randomizeName(int index) {
    if (index >= 0 && index < playerControllers.length) {
      String newName = randomNames[_random.nextInt(randomNames.length)];
      int attempts = 0;
      while (playerControllers.any((c) => c.text == newName) && attempts < 15) {
        newName = randomNames[_random.nextInt(randomNames.length)];
        attempts++;
      }
      playerControllers[index].text = newName;
    }
  }

  void randomizeEmoji(int index) {
    if (index >= 0 && index < playerEmojisList.length) {
      String nextEmoji = playerEmojis[_random.nextInt(playerEmojis.length)];
      playerEmojisList[index] = nextEmoji;
    }
  }

  Future<void> startGame() async {
    isLoading.value = true;
    try {
      final questions = await repository.getQuestions(selectedCategory.value);

      List<PlayerModel> players = List.generate(playerControllers.length, (i) {
        String name = playerControllers[i].text.trim();
        String emoji = i < playerEmojisList.length ? playerEmojisList[i] : '👾';
        Color color = i < playerColorsList.length ? playerColorsList[i] : const Color(0xFFFF007F);
        return PlayerModel(
          name: name.isEmpty ? "Player ${i + 1}" : name,
          emoji: emoji,
          color: color,
        );
      });

      Get.toNamed(
        Routes.GAME,
        arguments: {
          'players': players,
          'questions': questions,
          'music': isMusicOn.value,
          'category': selectedCategory.value,
        },
      );
    } catch (e) {
      Get.snackbar(
        "Network Error",
        "Cannot reach server. Loading offline backup deck...",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      Get.snackbar('Error', 'Could not launch URL');
    }
  }

  @override
  void onClose() {
    newPlayerInputController.dispose();
    for (var controller in playerControllers) {
      controller.dispose();
    }
    super.onClose();
  }
}
