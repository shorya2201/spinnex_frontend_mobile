import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaal_spinnex/data/models/player_model.dart';

void main() {
  group('PlayerModel.fromJson', () {
    test('creates model from complete JSON', () {
      final json = {
        'playerId': 'usr_123',
        'name': 'Alice',
        'avatar': 'avatar_neon_2',
        'status': 'ACTIVE',
        'host': true,
        'joinedAt': 1700000000,
      };
      final player = PlayerModel.fromJson(json);

      expect(player.playerId, 'usr_123');
      expect(player.name, 'Alice');
      expect(player.avatar, 'avatar_neon_2');
      expect(player.status, 'ACTIVE');
      expect(player.host, true);
      expect(player.joinedAt, 1700000000);
      expect(player.score, 0);
    });

    test('defaults playerId to empty string when missing', () {
      final json = {'name': 'Bob'};
      final player = PlayerModel.fromJson(json);
      expect(player.playerId, '');
    });

    test('defaults name to "Player" when missing', () {
      final json = <String, dynamic>{};
      final player = PlayerModel.fromJson(json);
      expect(player.name, 'Player');
    });

    test('defaults status to "ACTIVE" when missing', () {
      final json = {'name': 'Carol'};
      final player = PlayerModel.fromJson(json);
      expect(player.status, 'ACTIVE');
    });

    test('defaults host to false when missing', () {
      final json = {'name': 'Dave'};
      final player = PlayerModel.fromJson(json);
      expect(player.host, false);
    });

    test('joinedAt is null when not provided', () {
      final json = {'name': 'Eve'};
      final player = PlayerModel.fromJson(json);
      expect(player.joinedAt, isNull);
    });

    test('applies provided color override', () {
      final json = {'name': 'Frank'};
      final player = PlayerModel.fromJson(json, color: Colors.blue);
      expect(player.color, Colors.blue);
    });

    test('applies provided emoji override', () {
      final json = {'name': 'Grace'};
      final player = PlayerModel.fromJson(json, emoji: '🐼');
      expect(player.emoji, '🐼');
    });
  });

  group('PlayerModel.isActive', () {
    test('returns true for ACTIVE status', () {
      final p = PlayerModel(name: 'Test', status: 'ACTIVE');
      expect(p.isActive, true);
    });

    test('returns false for PENDING status', () {
      final p = PlayerModel(name: 'Test', status: 'PENDING');
      expect(p.isActive, false);
    });

    test('returns false for DENIED status', () {
      final p = PlayerModel(name: 'Test', status: 'DENIED');
      expect(p.isActive, false);
    });

    test('returns false for DISCONNECTED status', () {
      final p = PlayerModel(name: 'Test', status: 'DISCONNECTED');
      expect(p.isActive, false);
    });
  });

  group('PlayerModel.toJson', () {
    test('serializes all fields correctly', () {
      final p = PlayerModel(
        name: 'Hank',
        playerId: 'usr_999',
        avatar: 'avatar_neon_3',
        status: 'ACTIVE',
        host: false,
        joinedAt: 1700001000,
      );
      final json = p.toJson();

      expect(json['playerId'], 'usr_999');
      expect(json['name'], 'Hank');
      expect(json['avatar'], 'avatar_neon_3');
      expect(json['status'], 'ACTIVE');
      expect(json['host'], false);
      expect(json['joinedAt'], 1700001000);
    });

    test('omits joinedAt from JSON when null', () {
      final p = PlayerModel(name: 'Ivy');
      final json = p.toJson();
      expect(json.containsKey('joinedAt'), false);
    });

    test('score is NOT serialized (local-only field)', () {
      final p = PlayerModel(name: 'Jack');
      p.score = 5;
      final json = p.toJson();
      expect(json.containsKey('score'), false);
    });
  });

  group('PlayerModel defaults', () {
    test('default emoji is 👾', () {
      final p = PlayerModel(name: 'Test');
      expect(p.emoji, '👾');
    });

    test('default score is 0', () {
      final p = PlayerModel(name: 'Test');
      expect(p.score, 0);
    });

    test('score can be mutated (mutable field)', () {
      final p = PlayerModel(name: 'Test');
      p.score += 3;
      expect(p.score, 3);
    });
  });
}
