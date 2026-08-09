import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:kaal_spinnex/data/models/question_model.dart';
import 'package:kaal_spinnex/data/providers/question_provider.dart';
import 'package:kaal_spinnex/data/repositories/question_repository.dart';

// Run: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([QuestionProvider])
import 'question_repository_test.mocks.dart';

void main() {
  late MockQuestionProvider mockProvider;
  late QuestionRepository repository;

  setUp(() {
    mockProvider = MockQuestionProvider();
    repository = QuestionRepository(provider: mockProvider);
  });

  group('QuestionRepository.getQuestions', () {
    final sampleQuestions = [
      Question(id: 1, content: 'Q1', type: 'TRUTH', category: 'CLASSIC'),
      Question(id: 2, content: 'Q2', type: 'DARE', category: 'CLASSIC'),
    ];

    test('returns list from provider on success', () async {
      when(mockProvider.fetchQuestions(any))
          .thenAnswer((_) async => sampleQuestions);

      final result = await repository.getQuestions('Classic (Family)');

      expect(result, sampleQuestions);
      verify(mockProvider.fetchQuestions('Classic (Family)')).called(1);
    });

    test('throws Exception when provider throws', () async {
      when(mockProvider.fetchQuestions(any))
          .thenThrow(Exception('Network timeout'));

      expect(
        () => repository.getQuestions('Classic (Family)'),
        throwsA(isA<Exception>()),
      );
    });

    test('wraps provider error in a descriptive message', () async {
      when(mockProvider.fetchQuestions(any))
          .thenThrow(Exception('Connection refused'));

      try {
        await repository.getQuestions('Party (Friends)');
        fail('Expected exception');
      } on Exception catch (e) {
        expect(e.toString(), contains('Failed to connect to backend'));
      }
    });

    test('forwards category string as-is to provider', () async {
      when(mockProvider.fetchQuestions(any))
          .thenAnswer((_) async => []);

      await repository.getQuestions('Spicy (Couples)');

      verify(mockProvider.fetchQuestions('Spicy (Couples)')).called(1);
    });

    test('returns empty list when provider returns empty', () async {
      when(mockProvider.fetchQuestions(any))
          .thenAnswer((_) async => []);

      final result = await repository.getQuestions('Classic (Family)');
      expect(result, isEmpty);
    });
  });
}
