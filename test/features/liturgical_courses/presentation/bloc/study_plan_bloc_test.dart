import 'package:flutter_test/flutter_test.dart';
import 'package:zpasjidoliturgii/features/liturgical_courses/data/models/study_plan_model.dart'; 
void main() {
  group('StudyPlanModel & QuizQuestion Tests', () {
    
    test('Poprawnie parsuje pełne dane z bazy (fromFirestore)', () {
      final Map<String, dynamic> firestoreData = {
        'courseId': 'course_01',
        'dayStage': 2,
        'liturgicalContent': 'Treść liturgiczna',
        'textMaterials': 'https://link.pl',
        'videoLinks': ['https://youtu.be/video1'],
        'quiz': [
          {
            'question': 'Pytanie 1',
            'options': ['Odp A', 'Odp B'],
            'correctAnswerIndex': 0,
            'explanation': 'Wyjaśnienie testowe'
          }
        ],
        'interactiveActivity': {
          'instruction': 'Dopasuj'
        },
        'quote': 'Testowy cytat',
        'quoteAuthor': 'Autor Cytatu',
        'deepReflection': 'Głębsze rozważanie',
      };

      final plan = StudyPlanModel.fromFirestore(firestoreData, 'plan_123');

      expect(plan.id, 'plan_123');
      expect(plan.courseId, 'course_01');
      expect(plan.dayStage, 2);
      expect(plan.liturgicalContent, 'Treść liturgiczna');
      expect(plan.textMaterials, 'https://link.pl');
      expect(plan.videoLinks, ['https://youtu.be/video1']);
      
      expect(plan.quiz.length, 1);
      expect(plan.quiz.first.question, 'Pytanie 1');
      expect(plan.quiz.first.options, ['Odp A', 'Odp B']);
      expect(plan.quiz.first.correctAnswerIndex, 0);
      expect(plan.quiz.first.explanation, 'Wyjaśnienie testowe');

      expect(plan.interactiveActivity, isNotNull);
      expect(plan.interactiveActivity!['instruction'], 'Dopasuj');

      expect(plan.quote, 'Testowy cytat');
      expect(plan.quoteAuthor, 'Autor Cytatu');
      expect(plan.deepReflection, 'Głębsze rozważanie');
    });

    test('Bezpiecznie obsługuje brakujące dane z bazy (Null Safety)', () {
      final Map<String, dynamic> emptyData = {};

      final plan = StudyPlanModel.fromFirestore(emptyData, 'empty_doc');

      expect(plan.id, 'empty_doc');
      expect(plan.courseId, '');
      expect(plan.dayStage, 0);
      expect(plan.liturgicalContent, '');
      expect(plan.textMaterials, '');
      expect(plan.videoLinks, isEmpty);
      expect(plan.quiz, isEmpty);
      expect(plan.interactiveActivity, isNull);
      expect(plan.quote, '');
      expect(plan.quoteAuthor, '');
      expect(plan.deepReflection, '');
    });

    test('Poprawnie konwertuje model na mapę dla Firebase (toFirestore)', () {
      const quizQuestion = QuizQuestion(
        question: 'Pytanie zapisu',
        options: ['Tak', 'Nie'],
        correctAnswerIndex: 0,
        explanation: 'Wyjaśnienie',
      );

      final plan = StudyPlanModel(
        id: 'plan_999',
        courseId: 'c_999',
        dayStage: 5,
        liturgicalContent: 'Treść',
        textMaterials: 'Tekst',
        videoLinks: const ['link'],
        quiz: const [quizQuestion],
        interactiveActivity: const {'typ': 'drag_drop'},
        quote: 'Cytat zapisu',
        quoteAuthor: 'Autor',
        deepReflection: 'Rozważanie',
      );

      final map = plan.toFirestore();

      expect(map['courseId'], 'c_999');
      expect(map['dayStage'], 5);
      expect(map['quiz'], isA<List>());
      expect((map['quiz'] as List).first['question'], 'Pytanie zapisu');
      expect(map['interactiveActivity']['typ'], 'drag_drop');
      expect(map['quote'], 'Cytat zapisu');
      expect(map['quoteAuthor'], 'Autor');
      expect(map['deepReflection'], 'Rozważanie');
      expect(map.containsKey('id'), isFalse);
    });
  });
}