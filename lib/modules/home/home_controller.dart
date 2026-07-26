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
  var selectedCategory = 'Party (Friends)'.obs;
  var isMusicOn = true.obs;
  var isLoading = false.obs;

  final List<String> categories = [
    'Classic (Family)',
    'Party (Friends)',
    'Spicy (Couples)'
  ];

  static const List<Color> glowColors = [
    Color(0xFFFF0055), // Hot Crimson
    Color(0xFF8B00FF), // Deep Cyber Violet
    Color(0xFF39FF14), // Electric Neon Lime
    Color(0xFF00FFFF), // Neon Cyan
    Color(0xFFFF4500), // Fiery Chili Orange
    Color(0xFFFFEA00), // Electric Voltage Yellow
    Color(0xFF0070FF), // Royal Cyber Blue
    Color(0xFFFF6B00), // Spicy Tangerine
    Color(0xFF00FF66), // Toxic Acid Mint
    Color(0xFFE60039), // Rich Ruby Red
    Color(0xFFB026FF), // Electric Purple
    Color(0xFF00E5FF), // Bright Aqua Blue
    Color(0xFFFFB700), // Sunset Amber Gold
    Color(0xFFFF00A0), // Neon Electric Magenta
  ];

  static const List<String> playerEmojis = [
    '💃', '💅', '👸', '👑', '🕶️', '💄', '🧜‍♀️', '🪩', '🥳', '🥂',
    '🎀', '👠', '✨', '🌟', '🌙', '🔮', '💎', '🔥', '💖', '🌼',
    '🦊', '🐼', '🦁', '🦙', '🐸', '👾', '🥷', '🌀', '😈', '🤖',
    '🚀', '🎧', '🎸', '🍿', '🍩', '🧁', '🍦', '🍸', '🎆', '🌺',
    '🏆', '🏴‍☠️', '🥔', '🪞', '🧿', '💡', '🧸', '🛡️', '💀', '🍹'
  ];

  static const Map<String, String> nameEmojiMap = {
    // Girl Names & Female Party Titles
    'Vibe Queen': '👑',
    'Neon Goddess': '✨',
    'Cyber Diva': '💅',
    'Sassy Siren': '🧜‍♀️',
    'Party Princess': '👸',
    'Glam Girl': '💄',
    'Dancing Queen': '💃',
    'Boss Babe': '🕶️',
    'Cosmic Babe': '🌌',
    'Starlight Stella': '🌟',
    'Luna Love': '🌙',
    'Bella Spin': '💫',
    'Zoe Zing': '⚡',
    'Aria Star': '⭐',
    'Maya Magic': '🔮',
    'Ruby Spark': '💎',
    'Chloe Glow': '💖',
    'Daisy Dare': '🌼',
    'Sparkle Girl': '❇️',
    'Wild Cat': '🐱',
    'Velvet Vixen': '🦊',
    'Drama Queen': '🎭',
    'Pixie Dust': '🧚‍♀️',
    'Sofia Sun': '☀️',
    'Niya Nova': '🌠',
    'Sassy Queen': '🪞',
    'Fierce Fiona': '🔥',
    'Chai Queen': '☕',
    'Mystic Maya': '🧿',
    'Glow Girl': '💡',

    // Cool & Fun Party Names
    'Neon Ninja': '🥷',
    'Spin Master': '🌀',
    'Daring Devil': '😈',
    'Truth Seeker': '🔍',
    'Vibe Lord': '🎧',
    'Disco King': '🪩',
    'Glitch Star': '👾',
    'Whiskey Wizard': '🧙‍♂️',
    'Cyber Punk': '🤖',
    'Cosmic Cow': '🐮',
    'Party Animal': '🦁',
    'Salty McSalt': '🧂',
    'Joker': '🃏',
    'Golden Spin': '🏆',
    'Rule Breaker': '🏴‍☠️',
    'Mystery Guest': '🕵️',
    'Wild Card': '🎴',
    'Llama Drama': '🦙',
    'Meme Lord': '🐸',
    'Couch Potato': '🥔',
    'Speedy': '🏎️',
    'Pancake': '🥞',
    'Noodle': '🍜',
    'Pickle': '🥒',
    'Gummy Bear': '🧸',
    'Pixel Hero': '🛡️',
    'Ghost Rider': '💀',
    'Space Cadet': '🚀',
  };

  static const List<String> randomNames = [
    // Girl Names & Female Party Titles
    'Vibe Queen', 'Neon Goddess', 'Cyber Diva', 'Sassy Siren', 'Party Princess',
    'Glam Girl', 'Dancing Queen', 'Boss Babe', 'Cosmic Babe', 'Starlight Stella',
    'Luna Love', 'Bella Spin', 'Zoe Zing', 'Aria Star', 'Maya Magic',
    'Ruby Spark', 'Chloe Glow', 'Daisy Dare', 'Sparkle Girl', 'Wild Cat',
    'Velvet Vixen', 'Drama Queen', 'Pixie Dust', 'Sofia Sun', 'Niya Nova',
    'Sassy Queen', 'Fierce Fiona', 'Chai Queen', 'Mystic Maya', 'Glow Girl',

    // Cool & Fun Party Names
    'Neon Ninja', 'Spin Master', 'Daring Devil', 'Truth Seeker', 'Vibe Lord',
    'Disco King', 'Glitch Star', 'Whiskey Wizard', 'Cyber Punk', 'Cosmic Cow',
    'Party Animal', 'Salty McSalt', 'Joker', 'Golden Spin', 'Rule Breaker',
    'Mystery Guest', 'Wild Card', 'Llama Drama', 'Meme Lord', 'Couch Potato',
    'Speedy', 'Pancake', 'Noodle', 'Pickle', 'Gummy Bear', 'Pixel Hero',
    'Ghost Rider', 'Space Cadet'
  ];

  final Random _random = Random();

  /// Gets a unique matching emoji for [name] that is NOT currently used by any player in the lobby.
  String getMatchingEmojiForName(String name, {int? playerIndex}) {
    Set<String> usedEmojis = {};
    for (int i = 0; i < playerEmojisList.length; i++) {
      if (playerIndex == null || i != playerIndex) {
        usedEmojis.add(playerEmojisList[i]);
      }
    }

    if (nameEmojiMap.containsKey(name)) {
      String mappedEmoji = nameEmojiMap[name]!;
      if (!usedEmojis.contains(mappedEmoji)) {
        return mappedEmoji;
      }
    }

    List<String> available = playerEmojis
        .where((e) => !usedEmojis.contains(e))
        .toList();

    if (available.isNotEmpty) {
      return available[_random.nextInt(available.length)];
    }

    return playerEmojis[playerIndex != null ? playerIndex % playerEmojis.length : 0];
  }

  /// Generates a random name guaranteed to be unique among active lobby players.
  String getRandomUniqueName({String? currentName}) {
    Set<String> existingNames = playerControllers
        .map((c) => c.text.trim())
        .where((name) => name.isNotEmpty && name != currentName)
        .toSet();

    List<String> available = randomNames
        .where((name) => !existingNames.contains(name))
        .toList();

    if (available.isNotEmpty) {
      return available[_random.nextInt(available.length)];
    }

    int count = 1;
    while (existingNames.contains("Player $count")) {
      count++;
    }
    return "Player $count";
  }

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
        String newName = getRandomUniqueName();
        playerControllers.add(TextEditingController(text: newName));

        // Assign matching emoji & unique color
        String newEmoji = getMatchingEmojiForName(newName);
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
        : getRandomUniqueName();

    playerControllers.add(TextEditingController(text: finalName));
    String newEmoji = getMatchingEmojiForName(finalName);
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
      String newName = getRandomUniqueName(
        currentName: playerControllers[index].text,
      );
      playerControllers[index].text = newName;
      if (index < playerEmojisList.length) {
        playerEmojisList[index] = getMatchingEmojiForName(newName);
        playerEmojisList.refresh();
      }
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
