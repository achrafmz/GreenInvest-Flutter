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

  Future<void> fillField(WidgetTester tester, String key, String value, String logName) async {
    print('[ACTION] Saisie $logName: $value');
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
    
    // Double clic pour le focus sur Chrome
    await tester.tap(finder);
    await tester.pumpAndSettle();

    await tester.enterText(finder, value);
    await waitSafe(tester, seconds: 2);
  }

  group('INVESTISSEUR - Flux d\'Investissement', () {

    testWidgets('Choisir un projet et investir un montant spécifique', (tester) async {
      print('\n[START] --- TEST INVESTISSEUR : CHOIX & INVESTISSEMENT ---');
      
      await tester.pumpWidget(createTestApp());
      await waitSafe(tester, seconds: 5);
      await ensureLoggedOut(tester);

      final ts = DateTime.now().millisecondsSinceEpoch;
      final user = 'investormaroc_$ts';
      const investmentAmount = '75000';

      // 1. Inscription
      print('[STEP 1] Inscription de l\'investisseur: $user');
      await tester.tap(find.text('S\'inscrire').last);
      await waitSafe(tester);
      await tester.enterText(find.byKey(const Key('input_username')), user);
      await tester.enterText(find.byKey(const Key('input_email')), '$user@test.com');
      await tester.enterText(find.byKey(const Key('input_password')), 'pass123');
      await tester.tap(find.byKey(const Key('dropdown_role')));
      await waitSafe(tester);
      await tester.tap(find.text('Investisseur').last);
      await waitSafe(tester);
      await tester.tap(find.byKey(const Key('btn_submit_auth')));
      await waitSafe(tester, seconds: 6);

      // 2. Connexion
      print('[STEP 2] Connexion...');
      await tester.enterText(find.byKey(const Key('input_username')), user);
      await tester.enterText(find.byKey(const Key('input_password')), 'pass123');
      await tester.tap(find.byKey(const Key('btn_submit_auth')));
      await waitSafe(tester, seconds: 8);

      // 3. Recharge du solde (Pour être sûr de pouvoir investir 75000)
      print('[STEP 3] Recharge du solde à 500 000 MAD via le Profil');
      await tester.tap(find.byTooltip('Menu utilisateur'));
      await waitSafe(tester, seconds: 2);
      await tester.tap(find.text('Profil').last);
      await waitSafe(tester, seconds: 4);

      print('[ACTION] Clic sur ÉDITER');
      await tester.tap(find.byKey(const Key('btn_edit_profile')));
      await waitSafe(tester, seconds: 2);

      await fillField(tester, 'input_solde', '500000', 'SOLDE');
      
      print('[ACTION] Clic sur ENREGISTRER');
      await tester.tap(find.byKey(const Key('btn_save_profile')));
      await waitSafe(tester, seconds: 5);

      print('[ACTION] Retour au Dashboard');
      // Utilisation explicite du bouton retour de l'AppBar au lieu de pageBack() pour plus de fiabilité
      final btnBackProfile = find.byIcon(Icons.arrow_back);
      await tester.tap(btnBackProfile);
      await waitSafe(tester, seconds: 4);

      // 4. Choix d'un projet (Priorité à "Projet Maroc")
      print('[STEP 4] Recherche d\'un projet pour investir');
      Finder projectCard = find.text('Projet Maroc');
      
      if (projectCard.evaluate().isEmpty) {
        print('[DEBUG] "Projet Maroc" non trouvé, sélection du premier projet disponible.');
        projectCard = find.byType(Card).first;
      }

      if (projectCard.evaluate().isEmpty) {
        print('[ERROR] Aucun projet disponible pour investir.');
      } else {
        print('[ACTION] Clic sur le projet choisi');
        await tester.scrollUntilVisible(projectCard, 300);
        await tester.tap(projectCard);
        await waitSafe(tester, seconds: 4);

        // 5. Investissement
        print('[STEP 5] Page de détails : Clic sur "Investir maintenant"');
        final btnInvest = find.text('Investir maintenant');
        
        await tester.ensureVisible(btnInvest);
        await tester.tap(btnInvest);
        await waitSafe(tester, seconds: 3);

        print('[ACTION] Saisie du montant d\'investissement: $investmentAmount MAD');
        await fillField(tester, 'input_investment_amount', investmentAmount, 'MONTANT');

        print('[ACTION] Validation finale de l\'investissement');
        final btnConfirm = find.byKey(const Key('btn_confirm_investment'));
        await tester.tap(btnConfirm);
        
        print('[WAIT] Validation Serveur (12s)...');
        await waitSafe(tester, seconds: 12);

        // 6. Vérification Succès
        print('[STEP 6] Vérification du succès de l\'investissement');
        expect(find.textContaining('succès'), findsWidgets);
        
        // 7. Retour aux projets
        print('[STEP 7] Clic sur "Retour aux projets"');
        final btnBack = find.text('Retour aux projets');
        await tester.ensureVisible(btnBack);
        await tester.tap(btnBack);
        await waitSafe(tester, seconds: 4);

        print('[INFO] Test arrêté après le retour aux projets comme demandé.');
      }
    });

  });
}
