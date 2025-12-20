import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_invest_app/widgets/snackbar_helper.dart';

void main() {
  group('showTopSnackBar()', () {
    testWidgets('displays success message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showTopSnackBar(
                    context,
                    'Operation successful!',
                    isError: false,
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      // Action
      await tester.tap(find.text('Show'));
      await tester.pump(); // Commence l'animation
      await tester.pump(const Duration(milliseconds: 400)); // Attend la fin de l'animation d'entrée

      // Vérification
      expect(find.text('Operation successful!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

      // Attendre que TOUS les timers se terminent (durée totale: 3s + animation de sortie)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('displays error message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showTopSnackBar(
                    context,
                    'Error message',
                    isError: true,
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      // Action
      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Vérification
      expect(find.text('Error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Attendre que tous les timers se terminent
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('disappears after duration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showTopSnackBar(
                    context,
                    'Temporary',
                    duration: const Duration(seconds: 1),
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      // Action
      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Snackbar visible
      expect(find.text('Temporary'), findsOneWidget);

      // Attendre la durée complète + animations
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Snackbar disparu
      expect(find.text('Temporary'), findsNothing);
    });

    testWidgets('displays custom icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showTopSnackBar(
                    context,
                    'Custom icon message',
                    icon: Icons.info_outline,
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      // Action
      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Vérification
      expect(find.text('Custom icon message'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      // Attendre que tous les timers se terminent
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('uses custom background color when provided', (tester) async {
      const customColor = Color(0xFF3B82F6);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showTopSnackBar(
                    context,
                    'Custom color',
                    backgroundColor: customColor,
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      // Action
      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Vérification que le message est affiché
      expect(find.text('Custom color'), findsOneWidget);

      // Attendre que tous les timers se terminent
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  });
}