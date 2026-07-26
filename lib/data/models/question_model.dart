// lib/app/data/models/question_model.dart

class Question {
  final int id;
  final String content;
  final String type; // TRUTH or DARE
  final String category;

  Question({
    required this.id,
    required this.content,
    required this.type,
    required this.category,
  });

  // Factory to convert JSON response to Question object
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      content: json['content'],
      type: json['type'],
      category: json['category'],
    );
  }
}
