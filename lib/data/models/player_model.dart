import 'package:flutter/material.dart';

class PlayerModel {
  String name;
  String emoji;
  int score;
  Color color;

  PlayerModel({
    required this.name,
    this.emoji = '👾',
    this.score = 0,
    this.color = const Color(0xFFFF007F),
  });
}

