import 'package:flutter_test/flutter_test.dart';
import 'package:kaal_spinnex/data/models/question_model.dart';

void main() {
  group('Question.fromJson', () {
    test('creates question from complete JSON with MongoDB ObjectId string', () {
      final json = {
        'id': '6aaf8834761ea6137cf460f8',
        'content': 'What is your biggest secret?',
        'type': 'TRUTH',
        'category': 'CLASSIC',
      };
      final q = Question.fromJson(json);

      expect(q.id, '6aaf8834761ea6137cf460f8');
      expect(q.content, 'What is your biggest secret?');
      expect(q.type, 'TRUTH');
      expect(q.category, 'CLASSIC');
    });

    test('backward compatibility: converts numeric int to String id', () {
      final json = {
        'id': 42,
        'content': 'What is your biggest secret?',
        'type': 'TRUTH',
        'category': 'CLASSIC',
      };
      final q = Question.fromJson(json);

      expect(q.id, '42');
      expect(q.content, 'What is your biggest secret?');
    });

    test('defaults id to empty string when missing', () {
      final json = {
        'content': 'Do a dare!',
        'type': 'DARE',
        'category': 'PARTY',
      };
      final q = Question.fromJson(json);
      expect(q.id, '');
    });

    test('parses MongoDB native _id field when id is missing', () {
      final json = {
        '_id': '6aaf8834761ea6137cf460f8',
        'content': 'Mongo question',
        'type': 'TRUTH',
        'category': 'CLASSIC',
      };
      final q = Question.fromJson(json);
      expect(q.id, '6aaf8834761ea6137cf460f8');
    });

    test('defaults content to empty string when null', () {
      final json = <String, dynamic>{
        'id': '1',
        'content': null,
        'type': 'TRUTH',
        'category': 'CLASSIC',
      };
      final q = Question.fromJson(json);
      expect(q.content, '');
    });

    test('defaults type to TRUTH when null', () {
      final json = <String, dynamic>{
        'id': '2',
        'content': 'Some question',
        'type': null,
        'category': 'PARTY',
      };
      final q = Question.fromJson(json);
      expect(q.type, 'TRUTH');
    });

    test('defaults category to CLASSIC when null', () {
      final json = <String, dynamic>{
        'id': '3',
        'content': 'Some question',
        'type': 'DARE',
        'category': null,
      };
      final q = Question.fromJson(json);
      expect(q.category, 'CLASSIC');
    });

    test('handles lowercase type value (not normalized)', () {
      // The model stores as-is; consumers use toUpperCase() for comparisons
      final json = {
        'id': '4',
        'content': 'Tell a secret',
        'type': 'truth',
        'category': 'classic',
      };
      final q = Question.fromJson(json);
      expect(q.type, 'truth');
      expect(q.type.toUpperCase(), 'TRUTH'); // consumer behaviour
    });

    test('preserves unknown category string', () {
      final json = {
        'id': '5',
        'content': 'Sing a song',
        'type': 'DARE',
        'category': 'CUSTOM_CATEGORY',
      };
      final q = Question.fromJson(json);
      expect(q.category, 'CUSTOM_CATEGORY');
    });

    test('handles completely empty JSON without throwing', () {
      final json = <String, dynamic>{};
      expect(() => Question.fromJson(json), returnsNormally);
      final q = Question.fromJson(json);
      expect(q.id, '');
      expect(q.content, '');
    });
  });
}
