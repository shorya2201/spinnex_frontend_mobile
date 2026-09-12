import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaal_spinnex/data/models/player_model.dart';
import '../mocks/mock_data.dart';

void main() {
  group('PlayerModel Tests', () {
    // --- POSITIVE CASES ---
    group('Positive Cases', () {
      test('should instantiate with default values when only name is provided', () {
        final player = PlayerModel(name: 'Neon Rider');

        expect(player.name, equals('Neon Rider'));
        expect(player.emoji, equals('👾'));
        expect(player.score, equals(0));
        expect(player.color, equals(const Color(0xFFFF007F)));
      });

      test('should instantiate with all custom values properly', () {
        final player = PlayerModel(
          name: 'Cyber Fox',
          emoji: '🦊',
          score: 15,
          color: const Color(0xFF00FFFF),
        );

        expect(player.name, equals('Cyber Fox'));
        expect(player.emoji, equals('🦊'));
        expect(player.score, equals(15));
        expect(player.color, equals(const Color(0xFF00FFFF)));
      });

      test('should allow mutating score positively and negatively', () {
        final player = MockData.createPlayer(score: 5);

        player.score += 2; // Dare completed
        expect(player.score, equals(7));

        player.score += 1; // Truth completed
        expect(player.score, equals(8));

        player.score -= 1; // Chickened out
        expect(player.score, equals(7));
      });

      test('should allow updating player name, emoji, and color', () {
        final player = MockData.createPlayer();

        player.name = 'New Alias';
        player.emoji = '🔥';
        player.color = const Color(0xFF39FF14);

        expect(player.name, equals('New Alias'));
        expect(player.emoji, equals('🔥'));
        expect(player.color, equals(const Color(0xFF39FF14)));
      });
    });

    // --- NEGATIVE CASES ---
    group('Negative Cases', () {
      test('should handle negative scores accurately without throwing', () {
        final player = PlayerModel(name: 'Unlucky Bob', score: -5);

        expect(player.score, equals(-5));

        player.score -= 3;
        expect(player.score, equals(-8));
      });

      test('should handle score decrements that transition from positive to negative', () {
        final player = PlayerModel(name: 'Faltering Player', score: 1);

        player.score -= 2;
        expect(player.score, equals(-1));
      });
    });

    // --- EDGE CASES ---
    group('Edge Cases', () {
      test('should handle empty string as name', () {
        final player = PlayerModel(name: '');
        expect(player.name, equals(''));
      });

      test('should handle special characters, unicode, and multi-byte emojis in name', () {
        const specialName = '⚡️_P!@y€r_#42 🚀';
        final player = PlayerModel(name: specialName);
        expect(player.name, equals(specialName));
      });

      test('should handle very large positive and negative integer scores', () {
        final highScorer = PlayerModel(name: 'Godlike', score: 999999999);
        final lowScorer = PlayerModel(name: 'MegaChicken', score: -999999999);

        expect(highScorer.score, equals(999999999));
        expect(lowScorer.score, equals(-999999999));
      });

      test('should handle unusual or empty emoji strings', () {
        final emptyEmojiPlayer = PlayerModel(name: 'NoEmoji', emoji: '');
        expect(emptyEmojiPlayer.emoji, equals(''));

        final compositeEmojiPlayer = PlayerModel(name: 'MultiEmoji', emoji: '👨‍👩‍👧‍👦');
        expect(compositeEmojiPlayer.emoji, equals('👨‍👩‍👧‍👦'));
      });
    });

    // --- MULTIPLAYER & SERIALIZATION TESTS ---
    group('Multiplayer & Serialization Cases', () {
      // Positive Cases
      test('fromJson should parse complete JSON payload with multiplayer fields', () {
        final json = {
          'playerId': 'usr_test_101',
          'name': 'CyberNinja',
          'avatar': 'avatar_neon_5',
          'status': 'ACTIVE',
          'host': true,
          'joinedAt': 1700000000,
        };

        final player = PlayerModel.fromJson(json, color: Colors.cyan, emoji: '🥷');

        expect(player.playerId, equals('usr_test_101'));
        expect(player.name, equals('CyberNinja'));
        expect(player.avatar, equals('avatar_neon_5'));
        expect(player.status, equals('ACTIVE'));
        expect(player.host, isTrue);
        expect(player.joinedAt, equals(1700000000));
        expect(player.score, equals(0));
        expect(player.color, equals(Colors.cyan));
        expect(player.emoji, equals('🥷'));
        expect(player.isActive, isTrue);
      });

      test('toJson should serialize all fields including joinedAt when set', () {
        final player = PlayerModel(
          name: 'CyberNinja',
          playerId: 'usr_test_101',
          avatar: 'avatar_neon_5',
          status: 'ACTIVE',
          host: true,
          joinedAt: 1700000000,
        );

        final json = player.toJson();

        expect(json['playerId'], equals('usr_test_101'));
        expect(json['name'], equals('CyberNinja'));
        expect(json['avatar'], equals('avatar_neon_5'));
        expect(json['status'], equals('ACTIVE'));
        expect(json['host'], isTrue);
        expect(json['joinedAt'], equals(1700000000));
      });

      // Negative Cases
      test('toJson should omit joinedAt when joinedAt is null', () {
        final player = PlayerModel(
          name: 'GuestBob',
          playerId: 'usr_guest_2',
        );

        final json = player.toJson();

        expect(json.containsKey('joinedAt'), isFalse);
      });

      test('isActive should return false for non-ACTIVE statuses', () {
        final pending = PlayerModel(name: 'A', status: 'PENDING');
        final denied = PlayerModel(name: 'B', status: 'DENIED');
        final disconnected = PlayerModel(name: 'C', status: 'DISCONNECTED');
        final unknown = PlayerModel(name: 'D', status: 'OTHER_STATUS');

        expect(pending.isActive, isFalse);
        expect(denied.isActive, isFalse);
        expect(disconnected.isActive, isFalse);
        expect(unknown.isActive, isFalse);
      });

      // Edge Cases
      test('fromJson should handle empty map with safe default values', () {
        final player = PlayerModel.fromJson(<String, dynamic>{});

        expect(player.playerId, equals(''));
        expect(player.name, equals('Player'));
        expect(player.avatar, equals('avatar_neon_1'));
        expect(player.status, equals('ACTIVE'));
        expect(player.host, isFalse);
        expect(player.joinedAt, isNull);
        expect(player.score, equals(0));
        expect(player.color, equals(const Color(0xFFFF007F)));
        expect(player.emoji, equals('👾'));
      });

      test('round-trip serialization toJson and fromJson should maintain data integrity', () {
        final original = PlayerModel(
          name: 'Neon Queen',
          playerId: 'usr_orig_99',
          avatar: 'avatar_neon_4',
          status: 'ACTIVE',
          host: true,
          joinedAt: 1712345678,
          color: Colors.purple,
          emoji: '👑',
        );

        final json = original.toJson();
        final restored = PlayerModel.fromJson(json, color: original.color, emoji: original.emoji);

        expect(restored.playerId, equals(original.playerId));
        expect(restored.name, equals(original.name));
        expect(restored.avatar, equals(original.avatar));
        expect(restored.status, equals(original.status));
        expect(restored.host, equals(original.host));
        expect(restored.joinedAt, equals(original.joinedAt));
        expect(restored.color, equals(original.color));
        expect(restored.emoji, equals(original.emoji));
      });
    });
  });
}
