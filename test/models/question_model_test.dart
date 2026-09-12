import 'package:flutter_test/flutter_test.dart';
import 'package:kaal_spinnex/data/models/question_model.dart';
import '../mocks/mock_data.dart';

void main() {
  group('Question Model Tests', () {
    // --- POSITIVE CASES ---
    group('Positive Cases', () {
      test('should instantiate directly via constructor', () {
        final question = Question(
          id: 42,
          content: 'What is your guilty pleasure song?',
          type: 'TRUTH',
          category: 'Party',
        );

        expect(question.id, equals(42));
        expect(question.content, equals('What is your guilty pleasure song?'));
        expect(question.type, equals('TRUTH'));
        expect(question.category, equals('Party'));
      });

      test('should construct Question from valid JSON map for TRUTH', () {
        final question = Question.fromJson(MockData.validTruthJson);

        expect(question.id, equals(1));
        expect(question.content, equals('What is your biggest secret?'));
        expect(question.type, equals('TRUTH'));
        expect(question.category, equals('Party'));
      });

      test('should construct Question from valid JSON map for DARE', () {
        final question = Question.fromJson(MockData.validDareJson);

        expect(question.id, equals(2));
        expect(question.content, equals('Do 10 pushups right now!'));
        expect(question.type, equals('DARE'));
        expect(question.category, equals('Party'));
      });

      test('should parse list of raw maps into Question instances', () {
        final questions = MockData.mockQuestionsRawJsonList
            .map((json) => Question.fromJson(json))
            .toList();

        expect(questions.length, equals(3));
        expect(questions[0].id, equals(101));
        expect(questions[0].type, equals('TRUTH'));
        expect(questions[1].id, equals(102));
        expect(questions[1].type, equals('DARE'));
        expect(questions[2].id, equals(103));
        expect(questions[2].category, equals('Party'));
      });
    });

    // --- NEGATIVE & FALLBACK CASES ---
    group('Negative Cases', () {
      test('should use fallback defaults when id or content is null in json', () {
        final partialJson = {
          'type': 'TRUTH',
          'category': 'Party',
        };

        final question = Question.fromJson(partialJson);
        expect(question.id, equals(0));
        expect(question.content, equals(''));
        expect(question.type, equals('TRUTH'));
        expect(question.category, equals('Party'));
      });

      test('should safely fallback to defaults when all fields are null', () {
        final nullJson = <String, dynamic>{
          'id': null,
          'content': null,
          'type': null,
          'category': null,
        };

        final question = Question.fromJson(nullJson);
        expect(question.id, equals(0));
        expect(question.content, equals(''));
        expect(question.type, equals('TRUTH'));
        expect(question.category, equals('CLASSIC'));
      });

      test('should throw TypeError when type is wrong type (e.g. integer instead of string)', () {
        final malformedJson = {
          'id': 1,
          'content': 'Test question',
          'type': 12345, // invalid type
          'category': 'Party',
        };

        expect(() => Question.fromJson(malformedJson), throwsA(isA<TypeError>()));
      });
    });

    // --- EDGE CASES ---
    group('Edge Cases', () {
      test('should safely ignore unexpected extra keys in JSON payload', () {
        final question = Question.fromJson(MockData.jsonWithExtraFields);

        expect(question.id, equals(3));
        expect(question.content, equals('Sing a song loudly'));
        expect(question.type, equals('DARE'));
        expect(question.category, equals('Classic'));
      });

      test('should handle empty strings in content, type, or category', () {
        final emptyFieldsJson = {
          'id': 999,
          'content': '',
          'type': '',
          'category': '',
        };

        final question = Question.fromJson(emptyFieldsJson);
        expect(question.id, equals(999));
        expect(question.content, isEmpty);
        expect(question.type, isEmpty);
        expect(question.category, isEmpty);
      });

      test('should preserve multi-line text, emojis, and quotes in question content', () {
        const complexContent = 'Line 1\nLine 2: "Quoted text" & special € symbols 🎉';
        final complexJson = {
          'id': 777,
          'content': complexContent,
          'type': 'DARE',
          'category': 'Spicy',
        };

        final question = Question.fromJson(complexJson);
        expect(question.content, equals(complexContent));
      });
    });
  });
}
