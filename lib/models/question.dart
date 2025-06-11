// lib/models/question.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String? difficulty; // Opsional

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.difficulty,
  });

  factory Question.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Question(
      id: doc.id,
      questionText: data['questionText'] as String? ?? '',
      options: List<String>.from(data['options'] as List? ?? []),
      correctAnswer: data['correctAnswer'] as String? ?? '',
      difficulty: data['difficulty'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "questionText": questionText,
      "options": options,
      "correctAnswer": correctAnswer,
      "difficulty": difficulty,
    };
  }
}