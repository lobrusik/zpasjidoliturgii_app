import 'package:equatable/equatable.dart';

// The single-question model in a quiz
class QuizQuestion extends Equatable {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  // Creating a query object from data retrieved from Firebase
  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswerIndex: map['correctAnswerIndex']?.toInt() ?? 0,
      explanation: map['explanation'] ?? '',
    );
  }

  // Preparing a query for Firebase
  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
    };
  }

  @override
  List<Object?> get props => [question, options, correctAnswerIndex, explanation];
}


// UPDATED MAIN CLASS: Study Plan Template
class StudyPlanModel extends Equatable {
  final String id;
  final String courseId;
  final int dayStage;
  final String liturgicalContent;
  final String textMaterials;
  final List<String> videoLinks;
  final List<QuizQuestion> quiz;

  const StudyPlanModel({
    required this.id,
    required this.courseId,
    required this.dayStage,
    required this.liturgicalContent,
    required this.textMaterials,
    required this.videoLinks,
    required this.quiz,
  });

  factory StudyPlanModel.fromFirestore(Map<String, dynamic> json, String documentId) {
    var quizList = json['quiz'] as List? ?? [];
    
    List<QuizQuestion> parsedQuiz = quizList.map((q) {
      final safeMap = Map<String, dynamic>.from(q as Map);
      return QuizQuestion.fromMap(safeMap);
    }).toList();

    return StudyPlanModel(
      id: documentId,
      courseId: json['courseId'] ?? '',
      dayStage: json['dayStage'] ?? 0,
      liturgicalContent: json['liturgicalContent'] ?? '',
      textMaterials: json['textMaterials'] ?? '',
      // Safely mapping a dynamic array from Firebase to a List<String>
      videoLinks: List<String>.from(json['videoLinks'] ?? []),
      quiz: parsedQuiz,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'courseId': courseId,
      'dayStage': dayStage,
      'liturgicalContent': liturgicalContent,
      'textMaterials': textMaterials,
      'videoLinks': videoLinks,
      'quiz': quiz.map((q) => q.toMap()).toList(), 
    };
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        dayStage,
        liturgicalContent,
        textMaterials,
        videoLinks,
        quiz,
      ];
}