import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:zpasjidoliturgii/features/liturgical_courses/domain/repositories/course_repository.dart';
import 'package:zpasjidoliturgii/features/liturgical_courses/data/models/study_plan_model.dart';
import 'package:zpasjidoliturgii/features/liturgical_courses/presentation/bloc/study_plan_bloc.dart';


class MockCourseRepository extends Mock implements CourseRepository {}

void main() {
  group('StudyPlanBloc Tests', () {
    late MockCourseRepository mockCourseRepository;
    late StudyPlanBloc studyPlanBloc;

    final dummyPlans = [
      const StudyPlanModel(
        id: 'plan_1',
        courseId: 'course_01',
        dayStage: 1,
        liturgicalContent: 'Treść',
        textMaterials: 'Materiały',
        videoLinks: [],
        quiz: [],
        quote: '',
        quoteAuthor: '',
        deepReflection: '',
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

    blocTest<StudyPlanBloc, StudyPlanState>(
      'Emituje [StudyPlanLoading, StudyPlanLoaded] przy pomyślnym pobraniu etapów',
      build: () {
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

    blocTest<StudyPlanBloc, StudyPlanState>(
      'Emituje [StudyPlanLoading, StudyPlanError] gdy wystąpi błąd serwera',
      build: () {
        when(() => mockCourseRepository.getStudyPlansForCourse('course_error'))
            .thenAnswer((_) => Stream.error(Exception('Brak sieci')));
        return studyPlanBloc;
      },
      act: (bloc) => bloc.add(const LoadStudyPlans('course_error')),
      expect: () => [
        StudyPlanLoading(),
        const StudyPlanError('Nie udało się pobrać etapów kursu.'),
      ],
    );
  });
}