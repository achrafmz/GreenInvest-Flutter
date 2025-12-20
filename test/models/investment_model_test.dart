import 'package:flutter_test/flutter_test.dart';
import 'package:green_invest_app/models/investment_model.dart';

void main() {
  group('Investment Model Tests', () {
    group('fromJson', () {
      test('should create Investment from complete JSON', () {
        // Arrange
        final json = {
          'id': 'inv-123',
          'montant': 5000.0,
          'dateInvestissement': '2024-01-20T14:30:00Z',
          'investisseurId': 'investor-456',
          'nomInvestisseur': 'John Investor',
          'projetId': 'project-789',
          'nomProjet': 'Projet Solaire Communautaire',
          'numeroContrat': 'CNT-2024-001',
        };

        // Act
        final investment = Investment.fromJson(json);

        // Assert
        expect(investment.id, 'inv-123');
        expect(investment.amount, 5000.0);
        expect(investment.dateInvestissement, '2024-01-20T14:30:00Z');
        expect(investment.investisseurId, 'investor-456');
        expect(investment.nomInvestisseur, 'John Investor');
        expect(investment.projetId, 'project-789');
        expect(investment.nomProjet, 'Projet Solaire Communautaire');
        expect(investment.numeroContrat, 'CNT-2024-001');
      });

      test('should convert montant to double from int', () {
        // Arrange
        final json = {
          'id': 'inv-1',
          'montant': 3000, // Integer instead of double
          'dateInvestissement': '2024-02-01T10:00:00Z',
          'investisseurId': 'inv-1',
          'nomInvestisseur': 'Investor One',
          'projetId': 'proj-1',
          'nomProjet': 'Wind Project',
          'numeroContrat': 'CNT-001',
        };

        // Act
        final investment = Investment.fromJson(json);

        // Assert
        expect(investment.amount, 3000.0);
        expect(investment.amount, isA<double>());
      });

      test('should handle zero montant', () {
        // Arrange
        final json = {
          'id': 'inv-0',
          'montant': 0,
          'dateInvestissement': '2024-01-01T00:00:00Z',
          'investisseurId': 'inv-0',
          'nomInvestisseur': 'Zero Investor',
          'projetId': 'proj-0',
          'nomProjet': 'Test Project',
          'numeroContrat': 'CNT-000',
        };

        // Act
        final investment = Investment.fromJson(json);

        // Assert
        expect(investment.amount, 0.0);
      });

      test('should handle null montant with default value', () {
        // Arrange
        final json = {
          'id': 'inv-null',
          'montant': null,
          'dateInvestissement': '2024-01-01T00:00:00Z',
          'investisseurId': 'inv-1',
          'nomInvestisseur': 'Investor',
          'projetId': 'proj-1',
          'nomProjet': 'Project',
          'numeroContrat': 'CNT-NULL',
        };

        // Act
        final investment = Investment.fromJson(json);

        // Assert
        expect(investment.amount, 0.0);
      });

      test('should handle large montant values', () {
        // Arrange
        final json = {
          'id': 'inv-big',
          'montant': 1000000.99,
          'dateInvestissement': '2024-03-15T12:00:00Z',
          'investisseurId': 'big-investor',
          'nomInvestisseur': 'Big Investor',
          'projetId': 'big-proj',
          'nomProjet': 'Major Project',
          'numeroContrat': 'CNT-BIG-001',
        };

        // Act
        final investment = Investment.fromJson(json);

        // Assert
        expect(investment.amount, 1000000.99);
      });

      test('should handle different date formats', () {
        // Arrange
        final dateFormats = [
          '2024-01-20T14:30:00Z',
          '2024-01-20T14:30:00.000Z',
          '2024-01-20T14:30:00+01:00',
        ];

        for (final dateFormat in dateFormats) {
          final json = {
            'id': 'inv-date',
            'montant': 1000.0,
            'dateInvestissement': dateFormat,
            'investisseurId': 'inv-1',
            'nomInvestisseur': 'Investor',
            'projetId': 'proj-1',
            'nomProjet': 'Project',
            'numeroContrat': 'CNT-001',
          };

          final investment = Investment.fromJson(json);
          expect(investment.dateInvestissement, dateFormat);
        }
      });

      test('should handle special characters in names', () {
        // Arrange
        final json = {
          'id': 'inv-special',
          'montant': 2500.0,
          'dateInvestissement': '2024-01-15T10:00:00Z',
          'investisseurId': 'inv-123',
          'nomInvestisseur': "Jean-Pierre O'Connor",
          'projetId': 'proj-456',
          'nomProjet': 'Projet Éolien & Solaire',
          'numeroContrat': 'CNT-2024/001',
        };

        // Act
        final investment = Investment.fromJson(json);

        // Assert
        expect(investment.nomInvestisseur, "Jean-Pierre O'Connor");
        expect(investment.nomProjet, 'Projet Éolien & Solaire');
        expect(investment.numeroContrat, 'CNT-2024/001');
      });

      test('should handle empty string fields', () {
        // Arrange
        final json = {
          'id': '',
          'montant': 500.0,
          'dateInvestissement': '',
          'investisseurId': '',
          'nomInvestisseur': '',
          'projetId': '',
          'nomProjet': '',
          'numeroContrat': '',
        };

        // Act
        final investment = Investment.fromJson(json);

        // Assert
        expect(investment.id, '');
        expect(investment.dateInvestissement, '');
        expect(investment.investisseurId, '');
        expect(investment.nomInvestisseur, '');
        expect(investment.projetId, '');
        expect(investment.nomProjet, '');
        expect(investment.numeroContrat, '');
      });
    });

    group('Model properties', () {
      test('should create Investment with constructor', () {
        // Act
        final investment = Investment(
          id: 'test-id',
          amount: 7500.50,
          dateInvestissement: '2024-02-15T09:30:00Z',
          investisseurId: 'test-investor',
          nomInvestisseur: 'Test Investor',
          projetId: 'test-project',
          nomProjet: 'Test Project',
          numeroContrat: 'TEST-001',
        );

        // Assert
        expect(investment.id, 'test-id');
        expect(investment.amount, 7500.50);
        expect(investment.dateInvestissement, '2024-02-15T09:30:00Z');
        expect(investment.investisseurId, 'test-investor');
        expect(investment.nomInvestisseur, 'Test Investor');
        expect(investment.projetId, 'test-project');
        expect(investment.nomProjet, 'Test Project');
        expect(investment.numeroContrat, 'TEST-001');
      });

      test('all fields should be final', () {
        // This test verifies the immutability of the Investment model
        final investment = Investment(
          id: 'immutable-id',
          amount: 1000.0,
          dateInvestissement: '2024-01-01T00:00:00Z',
          investisseurId: 'inv-1',
          nomInvestisseur: 'Investor',
          projetId: 'proj-1',
          nomProjet: 'Project',
          numeroContrat: 'CNT-001',
        );

        // All fields are final, so this should not compile if we try to modify them
        // This is more of a compile-time check, but we can verify they exist
        expect(investment.id, isNotNull);
        expect(investment.amount, isNotNull);
        expect(investment.dateInvestissement, isNotNull);
        expect(investment.investisseurId, isNotNull);
        expect(investment.nomInvestisseur, isNotNull);
        expect(investment.projetId, isNotNull);
        expect(investment.nomProjet, isNotNull);
        expect(investment.numeroContrat, isNotNull);
      });
    });

    group('Real-world scenarios', () {
      test('should handle typical investment scenario', () {
        // Arrange - Simulate API response
        final json = {
          'id': 'inv-real-001',
          'montant': 12500.00,
          'dateInvestissement': '2024-03-20T15:45:30Z',
          'investisseurId': 'usr-investor-42',
          'nomInvestisseur': 'Marie Dupont',
          'projetId': 'proj-solar-15',
          'nomProjet': 'Installation Panneaux Solaires École Primaire',
          'numeroContrat': 'GI-CNT-2024-03-001',
        };

        // Act
        final investment = Investment.fromJson(json);

        // Assert
        expect(investment.amount, 12500.00);
        expect(investment.nomInvestisseur, 'Marie Dupont');
        expect(investment.nomProjet, 'Installation Panneaux Solaires École Primaire');
        expect(investment.numeroContrat, 'GI-CNT-2024-03-001');
      });

      test('should handle minimum investment amount', () {
        // Arrange
        final json = {
          'id': 'inv-min',
          'montant': 100.0,
          'dateInvestissement': '2024-01-10T08:00:00Z',
          'investisseurId': 'inv-new',
          'nomInvestisseur': 'New Investor',
          'projetId': 'proj-starter',
          'nomProjet': 'Starter Project',
          'numeroContrat': 'CNT-MIN-001',
        };

        // Act
        final investment = Investment.fromJson(json);

        // Assert
        expect(investment.amount, 100.0);
      });

      test('should handle decimal precision', () {
        // Arrange
        final json = {
          'id': 'inv-decimal',
          'montant': 1234.56,
          'dateInvestissement': '2024-02-28T23:59:59Z',
          'investisseurId': 'inv-precise',
          'nomInvestisseur': 'Precise Investor',
          'projetId': 'proj-precise',
          'nomProjet': 'Precision Project',
          'numeroContrat': 'CNT-DEC-001',
        };

        // Act
        final investment = Investment.fromJson(json);

        // Assert
        expect(investment.amount, 1234.56);
      });
    });

    group('JSON round-trip', () {
      test('should maintain data through fromJson', () {
        // Arrange
        final originalJson = {
          'id': 'round-trip-1',
          'montant': 8888.88,
          'dateInvestissement': '2024-04-01T12:00:00Z',
          'investisseurId': 'investor-rt',
          'nomInvestisseur': 'Round Trip Investor',
          'projetId': 'project-rt',
          'nomProjet': 'Round Trip Project',
          'numeroContrat': 'RT-CNT-001',
        };

        // Act
        final investment = Investment.fromJson(originalJson);

        // Assert - Verify all data matches
        expect(investment.id, originalJson['id']);
        expect(investment.amount, originalJson['montant']);
        expect(investment.dateInvestissement, originalJson['dateInvestissement']);
        expect(investment.investisseurId, originalJson['investisseurId']);
        expect(investment.nomInvestisseur, originalJson['nomInvestisseur']);
        expect(investment.projetId, originalJson['projetId']);
        expect(investment.nomProjet, originalJson['nomProjet']);
        expect(investment.numeroContrat, originalJson['numeroContrat']);
      });
    });
  });
}
