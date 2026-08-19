import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zpasjidoliturgii/features/liturgical_courses/presentation/widgets/drag_and_drop_quiz.dart';

void main() {
  group('DragAndDropQuiz Widget Tests', () {
    
    // Przykładowe dane do testu
    final testActivityData = {
      'categories': ['Kategoria A', 'Kategoria B'],
      'itemsToMatch': [
        {'text': 'Poprawny element A', 'correctCategory': 'Kategoria A'},
        {'text': 'Poprawny element B', 'correctCategory': 'Kategoria B'},
      ],
    };

    // Funkcja budująca testowy widżet
    Widget buildTestableWidget({required VoidCallback onCompleted}) {
      return MaterialApp(
        // Scaffold jest tu niezbędny, bo nasz widget wyświetla SnackBar (dymek błędu)
        home: Scaffold(
          body: DragAndDropQuiz(
            activityData: testActivityData,
            onCompleted: onCompleted,
          ),
        ),
      );
    }

    testWidgets('Początkowe renderowanie - widać kategorie i elementy', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(onCompleted: () {}));

      // Sprawdzamy, czy widać nazwy kategorii
      expect(find.text('Kategoria A'), findsOneWidget);
      expect(find.text('Kategoria B'), findsOneWidget);

      // Sprawdzamy, czy widać elementy do przeciągnięcia
      expect(find.text('Poprawny element A'), findsOneWidget);
      expect(find.text('Poprawny element B'), findsOneWidget);
      
      // Powinien być też widoczny nagłówek sekcji elementów
      expect(find.text('Elementy do przypisania:'), findsOneWidget);
    });

    testWidgets('Błędne upuszczenie pokazuje czerwony SnackBar z błędem', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(onCompleted: () {}));

      // Znajdujemy środek elementu A oraz środek BŁĘDNEJ kategorii B
      final elementToDrag = tester.getCenter(find.text('Poprawny element A'));
      final wrongTarget = tester.getCenter(find.text('Kategoria B'));

      // Wykonujemy wirtualny gest przeciągnięcia i puszczamy (dragFrom oblicza wektor przesunięcia)
      await tester.dragFrom(elementToDrag, wrongTarget - elementToDrag);
      
      // Wymuszamy aktualizację klatek ekranu, żeby animacja i SnackBar się wyrenderowały
      await tester.pumpAndSettle();

      // Sprawdzamy, czy pokazał się komunikat błędu
      expect(find.text('Pudło! To nie pasuje do tej kategorii. Spróbuj ponownie.'), findsOneWidget);
    });

    testWidgets('Prawidłowe dopasowanie wszystkich elementów wywołuje onCompleted', (WidgetTester tester) async {
      bool isCompleted = false;

      await tester.pumpWidget(buildTestableWidget(onCompleted: () {
        isCompleted = true;
      }));

      // --- KROK 1: Przeciągamy pierwszy element ---
      final elementA = tester.getCenter(find.text('Poprawny element A'));
      final targetA = tester.getCenter(find.text('Kategoria A'));
      
      await tester.dragFrom(elementA, targetA - elementA);
      await tester.pumpAndSettle();

      // Gra nie jest jeszcze skończona
      expect(isCompleted, isFalse);

      // --- KROK 2: Przeciągamy drugi element ---
      // (ponieważ widget losuje kolejność - shuffle() - szukamy go zawsze po tekście)
      final elementB = tester.getCenter(find.text('Poprawny element B'));
      final targetB = tester.getCenter(find.text('Kategoria B'));
      
      await tester.dragFrom(elementB, targetB - elementB);
      await tester.pumpAndSettle();

      // Wszystkie elementy zostały przypisane, nagłówek 'Elementy do przypisania:' powinien zniknąć
      expect(find.text('Elementy do przypisania:'), findsNothing);
      
      // Callback z sukcesem powinien zostać wywołany!
      expect(isCompleted, isTrue);
    });
  });
}