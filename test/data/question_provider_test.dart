import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kaal_spinnex/data/models/question_model.dart';
import 'package:kaal_spinnex/data/providers/question_provider.dart';

/// Testable subclass of QuestionProvider that intercepts `get` calls
/// to return controlled mock responses without touching the network.
class FakeQuestionProvider extends QuestionProvider {
  Response<dynamic>? mockResponse;
  String? capturedPath;
  Map<String, dynamic>? capturedQuery;

  @override
  Future<Response<T>> get<T>(
    String url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
  }) async {
    capturedPath = url;
    capturedQuery = query;

    if (mockResponse != null) {
      return mockResponse as Response<T>;
    }
    return Response<T>(statusCode: 200, body: <dynamic>[] as T);
  }
}

void main() {
  group('QuestionProvider Tests', () {
    late FakeQuestionProvider provider;

    setUp(() {
      provider = FakeQuestionProvider();
      provider.onInit();
    });

    // ── Positive Cases ────────────────────────────────────────────
    group('Positive Cases', () {
      test('onInit should configure proper base settings', () {
        final realProvider = QuestionProvider()..onInit();
        expect(realProvider.baseUrl, equals('https://spinnex-backend-dev.onrender.com/api'));
        expect(realProvider.allowAutoSignedCert, isTrue);
        expect(realProvider.httpClient.timeout, equals(const Duration(seconds: 60)));
      });

      test('fetchQuestions should map "Party (Friends)" to "Party" category query parameter', () async {
        provider.mockResponse = const Response(
          statusCode: 200,
          body: [
            {'id': 1, 'content': 'Party Question 1', 'type': 'TRUTH', 'category': 'Party'}
          ],
        );

        final result = await provider.fetchQuestions('Party (Friends)');

        expect(provider.capturedPath, equals('/questions'));
        expect(provider.capturedQuery?['category'], equals('Party'));
        expect(result.length, equals(1));
        expect(result.first.content, equals('Party Question 1'));
      });

      test('fetchQuestions should map "Spicy (Couples)" to "Spicy" category query parameter', () async {
        provider.mockResponse = const Response(
          statusCode: 200,
          body: [
            {'id': 2, 'content': 'Spicy Question 1', 'type': 'DARE', 'category': 'Spicy'}
          ],
        );

        final result = await provider.fetchQuestions('Spicy (Couples)');

        expect(provider.capturedQuery?['category'], equals('Spicy'));
        expect(result.first.content, equals('Spicy Question 1'));
      });

      test('fetchQuestions should map "Classic (Family)" to "Classic" category query parameter', () async {
        provider.mockResponse = const Response(
          statusCode: 200,
          body: [
            {'id': 3, 'content': 'Classic Question 1', 'type': 'TRUTH', 'category': 'Classic'}
          ],
        );

        final result = await provider.fetchQuestions('Classic (Family)');

        expect(provider.capturedQuery?['category'], equals('Classic'));
        expect(result.first.content, equals('Classic Question 1'));
      });
    });

    // ── Negative Cases ────────────────────────────────────────────
    group('Negative Cases', () {
      test('fetchQuestions should default to "Classic" for unknown category input', () async {
        provider.mockResponse = const Response(
          statusCode: 200,
          body: [],
        );

        await provider.fetchQuestions('Alien Mode 99');

        expect(provider.capturedQuery?['category'], equals('Classic'));
      });

      test('fetchQuestions should throw error message when response hasError is true', () async {
        provider.mockResponse = const Response(
          statusCode: 500,
          statusText: 'Internal Server Error',
        );

        expect(
          () => provider.fetchQuestions('Party (Friends)'),
          throwsA(equals('Internal Server Error')),
        );
      });

      test('fetchQuestions should fallback to default error message when statusText is null', () async {
        provider.mockResponse = const Response(
          statusCode: 404,
          statusText: null,
        );

        expect(
          () => provider.fetchQuestions('Party (Friends)'),
          throwsA(equals('Error fetching questions')),
        );
      });
    });

    // ── Edge Cases ────────────────────────────────────────────────
    group('Edge Cases', () {
      test('fetchQuestions should handle empty body list gracefully', () async {
        provider.mockResponse = const Response(
          statusCode: 200,
          body: [],
        );

        final result = await provider.fetchQuestions('Classic');
        expect(result, isEmpty);
      });

      test('fetchQuestions should parse items with extra fields properly', () async {
        provider.mockResponse = const Response(
          statusCode: 200,
          body: [
            {
              'id': 10,
              'content': 'Valid Question',
              'type': 'TRUTH',
              'category': 'Classic',
              'extraField1': 'ignored',
              'nestedObj': {'a': 1}
            }
          ],
        );

        final result = await provider.fetchQuestions('Classic');
        expect(result.length, equals(1));
        expect(result.first.content, equals('Valid Question'));
      });

      test('fetchQuestions should handle empty string category input defaulting to Classic', () async {
        provider.mockResponse = const Response(
          statusCode: 200,
          body: [],
        );

        await provider.fetchQuestions('');
        expect(provider.capturedQuery?['category'], equals('Classic'));
      });
    });
  });
}
