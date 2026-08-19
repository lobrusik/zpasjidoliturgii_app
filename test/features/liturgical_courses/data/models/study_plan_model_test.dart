import 'package:flutter_test/flutter_test.dart';
import 'package:zpasjidoliturgii/features/liturgical_courses/data/models/study_plan_model.dart'; 

void main() {
  group('StudyPlanModel & QuizQuestion Tests', () {
    
    test('Poprawnie parsuje pełne dane z bazy (fromFirestore)', () {
      // Simulate data retrieved directly from Firebase
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
        }
      };

      // We call the fromFirestore method
      final plan = StudyPlanModel.fromFirestore(firestoreData, 'plan_123');

      // Has all the data been assigned correctly
      expect(plan.id, 'plan_123');
      expect(plan.courseId, 'course_01');
      expect(plan.dayStage, 2);
      expect(plan.liturgicalContent, 'Treść liturgiczna');
      expect(plan.textMaterials, 'https://link.pl');
      expect(plan.videoLinks, ['https://youtu.be/video1']);
      
      // Checking QuizQuestion
      expect(plan.quiz.length, 1);
      expect(plan.quiz.first.question, 'Pytanie 1');
      expect(plan.quiz.first.options, ['Odp A', 'Odp B']);
      expect(plan.quiz.first.correctAnswerIndex, 0);
      expect(plan.quiz.first.explanation, 'Wyjaśnienie testowe');

      // Checkin Drag & Drop
      expect(plan.interactiveActivity, isNotNull);
      expect(plan.interactiveActivity!['instruction'], 'Dopasuj');
    });

    test('Bezpiecznie obsługuje brakujące dane z bazy (Null Safety)', () {
      // simulate a  empty document in Firebase
      final Map<String, dynamic> emptyData = {};

      final plan = StudyPlanModel.fromFirestore(emptyData, 'empty_doc');

      // the model used the default values and didn't throw an error
      expect(plan.id, 'empty_doc');
      expect(plan.courseId, '');
      expect(plan.dayStage, 0);
      expect(plan.liturgicalContent, '');
      expect(plan.textMaterials, '');
      expect(plan.videoLinks, isEmpty);
      expect(plan.quiz, isEmpty);
      expect(plan.interactiveActivity, isNull);
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
      );

      // Convert to a map
      final map = plan.toFirestore();

      // the map have the correct keys for writing to the database
      expect(map['courseId'], 'c_999');
      expect(map['dayStage'], 5);
      expect(map['quiz'], isA<List>());
      expect((map['quiz'] as List).first['question'], 'Pytanie zapisu');
      expect(map['interactiveActivity']['typ'], 'drag_drop');
      expect(map.containsKey('id'), isFalse);
    });
  });
}