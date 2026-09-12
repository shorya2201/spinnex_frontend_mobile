import 'package:flutter_test/flutter_test.dart';
import 'package:kaal_spinnex/data/models/question_model.dart';
import 'package:kaal_spinnex/data/repositories/question_repository.dart';
import '../mocks/mock_data.dart';

void main() {
  group('QuestionRepository Tests', () {
    late MockQuestionProvider mockProvider;
    late QuestionRepository repository;

    setUp(() {
      mockProvider = MockQuestionProvider();
      repository = QuestionRepository(provider: mockProvider);
    });

    // --- POSITIVE CASES ---
    group('Positive Cases', () {
      test('should fetch and return questions list successfully for requested category', () async {
        final mockList = MockData.mockQuestionsList;
        mockProvider.mockResponseQuestions = mockList;

        final result = await repository.getQuestions('Party');

        expect(mockProvider.lastRequestedCategory, equals('Party'));
        expect(result, isA<List<Question>>());
        expect(result.length, equals(mockList.length));
        expect(result.first.id, equals(mockList.first.id));
        expect(result.first.content, equals(mockList.first.content));
      });

      test('should return correct questions for different categories (Classic, Spicy)', () async {
        mockProvider.mockResponseQuestions = [MockData.truthQuestion1];
        final classicResult = await repository.getQuestions('Classic');
        expect(mockProvider.lastRequestedCategory, equals('Classic'));
        expect(classicResult.length, equals(1));

        mockProvider.mockResponseQuestions = [MockData.dareQuestion1];
        final spicyResult = await repository.getQuestions('Spicy');
        expect(mockProvider.lastRequestedCategory, equals('Spicy'));
        expect(spicyResult.length, equals(1));
      });
    });

    // --- NEGATIVE CASES ---
    group('Negative Cases', () {
      test('should wrap provider failure into Exception with descriptive error message', () async {
        mockProvider.shouldThrowError = true;
        mockProvider.errorMessage = 'Connection timeout';

        expect(
          () => repository.getQuestions('Party'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to connect to backend: Connection timeout'),
            ),
          ),
        );
      });

      test('should handle generic provider error string properly', () async {
        mockProvider.shouldThrowError = true;
        mockProvider.errorMessage = '500 Internal Server Error';

        expect(
          () => repository.getQuestions('Party'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to connect to backend: 500 Internal Server Error'),
            ),
          ),
        );
      });
    });

    // --- EDGE CASES ---
    group('Edge Cases', () {
      test('should handle empty list returned by provider gracefully', () async {
        mockProvider.mockResponseQuestions = [];

        final result = await repository.getQuestions('EmptyCategory');

        expect(result, isEmpty);
        expect(result, isA<List<Question>>());
      });

      test('should correctly forward empty or whitespace category strings to provider', () async {
        mockProvider.mockResponseQuestions = [];

        await repository.getQuestions('   ');
        expect(mockProvider.lastRequestedCategory, equals('   '));

        await repository.getQuestions('');
        expect(mockProvider.lastRequestedCategory, equals(''));
      });
    });
  });
}
