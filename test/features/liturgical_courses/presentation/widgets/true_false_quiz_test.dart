import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zpasjidoliturgii/features/liturgical_courses/presentation/widgets/true_false_quiz.dart';

void main() {
  group('TrueFalseQuiz Widget Tests', () {
    
    // Przykładowe dane do testów
    final testQuestions = [
      {'q': 'Liturgia to tylko zbiór przepisów?', 'a': false},
      {'q': 'Chrystus jest głównym celebransem liturgii?', 'a': true},
    ];

    // Funkcja pomocnicza budująca nasz widżet w wirtualnym środowisku testowym
    Widget buildTestableWidget({VoidCallback? onCompleted}) {
      return MaterialApp(
        home: Scaffold(
          body: TrueFalseQuiz(
            questions: testQuestions,
            onCompleted: onCompleted,
          ),
        ),
      );
    }

    testWidgets('Poprawnie renderuje pytania i przyciski', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Sprawdzamy, czy widać teksty pytań
      expect(find.text('Liturgia to tylko zbiór przepisów?'), findsOneWidget);
      expect(find.text('Chrystus jest głównym celebransem liturgii?'), findsOneWidget);

      // Mamy 2 pytania, więc powinno być dokładnie po 2 przyciski Prawda i Fałsz
      expect(find.text('Prawda'), findsNWidgets(2));
      expect(find.text('Fałsz'), findsNWidgets(2));
    });

    testWidgets('Zaznaczenie błędnej odpowiedzi pokazuje błąd i przycisk powtórki', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Klikamy błędną odpowiedź na pierwsze pytanie ("Prawda", a powinno być "Fałsz")
      // Używamy .first, żeby kliknąć przycisk przypisany do pierwszego pytania
      await tester.tap(find.text('Prawda').first);
      
      // Musimy "przepompować" klatkę animacji, żeby UI się zaktualizowało (np. setState)
      await tester.pump();

      // Oczekujemy, że pojawi się komunikat o błędzie i przycisk spróbuj ponownie
      expect(find.text('Pudło! Przemyśl to jeszcze raz.'), findsOneWidget);
      expect(find.text('Spróbuj ponownie'), findsOneWidget);
    });

    testWidgets('Kliknięcie "Spróbuj ponownie" resetuje pytanie', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Klikamy błędnie i aktualizujemy ekran
      await tester.tap(find.text('Prawda').first);
      await tester.pump();

      // Klikamy "Spróbuj ponownie" i aktualizujemy ekran
      await tester.tap(find.text('Spróbuj ponownie'));
      await tester.pump();

      // Błąd i przycisk powtórki powinny zniknąć
      expect(find.text('Pudło! Przemyśl to jeszcze raz.'), findsNothing);
      expect(find.text('Spróbuj ponownie'), findsNothing);
    });

    testWidgets('Poprawne rozwiązanie całego quizu wywołuje onCompleted', (WidgetTester tester) async {
      bool isCompleted = false;

      await tester.pumpWidget(buildTestableWidget(
        onCompleted: () => isCompleted = true,
      ));

      // Rozwiązujemy pierwsze pytanie poprawnie (Fałsz)
      await tester.tap(find.text('Fałsz').first);
      await tester.pump();

      // Pojawia się świetnie, ale isCompleted nadal powinno być false (bo zostało drugie pytanie!)
      expect(find.text('Świetnie!'), findsOneWidget);
      expect(isCompleted, isFalse);

      // Rozwiązujemy drugie pytanie poprawnie (Prawda)
      await tester.tap(find.text('Prawda').last);
      await tester.pump();

      // Teraz isCompleted powinno zmienić się na true
      expect(find.text('Świetnie!'), findsNWidgets(2)); // Obie odpowiedzi świetne
      expect(isCompleted, isTrue);
    });
  });
}