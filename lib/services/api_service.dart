import 'package:get/get.dart';
import '../data/models/question_model.dart';

class QuestionProvider extends GetConnect {
  @override
  void onInit() {
    // 1. UPDATE THIS to your live Render backend
    baseUrl = 'https://spinnex-backend-dev.onrender.com/api';

    // 2. INCREASE THE TIMEOUT (See explanation below)
    httpClient.timeout = const Duration(seconds: 60);

    // Request Logging
    httpClient.addRequestModifier<dynamic>((request) {
      print('--> [GetConnect Request] ${request.method.toUpperCase()} ${request.url}');
      print('Headers: ${request.headers}');
      return request;
    });

    // Response Logging
    httpClient.addResponseModifier<dynamic>((request, response) {
      print('<-- [GetConnect Response] Status: ${response.statusCode} | ${request.method.toUpperCase()} ${request.url}');
      if (response.status.hasError) {
        print('Error details: ${response.statusText}');
      }
      print('Body: ${response.body}');
      return response;
    });

    super.onInit();
  }

  Future<List<Question>> fetchQuestions(String category) async {
    final response = await get('/questions', query: {'category': category});

    if (response.status.hasError) {
      return Future.error(response.statusText ?? "Error fetching questions");
    } else {
      List<dynamic> body = response.body;
      return body.map((item) => Question.fromJson(item)).toList();
    }
  }
}
