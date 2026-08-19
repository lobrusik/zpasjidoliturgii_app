import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:zpasjidoliturgii/features/liturgical_courses/domain/repositories/course_repository.dart';
import 'package:zpasjidoliturgii/features/liturgical_courses/data/models/study_plan_model.dart';
import 'package:zpasjidoliturgii/features/liturgical_courses/presentation/bloc/study_plan_bloc.dart';

// 1. Tworzymy sztuczne repozytorium (Mock)
class MockCourseRepository extends Mock implements CourseRepository {}

void main() {
  group('StudyPlanBloc Tests', () {
    late MockCourseRepository mockCourseRepository;
    late StudyPlanBloc studyPlanBloc;

    // Przykładowe dane, które "baza" zwróci w teście
    final dummyPlans = [
      const StudyPlanModel(
        id: 'plan_1',
        courseId: 'course_01',
        dayStage: 1,
        liturgicalContent: 'Treść',
        textMaterials: 'Materiały',
        videoLinks: [],
        quiz: [],
      ),
    ];

    setUp(() {
      mockCourseRepository = MockCourseRepository();
      studyPlanBloc = StudyPlanBloc(courseRepository: mockCourseRepository);
    });

    tearDown(() {
      studyPlanBloc.close();
    });

    test('Stanem początkowym powinien być StudyPlanLoading', () {
      expect(studyPlanBloc.state, equals(StudyPlanLoading()));
    });

    // 2. Test dla pomyślnego pobrania danych z bazy
    blocTest<StudyPlanBloc, StudyPlanState>(
      'Emituje [StudyPlanLoading, StudyPlanLoaded] przy pomyślnym pobraniu etapów',
      build: () {
        // Kiedy BLoC poprosi o plany dla 'course_01', zwracamy strumień z naszymi przykładowymi danymi
        when(() => mockCourseRepository.getStudyPlansForCourse('course_01'))
            .thenAnswer((_) => Stream.value(dummyPlans));
        return studyPlanBloc;
      },
      act: (bloc) => bloc.add(const LoadStudyPlans('course_01')),
      expect: () => [
        StudyPlanLoading(),
        StudyPlanLoaded(dummyPlans),
      ],
    );

    // 3. Test dla błędu połączenia z bazą lub błędu serwera
    blocTest<StudyPlanBloc, StudyPlanState>(
      'Emituje [StudyPlanLoading, StudyPlanError] gdy wystąpi błąd serwera',
      build: () {
        // Symulujemy awarię (np. brak internetu, błąd Firestore)
        when(() => mockCourseRepository.getStudyPlansForCourse('course_error'))
            .thenAnswer((_) => Stream.error(Exception('Brak sieci')));
        return studyPlanBloc;
      },
      act: (bloc) => bloc.add(const LoadStudyPlans('course_error')),
      expect: () => [
        StudyPlanLoading(),
        // Komunikat musi być dokładnie taki, jaki był w BLoCu w on<LoadStudyPlans>
        const StudyPlanError('Nie udało się pobrać etapów kursu.'),
      ],
    );
  });
}