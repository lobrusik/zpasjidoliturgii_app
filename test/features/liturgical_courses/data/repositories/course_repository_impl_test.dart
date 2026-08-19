import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:zpasjidoliturgii/features/liturgical_courses/data/repositories/course_repository_impl.dart';
import 'package:zpasjidoliturgii/features/liturgical_courses/data/models/course_model.dart';
import 'package:zpasjidoliturgii/features/liturgical_courses/data/models/study_plan_model.dart';

void main() {
  group('CourseRepositoryImpl Tests z Fake Firestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CourseRepositoryImpl repository;

    // Odpala się przed KAZDYM testem - mamy czystą bazę danych!
    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = CourseRepositoryImpl(firestore: fakeFirestore);
    });

    test('getCourses pobiera kursy i sortuje je po polu "order"', () async {
      // 1. Zapisujemy fałszywe dane do naszej lokalnej bazy testowej
      // Wrzucamy celowo w odwrotnej kolejności, żeby sprawdzić sortowanie (.orderBy)
      await fakeFirestore.collection('courses').doc('course_2').set({
        'title': 'Drugi kurs',
        'order': 2, // Sortowanie 2
        'description': '',
        'imageUrl': '',
        'totalDays': 10,
      });

      await fakeFirestore.collection('courses').doc('course_1').set({
        'title': 'Pierwszy kurs',
        'order': 1, // Sortowanie 1
        'description': '',
        'imageUrl': '',
        'totalDays': 5,
      });

      // 2. Pobieramy strumień z repozytorium
      final stream = repository.getCourses();

      // 3. Sprawdzamy, czy aplikacja sama je posortuje
      // Używamy predicate, aby upewnić się, że na pierwszym miejscu listy jest course_1
      expect(
        stream,
        emits(predicate<List<CourseModel>>((courses) {
          return courses.length == 2 && 
                 courses[0].id == 'course_1' && 
                 courses[1].id == 'course_2';
        })),
      );
    });

    test('getStudyPlansForCourse pobiera plany TYLKO dla wybranego kursu i sortuje po dayStage', () async {
      // 1. Dodajemy mieszane dane do kolekcji 'study_plans'
      await fakeFirestore.collection('study_plans').doc('plan_other').set({
        'courseId': 'inny_kurs', // To nie powinno się pobrać!
        'dayStage': 1,
      });

      await fakeFirestore.collection('study_plans').doc('plan_b').set({
        'courseId': 'moj_kurs',
        'dayStage': 2, // Drugi etap
      });

      await fakeFirestore.collection('study_plans').doc('plan_a').set({
        'courseId': 'moj_kurs',
        'dayStage': 1, // Pierwszy etap
      });

      // 2. Odpytujemy repozytorium TYLKO o 'moj_kurs'
      final stream = repository.getStudyPlansForCourse('moj_kurs');

      // 3. Sprawdzamy wyniki - zignorowany inny kurs + poprawne sortowanie!
      expect(
        stream,
        emits(predicate<List<StudyPlanModel>>((plans) {
          return plans.length == 2 && 
                 plans[0].id == 'plan_a' && 
                 plans[1].id == 'plan_b';
        })),
      );
    });
  });
}