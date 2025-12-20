import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_invest_app/models/user_model.dart';
import 'package:green_invest_app/models/project_model.dart';
import 'package:green_invest_app/models/investment_model.dart';

/// Données de test réutilisables pour les utilisateurs
class MockUserData {
  static Map<String, dynamic> investorJson = {
    'id': '1',
    'username': 'investor1',
    'email': 'investor@test.com',
    'role': 'INVESTISSEUR',
    'keycloakUserId': 'kc-123',
    'dateInscription': '2024-01-01T10:00:00Z',
    'solde': 10000.0,
  };

  static Map<String, dynamic> ownerJson = {
    'id': '2',
    'username': 'owner1',
    'email': 'owner@test.com',
    'role': 'PORTEUR_PROJET',
    'keycloakUserId': 'kc-456',
    'dateInscription': '2024-01-02T10:00:00Z',
  };

  static Map<String, dynamic> adminJson = {
    'id': '3',
    'username': 'admin',
    'email': 'admin@test.com',
    'role': 'ADMIN',
    'keycloakUserId': 'kc-789',
    'dateInscription': '2024-01-03T10:00:00Z',
  };

  static User get investorUser => User.fromJson(investorJson);
  static User get ownerUser => User.fromJson(ownerJson);
  static User get adminUser => User.fromJson(adminJson);
}

/// Données de test réutilisables pour les projets
class MockProjectData {
  static Map<String, dynamic> pendingProjectJson = {
    'id': 'proj-1',
    'nom': 'Projet Solaire',
    'description': 'Installation de panneaux solaires',
    'montantObjectif': 50000.0,
    'montantInvesti': 0.0,
    'porteurId': '2',
    'statut': 'pending',
    'contrepartie': '5% de rendement annuel',
    'pourcentageRendement': 5.0,
    'dureeContrepartie': 36,
    'typeContrepartie': 'financière',
    'dateCreation': '2024-01-15',
    'nombreInvestisseurs': 0,
  };

  static Map<String, dynamic> approvedProjectJson = {
    'id': 'proj-2',
    'title': 'Éolienne Communautaire',
    'description': 'Installation éolienne',
    'targetAmount': 100000.0,
    'currentAmount': 25000.0,
    'ownerId': '2',
    'status': 'approved',
    'contrepartie': '7% de rendement annuel',
    'pourcentage_rendement': 7.0,
    'duree_contrepartie': 48,
    'type_contrepartie': 'financière',
    'date_creation': '2024-01-10',
    'nombre_investisseurs': 5,
    'imageUrl': 'https://example.com/image.jpg',
  };

  static Map<String, dynamic> fundedProjectJson = {
    'id': 'proj-3',
    'name': 'Biomasse Locale',
    'description': 'Centrale biomasse',
    'montant_objectif': 75000.0,
    'montant_investi': 75000.0,
    'porteur_id': '2',
    'statut': 'funded',
    'contrepartie': '6% de rendement annuel',
    'pourcentageRendement': 6.0,
    'dureeContrepartie': 60,
    'typeContrepartie': 'financière',
    'dateCreation': '2024-01-05',
    'nombreInvestisseurs': 15,
  };

  static Project get pendingProject => Project.fromJson(pendingProjectJson);
  static Project get approvedProject => Project.fromJson(approvedProjectJson);
  static Project get fundedProject => Project.fromJson(fundedProjectJson);
}

/// Données de test réutilisables pour les investissements
class MockInvestmentData {
  static Map<String, dynamic> investmentJson = {
    'id': 'inv-1',
    'montant': 5000.0,
    'dateInvestissement': '2024-01-20T14:30:00Z',
    'investisseurId': '1',
    'nomInvestisseur': 'investor1',
    'projetId': 'proj-2',
    'nomProjet': 'Éolienne Communautaire',
    'numeroContrat': 'CNT-2024-001',
  };

  static Investment get investment => Investment.fromJson(investmentJson);
}

/// Helper pour créer des widgets avec MaterialApp pour les tests
Widget createTestableWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

/// Helper pour créer un BuildContext de test
BuildContext? _testContext;

Future<BuildContext> getTestContext(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          _testContext = context;
          return Container();
        },
      ),
    ),
  );
  return _testContext!;
}
