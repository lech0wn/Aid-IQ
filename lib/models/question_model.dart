class Question {
  final String questionText; // The text of the question
  final List<String> options; // List of possible answers
  final int
  correctOptionIndex; // Index of the correct answer in the options list

  Question({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });

  // Convert a Question object to a Map (useful for serialization)
  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }

  // Create a Question object from a Map (useful for deserialization)
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionText: map['questionText'] as String,
      options: List<String>.from(map['options'] as List),
      correctOptionIndex: map['correctOptionIndex'] as int,
    );
  }
}
