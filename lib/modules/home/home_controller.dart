import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/player_model.dart';
import '../../data/models/room_models.dart';
import '../../data/repositories/question_repository.dart';
import '../../routes/app_routes.dart';
import '../../services/stomp_service.dart';
import '../../theme/app_theme.dart';

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

  // ── Online Arena state ──────────────────────────────────────────
  final isOnlineMode = false.obs;
  final roomCode = ''.obs;
  final myPlayerId = ''.obs;
  final isHost = false.obs;
  final isOnlineLoading = false.obs;
  final onlinePlayers = <PlayerModel>[].obs; // players synced from server

  // REST base URL (same host as the existing API service)
  static const String _restBase = 'https://spinnex-backend-dev.onrender.com/api/rooms';

  StompService? get _stomp => Get.isRegistered<StompService>() ? Get.find<StompService>() : null;

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
        var removed = playerControllers.removeAt(i);
        removed.dispose();
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
      if (Get.context != null) {
        Get.snackbar(
          "Limit Reached",
          "Maximum of 12 players allowed.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.amber,
          colorText: Colors.black,
        );
      }
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
      if (Get.context != null) {
        Get.snackbar(
          "Minimum Players",
          "At least 2 players are required to spin the bottle!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.amber,
          colorText: Colors.black,
        );
      }
    }
  }

  void removePlayerAt(int index) {
    if (playerCount.value > 2 && index >= 0 && index < playerControllers.length) {
      var removed = playerControllers.removeAt(index);
      removed.dispose();
      if (index < playerEmojisList.length) {
        playerEmojisList.removeAt(index);
      }
      if (index < playerColorsList.length) {
        playerColorsList.removeAt(index);
      }
      playerCount.value = playerControllers.length;
    } else if (playerCount.value <= 2) {
      if (Get.context != null) {
        Get.snackbar(
          "Minimum Players",
          "At least 2 players are required to spin the bottle!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.amber,
          colorText: Colors.black,
        );
      }
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
    // If online mode and host, publish start game WS frame to notify all room members
    if (isOnlineMode.value && isHost.value && roomCode.value.isNotEmpty) {
      _stomp?.sendStartGame(roomCode: roomCode.value, hostId: myPlayerId.value);
    }

    isLoading.value = true;
    try {
      final questions = await repository.getQuestions(selectedCategory.value);

      // In online mode use server-synced players; otherwise use local lobby.
      final List<PlayerModel> players = isOnlineMode.value && onlinePlayers.isNotEmpty
          ? List<PlayerModel>.from(onlinePlayers)
          : List.generate(playerControllers.length, (i) {
              final name = playerControllers[i].text.trim();
              final emoji = i < playerEmojisList.length ? playerEmojisList[i] : '👾';
              final color = i < playerColorsList.length ? playerColorsList[i] : const Color(0xFFFF007F);
              return PlayerModel(
                name: name.isEmpty ? 'Player ${i + 1}' : name,
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
          // Online session data (ignored by GameController in offline mode)
          'isOnlineMode': isOnlineMode.value,
          'roomCode': roomCode.value,
          'myPlayerId': myPlayerId.value,
          'isHost': isHost.value,
          'pendingApproval': false,
        },
      );
    } catch (e) {
      if (Get.context != null) {
        Get.snackbar(
          "Network Error",
          "Cannot reach server. Loading offline backup deck...",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      Get.snackbar('Error', 'Could not launch URL');
    }
  }

  // ── Online Arena – REST + STOMP operations ──────────────────────

  /// Create a new online room. Connects STOMP and subscribes to the room topic.
  Future<void> createOnlineRoom(String hostName) async {
    if (isOnlineLoading.value) return;
    isOnlineLoading.value = true;

    try {
      final category = GameCategoryX.fromDisplayName(selectedCategory.value).serverValue;
      final hostId = 'usr_${DateTime.now().millisecondsSinceEpoch}';
      const avatar = 'avatar_neon_1';

      // ── REST Create Room ──────────────────────────────────────
      final reqBody = {
        'hostName': hostName,
        'hostAvatar': avatar,
        'hostId': hostId,
        'maxPlayers': 10,
        'category': category,
      };
      print('🌐 [API Request] POST $_restBase/create');
      print('Request Body: ${jsonEncode(reqBody)}');

      final connect = GetConnect(timeout: const Duration(seconds: 30));
      connect.allowAutoSignedCert = true;
      final response = await connect.post('$_restBase/create', reqBody);

      print('📥 [API Response] Status: ${response.statusCode} | POST $_restBase/create');
      print('Response Body: ${response.body}');

      if (response.status.hasError) {
        final errorMsg = response.statusText ?? 'Could not create room. Try again.';
        Get.snackbar('Error', errorMsg, snackPosition: SnackPosition.BOTTOM);
        return;
      }

      Map<String, dynamic> jsonBody;
      if (response.body is String) {
        jsonBody = jsonDecode(response.body as String) as Map<String, dynamic>;
      } else if (response.body is Map) {
        jsonBody = Map<String, dynamic>.from(response.body as Map);
      } else {
        Get.snackbar('Error', 'Invalid response format from server.', snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final data = CreateRoomResponse.fromJson(jsonBody);
      roomCode.value = data.roomCode;
      myPlayerId.value = data.hostId;
      isHost.value = true;
      isOnlineMode.value = true;

      // Populate online players from response
      _syncPlayersFromJson(data.activePlayers);

      // ── STOMP subscriptions ───────────────────────────────────
      _stomp?.connect();
      _stomp?.subscribe('/topic/room/${data.roomCode}', _handleRoomStateUpdate);
      _stomp?.subscribe('/topic/room/${data.roomCode}/host', _handleHostNotification);

      Get.snackbar(
        '🎉 Room Created!',
        'Code: ${data.roomCode}  Share it with your friends!',
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.neonGreen.withOpacity(0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to create room: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isOnlineLoading.value = false;
    }
  }

  /// Join an existing online room by code.
  Future<void> joinOnlineRoom(String guestName, String code) async {
    if (isOnlineLoading.value) return;
    isOnlineLoading.value = true;

    try {
      final playerId = 'usr_${DateTime.now().millisecondsSinceEpoch}';
      const avatar = 'avatar_neon_3';

      final reqBody = {
        'roomCode': code.trim().toUpperCase(),
        'playerName': guestName,
        'playerAvatar': avatar,
        'playerId': playerId,
      };
      print('🌐 [API Request] POST $_restBase/join');
      print('Request Body: ${jsonEncode(reqBody)}');

      final connect = GetConnect(timeout: const Duration(seconds: 30));
      connect.allowAutoSignedCert = true;
      final response = await connect.post('$_restBase/join', reqBody);

      print('📥 [API Response] Status: ${response.statusCode} | POST $_restBase/join');
      print('Response Body: ${response.body}');

      if (response.status.hasError) {
        Get.snackbar('Not Found', 'Room "$code" not found. Check the code and try again.', snackPosition: SnackPosition.BOTTOM);
        return;
      }

      Map<String, dynamic> jsonBody;
      if (response.body is String) {
        jsonBody = jsonDecode(response.body as String) as Map<String, dynamic>;
      } else if (response.body is Map) {
        jsonBody = Map<String, dynamic>.from(response.body as Map);
      } else {
        Get.snackbar('Error', 'Invalid response format from server.', snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final data = JoinRoomResponse.fromJson(jsonBody);

      if (data.joinStatus == 'ROOM_NOT_FOUND') {
        Get.snackbar('Room Not Found', data.message, snackPosition: SnackPosition.BOTTOM);
        return;
      }

      roomCode.value = data.roomCode;
      myPlayerId.value = data.playerId;
      isHost.value = false;
      isOnlineMode.value = true;

      // Connect STOMP
      _stomp?.connect();
      _stomp?.subscribe('/topic/room/${data.roomCode}', _handleRoomStateUpdate);
      _stomp?.subscribe('/topic/user/${data.playerId}/notifications', _handlePrivateNotification);

      if (data.roomState != null) {
        _syncPlayersFromJson(data.roomState!.activePlayers);
      }

      if (data.joinStatus == 'PENDING_APPROVAL') {
        Get.snackbar(
          '⏳ Pending Approval',
          'Your request is sent to the host. Waiting...',
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.neonAmber.withOpacity(0.9),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          '✅ Joined!',
          'Welcome to room ${data.roomCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.neonGreen.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to join room: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isOnlineLoading.value = false;
    }
  }

  /// Share the room code using the native share sheet.
  void shareRoomCode() {
    if (roomCode.value.isEmpty) return;
    Share.share('Join my Spinnex room! Code: ${roomCode.value}');
  }

  /// Leave the current online room and reset state.
  void leaveOnlineRoom() {
    if (roomCode.value.isNotEmpty && myPlayerId.value.isNotEmpty) {
      _stomp?.sendLeave(roomCode: roomCode.value, playerId: myPlayerId.value);
    }
    _stomp?.disconnect();
    isOnlineMode.value = false;
    roomCode.value = '';
    myPlayerId.value = '';
    isHost.value = false;
    onlinePlayers.clear();
  }

  // ── STOMP event handlers ──────────────────────────────────────

  void _handleRoomStateUpdate(Map<String, dynamic> json) {
    try {
      final update = RoomStateUpdate.fromJson(json);
      _syncPlayersFromJson(update.activePlayers);

      // Automatically redirect participants on HomeView to GameView when game is started by host
      final statusStr = json['status'] as String? ?? '';
      final eventTypeStr = json['eventType'] as String? ?? '';
      if (isOnlineMode.value && (statusStr == 'PLAYING' || eventTypeStr == 'GAME_STARTED')) {
        if (Get.currentRoute != Routes.GAME) {
          startGame();
        }
      }
    } catch (e) {
      print('[HomeController] RoomStateUpdate parse error: $e');
    }
  }

  void _handleHostNotification(Map<String, dynamic> json) {
    // Forwarded to GameController via a global event if game is running.
    // Here we just update onlinePlayers from pendingPlayers info if present.
    try {
      final update = RoomStateUpdate.fromJson(json);
      // Update pending players list so GameController can pick it up.
      _syncPlayersFromJson(update.activePlayers);
    } catch (e) {
      print('[HomeController] HostNotification parse error: $e');
    }
  }

  void _handlePrivateNotification(Map<String, dynamic> json) {
    final eventType = json['eventType'] as String? ?? '';
    final message = json['message'] as String? ?? '';
    if (eventType == 'HOST_DECISION') {
      final approved = json['approve'] as bool? ?? false;
      if (approved) {
        Get.snackbar('✅ Approved!', 'The host approved your join request.', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('❌ Rejected', 'The host rejected your join request.', snackPosition: SnackPosition.BOTTOM);
        leaveOnlineRoom();
      }
    } else if (message.isNotEmpty) {
      print('[HomeController] Private notice: $message');
    }
  }

  /// Sync the server player list → [onlinePlayers] reactive list.
  void _syncPlayersFromJson(List<Map<String, dynamic>> serverPlayers) {
    final colors = glowColors;
    final List<PlayerModel> updated = [];
    for (int i = 0; i < serverPlayers.length; i++) {
      final existing = onlinePlayers.firstWhereOrNull((p) => p.playerId == (serverPlayers[i]['playerId'] as String? ?? ''));
      final color = existing?.color ?? colors[i % colors.length];
      final assignedEmoji = existing?.emoji ?? playerEmojis[i % playerEmojis.length];
      updated.add(PlayerModel.fromJson(serverPlayers[i], color: color, emoji: assignedEmoji));
    }
    onlinePlayers.assignAll(updated);
  }

  @override
  void onClose() {
    newPlayerInputController.dispose();
    var list = List<TextEditingController>.from(playerControllers);
    playerControllers.clear();
    for (var controller in list) {
      controller.dispose();
    }
    super.onClose();
  }
}
