import 'package:flutter/material.dart';
import 'package:kaal_spinnex/data/models/player_model.dart';
import 'package:kaal_spinnex/data/models/question_model.dart';
import 'package:kaal_spinnex/data/providers/question_provider.dart';
import 'package:kaal_spinnex/data/repositories/question_repository.dart';

/// Reusable mock data fixtures for Spinnex testing suite
class MockData {
  // --- JSON Data ---
  static const Map<String, dynamic> validTruthJson = {
    'id': 1,
    'content': 'What is your biggest secret?',
    'type': 'TRUTH',
    'category': 'Party',
  };

  static const Map<String, dynamic> validDareJson = {
    'id': 2,
    'content': 'Do 10 pushups right now!',
    'type': 'DARE',
    'category': 'Party',
  };

  static const Map<String, dynamic> jsonWithExtraFields = {
    'id': 3,
    'content': 'Sing a song loudly',
    'type': 'DARE',
    'category': 'Classic',
    'extra_metadata': 'ignored_value',
    'created_at': '2026-01-01T00:00:00Z',
  };

  static const List<Map<String, dynamic>> mockQuestionsRawJsonList = [
    {
      'id': 101,
      'content': 'Have you ever cheated on a test?',
      'type': 'TRUTH',
      'category': 'Classic',
    },
    {
      'id': 102,
      'content': 'Dance without music for 30 seconds',
      'type': 'DARE',
      'category': 'Classic',
    },
    {
      'id': 103,
      'content': 'Call your crush and say hello',
      'type': 'DARE',
      'category': 'Party',
    },
  ];

  // --- Model Objects ---
  static final Question truthQuestion1 = Question(
    id: 1,
    content: 'What is your biggest secret?',
    type: 'TRUTH',
    category: 'Party',
  );

  static final Question truthQuestion2 = Question(
    id: 2,
    content: 'Who was your first crush?',
    type: 'TRUTH',
    category: 'Party',
  );

  static final Question dareQuestion1 = Question(
    id: 3,
    content: 'Do 10 pushups right now!',
    type: 'DARE',
    category: 'Party',
  );

  static final Question dareQuestion2 = Question(
    id: 4,
    content: 'Speak in an accent for the next 2 rounds',
    type: 'DARE',
    category: 'Party',
  );

  static List<Question> get mockQuestionsList => [
        truthQuestion1,
        truthQuestion2,
        dareQuestion1,
        dareQuestion2,
      ];

  static List<Question> get mockTruthOnlyQuestions => [
        truthQuestion1,
        truthQuestion2,
      ];

  static List<Question> get mockDareOnlyQuestions => [
        dareQuestion1,
        dareQuestion2,
      ];

  // --- Players Fixtures ---
  static PlayerModel createPlayer({
    String name = 'Player 1',
    String emoji = '👾',
    int score = 0,
    Color color = const Color(0xFFFF007F),
  }) {
    return PlayerModel(
      name: name,
      emoji: emoji,
      score: score,
      color: color,
    );
  }

  static List<PlayerModel> get standardTwoPlayers => [
        PlayerModel(name: 'Alice', emoji: '👾', score: 3, color: const Color(0xFFFF007F)),
        PlayerModel(name: 'Bob', emoji: '⚡', score: 1, color: const Color(0xFF00FFFF)),
      ];

  static List<PlayerModel> get rankedThreePlayers => [
        PlayerModel(name: 'Alice', emoji: '👾', score: 10, color: const Color(0xFFFF007F)),
        PlayerModel(name: 'Bob', emoji: '⚡', score: 4, color: const Color(0xFF00FFFF)),
        PlayerModel(name: 'Charlie', emoji: '👑', score: -2, color: const Color(0xFF39FF14)),
      ];

  static List<PlayerModel> get tiedPlayers => [
        PlayerModel(name: 'Player 1', score: 5),
        PlayerModel(name: 'Player 2', score: 5),
      ];

  static List<PlayerModel> get zeroAndNegativeScorePlayers => [
        PlayerModel(name: 'Zero Hero', score: 0),
        PlayerModel(name: 'Negative Nancy', score: -3),
      ];

  static List<PlayerModel> generate12Players() {
    return List.generate(
      12,
      (i) => PlayerModel(
        name: 'Player ${i + 1}',
        emoji: '👾',
        score: i,
        color: const Color(0xFFFF007F),
      ),
    );
  }
}

/// Fake QuestionProvider for unit and integration testing without real HTTP calls
class MockQuestionProvider extends QuestionProvider {
  bool shouldThrowError = false;
  String errorMessage = 'Failed to fetch questions from backend';
  List<Question>? mockResponseQuestions;
  Duration? simulatedDelay;
  String? lastRequestedCategory;

  @override
  void onInit() {
    // Override to prevent real HTTP client configuration in tests
  }

  @override
  Future<List<Question>> fetchQuestions(String category) async {
    lastRequestedCategory = category;

    if (simulatedDelay != null) {
      await Future.delayed(simulatedDelay!);
    }

    if (shouldThrowError) {
      return Future.error(errorMessage);
    }

    return mockResponseQuestions ?? MockData.mockQuestionsList;
  }
}

/// Fake QuestionRepository for isolated testing of controllers
class MockQuestionRepository extends QuestionRepository {
  final MockQuestionProvider mockProvider;

  MockQuestionRepository({MockQuestionProvider? provider})
      : mockProvider = provider ?? MockQuestionProvider(),
        super(provider: provider ?? MockQuestionProvider());

  void setQuestions(List<Question> questions) {
    mockProvider.mockResponseQuestions = questions;
    mockProvider.shouldThrowError = false;
  }

  void setError(String error) {
    mockProvider.shouldThrowError = true;
    mockProvider.errorMessage = error;
  }
}
