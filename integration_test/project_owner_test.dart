import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:green_invest_app/main.dart' as app;
import 'package:provider/provider.dart';
import 'package:green_invest_app/services/auth_service.dart';
import 'package:green_invest_app/services/project_service.dart';
import 'package:green_invest_app/services/investment_service.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  Widget createTestApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ProjectService()),
        ChangeNotifierProvider(create: (_) => InvestmentService()),
      ],
      child: const app.MyApp(),
    );
  }

  Future<void> waitSafe(WidgetTester tester, {int seconds = 2}) async {
    await tester.pump(Duration(seconds: seconds));
    await tester.pumpAndSettle();
  }

  Future<void> ensureLoggedOut(WidgetTester tester) async {
    await tester.pumpAndSettle();
    final menuUser = find.byTooltip('Menu utilisateur');
    if (menuUser.evaluate().isNotEmpty) {
      await tester.tap(menuUser);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();
    }
  }

  // Fonctions Helper
  Future<void> fillField(WidgetTester tester, String key, String value, String logName) async {
    print('[ACTION] Saisie $logName: $value');
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    
    await tester.tap(finder);
    await tester.pumpAndSettle();
    
    await tester.enterText(finder, value);
    await waitSafe(tester, seconds: 2);
  }

  group('SOLUTION FINALE - Porteur de Projet', () {

    testWidgets('Cas 1: Succès - Projet Maroc avec Refresh', (tester) async {
      print('\n[START] --- TEST 1 : SUCCÈS (Projet Maroc) ---');
      try {
        await tester.pumpWidget(createTestApp());
        await waitSafe(tester, seconds: 5);
        await ensureLoggedOut(tester);

        final ts = DateTime.now().millisecondsSinceEpoch;
        final user = 'nouha_ok_$ts';
        const ptName = 'Projet Maroc';

        // 1. Inscription + Connexion
        print('[STEP 1] Inscription de $user');
        await tester.tap(find.text('S\'inscrire').last);
        await waitSafe(tester);
        await tester.enterText(find.byKey(const Key('input_username')), user);
        await tester.enterText(find.byKey(const Key('input_email')), '$user@test.com');
        await tester.enterText(find.byKey(const Key('input_password')), 'pass123');
        await tester.tap(find.byKey(const Key('dropdown_role')));
        await waitSafe(tester);
        await tester.tap(find.text('Porteur de projet').last);
        await waitSafe(tester);
        await tester.tap(find.byKey(const Key('btn_submit_auth')));
        await waitSafe(tester, seconds: 6);

        print('[STEP 2] Connexion...');
        await tester.enterText(find.byKey(const Key('input_username')), user);
        await tester.enterText(find.byKey(const Key('input_password')), 'pass123');
        await tester.tap(find.byKey(const Key('btn_submit_auth')));
        await waitSafe(tester, seconds: 8);

        // 3. Navigation
        print('[STEP 3] Ouverture Formulaire');
        await tester.tap(find.byKey(const Key('btn_create_project_nav')));
        await waitSafe(tester, seconds: 4);

        // 4. Remplissage Complet
        await fillField(tester, 'input_project_name', ptName, 'NOM');
        await fillField(tester, 'input_project_desc', 'bla bla', 'DESCRIPTION');
        await fillField(tester, 'input_project_amount', '100000', 'MONTANT');
        await fillField(tester, 'input_project_counterpart', 'benifi menteuel', 'CONTREPARTIE');
        await fillField(tester, 'input_project_roi', '10', 'RENDEMENT');
        await fillField(tester, 'input_project_duration', '20', 'DURÉE');

        print('[ACTION] Sélection Type: Actions / Titres');
        final dropFinder = find.byKey(const Key('dropdown_project_type'));
        await tester.ensureVisible(dropFinder);
        await tester.tap(dropFinder);
        await waitSafe(tester, seconds: 3);
        await tester.tap(find.text('Actions / Titres').last);
        await waitSafe(tester, seconds: 2);

        // 5. Soumission
        print('[STEP 5] Clic sur "Créer le projet"');
        await tester.tap(find.byKey(const Key('btn_submit_project')));
        await waitSafe(tester, seconds: 12);

        // 6. ACTUALISATION (Mes projets)
        print('[REFRESH] Simulation d\'actualisation du dashboard via "Mes projets"...');
        await tester.tap(find.byTooltip('Menu utilisateur'));
        await waitSafe(tester, seconds: 2);
        await tester.tap(find.text('Mes projets').last); 
        await waitSafe(tester, seconds: 4);
        // Au cas où le clic sur "Mes projets" a ouvert un nouveau dashboard, on en a un fresh.
        // Sinon pageBack pour revenir sur l'original qui a été mis à jour.
        await tester.pageBack(); 
        await waitSafe(tester, seconds: 5);

        // 7. Vérification et Clic
        print('[STEP 6] Recherche et Clic sur $ptName');
        final projectLine = find.text(ptName);
        expect(projectLine, findsWidgets);
        await tester.tap(projectLine.first);
        await waitSafe(tester, seconds: 5);
        expect(find.text('Description du projet'), findsOneWidget);
        print('[OK] TEST 1 RÉUSSI ✅');
      } catch (e, stack) {
        print('[ERROR-TEST-1] $e');
        print(stack);
        rethrow;
      }
    });

    testWidgets('Cas 2: Échec - Nom de projet absent', (tester) async {
      print('\n[START] --- TEST 2 : ÉCHEC (Nom Absent) ---');
      await tester.pumpWidget(createTestApp());
      await waitSafe(tester, seconds: 5);
      await ensureLoggedOut(tester);

      final ts = DateTime.now().millisecondsSinceEpoch + 500;
      final user = 'nouha_fail_$ts';

      // 1. Inscription + Connexion
      await tester.tap(find.text('S\'inscrire').last);
      await waitSafe(tester);
      await tester.enterText(find.byKey(const Key('input_username')), user);
      await tester.enterText(find.byKey(const Key('input_email')), '$user@test.com');
      await tester.enterText(find.byKey(const Key('input_password')), 'pass123');
      await tester.tap(find.byKey(const Key('dropdown_role')));
      await waitSafe(tester);
      await tester.tap(find.text('Porteur de projet').last);
      await waitSafe(tester);
      await tester.tap(find.byKey(const Key('btn_submit_auth')));
      await waitSafe(tester, seconds: 6);

      await tester.enterText(find.byKey(const Key('input_username')), user);
      await tester.enterText(find.byKey(const Key('input_password')), 'pass123');
      await tester.tap(find.byKey(const Key('btn_submit_auth')));
      await waitSafe(tester, seconds: 8);

      // 2. Navigation
      await tester.tap(find.byKey(const Key('btn_create_project_nav')));
      await waitSafe(tester, seconds: 4);

      // 3. Remplissage SANS LE NOM (Exactement comme Cas 1 mais sans Nom)
      print('[ACTION] Remplissage de tout SAUF LE NOM (Mêmes valeurs que Test 1)');
      await fillField(tester, 'input_project_desc', 'bla bla', 'DESCRIPTION');
      await fillField(tester, 'input_project_amount', '100000', 'MONTANT');
      await fillField(tester, 'input_project_counterpart', 'benifi menteuel', 'CONTREPARTIE');
      await fillField(tester, 'input_project_roi', '10', 'RENDEMENT');
      await fillField(tester, 'input_project_duration', '20', 'DURÉE');

      // 4. Soumission
      print('[STEP 4] Tentative de clic sur Créer...');
      await tester.tap(find.byKey(const Key('btn_submit_project')));
      await waitSafe(tester, seconds: 5);

      // 5. Vérification erreur
      print('[CHECK] Recherche du message d\'erreur "Champ requis"');
      expect(find.textContaining('requis'), findsWidgets);
      print('[OK] TEST 2 RÉUSSI (Validation bloquée) ✅');
    });

  });
}
