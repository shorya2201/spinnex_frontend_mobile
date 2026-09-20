import 'package:flutter_test/flutter_test.dart';
import 'package:kaal_spinnex/data/models/question_model.dart';
import '../mocks/mock_data.dart';

void main() {
  group('Question Model Tests', () {
    // --- POSITIVE CASES ---
    group('Positive Cases', () {
      test('should instantiate directly via constructor with String id', () {
        final question = Question(
          id: '42',
          content: 'What is your guilty pleasure song?',
          type: 'TRUTH',
          category: 'Party',
        );

        expect(question.id, equals('42'));
        expect(question.content, equals('What is your guilty pleasure song?'));
        expect(question.type, equals('TRUTH'));
        expect(question.category, equals('Party'));
      });

      test('parses MongoDB ObjectId String', () {
        final json = {
          'id': '6aaf8834761ea6137cf460f8',
          'content': 'What is your biggest secret?',
          'type': 'TRUTH',
          'category': 'CLASSIC',
        };
        final question = Question.fromJson(json);
        expect(question.id, equals('6aaf8834761ea6137cf460f8'));
        expect(question.content, equals('What is your biggest secret?'));
        expect(question.type, equals('TRUTH'));
        expect(question.category, equals('CLASSIC'));
      });

      test('backward compatibility: parses numeric int in JSON as String', () {
        final question = Question.fromJson(MockData.validTruthJson);

        expect(question.id, equals('1'));
        expect(question.content, equals('What is your biggest secret?'));
        expect(question.type, equals('TRUTH'));
        expect(question.category, equals('Party'));
      });

      test('should construct Question from valid JSON map for DARE', () {
        final question = Question.fromJson(MockData.validDareJson);

        expect(question.id, equals('2'));
        expect(question.content, equals('Do 10 pushups right now!'));
        expect(question.type, equals('DARE'));
        expect(question.category, equals('Party'));
      });

      test('should parse list of raw maps into Question instances', () {
        final questions = MockData.mockQuestionsRawJsonList
            .map((json) => Question.fromJson(json))
            .toList();

        expect(questions.length, equals(3));
        expect(questions[0].id, equals('101'));
        expect(questions[0].type, equals('TRUTH'));
        expect(questions[1].id, equals('102'));
        expect(questions[1].type, equals('DARE'));
        expect(questions[2].id, equals('103'));
        expect(questions[2].category, equals('Party'));
      });

      test('serializes to JSON correctly via toJson', () {
        final question = Question(
          id: '6aaf8834761ea6137cf460f8',
          content: 'Tell a funny story',
          type: 'TRUTH',
          category: 'Party',
        );

        final map = question.toJson();
        expect(map['id'], equals('6aaf8834761ea6137cf460f8'));
        expect(map['content'], equals('Tell a funny story'));
        expect(map['type'], equals('TRUTH'));
        expect(map['category'], equals('Party'));
      });

      test('implements value equality and hashCode based on id', () {
        final q1 = Question(
          id: 'mongo_123',
          content: 'Question A',
          type: 'TRUTH',
          category: 'Party',
        );
        final q2 = Question(
          id: 'mongo_123',
          content: 'Question B',
          type: 'DARE',
          category: 'Spicy',
        );
        final q3 = Question(
          id: 'mongo_456',
          content: 'Question A',
          type: 'TRUTH',
          category: 'Party',
        );

        expect(q1, equals(q2));
        expect(q1.hashCode, equals(q2.hashCode));
        expect(q1, isNot(equals(q3)));
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
        expect(question.id, equals(''));
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
        expect(question.id, equals(''));
        expect(question.content, equals(''));
        expect(question.type, equals('TRUTH'));
        expect(question.category, equals('CLASSIC'));
      });

      test('parses MongoDB native _id field when id is not present', () {
        final mongoJson = {
          '_id': '6aaf8834761ea6137cf460f8',
          'content': 'Native Mongo document',
          'type': 'TRUTH',
          'category': 'Classic',
        };

        final question = Question.fromJson(mongoJson);
        expect(question.id, equals('6aaf8834761ea6137cf460f8'));
        expect(question.content, equals('Native Mongo document'));
      });
    });

    // --- EDGE CASES ---
    group('Edge Cases', () {
      test('should safely ignore unexpected extra keys in JSON payload', () {
        final question = Question.fromJson(MockData.jsonWithExtraFields);

        expect(question.id, equals('3'));
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
        expect(question.id, equals('999'));
        expect(question.content, isEmpty);
        expect(question.type, isEmpty);
        expect(question.category, isEmpty);
      });

      test('should preserve multi-line text, emojis, and quotes in question content', () {
        const complexContent = 'Line 1\nLine 2: "Quoted text" & special € symbols 🎉';
        final complexJson = {
          'id': '777',
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

