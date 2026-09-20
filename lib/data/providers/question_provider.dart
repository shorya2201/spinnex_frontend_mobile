// lib/app/data/providers/question_provider.dart
import 'package:get/get.dart';
import '../models/question_model.dart';

class QuestionProvider extends GetConnect {
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://spinnex-backend-dev.onrender.com/api',
  );

  @override
  void onInit() {
    // Bypass SSL certificate check (required for self-signed/untrusted issuer certificates on mobile)
    allowAutoSignedCert = true;

    // Set to live Render backend or environment override
    baseUrl = defaultBaseUrl;

    // Increase timeout to 60 seconds to handle cold starts on Render
    httpClient.timeout = const Duration(seconds: 60);

    // Request Logging
    httpClient.addRequestModifier<dynamic>((request) {
      print('🌐 [API Request] ${request.method.toUpperCase()} ${request.url}');
      print('Headers: ${request.headers}');
      return request;
    });

    // Response Logging
    httpClient.addResponseModifier<dynamic>((request, response) {
      print('📥 [API Response] Status: ${response.statusCode} | ${request.method.toUpperCase()} ${request.url}');
      if (response.status.hasError) {
        print('Error details: ${response.statusText}');
      }
      print('Response Body: ${response.body}');
      return response;
    });

    super.onInit();
  }

  Future<List<Question>> fetchQuestions(String category) async {
    String apiCategory = 'Classic';
    if (category.contains('Party')) {
      apiCategory = 'Party';
    } else if (category.contains('Spicy')) {
      apiCategory = 'Spicy';
    } else {
      apiCategory = 'Classic';
    }
    final params = {'category': apiCategory};
    print('🌐 [API Request] GET /questions | Query Params: $params');
    final response = await get('/questions', query: params);

    if (response.status.hasError) {
      return Future.error(response.statusText ?? "Error fetching questions");
    } else {
      List<dynamic> body = response.body;
      return body.map((item) => Question.fromJson(item)).toList();
    }
  }
}
