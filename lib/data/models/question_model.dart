// lib/app/data/models/question_model.dart

class Question {
  final String id;
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
  // Resilient: handles MongoDB 24-char ObjectId strings, native `_id`, legacy numeric ints, and nulls
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'TRUTH',
      category: json['category'] as String? ?? 'CLASSIC',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'type': type,
    'category': category,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Question && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

