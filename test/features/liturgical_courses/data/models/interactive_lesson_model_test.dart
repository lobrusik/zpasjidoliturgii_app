import 'package:flutter_test/flutter_test.dart';
import 'package:zpasjidoliturgii/features/liturgical_courses/data/models/interactive_lesson_model.dart'; 

void main() {
  group('InteractiveLesson & LessonSlide Model Tests', () {
    
    test('Poprawnie parsuje pełny JSON (wszystkie dane obecne)', () {
      final Map<String, dynamic> json = {
        'courseId': 'trunk_liturgy_01',
        'day_stage': 1,
        'title': 'Definicja Liturgii 1',
        'slides': [
          {
            'type': 'intro',
            'title': 'Wprowadzenie',
            'imageUrl': 'assets/images/wstep.png',
            'content': 'Testowy tekst',
            'quote': 'Testowy cytat'
          }
        ]
      };

      final lesson = InteractiveLesson.fromJson(json, 'doc_123');

      expect(lesson.id, 'doc_123');
      expect(lesson.courseId, 'trunk_liturgy_01');
      expect(lesson.dayStage, 1);
      expect(lesson.title, 'Definicja Liturgii 1');
      
      expect(lesson.slides.length, 1);
      final firstSlide = lesson.slides.first;
      expect(firstSlide.type, 'intro');
      expect(firstSlide.title, 'Wprowadzenie');
      expect(firstSlide.imageUrl, 'assets/images/wstep.png');
      expect(firstSlide.content, 'Testowy tekst');
      expect(firstSlide.quote, 'Testowy cytat');
    });

    test('Nie wywala błędu przy brakujących polach (Null Safety)', () {
      final Map<String, dynamic> emptySlide = <String, dynamic>{};
      final Map<String, dynamic> emptyJson = {
        'slides': [emptySlide]
      };

      final lesson = InteractiveLesson.fromJson(emptyJson, 'doc_empty');

      expect(lesson.id, 'doc_empty');
      expect(lesson.courseId, '');
      expect(lesson.dayStage, 0);
      expect(lesson.title, '');
      
      final firstSlide = lesson.slides.first;
      expect(firstSlide.type, 'text');
      expect(firstSlide.title, '');
      expect(firstSlide.content, isNull);
      expect(firstSlide.imageUrl, isNull);
    });
  });
}