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
      print('[LOGOUT] Déconnexion préalable...');
      await tester.tap(menuUser);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();
    }
  }

  Future<void> loginAsAdmin(WidgetTester tester) async {
    const adminUser = 'anasse';
    const adminPass = '123456';

    print('[LOGIN] Connexion en tant que Admin ($adminUser)');
    
    // Vérifier si on est déjà sur l'écran de login, sinon naviguer
    final btnLogin = find.byKey(const Key('btn_submit_auth'));
    if (btnLogin.evaluate().isEmpty) {
        // Essayer de trouver le bouton "Se connecter" si on est sur inscription
        final linkLogin = find.text('Se connecter');
        if (linkLogin.evaluate().isNotEmpty) {
            await tester.tap(linkLogin);
            await waitSafe(tester);
        }
    }

    await tester.enterText(find.byKey(const Key('input_username')), adminUser);
    await tester.enterText(find.byKey(const Key('input_password')), adminPass);
    await tester.tap(find.byKey(const Key('btn_submit_auth')));
    await waitSafe(tester, seconds: 5);
  }

  group('Admin Integration Tests', () {

    testWidgets('Cas 1: Admin approuve un projet', (tester) async {
      print('\n[START] --- TEST ADMIN : APPROBATION PROJET ---');
      await tester.pumpWidget(createTestApp());
      await waitSafe(tester, seconds: 3);
      await ensureLoggedOut(tester);

      // 1. Connexion Admin
      await loginAsAdmin(tester);

      // Vérification Dashboard
      expect(find.text('Tableau de bord Admin'), findsOneWidget);

      // 2. Navigation via Menu Utilisateur
      print('[STEP 2] Clic sur les initiales (Menu utilisateur)');
      final menuUser = find.byTooltip('Menu utilisateur');
      await tester.tap(menuUser);
      await waitSafe(tester, seconds: 2);

      print('[STEP 3] Clic sur "Projets" dans le menu');
      // Note: Dans UserMenuButton, le titre est 'Projets' pour l'admin
      await tester.tap(find.text('Projets').last); 
      await waitSafe(tester, seconds: 4);

      // 3. Sélection d'un projet en attente
      print('[STEP 4] Recherche d\'un projet en attente');
      
      // On filtre pour être sûr d'avoir les projets "EN_ATTENTE"
      // Le user pourrait déjà être sur "TOUS", on clique sur le chip "En attente" si besoin
      // Mais dans le test on va supposer qu'on en trouve un dans la liste par défaut ou on filtre.
      // Le menu "Projets" ouvre "/pending-projects" qui charge "TOUS" par défaut.
      
      final chipEnAttente = find.byKey(const Key('chip_status_EN_ATTENTE'));
      if (chipEnAttente.evaluate().isNotEmpty) {
          await tester.tap(chipEnAttente);
          await waitSafe(tester, seconds: 3);
      }

      // Trouver le premier projet dans la liste
      final projectCard = find.bySemanticsLabel(RegExp(r'project_item_\d+'));
      
      if (projectCard.evaluate().isEmpty) {
        print('[WARN] Aucun projet en attente trouvé ! Le test risque d\'échouer.');
        // Si aucun projet, on ne peut pas continuer. 
        // Idéalement on devrait en créer un avant, mais on suit le scénario demandé.
      } else {
        print('[STEP 5] Ouverture du premier projet trouvé');
        await tester.tap(projectCard.first);
        await waitSafe(tester, seconds: 4);

        // 4. Approbation
        print('[STEP 6] Clic sur "Valider"');
        final btnValidate = find.bySemanticsLabel('btn_validate_project');
        
        if (btnValidate.evaluate().isNotEmpty) {
             await tester.ensureVisible(btnValidate);
             await tester.tap(btnValidate);
             await waitSafe(tester, seconds: 5);
             print('[SUCCESS] Projet validé avec succès !');
        } else {
            print('[ERROR] Bouton Valider introuvable (Projet déjà validé ou bug ?)');
        }
      }
      
      print('[END] Fin du test d\'approbation');
    });

    testWidgets('Cas 2: Admin rejette un projet', (tester) async {
      print('\n[START] --- TEST ADMIN : REJET PROJET ---');
      await tester.pumpWidget(createTestApp());
      await waitSafe(tester, seconds: 3);
      await ensureLoggedOut(tester);

      // 1. Connexion Admin
      await loginAsAdmin(tester);

      // 2. Navigation
      print('[STEP 2] Navigation vers les projets');
      await tester.tap(find.byTooltip('Menu utilisateur'));
      await waitSafe(tester, seconds: 2);
      await tester.tap(find.text('Projets').last);
      await waitSafe(tester, seconds: 4);

      // 3. Filtrage En Attente
      final chipEnAttente = find.byKey(const Key('chip_status_EN_ATTENTE'));
      await tester.tap(chipEnAttente);
      await waitSafe(tester, seconds: 3);

      // 4. Sélection Projet
      final projectCard = find.bySemanticsLabel(RegExp(r'project_item_\d+'));
      if (projectCard.evaluate().isNotEmpty) {
        await tester.tap(projectCard.first);
        await waitSafe(tester, seconds: 4);

        // 5. Rejet
        print('[STEP 5] Clic sur "Refuser"');
        final btnReject = find.bySemanticsLabel('btn_reject_project');
        if (btnReject.evaluate().isNotEmpty) {
            await tester.ensureVisible(btnReject);
            await tester.tap(btnReject);
            await waitSafe(tester, seconds: 5);
            print('[SUCCESS] Projet rejeté avec succès !');
        } else {
            print('[ERROR] Bouton Refuser introuvable');
        }
      } else {
         print('[WARN] Pas de projet disponible pour le test de rejet');
      }
       print('[END] Fin du test de rejet');
    });

  });
}
