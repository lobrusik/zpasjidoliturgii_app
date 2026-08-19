import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:zpasjidoliturgii/features/liturgical_courses/data/repositories/progress_repository.dart';
import 'package:zpasjidoliturgii/features/liturgical_courses/presentation/bloc/progress_bloc.dart'; // Tu podaj ścieżkę do swojego ProgressBloc

// 1. Tworzymy tzw. "Mocka", czyli udawane repozytorium.
// Dzięki temu nie dotykamy prawdziwego Firebase w trakcie testów!
class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  group('ProgressBloc Tests', () {
    late MockProgressRepository mockProgressRepository;
    late ProgressBloc progressBloc;

    // setUp wywołuje się automatycznie PRZED każdym testem.
    // Dzięki temu każdy test ma czysty, zresetowany BLoC.
    setUp(() {
      mockProgressRepository = MockProgressRepository();
      progressBloc = ProgressBloc(progressRepository: mockProgressRepository);
    });

    // tearDown wywołuje się PO każdym teście. Zamykamy BLoC, żeby nie zapychał pamięci.
    tearDown(() {
      progressBloc.close();
    });

    test('Stanem początkowym BLoCa powinien być ProgressLoading', () {
      expect(progressBloc.state, equals(ProgressLoading()));
    });

    // 2. Używamy blocTest z paczki bloc_test do symulacji zdarzeń
    blocTest<ProgressBloc, ProgressState>(
      'Emituje [ProgressLoading, ProgressLoaded] gdy pobieranie postępu się powiedzie',
      // Przygotowujemy sztuczną odpowiedź z repozytorium
      build: () {
        when(() => mockProgressRepository.getCompletedPlansForCourse('course_01'))
            .thenAnswer((_) => Stream.value(['plan_1', 'plan_2']));
        return progressBloc;
      },
      // Odpalamy zdarzenie w BLoCu
      act: (bloc) => bloc.add(const LoadProgress('course_01')),
      // Oczekujemy, że BLoC wyemituje te stany w tej kolejności:
      expect: () => [
        ProgressLoading(),
        const ProgressLoaded(['plan_1', 'plan_2']),
      ],
    );

    blocTest<ProgressBloc, ProgressState>(
      'Emituje [ProgressLoading, ProgressError] gdy wystąpi błąd pobierania bazy',
      build: () {
        when(() => mockProgressRepository.getCompletedPlansForCourse('course_error'))
            .thenAnswer((_) => Stream.error(Exception('Brak sieci')));
        return progressBloc;
      },
      act: (bloc) => bloc.add(const LoadProgress('course_error')),
      expect: () => [
        ProgressLoading(),
        const ProgressError('Nie udało się pobrać postępów.'),
      ],
    );

    blocTest<ProgressBloc, ProgressState>(
      'Wysyła polecenie zapisu do repozytorium po wywołaniu ToggleLessonProgress',
      build: () {
        // Symulujemy, że funkcja zapisu w chmurze wykonała się poprawnie (nie zwracając błędu)
        when(() => mockProgressRepository.toggleLessonCompletion('course_01', 'plan_01', true))
            .thenAnswer((_) async {});
        return progressBloc;
      },
      act: (bloc) => bloc.add(const ToggleLessonProgress(
        courseId: 'course_01', 
        planId: 'plan_01', 
        isCompleted: true,
      )),
      // verify pozwala sprawdzić, czy BLoC faktycznie wywołał funkcję zapisu w Repozytorium
      verify: (_) {
        verify(() => mockProgressRepository.toggleLessonCompletion('course_01', 'plan_01', true)).called(1);
      },
    );
  });
}