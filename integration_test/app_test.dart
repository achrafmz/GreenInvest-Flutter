import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:green_invest_app/main.dart' as app;
import 'package:green_invest_app/services/auth_service.dart';
import 'package:green_invest_app/services/project_service.dart';
import 'package:green_invest_app/services/investment_service.dart';
import 'package:provider/provider.dart';

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

  Future<void> waitSafe(WidgetTester tester, {int seconds = 2}) async {
    await tester.pump(Duration(seconds: seconds));
    await tester.pumpAndSettle();
  }

  group('Suite Complète d\'Automation GreenInvest', () {

    testWidgets('1. Inscription Investisseur (Succès)', (tester) async {
      print('[STEP 1] Inscription Investisseur');
      await tester.pumpWidget(createTestApp());
      await waitSafe(tester, seconds: 3);
      await ensureLoggedOut(tester);

      await tester.tap(find.text('S\'inscrire').last);
      await waitSafe(tester);
      await tester.tap(find.byKey(const Key('tab_signup')));
      await waitSafe(tester);

      final ts = DateTime.now().millisecondsSinceEpoch;
      await tester.enterText(find.byKey(const Key('input_username')), 'inv_$ts');
      await tester.enterText(find.byKey(const Key('input_email')), 'inv_$ts@test.com');
      await tester.enterText(find.byKey(const Key('input_password')), 'pass123');
      await tester.tap(find.byKey(const Key('btn_submit_auth')));
      
      print('[WAIT] Finalisation Inscription...');
      await waitSafe(tester, seconds: 6);
      expect(find.textContaining('réussie'), findsOneWidget);
    });

    testWidgets('2. Échec Signup Porteur: Nom vide', (tester) async {
      print('[STEP 2] Validation Nom vide');
      await tester.pumpWidget(createTestApp());
      await waitSafe(tester);
      await ensureLoggedOut(tester);

      await tester.tap(find.text('S\'inscrire'));
      await waitSafe(tester);
      await tester.tap(find.byKey(const Key('tab_signup')));
      await waitSafe(tester);

      await tester.tap(find.byKey(const Key('dropdown_role')));
      await waitSafe(tester);
      await tester.tap(find.text('Porteur de projet').last);
      await waitSafe(tester);

      await tester.enterText(find.byKey(const Key('input_email')), 'fail@test.com');
      await tester.enterText(find.byKey(const Key('input_password')), 'pass123');
      await tester.tap(find.byKey(const Key('btn_submit_auth')));
      await waitSafe(tester);
      expect(find.textContaining('requis'), findsOneWidget);
    });

    testWidgets('3. Échec Signup Porteur: MDP vide', (tester) async {
      print('[STEP 3] Validation MDP vide');
      await tester.pumpWidget(createTestApp());
      await waitSafe(tester);
      await ensureLoggedOut(tester);

      await tester.tap(find.text('S\'inscrire'));
      await waitSafe(tester);
      await tester.tap(find.byKey(const Key('tab_signup')));
      await waitSafe(tester);

      await tester.enterText(find.byKey(const Key('input_username')), 'user_fail');
      await tester.tap(find.byKey(const Key('btn_submit_auth')));
      await waitSafe(tester);
      expect(find.textContaining('requis'), findsOneWidget);
    });

    testWidgets('4. Connexion Réussie (Flux complet)', (tester) async {
      print('[STEP 4] Connexion Dynamique');
      await tester.pumpWidget(createTestApp());
      await waitSafe(tester, seconds: 3);
      await ensureLoggedOut(tester);

      final ts = DateTime.now().millisecondsSinceEpoch;
      final user = 'login_$ts';
      final pass = 'pass123';

      await tester.tap(find.text('S\'inscrire'));
      await waitSafe(tester);
      await tester.enterText(find.byKey(const Key('input_username')), user);
      await tester.enterText(find.byKey(const Key('input_email')), '$user@test.com');
      await tester.enterText(find.byKey(const Key('input_password')), pass);
      await tester.tap(find.byKey(const Key('btn_submit_auth')));
      await waitSafe(tester, seconds: 4);

      await ensureLoggedOut(tester);

      await tester.tap(find.text('Se connecter').last);
      await waitSafe(tester);
      await tester.enterText(find.byKey(const Key('input_username')), user);
      await tester.enterText(find.byKey(const Key('input_password')), pass);
      await tester.tap(find.byKey(const Key('btn_submit_auth')));
      await waitSafe(tester, seconds: 6);
      expect(find.textContaining('Bonjour'), findsOneWidget);
    });

    testWidgets('5. Connexion Échouée (Inexistant)', (tester) async {
      print('[STEP 5] Login Fail');
      await tester.pumpWidget(createTestApp());
      await waitSafe(tester);
      await ensureLoggedOut(tester);

      await tester.tap(find.text('Se connecter'));
      await waitSafe(tester);
      await tester.enterText(find.byKey(const Key('input_username')), 'user_ghost_999');
      await tester.enterText(find.byKey(const Key('input_password')), 'bad_pass');
      await tester.tap(find.byKey(const Key('btn_submit_auth')));
      await waitSafe(tester, seconds: 2);
      expect(find.textContaining('Échec'), findsOneWidget);
    });

    testWidgets('6. Création de Projet Nouh (Succès Final)', (tester) async {
      print('[STEP 6] Création de Projet - Succès');
      await tester.pumpWidget(createTestApp());
      await waitSafe(tester, seconds: 5);
      await ensureLoggedOut(tester);

      final ts = DateTime.now().millisecondsSinceEpoch;
      final user = 'nouh_$ts';
      const ptName = 'PROJET DE NOUHA';

      // 1. Inscription + Login Porteur
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
      
      print('[WAIT] Finalisation Inscription...');
      await waitSafe(tester, seconds: 6);

      print('[AUTH] Connexion de $user');
      await tester.enterText(find.byKey(const Key('input_username')), user);
      await tester.enterText(find.byKey(const Key('input_password')), 'pass123');
      await tester.tap(find.byKey(const Key('btn_submit_auth')));
      await waitSafe(tester, seconds: 8);

      // 2. Navigation Dashboard
      print('[NAV] Ouverture Formulaire via le Dashboard');
      final btnNav = find.byKey(const Key('btn_create_project_nav'));
      await tester.tap(btnNav);
      await waitSafe(tester, seconds: 3);

      // 3. Formulaire (MODE ULTRA LENT + FOCUS)
      final scrollFinder = find.byType(SingleChildScrollView);
      print('[FORM] Remplissage détaillé...');
      
      print('[ACTION] Nom: $ptName');
      await tester.scrollUntilVisible(find.byKey(const Key('input_project_name')), 300, scrollable: scrollFinder);
      await tester.tap(find.byKey(const Key('input_project_name')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('input_project_name')), ptName);
      await waitSafe(tester, seconds: 2);
      
      print('[ACTION] Description');
      await tester.scrollUntilVisible(find.byKey(const Key('input_project_desc')), 300, scrollable: scrollFinder);
      await tester.tap(find.byKey(const Key('input_project_desc')));
      await tester.enterText(find.byKey(const Key('input_project_desc')), 'PROJET DE NOUHA - Test Automatique');
      await waitSafe(tester, seconds: 2);

      print('[ACTION] Montant');
      await tester.scrollUntilVisible(find.byKey(const Key('input_project_amount')), 300, scrollable: scrollFinder);
      await tester.tap(find.byKey(const Key('input_project_amount')));
      await tester.enterText(find.byKey(const Key('input_project_amount')), '500000');
      await waitSafe(tester, seconds: 2);

      await tester.scrollUntilVisible(find.byKey(const Key('input_project_duration')), 300, scrollable: scrollFinder);
      await tester.tap(find.byKey(const Key('input_project_duration')));
      await tester.enterText(find.byKey(const Key('input_project_duration')), '24');
      await waitSafe(tester, seconds: 2);

      await tester.scrollUntilVisible(find.byKey(const Key('dropdown_project_type')), 300, scrollable: scrollFinder);
      await tester.tap(find.byKey(const Key('dropdown_project_type')));
      await waitSafe(tester, seconds: 2);
      await tester.tap(find.text('Taux d\'intérêt fixe').last);
      await waitSafe(tester, seconds: 2);

      // 4. Soumission
      print('[SUBMIT] Clic sur Créer...');
      await tester.scrollUntilVisible(find.byKey(const Key('btn_submit_project')), 300, scrollable: scrollFinder);
      FocusManager.instance.primaryFocus?.unfocus();
      await waitSafe(tester);
      await tester.tap(find.byKey(const Key('btn_submit_project')));
      
      print('[WAIT] Validation Serveur (10s)...');
      await waitSafe(tester, seconds: 10);

      expect(find.text(ptName), findsWidgets);
      print('[OK] Projet créé ✅');
    });

    testWidgets('7. Échec Création Projet (Nom absent)', (tester) async {
      print('[STEP 7] Échec Validation');
      await tester.pumpWidget(createTestApp());
      await waitSafe(tester, seconds: 5);
      await ensureLoggedOut(tester);

      final ts = DateTime.now().millisecondsSinceEpoch;
      final user = 'fail_nouh_$ts';

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

      await tester.tap(find.byKey(const Key('btn_create_project_nav')));
      await waitSafe(tester);

      print('[FORM] Remplissage partiel (Sans Nom)');
      final scrollFinder = find.byType(SingleChildScrollView);
      await tester.scrollUntilVisible(find.byKey(const Key('input_project_amount')), 300, scrollable: scrollFinder);
      await tester.enterText(find.byKey(const Key('input_project_amount')), '10000');
      
      await tester.scrollUntilVisible(find.byKey(const Key('btn_submit_project')), 300, scrollable: scrollFinder);
      FocusManager.instance.primaryFocus?.unfocus();
      await waitSafe(tester);
      await tester.tap(find.byKey(const Key('btn_submit_project')));
      
      print('[WAIT] Visualisation de l\'erreur (5s)');
      await tester.pump(const Duration(seconds: 5));
      expect(find.textContaining('requis'), findsWidgets);
      print('[OK] Échec détecté ✅');
    });
  });
}
