import '../models/question_model.dart';
import '../providers/question_provider.dart';

class QuestionRepository {
  final QuestionProvider provider;
  QuestionRepository({required this.provider});

  Future<List<Question>> getQuestions(String category) async {
    try {
      // The provider.fetchQuestions() method already handles the HTTP status
      // check and returns a clean List<Question>. We just pass it through.
      return await provider.fetchQuestions(category);
    } catch (e) {
      throw Exception("Failed to connect to backend: $e");
    }
  }
}
