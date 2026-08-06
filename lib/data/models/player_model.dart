import 'package:flutter/material.dart';

class PlayerModel {
  String name;
  String emoji; // local UI emoji (e.g. '💃')
  int score;
  Color color;

  // ── Online multiplayer fields ──────────────────────────────────
  String playerId; // server-assigned unique ID (e.g. "usr_9981a2")
  String avatar; // server avatar key (e.g. "avatar_neon_1")
  String status; // "ACTIVE" | "PENDING" | "DENIED" | "DISCONNECTED"
  bool host; // true if this player is the room host
  int? joinedAt; // epoch ms from server

  PlayerModel({
    required this.name,
    this.emoji = '👾',
    this.score = 0,
    this.color = const Color(0xFFFF007F),
    this.playerId = '',
    this.avatar = 'avatar_neon_1',
    this.status = 'ACTIVE',
    this.host = false,
    this.joinedAt,
  });

  /// Create a [PlayerModel] from the backend JSON player object.
  factory PlayerModel.fromJson(Map<String, dynamic> json, {Color color = const Color(0xFFFF007F), String emoji = '👾'}) {
    return PlayerModel(
      playerId: json['playerId'] as String? ?? '',
      name: json['name'] as String? ?? 'Player',
      avatar: json['avatar'] as String? ?? 'avatar_neon_1',
      status: json['status'] as String? ?? 'ACTIVE',
      host: json['host'] as bool? ?? false,
      joinedAt: json['joinedAt'] as int?,
      score: 0,
      color: color,
      emoji: emoji,
    );
  }

  /// Serialise to JSON for STOMP payloads.
  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'name': name,
        'avatar': avatar,
        'status': status,
        'host': host,
        if (joinedAt != null) 'joinedAt': joinedAt,
      };

  /// Returns true if the player is actively in the game.
  bool get isActive => status == 'ACTIVE';
}
