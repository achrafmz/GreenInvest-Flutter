# Flutter Integration Tests - Authentification

Ce répertoire contient les tests d'intégration natifs pour les scénarios d'authentification (**TU-01** à **TU-06**).

## Scénarios Couverts
1. **TU-01** : Inscription Réussie.
2. **TU-02** : Inscription Échouée (Email déjà utilisé).
3. **TU-03** : Inscription Échouée (Champs vides).
4. **TU-04** : Inscription Échouée (Username vide).
5. **TU-05** : Authentification Réussie (**lili / 654321**).
6. **TU-06** : Authentification Échouée (Identifiants invalides).

### Scénarios Porteur de Projet (TP-01 à TP-06)
1. **TP-01** : Création de projet Réussie (tous les champs remplis, sans image).
2. **TP-02** : Création Échouée (Nom manquant).
3. **TP-03** : Création Échouée (Montant négatif).
4. **TP-04** : Création Échouée (Rendement négatif ou > 100%).
5. **TP-05** : Création Échouée (Durée négative).
6. **TP-06** : Création Échouée (Type de contrepartie non choisi).

### Scénarios Administrateur (TA-01 à TA-03)
1. **TA-01** : Connexion Admin & Accès au tableau de bord.
2. **TA-02** : Validation d'un nouveau projet.
3. **TA-03** : Rejet d'un nouveau projet.

### Scénarios Investisseur (TI-01 à TI-03)
1. **TI-01** : Mise à jour du profil et du solde.
2. **TI-02** : Recherche et Investissement dans un projet validé.
3. **TI-03** : Téléchargement du contrat PDF de l'investissement.

## Comment Lancer les Tests

Pour **voir** les tests s'exécuter en direct dans votre navigateur Chrome :

```bash
cd 'c:\Users\pc\Desktop\Projet Flutter\GreenInvest-Flutter'
flutter run -d chrome integration_test/app_test.dart --web-port=8087
```

### Pourquoi utiliser `flutter run` ?
Contrairement à `flutter test`, la commande `flutter run` vous permet de voir l'application s'animer et d'observer les clics automatiques, ce qui facilite le débogage visuel.

## Prérequis
- Flutter SDK installé.
- Le backend Spring Boot doit être lancé sur `localhost:8082`.
- Keycloak doit être lancé sur `localhost:8080`.
